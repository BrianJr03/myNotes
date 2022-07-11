import 'home.dart';
import 'sign_in.dart';
import 'sign_up.dart';

import '/util/launch.dart';
import '/util/colors.dart';
import '/util/toasted.dart';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:page_transition/page_transition.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class WelcomeWidget extends StatefulWidget {
  const WelcomeWidget({Key? key}) : super(key: key);

  @override
  State<WelcomeWidget> createState() => _WelcomeWidgetState();
}

class _WelcomeWidgetState extends State<WelcomeWidget> {
  void _launchHome() {
    launch(context: context, widget: const HomeWidget());
  }

  void _launchSignUp(BuildContext context) async {
    launch(
        context: context,
        animationType: PageTransitionType.topToBottom,
        widget: const SignUpWidget());
  }

  void _launchSignIn(BuildContext context) async {
    launch(
        context: context,
        animationType: PageTransitionType.bottomToTop,
        widget: const SignInWidget());
  }

  SizedBox _myNotesAnimated(BuildContext context) {
    List<Color> colorizeColors = [
      MyColors.themeColor,
      Colors.white,
      Colors.pink[400]!
    ];
    const colorizeTextStyle = TextStyle(
      fontSize: 50.0,
    );
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: AnimatedTextKit(
        onTap: () => showToast(msg: "Welcome!"),
        animatedTexts: [
          ColorizeAnimatedText('myNotes',
              textStyle: colorizeTextStyle,
              colors: colorizeColors,
              textAlign: TextAlign.center),
        ],
        isRepeatingAnimation: false,
      ),
    );
  }

  Widget _appIcon(BuildContext context) {
    return Image.asset(
      'assets/notes.png',
      width: 90,
      height: 90,
      fit: BoxFit.fitWidth,
    );
  }

  /// Initializes FirebaseApp and sends the user to Home if
  /// their account has been created.
  Future<FirebaseApp> _initFirebaseApp(BuildContext context) async {
    FirebaseApp firebaseApp = await Firebase.initializeApp();
    if (await _isUserEmailVerified()) {
      _launchHome();
    }
    return firebaseApp;
  }

  /// Returns bool indicating email verification status.
  Future<bool> _isUserEmailVerified() async {
    User? user = FirebaseAuth.instance.currentUser;
    user?.reload().then((_) => user.getIdToken(true));
    return user == null ? false : user.emailVerified;
  }

  /// Returns a row containing a loading message and [CircularProgressIndicator].
  ///
  /// This is displayed while the FirebaseApp initializes upon startup.
  Row _loadingSplash() {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Loading myNotes...",
                  style: TextStyle(fontSize: 20, color: MyColors.white)),
              const SizedBox(height: 50),
              const CircularProgressIndicator(),
            ])
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: MyColors.darkGrey,
        body: FutureBuilder(
            future: _initFirebaseApp(context),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _myNotesAnimated(context),
                      SizedBox(height: MediaQuery.of(context).size.height / 10),
                      _appIcon(context),
                      SizedBox(height: MediaQuery.of(context).size.height / 10),
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 2.85,
                        child: ElevatedButton(
                            style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    MyColors.themeColor)),
                            onPressed: () => _launchSignUp(context),
                            child: Text(
                              "Sign Up",
                              style: TextStyle(
                                  fontSize: 20, color: MyColors.white),
                            )),
                      ),
                      const SizedBox(height: 25),
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 2.85,
                        child: ElevatedButton(
                            style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    MyColors.themeColor)),
                            onPressed: () => _launchSignIn(context),
                            child: Text("Sign In",
                                style: TextStyle(
                                    fontSize: 20, color: MyColors.white))),
                      ),
                    ],
                  ),
                );
              }
              return Center(child: _loadingSplash());
            }),
      ),
    );
  }
}
