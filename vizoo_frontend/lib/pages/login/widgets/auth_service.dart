import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<User?> signInWithGoogle() async {
    try {
      await _googleSignIn
          .signOut(); // Đăng xuất tài khoản Google trước để chọn lại
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      User? user = userCredential.user;

      if (user != null) {
        final docRef = FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid);
        final docSnapshot = await docRef.get();

        if (!docSnapshot.exists) {
          // Nếu chưa có user, mới thêm vào Firestore
          await docRef.set({
            'uid': user.uid,
            'email': user.email,
            'username': user.displayName ?? '',
            'photoURL': user.photoURL ?? '',
            'lastSignIn': DateTime.now(),
            'role': "user",
          });
        } else {
          print("Tài khoản đã tồn tại, không cập nhật dữ liệu.");
        }
      }

      return user;
    } catch (e) {
      print("Đăng nhập Google thất bại: $e");
      return null;
    }
  }

  Future<User?> signInWithEmail(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      print("Lỗi đăng nhập email: $e");
      return null;
    }
  }

  Future<User?> registerWithEmail(
    String email,
    String password,
    String username,
  ) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': user.email,
          'username': username,
          'photoURL': "",
          'createdAt': DateTime.now(),
          'role': "user",
        });
      }
      return user;
    } catch (e) {
      print("Lỗi đăng ký: $e");
      return null;
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      print("Email đặt lại mật khẩu đã được gửi");
    } catch (e) {
      print("Lỗi khi gửi email đặt lại mật khẩu: $e");
      rethrow;
    }
  }
}
