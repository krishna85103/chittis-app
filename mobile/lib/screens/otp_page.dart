import 'package:flutter/material.dart';

import '../services/auth_service.dart';

class OtpPage extends StatefulWidget {
  final String email;

  const OtpPage({
    super.key,
    required this.email,
  });

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final otpController = TextEditingController();

  bool loading = false;
  bool resending = false;

  final AuthService authService = AuthService();

  Future<void> verifyOtp() async {
    if (loading) return;

    final otp = otpController.text.trim();

    if (otp.length != 6) {
      showMessage(
        'Please enter the 6-digit OTP',
      );
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      debugPrint('====================================');
      debugPrint('VERIFY OTP');
      debugPrint('Email: ${widget.email}');
      debugPrint('OTP: $otp');
      debugPrint('====================================');

      final result = await authService.verifyOtp(
        widget.email,
        otp,
      );

      if (!mounted) return;

      debugPrint('OTP response: $result');

      if (result['success'] == true) {
        showMessage(
          'Email verified successfully',
        );

        Navigator.pop(context);
      } else {
        showMessage(
          result['message'] ?? 'Invalid OTP',
        );
      }
    } catch (e) {
      debugPrint('OTP verification error: $e');

      if (mounted) {
        showMessage(
          'Unable to connect to server',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  Future<void> resendOtp() async {
    if (resending) return;

    setState(() {
      resending = true;
    });

    try {
      debugPrint(
        'Resending OTP to ${widget.email}',
      );

      final result = await authService.resendOtp(
        widget.email,
      );

      if (!mounted) return;

      showMessage(
        result['message'] ?? 'OTP request completed',
      );
    } catch (e) {
      debugPrint('Resend OTP error: $e');

      if (mounted) {
        showMessage(
          'Unable to connect to server',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          resending = false;
        });
      }
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  void dispose() {
    otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Email'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.mark_email_read,
              size: 80,
              color: Colors.green,
            ),

            const SizedBox(height: 25),

            const Text(
              'Check your email',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            Text(
              'We sent a 6-digit OTP to\n${widget.email}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 30),

            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 28,
                letterSpacing: 8,
              ),
              decoration: const InputDecoration(
                labelText: 'Enter OTP',
                hintText: '123456',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: loading ? null : verifyOtp,
                child: loading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'VERIFY OTP',
                      ),
              ),
            ),

            const SizedBox(height: 15),

            TextButton(
              onPressed: resending ? null : resendOtp,
              child: resending
                  ? const Text('Sending...')
                  : const Text('RESEND OTP'),
            ),
          ],
        ),
      ),
    );
  }
}
