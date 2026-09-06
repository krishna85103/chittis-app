package com.testmobile.backend.controller;

import com.testmobile.backend.service.AuthService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/auth")
@CrossOrigin(origins = "*")
public class AuthController {

    private final AuthService authService;

    public AuthController(AuthService authService) {
        this.authService = authService;
    }

    // ==========================================
    // SIGNUP
    // ==========================================

    @PostMapping("/signup")
    public ResponseEntity<AuthResponse> signup(
            @RequestBody SignupRequest request) {

        AuthService.AuthResult result =
                authService.signup(
                        request.email,
                        request.password
                );

        return ResponseEntity.ok(
                new AuthResponse(
                        result.isSuccess(),
                        result.getMessage()
                )
        );
    }

    // ==========================================
    // VERIFY OTP
    // ==========================================

    @PostMapping("/verify-otp")
    public ResponseEntity<AuthResponse> verifyOtp(
            @RequestBody VerifyOtpRequest request) {

        AuthService.AuthResult result =
                authService.verifyOtp(
                        request.email,
                        request.otp
                );

        return ResponseEntity.ok(
                new AuthResponse(
                        result.isSuccess(),
                        result.getMessage()
                )
        );
    }

    // ==========================================
    // RESEND OTP
    // ==========================================

    @PostMapping("/resend-otp")
    public ResponseEntity<AuthResponse> resendOtp(
            @RequestBody ResendOtpRequest request) {

        AuthService.AuthResult result =
                authService.resendOtp(
                        request.email
                );

        return ResponseEntity.ok(
                new AuthResponse(
                        result.isSuccess(),
                        result.getMessage()
                )
        );
    }

    // ==========================================
    // SIGNUP REQUEST
    // ==========================================

    public static class SignupRequest {

        public String email;
        public String password;
    }

    // ==========================================
    // OTP REQUEST
    // ==========================================

    public static class VerifyOtpRequest {

        public String email;
        public String otp;
    }

    // ==========================================
    // RESEND REQUEST
    // ==========================================

    public static class ResendOtpRequest {

        public String email;
    }

    // ==========================================
    // RESPONSE
    // ==========================================

    public static class AuthResponse {

        public boolean success;
        public String message;

        public AuthResponse(
                boolean success,
                String message) {

            this.success = success;
            this.message = message;
        }
    }
}
