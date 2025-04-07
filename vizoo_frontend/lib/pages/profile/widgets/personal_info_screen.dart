import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vizoo_frontend/apps/colors/colors.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = 'Phan Văn Huy';
    _emailController.text = '2251120293@ut.edu.vn';
    _addressController.text = 'UTH University';
    _passwordController.text = '••••••••';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(MyColor.white),
        appBar: AppBar(
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
              onPressed: () {},
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      _buildMainContainer(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
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
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(24, 70, 24, 30),
          child: Column(
            children: [
              const SizedBox(height: 20),
              _buildFloatingLabelField(
                label: 'Name',
                text: _nameController.text,
              ),
              const SizedBox(height: 20),
              _buildFloatingLabelField(
                label: 'Email',
                text: _emailController.text,
              ),
              const SizedBox(height: 20),
              _buildFloatingLabelField(
                label: 'Delivery Address',
                text: _addressController.text,
              ),
              const SizedBox(height: 20),
              _buildFloatingLabelPasswordField(),
              const SizedBox(height: 30),
              _buildSaveButton(),
            ],
          ),
        ),
        Positioned(
          top: 0,
          child: Container(
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
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/images/VanHuy.png"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingLabelField({
    required String label,
    required String text,
  }) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 56,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(MyColor.pr2),
            border: Border.all(color: const Color(MyColor.pr5), width: 1.5),
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              text,
              style: const TextStyle(
                color: Color(MyColor.pr5),
                fontSize: 16,
                fontStyle: FontStyle.italic,
                fontFamily: 'Inter',
              ),
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

  Widget _buildFloatingLabelPasswordField() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 56,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(MyColor.pr2),
            border: Border.all(color: const Color(MyColor.pr5), width: 1.5),
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              8,
              (index) => Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: const BoxDecoration(
                  color: Color(MyColor.pr5),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: -10,
          left: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            color: const Color(MyColor.pr2),
            child: Row(
              children: const [
                Text(
                  'Password',
                  style: TextStyle(
                    color: Color(MyColor.pr5),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Inter',
                  ),
                ),
                SizedBox(width: 4),
                Icon(Icons.lock, size: 12, color: Color(MyColor.pr5)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: () {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Changes saved!')));
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Save edit',
                  style: TextStyle(
                    color: const Color(MyColor.pr5).withOpacity(0.8),
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
    );
  }
}
