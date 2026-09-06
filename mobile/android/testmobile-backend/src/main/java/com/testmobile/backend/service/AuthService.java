package com.testmobile.backend.service;

import com.testmobile.backend.entity.User;
import com.testmobile.backend.repository.UserRepository;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;

import java.security.SecureRandom;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

@Service
public class AuthService {

    private final UserRepository userRepository;
    private final JavaMailSender mailSender;

    private final BCryptPasswordEncoder passwordEncoder =
            new BCryptPasswordEncoder();

    private final SecureRandom secureRandom =
            new SecureRandom();

    /*
     * OTP is stored only in server memory.
     *
     * No database changes required.
     *
     * email -> OTP information
     */
    private final Map<String, OtpData> otpStore =
            new ConcurrentHashMap<>();

    /*
     * OTP valid for 5 minutes.
     */
    private static final long OTP_VALIDITY_MS =
            5 * 60 * 1000L;

    public AuthService(
            UserRepository userRepository,
            JavaMailSender mailSender) {

        this.userRepository = userRepository;
        this.mailSender = mailSender;
    }

    // ==========================================
    // SIGNUP
    // ==========================================

    public AuthResult signup(
            String email,
            String password) {

        if (email == null || email.trim().isEmpty()) {

            return new AuthResult(
                    false,
                    "Email is required"
            );
        }

        if (password == null || password.isEmpty()) {

            return new AuthResult(
                    false,
                    "Password is required"
            );
        }

        email = email.trim().toLowerCase();

        if (!email.contains("@")) {

            return new AuthResult(
                    false,
                    "Please enter a valid email address"
            );
        }

        if (password.length() < 6) {

            return new AuthResult(
                    false,
                    "Password must be at least 6 characters"
            );
        }

        /*
         * Check existing account.
         */
        User existingUser = userRepository
                .findByEmail(email)
                .orElse(null);

        if (existingUser != null) {

            return new AuthResult(
                    false,
                    "An account with this email already exists"
            );
        }

        /*
         * New customers are always USER.
         *
         * Existing ADMIN account is not modified.
         */
        String hashedPassword =
                passwordEncoder.encode(password);

        User newUser = new User(
                email,
                hashedPassword,
                "USER"
        );

        userRepository.save(newUser);

        System.out.println("========================================");
        System.out.println("ACCOUNT CREATED");
        System.out.println("Email: " + email);
        System.out.println("Role: USER");
        System.out.println("========================================");

        /*
         * Generate OTP.
         */
        String otp = generateOtp();

        otpStore.put(
                email,
                new OtpData(
                        otp,
                        System.currentTimeMillis()
                                + OTP_VALIDITY_MS
                )
        );

        System.out.println("========================================");
        System.out.println("OTP GENERATED");
        System.out.println("Email: " + email);
        System.out.println("OTP: " + otp);
        System.out.println("Valid for: 5 minutes");
        System.out.println("========================================");

        /*
         * Send OTP email.
         */
        try {

            sendOtpEmail(email, otp);

            System.out.println("========================================");
            System.out.println("OTP EMAIL SENT SUCCESSFULLY");
            System.out.println("To: " + email);
            System.out.println("========================================");

        } catch (Exception e) {

            /*
             * IMPORTANT:
             * Print complete SMTP error.
             */
            System.err.println("========================================");
            System.err.println("OTP EMAIL SEND FAILED");
            System.err.println("To: " + email);
            System.err.println(
                    "Exception type: "
                            + e.getClass().getName()
            );
            System.err.println(
                    "Exception message: "
                            + e.getMessage()
            );

            e.printStackTrace();

            System.err.println("========================================");

            /*
             * Remove OTP because email was not sent.
             */
            otpStore.remove(email);

            return new AuthResult(
                    false,
                    "Account created, but OTP email could not be sent"
            );
        }

        return new AuthResult(
                true,
                "Account created. OTP sent to your email."
        );
    }

    // ==========================================
    // VERIFY OTP
    // ==========================================

