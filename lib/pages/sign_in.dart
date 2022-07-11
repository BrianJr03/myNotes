import 'home.dart';

import '/widgets/textfield.dart';

import '/firebase/fire_auth.dart';

import '/util/colors.dart';
import '/util/toasted.dart';
import '/util/launch.dart';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:auto_size_text/auto_size_text.dart';

class SignInWidget extends StatefulWidget {
  const SignInWidget({Key? key}) : super(key: key);

  @override
  State<SignInWidget> createState() => SignInWidgetState();
}

class SignInWidgetState extends State<SignInWidget> {
  final _emailTC = TextEditingController();
  final _passwordTC = TextEditingController();
  bool _passwordVisibility = false;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  /// This method is called when a user presses the 'Log In' button.
  ///
  /// If the user is not connected to the Internet before
  /// this method is called, a relevant warning toast will be displayed.
  ///
  /// Otherwise, if connected to the Internet, an attempt to validate
  /// the [Form] is made, and if successful, the user is signed in.
  void _signIn() async {
    if (_formKey.currentState!.validate()) {
      await FireAuth.signInUsingEmailPassword(
          email: _emailTC.text, password: _passwordTC.text);
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        await currentUser.reload();
        if (currentUser.emailVerified) {
          launch(context: context, widget: const HomeWidget());
        } else {
          showToast(msg: "Please verify your email address.");
        }
      }
    }
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

  SizedBox get _welcomeText => SizedBox(
        width: MediaQuery.of(context).size.width * 0.5,
        child: AutoSizeText(
          "Welcome to myNotes!",
          style: TextStyle(color: MyColors.themeColor, fontSize: 20),
        ),
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
          return null;
        },
      );

  SizedBox get _passwordTextField => textField(
      key: const Key("SignUp.password"),
      context: context,
      contr: _passwordTC,
      hintText: "Password",
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Please provide a password";
        }
        return null;
      },
      showPasswordIcons: true,
      isPasswordVisible: _passwordVisibility,
      obscureText: !_passwordVisibility,
      visibilityIconOnTap: () => setState(() {
            _passwordVisibility = !_passwordVisibility;
          }));

  SizedBox get _signInButton => SizedBox(
        width: MediaQuery.of(context).size.width / 2.85,
        child: ElevatedButton(
            style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all(MyColors.themeColor)),
            onPressed: () {
              _signIn();
            },
            child: Icon(Icons.check, color: MyColors.white)),
      );

  @override
  void dispose() {
    super.dispose();
    _emailTC.dispose();
    _passwordTC.dispose();
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
                  _welcomeText,
                  const SizedBox(height: 30),
                  _emailTextField,
                  const SizedBox(height: 20),
                  _passwordTextField,
                  const SizedBox(height: 50),
                  _signInButton,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
