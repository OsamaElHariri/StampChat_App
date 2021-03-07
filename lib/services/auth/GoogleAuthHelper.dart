import 'package:StampChat/services/auth/AuthRequest.dart';
import 'package:StampChat/services/auth/AuthService.dart';
import 'package:StampChat/services/auth/UserToken.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthHelper {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  Future<UserToken> signInWithGoogle() async {
    await Firebase.initializeApp();

    if (_auth.currentUser != null) {
      return AuthService.login(
          AuthRequest.googleAuth(await _auth.currentUser.getIdToken()));
    }

    final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
    final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );

    final UserCredential authResult =
        await _auth.signInWithCredential(credential);
    final User user = authResult.user;

    if (user != null) {
      assert(!user.isAnonymous);
      assert(await user.getIdToken() != null);

      final User currentUser = _auth.currentUser;
      assert(user.uid == currentUser.uid);

      return AuthService.login(
          AuthRequest.googleAuth(await currentUser.getIdToken()));
    }

    return null;
  }

  Future<void> signOutGoogle() async {
    await googleSignIn.signOut();
    await _auth.signOut();
  }

  Future<User> getCurrentUser() async {
    await Firebase.initializeApp();
    return _auth.currentUser;
  }
}
