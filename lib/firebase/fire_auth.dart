import '/util/toasted.dart';
import 'dart:developer' as dev;

import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FireAuth {
  /// Registers a user via email and password.
  static Future<User?> registerUsingEmailPassword(
      {required String name,
      required String email,
      required String password}) async {
    User? user;
    FirebaseAuth auth = FirebaseAuth.instance;
    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
          email: email, password: password);
      user = userCredential.user;
      await user!.updateDisplayName(name);
      await user.reload();
      user = auth.currentUser;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'weak-password':
          showToast(msg: 'The password provided is too weak.');
          break;
        case 'email-already-in-use':
          showToast(msg: 'Account exists. Please sign in.');
          break;
      }
    }
    return user;
  }

  /// Signs in a user via email and password.
  static Future<User?> signInUsingEmailPassword(
      {required String email, required String password}) async {
    User? user;
    FirebaseAuth auth = FirebaseAuth.instance;
    try {
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
          email: email, password: password);
      user = userCredential.user;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          showToast(msg: 'No user found for that email.');
          break;
        case 'wrong-password':
          showToast(msg: 'Wrong password provided.');
          break;
        case 'user-disabled':
          showToast(msg: 'Account is disabled. Please contact the admin.');
          break;
      }
    }
    return user;
  }

  /// Sends another verification email to the user's email address.
  ///
  /// If a user has already verified their email, and toast will be displayed to
  /// inform the user.
  static reSendEmailVerification() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.reload();
      if (!user.emailVerified) {
        user
            .sendEmailVerification()
            .onError((error, stackTrace) => dev.log(error.toString()));
        showToast(
            msg: "A new verification email has been sent to: ${user.email}");
      } else {
        showToast(msg: 'Your email has already been verified.');
      }
    }
  }

  /// Signs the user out.
  static signOut() async {
    await FirebaseAuth.instance.signOut();
    showToast(msg: "Signed out.");
  }

  /// Deletes user then closes app.
  static void deleteUserAccount() {
    FirebaseAuth.instance.currentUser?.delete().whenComplete(() {
      showToast(msg: "Account has been deleted.");
      closeApp();
    });
  }

  /// Closes app.
  static void closeApp() {
    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
  }

  /// Allows a user to update their email address.
  static updateEmail({required String newEmail}) {
    User? user = FirebaseAuth.instance.currentUser;
    user!
        .updateEmail(newEmail)
        .then((value) => showToast(msg: "Email has been updated."));
  }

  /// Sends a password reset link to the user's email address.
  static sendResetPasswordLink({required String email}) async {
    final auth = FirebaseAuth.instance;
    await auth
        .sendPasswordResetEmail(email: email)
        .whenComplete(() => showToast(msg: "A link has been sent to $email"))
        .onError((error, stackTrace) => dev.log(error.toString()));
  }
}
