import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:app/core/constants/app_environment.dart';
import 'package:app/core/helpers/general_helper.dart';

class AuthHelper {
  static final GoogleSignIn _signIn = GoogleSignIn.instance;

  static Future<void> init() async {
    await _signIn.initialize(
      serverClientId: GeneralHelper.osInfo == 'android'
          ? AppEnvironment.firebaseWebClientId
          : null,
    );
    FirebaseAuth.instance.setLanguageCode(GeneralHelper.deviceLanguageCode);
  }

  static Future<UserCredential> signInWithGoogle() async {
    /// This example always uses the stream-based approach to determining
    /// which UI state to show, rather than using the future returned here,
    /// if any, to conditionally skip directly to the signed-in state.
    final GoogleSignInAccount googleUser = await _signIn.authenticate(
      scopeHint: ['email', 'profile'],
    );

    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth = googleUser.authentication;

    // Create a new credential
    final oathCredential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );

    // Once signed in, return the UserCredential
    final credential = await FirebaseAuth.instance.signInWithCredential(
      oathCredential,
    );

    return credential;
  }

  static Future<UserCredential?> signInWithPassword({
    required String emailAddress,
    required String password,
  }) async {
    final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: emailAddress,
      password: password,
    );

    // if (!credential.user!.emailVerified) {
    //   credential.user!.sendEmailVerification(
    //     ActionCodeSettings(
    //       url: 'https://pixage.tipai.tech/app',
    //       handleCodeInApp: true,
    //       iOSBundleId: 'com.tipai.ximage',
    //       androidPackageName: 'com.ximage.android',
    //       // linkDomain: 'pixage.tipai.tech',
    //     ),
    //   );
    //   // .catchError(Utils.debugLogError);
    // }

    return credential;
  }

  static Future<UserCredential?> registerWithPassword({
    required String emailAddress,
    required String password,
    // bool sendVerifyEmail = false,
  }) async {
    final credential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(
          email: emailAddress,
          password: password,
        );

    // if (!credential.user!.emailVerified && sendVerifyEmail) {
    //   credential.user!.sendEmailVerification(
    //     ActionCodeSettings(
    //       url: 'https://pixage.tipai.tech/app',
    //       handleCodeInApp: true,
    //       iOSBundleId: 'com.tipai.ximage',
    //       androidPackageName: 'com.ximage.android',
    //       // linkDomain: 'pixage.tipai.tech',
    //     ),
    //   );
    // }

    return credential;
  }

  static Future<void> sendForgotPasswordEmail(String email) {
    return FirebaseAuth.instance.sendPasswordResetEmail(email: email);
  }

  static Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    // await _signIn.signOut();
  }
}
