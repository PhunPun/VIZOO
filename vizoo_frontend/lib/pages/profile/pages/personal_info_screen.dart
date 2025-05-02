import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vizoo_frontend/themes/colors/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:vizoo_frontend/apps/router/router_name.dart';
// Import màn hình mới
import 'password_confirmation_screen.dart';
import 'password_change_screen.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  // Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  
  // Controllers
  final Map<String, TextEditingController> _controllers = {
    'name': TextEditingController(),
    'email': TextEditingController(),
    'address': TextEditingController(),
    'phone': TextEditingController(),
  };

  // States
  final Map<String, dynamic> _state = {
    'isLoading': true,
    'isUploading': false,
    'errorMessage': '',
    'profileImageUrl': '',
    'isEmailPasswordAuth': false,
    'isGoogleAuth': false,
  };

  File? _imageFile;
  bool get _isLoading => _state['isLoading'] as bool;
  bool get _isUploading => _state['isUploading'] as bool;
  bool get _isGoogleAuth => _state['isGoogleAuth'] as bool;
  bool get _isEmailPasswordAuth => _state['isEmailPasswordAuth'] as bool;
  String get _errorMessage => _state['errorMessage'] as String;
  String get _profileImageUrl => _state['profileImageUrl'] as String;

  // Collections reference
  CollectionReference get _usersCollection => _firestore.collection('users');

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  // Helper methods
  void _updateState(String key, dynamic value) {
    if (mounted) {
      setState(() => _state[key] = value);
    }
  }

  void _updateController(String key, String value) {
    _controllers[key]?.text = value;
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message))
    );
  }

  // Data loading
  Future<void> _loadUserData() async {
    _updateState('isLoading', true);
    _updateState('errorMessage', '');

    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        _updateState('errorMessage', 'No authenticated user found');
        return;
      }

      // Check login provider
      final bool isGoogleAuth = currentUser.providerData
          .any((info) => info.providerId == 'google.com');
      _updateState('isGoogleAuth', isGoogleAuth);
      _updateState(
        'isEmailPasswordAuth',
        currentUser.providerData.any((info) => info.providerId == 'password'),
      );

      // Load user data
      await _loadUserDataFromFirestore(currentUser);
    } catch (e) {
      _updateState('errorMessage', 'Failed to load user data: ${e.toString()}');
    } finally {
      _updateState('isLoading', false);
    }
  }

  Future<void> _loadUserDataFromFirestore(User currentUser) async {
    try {
      final userDoc = await _usersCollection.doc(currentUser.uid).get();
      final bool isGoogleAuth = _state['isGoogleAuth'] as bool;

      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;

        // Load basic info
        _updateController('name', userData['username'] ?? '');
        _updateController('email', userData['email'] ?? currentUser.email ?? '');
        _updateController('address', userData['dia_chi'] ?? '');
        _updateController('phone', userData['phone_number'] ?? '');

        // Handle avatar based on provider
        if (isGoogleAuth) {
          _updateState(
            'profileImageUrl',
            userData['photoURL'] ?? currentUser.photoURL ?? '',
          );
        } else {
          _updateState('profileImageUrl', userData['photoURL'] ?? '');
        }
      } else {
        // User exists in Auth but not in Firestore
        _updateController('email', currentUser.email ?? '');
        _updateController('name', currentUser.displayName ?? '');
        
        if (isGoogleAuth) {
          _updateState('profileImageUrl', currentUser.photoURL ?? '');
        }
      }
    } catch (e) {
      throw Exception('Error loading user data from Firestore: $e');
    }
  }

  // Image handling
  Future<void> _pickImage() async {
    try {
      final XFile? image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() => _imageFile = File(image.path));
      }
    } catch (e) {
      _showSnackBar('Lỗi khi chọn ảnh: ${e.toString()}');
    }
  }

  Future<String?> _uploadImage() async {
    if (_imageFile == null) return null;

    _updateState('isUploading', true);

    try {
      final String extension = _imageFile!.path.split('.').last.toLowerCase();
      final String fileName = 'profile_${_auth.currentUser?.uid}_${DateTime.now().millisecondsSinceEpoch}.$extension';
      final storageRef = _storage.ref().child('profile_images/$fileName');

      final uploadTask = storageRef.putFile(_imageFile!);
      final taskSnapshot = await uploadTask.whenComplete(() => null);
      final downloadUrl = await taskSnapshot.ref.getDownloadURL();

      // Update user photo URL
      await _auth.currentUser?.updatePhotoURL(downloadUrl);
      return downloadUrl;
    } catch (e) {
      if (mounted) {
        _showSnackBar('Lỗi khi tải ảnh lên: ${e.toString()}');
      }
      print("Upload error details: $e");
      return null;
    } finally {
      if (mounted) {
        _updateState('isUploading', false);
      }
    }
  }

  // User data operations
  Future<void> _saveUserData() async {
    _updateState('isLoading', true);

    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) return;

      // Prepare update data for basic info
      final Map<String, dynamic> updateData = {
        'username': _controllers['name']!.text,
        'dia_chi': _controllers['address']!.text,
        'phone_number': _controllers['phone']!.text,
      };

      // Upload image if needed
      final String? downloadUrl = await _uploadImage();
      if (downloadUrl != null) {
        updateData['photoURL'] = downloadUrl;
        _updateState('profileImageUrl', downloadUrl);
      }

      // Update Firestore with basic info
      await _usersCollection.doc(currentUser.uid).update(updateData);
      
      if (!mounted) return;
      _showSnackBar('Thông tin đã được cập nhật!');
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Lỗi khi cập nhật: ${e.toString()}');
    } finally {
      if (mounted) {
        _updateState('isLoading', false);
      }
    }
  }

  // Password change
  void _initiatePasswordChange() {
    if (_isGoogleAuth) {
      _showSnackBar('Tài khoản Google không thể thay đổi mật khẩu trực tiếp trong ứng dụng.');
      return;
    }
    
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PasswordConfirmationScreen(
          onConfirmed: (password) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => PasswordChangeScreen(
                  currentPassword: password,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Authentication
  Future<void> _signOut() async {
    try {
      await _auth.signOut();
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
        context.goNamed(RouterName.login);
      }
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Lỗi khi đăng xuất: ${e.toString()}');
    }
  }

  // Dialogs
  void _showSettingsMenu() {
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        MediaQuery.of(context).size.width - 50, 
        80, 
        0, 
        0
      ),
      items: [
        PopupMenuItem(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.logout, color: const Color(MyColor.pr5)),
              const SizedBox(width: 10),
              Text(
                'Đăng xuất',
                style: TextStyle(color: const Color(MyColor.pr5)),
              ),
            ],
          ),
        ),
      ],
    ).then((value) {
      if (value == 'logout') {
        _showLogoutDialog();
      }
    });
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => _signOut(),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(MyColor.pr5),
            ),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );
  }

  // UI Components
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(MyColor.white),
        appBar: _buildAppBar(),
        body: _buildBody(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(MyColor.white),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Color(MyColor.pr5)),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: SvgPicture.asset('assets/icons/logo.svg'),
      actions: [
        IconButton(
          icon: const Icon(Icons.settings, color: Color(MyColor.pr5)),
          tooltip: 'Cài đặt',
          onPressed: _showSettingsMenu,
        ),
      ],
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(MyColor.pr5)),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Text(
          _errorMessage,
          style: const TextStyle(color: Color(MyColor.red)),
        ),
      );
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: _buildMainContainer(),
      ),
    );
  }

  Widget _buildMainContainer() {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 50),
          decoration: BoxDecoration(
            color: const Color(MyColor.pr2),
            borderRadius: BorderRadius.circular(40),
            border: Border.all(color: const Color(MyColor.pr5), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(13),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(24, 70, 24, 30),
          child: Column(
            children: [
              const SizedBox(height: 20),
              _buildInputField('Name', 'name'),
              const SizedBox(height: 25),
              _buildInputField('Email', 'email', 
                isEmail: true, 
                enabled: false,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Text(
                  'Email không thể thay đổi',
                  style: TextStyle(
                    color: const Color(MyColor.grey),
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              const SizedBox(height: 25),
              _buildInputField('Delivery Address', 'address'),
              const SizedBox(height: 25),
              _buildInputField('Phone Number', 'phone'),
              const SizedBox(height: 35),
              _buildActionButtons(),
            ],
          ),
        ),
        Positioned(top: 0, child: _buildProfilePicture()),
      ],
    );
  }

  Widget _buildInputField(
    String label,
    String controllerKey, {
    bool isEmail = false,
    bool enabled = true,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 56,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(MyColor.pr2),
            border: Border.all(
              color: const Color(MyColor.pr5), 
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            controller: _controllers[controllerKey],
            enabled: enabled,
            keyboardType:
                isEmail ? TextInputType.emailAddress : TextInputType.text,
            style: TextStyle(
              color: enabled ? const Color(MyColor.pr5) : const Color(MyColor.grey),
              fontSize: 16,
              fontStyle: FontStyle.italic,
              fontFamily: 'Inter',
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
        Positioned(
          top: -10,
          left: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            color: const Color(MyColor.pr2),
            child: Text(
              label,
              style: const TextStyle(
                color: Color(MyColor.pr5),
                fontSize: 14,
                fontWeight: FontWeight.w500,
                fontFamily: 'Inter',
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfilePicture() {
    return GestureDetector(
      onTap: _pickImage,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(MyColor.pr5), width: 1.5),
              color: const Color(MyColor.pr2),
            ),
            padding: const EdgeInsets.all(4),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: _getProfileImage(),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          if (_isUploading)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(128),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Color(MyColor.white),
                    strokeWidth: 3,
                  ),
                ),
              ),
            ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(MyColor.pr5),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(MyColor.pr2), width: 2),
              ),
              child: const Icon(
                Icons.camera_alt,
                color: Color(MyColor.white),
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  ImageProvider _getProfileImage() {
    if (_imageFile != null) {
      return FileImage(_imageFile!);
    } else if (_profileImageUrl.isNotEmpty) {
      return NetworkImage(_profileImageUrl);
    } else {
      // Default avatar for non-Google accounts
      return const AssetImage("assets/images/default_avatar.png");
    }
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Change Password button only for email/password authentication
        if (_isEmailPasswordAuth && !_isGoogleAuth)
          GestureDetector(
            onTap: _initiatePasswordChange,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Đổi mật khẩu',
                      style: TextStyle(
                        color: const Color(MyColor.pr5).withAlpha(204),
                        fontSize: 16,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.lock_outline, size: 16, color: Color(MyColor.pr5)),
                  ],
                ),
                const SizedBox(height: 4),
                Image.asset(
                  'assets/images/MuiTen.png',
                  width: 110,
                  height: 20,
                  fit: BoxFit.contain,
                ),
              ],
            ),
          )
        else
          const SizedBox(), // Empty placeholder when password change is not available
          
        // Save Edit button
        GestureDetector(
          onTap: _saveUserData,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Save edit',
                    style: TextStyle(
                      color: const Color(MyColor.pr5).withAlpha(204),
                      fontSize: 16,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.edit, size: 16, color: Color(MyColor.pr5)),
                ],
              ),
              const SizedBox(height: 4),
              Image.asset(
                'assets/images/MuiTen.png',
                width: 110,
                height: 20,
                fit: BoxFit.contain,
              ),
            ],
          ),
        ),
      ],
    );
  }
}