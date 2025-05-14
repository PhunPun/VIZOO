import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vizoo_frontend/themes/colors/colors.dart';
import 'package:go_router/go_router.dart';
import 'package:vizoo_frontend/apps/router/router_name.dart';

class PasswordChangeScreen extends StatefulWidget {
  final String currentPassword;
  
  const PasswordChangeScreen({
    required this.currentPassword,
    super.key
  });

  @override
  State<PasswordChangeScreen> createState() => _PasswordChangeScreenState();
}

class _PasswordChangeScreenState extends State<PasswordChangeScreen> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  bool _isLoading = false;
  String _errorMessage = '';
  bool _isCompleted = false;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  String _statusMessage = '';
  
  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
  
  bool _validatePassword(String password) {
    
    return password.length >= 6 && 
           RegExp(r'[A-Za-z]').hasMatch(password) && 
           RegExp(r'[0-9]').hasMatch(password);
  }
  
  Future<void> _changePassword() async {
    // Validate form
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;
    
    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      setState(() => _errorMessage = 'Vui lòng điền đầy đủ thông tin');
      return;
    }
    
    if (newPassword != confirmPassword) {
      setState(() => _errorMessage = 'Mật khẩu mới không khớp');
      return;
    }
    
    if (!_validatePassword(newPassword)) {
      setState(() => _errorMessage = 'Mật khẩu phải có ít nhất 8 ký tự, bao gồm chữ và số');
      return;
    }
    
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    
    try {
      // Get current user
      final user = FirebaseAuth.instance.currentUser;
      if (user == null || user.email == null) {
        throw Exception('Không tìm thấy người dùng');
      }
      
      // Re-authenticate user with current password (required before password change)
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: widget.currentPassword,
      );
      
      await user.reauthenticateWithCredential(credential);
      
      // Change password
      await user.updatePassword(newPassword);
      
      setState(() {
        _isLoading = false;
        _isCompleted = true;
        _statusMessage = 'Mật khẩu đã được thay đổi thành công! Vui lòng đăng xuất và đăng nhập lại bằng mật khẩu mới.';
      });
    } on FirebaseAuthException catch (e) {
      String message;
      
      switch (e.code) {
        case 'weak-password':
          message = 'Mật khẩu quá yếu';
          break;
        case 'requires-recent-login':
          message = 'Phiên đăng nhập hết hạn, vui lòng đăng nhập lại';
          break;
        default:
          message = 'Lỗi: ${e.message}';
      }
      
      setState(() {
        _errorMessage = message;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Lỗi khi đổi mật khẩu: ${e.toString()}';
        _isLoading = false;
      });
    }
  }
  
  void _signOut() async {
    setState(() => _isLoading = true);
    
    try {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
        context.goNamed(RouterName.login);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi đăng xuất: ${e.toString()}')),
        );
        setState(() => _isLoading = false);
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(MyColor.white),
      appBar: AppBar(
        title: const Text('Đổi mật khẩu'),
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
          children: _isCompleted ? _buildCompletionUI() : _buildChangePasswordUI(),
        ),
      ),
    );
  }
  
  List<Widget> _buildChangePasswordUI() {
    return [
      const Text(
        'Tạo mật khẩu mới cho tài khoản của bạn',
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
          controller: _newPasswordController,
          obscureText: _obscureNewPassword,
          style: const TextStyle(
            color: Color(MyColor.pr5),
            fontSize: 16,
          ),
          decoration: InputDecoration(
            labelText: 'Mật khẩu mới',
            labelStyle: const TextStyle(color: Color(MyColor.pr4)),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureNewPassword ? Icons.visibility : Icons.visibility_off,
                color: const Color(MyColor.pr5),
              ),
              onPressed: () => setState(() => _obscureNewPassword = !_obscureNewPassword),
            ),
          ),
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
          controller: _confirmPasswordController,
          obscureText: _obscureConfirmPassword,
          style: const TextStyle(
            color: Color(MyColor.pr5),
            fontSize: 16,
          ),
          decoration: InputDecoration(
            labelText: 'Xác nhận mật khẩu mới',
            labelStyle: const TextStyle(color: Color(MyColor.pr4)),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                color: const Color(MyColor.pr5),
              ),
              onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
            ),
          ),
        ),
      ),
      if (_errorMessage.isNotEmpty) ...[
        const SizedBox(height: 15),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(MyColor.red).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            _errorMessage,
            style: const TextStyle(
              color: Color(MyColor.red),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
      const SizedBox(height: 30),
      SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _isLoading ? null : _changePassword,
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
                  'Đổi mật khẩu',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(MyColor.white),
                  ),
                ),
        ),
      ),
    ];
  }
  
  List<Widget> _buildCompletionUI() {
    return [
      const SizedBox(height: 20),
      Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle_outline,
              size: 100,
              color: Color(MyColor.pr5),
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(MyColor.pr2),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: const Color(MyColor.pr5),
                  width: 1.5,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    _statusMessage,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(MyColor.pr5),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    'Vui lòng đăng xuất và đăng nhập lại với mật khẩu mới của bạn',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(MyColor.pr4),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _signOut,
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
                        'Đăng xuất ngay',
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
    ];
  }
}