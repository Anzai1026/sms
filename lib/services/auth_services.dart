import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sms/firestore/user_firestore.dart';

class AuthService {

  signInWithGoogle() async{

    final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication gAuth = await gUser!.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: gAuth.accessToken,
      idToken: gAuth.idToken,
    );
    final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
    final displayName = userCredential.user?.displayName;
    final photoUrl = userCredential.user?.photoURL;

    await FirebaseFirestore
        .instance.collection('user').doc(userCredential.user?.uid).set({
      'name': displayName,
      'image_path': photoUrl,
      'lastSignIn': FieldValue.serverTimestamp(),
    });
  }
}