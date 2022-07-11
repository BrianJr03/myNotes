import 'welcome.dart';

import '/util/colors.dart';
import '/util/toasted.dart';
import '/util/validator.dart';

import '/widgets/textfield.dart';

import '/firebase/fire_auth.dart';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:page_transition/page_transition.dart';

class SignUpWidget extends StatefulWidget {
  const SignUpWidget({Key? key}) : super(key: key);

  @override
  State<SignUpWidget> createState() => _SignUpWidgetState();
}

class _SignUpWidgetState extends State<SignUpWidget> {
  final _fullNameTC = TextEditingController();
  final _emailTC = TextEditingController();
  final _passwordTC = TextEditingController();
  final _confirmPassTC = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _passwordVisibility = false;
  bool _confirmPasswordVisibility = false;

  @override
  void initState() {
    super.initState();
  }

  static String capitalizeStr(String str) {
    return "${str[0].toUpperCase()}${str.substring(1, str.length)}";
  }

  SizedBox get _backButton => SizedBox(
        width: MediaQuery.of(context).size.width / 2.85,
        child: ElevatedButton(
            style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all(MyColors.themeColor)),
            onPressed: () => Navigator.pop(context),
            child: Icon(Icons.arrow_back, color: MyColors.white)),
      );

  SizedBox get _provideInfoText => SizedBox(
        width: MediaQuery.of(context).size.width * 0.5,
        child: AutoSizeText(
          "Welcome to myNotes!",
          style: TextStyle(color: MyColors.themeColor, fontSize: 20),
        ),
      );

  SizedBox get _signUpButton => SizedBox(
        width: MediaQuery.of(context).size.width / 2.85,
        child: ElevatedButton(
            style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all(MyColors.themeColor)),
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _createAccount();
              }
            },
            child: Icon(Icons.check, color: MyColors.white)),
      );

  SizedBox get _nameTextField => textField(
        key: const Key("SignUp.fullName"),
        context: context,
        contr: _fullNameTC,
        hintText: "Full Name",
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Please provide your full name";
          }
          if (!isValidName(value)) {
            return "Please provide a valid name";
          } else {
            var fullName = value.trim().split(" ");
            var firstCapitalized = capitalizeStr(fullName[0]);
            var lastCapitalized = capitalizeStr(fullName[1]);
            _fullNameTC.text = "$firstCapitalized $lastCapitalized";
          }
          return null;
        },
      );

  SizedBox get _emailTextField => textField(
        key: const Key("SignUp.email"),
        context: context,
        contr: _emailTC,
        hintText: "Email Address",
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Please provide your email address";
          }
          if (!isValidEmail(value)) {
            return "Please provide a valid email address";
          } else {
            _emailTC.text = value.trim();
          }
          return null;
        },
      );

  SizedBox get _passwordTextField => textField(
        key: const Key("SignUp.password"),
        context: context,
        contr: _passwordTC,
        hintText: "!Password12",
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Please provide a password";
          }
          if (!isValidPassword(value)) {
            return "Please provide a valid password";
          }
          return null;
        },
        showPasswordIcons: true,
        isPasswordVisible: _passwordVisibility,
        obscureText: !_passwordVisibility,
        visibilityIconOnTap: () => setState(() {
          _passwordVisibility = !_passwordVisibility;
        }),
      );

  SizedBox get _confirmPassWord => textField(
        key: const Key("SignUp.confirmPass"),
        context: context,
        contr: _confirmPassTC,
        hintText: "!Password12",
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Please confirm your password";
          }
          if (value != _passwordTC.text) {
            return "Passwords must match";
          } else if (!isValidPassword(value)) {
            return "Please provide a valid password";
          }
          return null;
        },
        showPasswordIcons: true,
        isPasswordVisible: _confirmPasswordVisibility,
        obscureText: !_confirmPasswordVisibility,
        visibilityIconOnTap: () => setState(() {
          _confirmPasswordVisibility = !_confirmPasswordVisibility;
        }),
      );

  /// Used to create a user's account based on their provided credentials.
  void _createAccount() async {
    User? user = await FireAuth.registerUsingEmailPassword(
        name: _fullNameTC.text,
        email: _emailTC.text,
        password: _passwordTC.text);
    user?.sendEmailVerification();
    if (user != null) {
      await user.reload();
      if (user.emailVerified) {
        showToast(msg: "Account has been verified. Please sign in.");
      } else {
        showToast(msg: "Please verify your email.");
        showToast(msg: "Be sure to check spam/junk mail.");
        _returnToWelcome();
      }
    }
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

  @override
  void dispose() {
    super.dispose();
    _fullNameTC.dispose();
    _emailTC.dispose();
    _passwordTC.dispose();
    _confirmPassTC.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: MyColors.darkGrey,
        body: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _backButton,
                  const SizedBox(height: 20),
                  _provideInfoText,
                  const SizedBox(height: 30),
                  _nameTextField,
                  const SizedBox(height: 20),
                  _emailTextField,
                  const SizedBox(height: 20),
                  _passwordTextField,
                  const SizedBox(height: 20),
                  _confirmPassWord,
                  const SizedBox(height: 50),
                  _signUpButton,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
