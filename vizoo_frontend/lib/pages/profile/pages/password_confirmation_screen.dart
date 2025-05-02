import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vizoo_frontend/themes/colors/colors.dart';
import 'package:go_router/go_router.dart';
import 'package:vizoo_frontend/apps/router/router_name.dart';

class PasswordConfirmationScreen extends StatefulWidget {
  final Function(String) onConfirmed;

  const PasswordConfirmationScreen({
    required this.onConfirmed,
    super.key
  });

  @override
  State<PasswordConfirmationScreen> createState() => _PasswordConfirmationScreenState();
}

class _PasswordConfirmationScreenState extends State<PasswordConfirmationScreen> {
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _confirmPassword() async {
    if (_passwordController.text.isEmpty) {
      setState(() => _errorMessage = 'Vui lòng nhập mật khẩu');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null || user.email == null) {
        setState(() {
          _errorMessage = 'Không thể xác thực: Người dùng không hợp lệ';
          _isLoading = false;
        });
        return;
      }
      
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: _passwordController.text,
      );
      
      // Try to re-authenticate to check password validity
      await user.reauthenticateWithCredential(credential);
      
      // Password is correct, pass it back
      widget.onConfirmed(_passwordController.text);
    } on FirebaseAuthException catch (e) {
      // Handle specific authentication errors
      setState(() {
        _isLoading = false;
        switch (e.code) {
          case 'wrong-password':
            _errorMessage = 'Mật khẩu không chính xác';
            break;
          case 'too-many-requests':
            _errorMessage = 'Quá nhiều yêu cầu. Vui lòng thử lại sau';
            break;
          case 'user-mismatch':
            _errorMessage = 'Thông tin xác thực không khớp với người dùng hiện tại';
            break;
          default:
            _errorMessage = 'Xác thực không thành công: ${e.message}';
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Xác thực không thành công: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _navigateToForgotPassword() {
    // Navigate to the existing forgot password page using the named route
    Navigator.of(context).pop(); // Close current screen
    context.goNamed(RouterName.forgotPassword); // Go to forgot password page using the named route
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(MyColor.white),
      appBar: AppBar(
        title: const Text('Xác thực mật khẩu'),
        backgroundColor: const Color(MyColor.white),
        foregroundColor: const Color(MyColor.pr5),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(MyColor.pr5)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Vui lòng nhập mật khẩu hiện tại của bạn để tiếp tục',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(MyColor.pr5),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: const Color(MyColor.pr5), width: 1.5),
                borderRadius: BorderRadius.circular(10),
                color: const Color(MyColor.pr2),
              ),
              child: TextField(
                controller: _passwordController,
                obscureText: true,
                style: const TextStyle(
                  color: Color(MyColor.pr5),
                  fontSize: 16,
                ),
                decoration: InputDecoration(
                  labelText: 'Mật khẩu hiện tại',
                  labelStyle: const TextStyle(color: Color(MyColor.pr4)),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                  errorText: _errorMessage.isNotEmpty ? _errorMessage : null,
                  errorStyle: const TextStyle(color: Color(MyColor.red)),
                ),
              ),
            ),
            // Quên mật khẩu link
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _navigateToForgotPassword,
                child: const Text(
                  'Quên mật khẩu?',
                  style: TextStyle(
                    color: Color(MyColor.pr5),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _confirmPassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(MyColor.pr5),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  disabledBackgroundColor: const Color(MyColor.grey),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Color(MyColor.white),
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Xác nhận',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(MyColor.white),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}