    public AuthResult verifyOtp(
            String email,
            String otp) {

        if (email == null || email.trim().isEmpty()) {

            return new AuthResult(
                    false,
                    "Email is required"
            );
        }

        if (otp == null || otp.trim().isEmpty()) {

            return new AuthResult(
                    false,
                    "OTP is required"
            );
        }

        email = email.trim().toLowerCase();
        otp = otp.trim();

        /*
         * Check that account exists.
         */
        User user = userRepository
                .findByEmail(email)
                .orElse(null);

        if (user == null) {

            return new AuthResult(
                    false,
                    "Account not found"
            );
        }

        /*
         * Get OTP from memory.
         */
        OtpData otpData =
                otpStore.get(email);

        if (otpData == null) {

            return new AuthResult(
                    false,
                    "OTP expired or not found. Please request a new OTP."
            );
        }

        /*
         * Check expiration.
         */
        if (System.currentTimeMillis()
                > otpData.expiryTime) {

            otpStore.remove(email);

            return new AuthResult(
                    false,
                    "OTP expired. Please request a new OTP."
            );
        }

        /*
         * Check OTP.
         */
        if (!otpData.otp.equals(otp)) {

            return new AuthResult(
                    false,
                    "Invalid OTP"
            );
        }

        /*
         * OTP is correct.
         *
         * Remove OTP from memory.
         */
        otpStore.remove(email);

        System.out.println("========================================");
        System.out.println("OTP VERIFIED");
        System.out.println("Email: " + email);
        System.out.println("========================================");

        return new AuthResult(
                true,
                "Email verified successfully"
        );
    }

    // ==========================================
    // RESEND OTP
    // ==========================================

    public AuthResult resendOtp(
            String email) {

        if (email == null || email.trim().isEmpty()) {

            return new AuthResult(
                    false,
                    "Email is required"
            );
        }

        email = email.trim().toLowerCase();

        /*
         * Check account.
         */
        User user = userRepository
                .findByEmail(email)
                .orElse(null);

        if (user == null) {

            return new AuthResult(
                    false,
                    "Account not found"
            );
        }

        /*
         * Generate new OTP.
         */
        String otp = generateOtp();

        otpStore.put(
                email,
                new OtpData(
                        otp,
                        System.currentTimeMillis()
                                + OTP_VALIDITY_MS
                )
        );

        System.out.println("========================================");
        System.out.println("RESEND OTP GENERATED");
        System.out.println("Email: " + email);
        System.out.println("OTP: " + otp);
        System.out.println("========================================");

        try {

            sendOtpEmail(email, otp);

            System.out.println("========================================");
            System.out.println("RESEND OTP EMAIL SENT SUCCESSFULLY");
            System.out.println("To: " + email);
            System.out.println("========================================");

        } catch (Exception e) {

            System.err.println("========================================");
            System.err.println("RESEND OTP EMAIL FAILED");
            System.err.println("To: " + email);
            System.err.println(
                    "Exception type: "
                            + e.getClass().getName()
            );
            System.err.println(
                    "Exception message: "
                            + e.getMessage()
            );

            e.printStackTrace();

            System.err.println("========================================");

            otpStore.remove(email);

            return new AuthResult(
                    false,
                    "Unable to send OTP email"
            );
        }

        return new AuthResult(
                true,
                "New OTP sent to your email"
        );
    }

    // ==========================================
    // GENERATE OTP
    // ==========================================

    private String generateOtp() {

        int number =
                secureRandom.nextInt(900000) + 100000;

        return String.valueOf(number);
    }

    // ==========================================
    // SEND OTP EMAIL
    // ==========================================

    private void sendOtpEmail(
            String email,
            String otp) {

        SimpleMailMessage message =
                new SimpleMailMessage();

        /*
         * Gmail account used to send mail.
         */
        message.setFrom(
                "vemireddy691@gmail.com"
        );

        /*
         * Customer's email address.
         */
        message.setTo(email);

        message.setSubject(
                "TestMobile - Email Verification OTP"
        );

        message.setText(
                "Hello,\n\n"
                        + "Your TestMobile verification OTP is:\n\n"
                        + otp
                        + "\n\n"
                        + "This OTP is valid for 5 minutes.\n\n"
                        + "If you did not create this account, "
                        + "you can ignore this email.\n\n"
                        + "TestMobile"
        );

        mailSender.send(message);
    }

    // ==========================================
    // OTP DATA
    // ==========================================

    private static class OtpData {

        private final String otp;
        private final long expiryTime;

        private OtpData(
                String otp,
                long expiryTime) {

            this.otp = otp;
            this.expiryTime = expiryTime;
        }
    }

    // ==========================================
    // RESULT
    // ==========================================

    public static class AuthResult {

        private final boolean success;
        private final String message;

        public AuthResult(
                boolean success,
                String message) {

            this.success = success;
            this.message = message;
        }

        public boolean isSuccess() {
            return success;
        }

        public String getMessage() {
            return message;
        }
    }
}
