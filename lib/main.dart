import '/util/colors.dart';

import 'pages/welcome.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  _lockPortrait();
  _setSavedTheme();
  runApp(
    Phoenix(
      child: const MyApp(),
    ),
  );
}

void _lockPortrait() {
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
    statusBarColor: MyColors.darkGrey,
  ));
}

/// Fetches user's stored theme and applies it.
void _setSavedTheme() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  int? themeColor = prefs.getInt('themeColor');
  if (themeColor != null) {
    MyColors.setThemeColor = Color(themeColor);
  } else {
    MyColors.setThemeColor = const Color(0xff53a99a);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'myNotes',
      home: WelcomeWidget(),
    );
  }
}
