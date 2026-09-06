import 'package:flutter/material.dart';

import '../services/api_service.dart';
import 'home_page.dart';
import 'signup_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool loading = false;
  bool obscurePassword = true;

  String errorMessage = '';

  Future<void> login() async {
    if (loading) return;

    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        errorMessage = 'Please enter email and password';
      });
      return;
    }

    setState(() {
      loading = true;
      errorMessage = '';
    });

    try {
      final result = await ApiService.login(
        email,
        password,
      );

      if (!mounted) return;

      if (result.success) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HomePage(
              email: result.email ?? email,
              isAdmin: result.isAdmin,
            ),
          ),
        );
      } else {
        setState(() {
          errorMessage = result.message;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = 'Unable to connect to server';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFF6B35),
              Color(0xFFFFA62B),
              Color(0xFFFFC857),
            ],
          ),
        ),

        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(22),

              child: Column(
                children: [
                  // LOGO
                  Container(
                    width: 95,
                    height: 95,

                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,

                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.18),
                          blurRadius: 25,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),

                    child: const Icon(
                      Icons.restaurant_menu,
                      size: 48,
                      color: Color(0xFFFF6B35),
                    ),
                  ),

                  const SizedBox(height: 18),

                  const Text(
                    'Chitti',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 5),

                  const Text(
                    'Food & Drinks',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 28),

                  // LOGIN CARD
                  Container(
                    padding: const EdgeInsets.all(24),

                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(26),

                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),

                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.18),
                          blurRadius: 25,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),

                    child: Column(
                      children: [
                        const Text(
                          'Welcome Back',
                          style: TextStyle(
                            fontSize: 27,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF252525),
                          ),
                        ),

                        const SizedBox(height: 7),

                        const Text(
                          'Login to continue',
                          style: TextStyle(
                            color: Color(0xFF777777),
                            fontSize: 15,
                          ),
                        ),

                        const SizedBox(height: 28),

                        TextField(
                          controller: emailController,

                          keyboardType:
                              TextInputType.emailAddress,

                          decoration: const InputDecoration(
                            labelText: 'Email address',
                            prefixIcon: Icon(
                              Icons.email_outlined,
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        TextField(
                          controller: passwordController,

                          obscureText: obscurePassword,

                          decoration: InputDecoration(
                            labelText: 'Password',

                            prefixIcon: const Icon(
                              Icons.lock_outline,
                            ),

                            suffixIcon: IconButton(
                              icon: Icon(
                                obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons
                                        .visibility_off_outlined,
                              ),

                              onPressed: () {
                                setState(() {
                                  obscurePassword =
                                      !obscurePassword;
                                });
                              },
                            ),
                          ),

                          onSubmitted: (_) => login(),
                        ),

                        const SizedBox(height: 18),

                        if (errorMessage.isNotEmpty)
                          Container(
                            width: double.infinity,

                            padding:
                                const EdgeInsets.all(12),

                            margin:
                                const EdgeInsets.only(
                              bottom: 18,
                            ),

                            decoration: BoxDecoration(
                              color: Colors.red.shade50,

                              borderRadius:
                                  BorderRadius.circular(12),

                              border: Border.all(
                                color: Colors.red.shade200,
                              ),
                            ),

                            child: Text(
                              errorMessage,

                              textAlign: TextAlign.center,

                              style: const TextStyle(
                                color: Colors.red,
                              ),
                            ),
                          ),

                        SizedBox(
                          width: double.infinity,
                          height: 54,

                          child: ElevatedButton(
                            onPressed:
                                loading ? null : login,

                            child: loading
                                ? const SizedBox(
                                    width: 25,
                                    height: 25,
                                    child:
                                        CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : const Text(
                                    'LOGIN',
                                  ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.center,

                          children: [
                            const Text(
                              "Don't have an account? ",
                              style: TextStyle(
                                color: Color(0xFF777777),
                              ),
                            ),

                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const SignupPage(),
                                  ),
                                );
                              },

                              child: const Text(
                                'Sign Up',
                                style: TextStyle(
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'Secure • Fast • Simple',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
