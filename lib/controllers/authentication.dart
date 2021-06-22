import 'package:kku_contest_app/imports.dart';

class Authentication {
  Authentication() {
    Firebase.initializeApp();
  }

  String _userID;

  UserModel _userModel;

  String get currentUserId => _userID;

  UserModel get loggedInUserModel => _userModel;

  Future<bool> signInWithGoogle() async {
    GoogleSignIn googleSignIn = GoogleSignIn();

    final GoogleSignInAccount googleUser = await googleSignIn.signIn();

    if (googleUser == null) {
      return false;
    }

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final GoogleAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    UserCredential userCreds =
        await FirebaseAuth.instance.signInWithCredential(credential);
    if (userCreds != null) {
      FirebaseUtilities.saveUserName(userCreds.user.displayName);
      FirebaseUtilities.saveUserEmail(userCreds.user.email);
      FirebaseUtilities.saveUserImageUrl(userCreds.user.photoURL);
      FirebaseUtilities.saveUserId(userCreds.user.uid);

      FirestoreDB.saveUserToFirebase(userCreds.user.displayName,userCreds.user.uid,"online");


      _userModel = UserModel(
        displayName: userCreds.user.displayName,
        photoUrl: userCreds.user.photoURL,
        email: userCreds.user.email,
        id: userCreds.user.uid,
      );
    }

    return true;
  }

  void signOut() async {
    await GoogleSignIn().signOut();
    await FirebaseFirestore.instance
        .collection("Users")
        .doc(_userModel.id).update({
      "status" : "offline"
    });
    _userModel = null;
  }
}
