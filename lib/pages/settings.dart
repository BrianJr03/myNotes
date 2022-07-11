import 'package:shared_preferences/shared_preferences.dart';

import 'welcome.dart';

import '/util/toasted.dart';
import '/util/colors.dart';
import '/util/dialog.dart';

import '/widgets/textfield.dart';

import '/firebase/fire_auth.dart';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:page_transition/page_transition.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class SettingsWidget extends StatefulWidget {
  const SettingsWidget({Key? key}) : super(key: key);

  @override
  State<SettingsWidget> createState() => _SettingsWidgetState();
}

class _SettingsWidgetState extends State<SettingsWidget> {
  User? get _currentUser => FirebaseAuth.instance.currentUser;

  /// [TextEditingController] for [_emailTextField].
  final _emailController = TextEditingController();

  /// [TextEditingController] for [_passwordTextField].
  final _passwordTC = TextEditingController();

  SizedBox _settingsButton(
      {required BuildContext context,
      required void Function()? onTap,
      required Widget? child}) {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 1.75,
      child: ElevatedButton(
          style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(MyColors.themeColor)),
          onPressed: onTap,
          child: child),
    );
  }

  /// Returns account deletion warning text.
  Text _deleteAcctDialogText() {
    return Text.rich(TextSpan(
        text: "Are you sure you want to delete your account?\n\nThis will be ",
        style: TextStyle(fontSize: 20, color: MyColors.white),
        children: [
          TextSpan(
              text: 'permanent',
              style: TextStyle(fontSize: 20, color: MyColors.themeColor)),
          TextSpan(
              text: ' and all of your data will be deleted.\n\n',
              style: TextStyle(fontSize: 20, color: MyColors.white))
        ]));
  }

  /// Returns a [TextField] which is used for email address input.
  ///
  /// This [Widget] uses [_emailController] as its [TextEditingController].
  SizedBox _emailTextField() {
    return textField(
        key: const Key(""),
        context: context,
        enabled: false,
        kbType: TextInputType.emailAddress,
        hintText: _currentUser!.email!,
        contr: _emailController);
  }

  /// Returns a [TextField] which is used for email address input.
  ///
  /// This [Widget] uses [_passwordTC] as its [TextEditingController].
  SizedBox _passwordTextField() {
    return textField(
        key: const Key(""),
        context: context,
        enabled: true,
        kbType: TextInputType.visiblePassword,
        hintText: 'Enter your password here',
        contr: _passwordTC);
  }

  /// Signs in the user and then immediately deletes their account.
  ///
  /// This is called when a user must reauthenticate in order to
  /// delete their account.
  _signInAndDelete() async {
    await FireAuth.signInUsingEmailPassword(
            email: _currentUser!.email!, password: _passwordTC.text)
        .then((value) {
      FireAuth.deleteUserAccount();
    });
  }

  SizedBox _settingsAnimated(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: TextLiquidFill(
        loadDuration: const Duration(milliseconds: 1000),
        waveDuration: const Duration(milliseconds: 750),
        text: 'Settings',
        waveColor: MyColors.themeColor,
        boxBackgroundColor: MyColors.darkGrey,
        textStyle: const TextStyle(
          fontSize: 50.0,
          fontWeight: FontWeight.bold,
        ),
        boxHeight: 100.0,
      ),
    );
  }

  void _returnToWelcome() {
    Navigator.pushAndRemoveUntil(
        context,
        PageTransition(
          alignment: Alignment.center,
          type: PageTransitionType.topToBottom,
          duration: const Duration(milliseconds: 300),
          reverseDuration: const Duration(milliseconds: 300),
          child: const WelcomeWidget(),
        ),
        (route) => false);
  }

  void _resetTheme() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('themeColor', 0xff53a99a);
    MyColors.setThemeColor = const Color(0xff53a99a);
  }

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordTC.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.darkGrey,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _settingsAnimated(context),
              const SizedBox(height: 40),
              _settingsButton(
                  context: context,
                  onTap: () => Navigator.pop(context),
                  child: Icon(
                    Icons.arrow_back,
                    color: MyColors.white,
                  )),
              const SizedBox(height: 20),
              _settingsButton(
                  context: context,
                  onTap: () {
                    FireAuth.sendResetPasswordLink(email: _currentUser!.email!);
                  },
                  child: Text(
                    "Reset Password",
                    style: TextStyle(color: MyColors.white, fontSize: 20),
                  )),
              const SizedBox(height: 20),
              _settingsButton(
                  context: context,
                  onTap: () {
                    showDialogPlus(
                        title: Text('Delete Account',
                            style: TextStyle(color: MyColors.white)),
                        context: context,
                        content: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _deleteAcctDialogText(),
                            ]),
                        cancelText: 'No',
                        submitText: 'Yes',
                        onCancelTap: () {
                          Navigator.pop(context);
                        },
                        onSubmitTap: () {
                          showDialogPlus(
                              context: context,
                              title: Text(
                                'Enter your password to confirm.',
                                style: TextStyle(color: MyColors.white),
                              ),
                              content: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _emailTextField(),
                                  const SizedBox(height: 10),
                                  _passwordTextField(),
                                ],
                              ),
                              cancelText: 'Back',
                              submitText: 'Delete Account',
                              onCancelTap: () {
                                Navigator.pop(context);
                              },
                              onSubmitTap: () async {
                                if (_passwordTC.text.isNotEmpty) {
                                  FocusManager.instance.primaryFocus?.unfocus();
                                  // Firebase requires a user to be recently
                                  // signed in before deleting their account.
                                  await FireAuth.signOut();
                                  _signInAndDelete();
                                  _resetTheme();
                                  _returnToWelcome();
                                } else {
                                  showToast(msg: 'Please provide a password.');
                                }
                              });
                        });
                  },
                  child: Text(
                    "Delete Account",
                    style: TextStyle(color: MyColors.white, fontSize: 20),
                  )),
              const SizedBox(height: 20),
              _settingsButton(
                  context: context,
                  onTap: () {
                    showDialogPlus(
                        context: context,
                        title: Text('Logout',
                            style: TextStyle(color: MyColors.white)),
                        content: Text(
                            'Are you sure you want to log out?'
                            '\n\nYour data will be saved.',
                            style:
                                TextStyle(fontSize: 20, color: MyColors.white)),
                        cancelText: 'No',
                        submitText: 'Yes',
                        onCancelTap: () {
                          Navigator.pop(context);
                        },
                        onSubmitTap: () async {
                          await FireAuth.signOut();
                          _resetTheme();
                          _returnToWelcome();
                        });
                  },
                  child: Text(
                    "Sign Out",
                    style: TextStyle(color: MyColors.white, fontSize: 20),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
