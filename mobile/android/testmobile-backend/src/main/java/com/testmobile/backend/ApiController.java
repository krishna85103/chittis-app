package com.testmobile.backend;

import com.testmobile.backend.entity.User;
import com.testmobile.backend.repository.UserRepository;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api")
@CrossOrigin(origins = "*")
public class ApiController {

private final UserRepository userRepository;

private final BCryptPasswordEncoder passwordEncoder =
        new BCryptPasswordEncoder();

public ApiController(UserRepository userRepository) {
    this.userRepository = userRepository;
}

// ====================================
// LOGIN
// ====================================

@PostMapping("/login")
public LoginResponse login(
        @RequestBody LoginRequest request) {

    System.out.println("====================================");
    System.out.println("LOGIN REQUEST");
    System.out.println("Email: " + request.email);
    System.out.println("====================================");

    if (request.email == null
            || request.password == null
            || request.email.trim().isEmpty()
            || request.password.isEmpty()) {

        return new LoginResponse(
                false,
                "Email and password are required",
                null,
                null
        );
    }

    String email = request.email
            .trim()
            .toLowerCase();

    User user = userRepository
            .findByEmail(email)
            .orElse(null);

    if (user != null
            && passwordMatches(
                    request.password,
                    user.getPassword())) {

        System.out.println(
                "Login successful for: "
                        + user.getEmail()
        );

        System.out.println(
                "Role: " + user.getRole()
        );

        return new LoginResponse(
                true,
                "Login successful",
                user.getEmail(),
                user.getRole()
        );
    }

    System.out.println(
            "Invalid login for: " + email
    );

    return new LoginResponse(
            false,
            "Invalid email or password",
            null,
            null
    );
}

// ====================================
// PASSWORD CHECK
// ====================================

private boolean passwordMatches(
        String rawPassword,
        String storedPassword) {

    if (storedPassword == null) {
        return false;
    }

    if (storedPassword.startsWith("$2")) {

        return passwordEncoder.matches(
                rawPassword,
                storedPassword
        );
    }

    return storedPassword.equals(rawPassword);
}

// ====================================
// TAB 1
// ====================================

@GetMapping("/tab1")
public TabResponse tab1() {

    return new TabResponse(
            "Tab 1",
            "Welcome to Tab 1",
            "This information is coming from the Java backend."
    );
}

// ====================================
// TAB 2
// ====================================

@GetMapping("/tab2")
public TabResponse tab2() {

    return new TabResponse(
            "Tab 2",
            "Welcome to Tab 2",
            "This is another piece of information from the Java backend."
    );
}

// ====================================
// TAB 3
// ====================================

@GetMapping("/tab3")
public TabResponse tab3() {

    return new TabResponse(
            "Tab 3",
            "Welcome to Tab 3",
            "This is the third backend option."
    );
}

// ====================================
// HEALTH CHECK
// ====================================

@GetMapping("/health")
public String health() {

    return "TestMobile backend is running";
}

// ====================================
// LOGIN REQUEST
// ====================================

public static class LoginRequest {

    public String email;
    public String password;
}

// ====================================
// LOGIN RESPONSE
// ====================================

public static class LoginResponse {

    public boolean success;
    public String message;
    public String email;
    public String role;

    public LoginResponse(
            boolean success,
            String message,
            String email,
            String role) {

        this.success = success;
        this.message = message;
        this.email = email;
        this.role = role;
    }
}

// ====================================
// TAB RESPONSE
// ====================================

public static class TabResponse {

    public String tab;
    public String title;
    public String message;

    public TabResponse(
            String tab,
            String title,
            String message) {

        this.tab = tab;
        this.title = title;
        this.message = message;
    }
}


}
