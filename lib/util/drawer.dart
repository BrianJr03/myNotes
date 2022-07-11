import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:my_notes/util/toasted.dart';

import 'colors.dart';
import 'dialog.dart';
import 'launch.dart' as l;

import '/pages/settings.dart';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class DrawerWidget extends StatefulWidget {
  final String noteCount;
  final bool isEndDrawer;
  final void Function()? favOnTap;
  final void Function()? deleteOnTap;
  final ScrollController? scrollController;
  const DrawerWidget(
      {Key? key,
      this.noteCount = "",
      this.isEndDrawer = false,
      this.favOnTap,
      this.deleteOnTap,
      this.scrollController})
      : super(key: key);

  @override
  State<DrawerWidget> createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  Color c = MyColors.themeColor;
  User? get _currentUser => FirebaseAuth.instance.currentUser;

  SizedBox _colorizeAnimate(BuildContext context, String text) {
    List<Color> colorizeColors = [
      Colors.white,
      Colors.white,
      MyColors.themeColor,
      Colors.black,
    ];
    const colorizeTextStyle = TextStyle(
      fontSize: 25.0,
    );
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: AnimatedTextKit(
        animatedTexts: [
          ColorizeAnimatedText(text,
              textStyle: colorizeTextStyle,
              colors: colorizeColors,
              textAlign: TextAlign.center),
        ],
        isRepeatingAnimation: false,
      ),
    );
  }

  Row _pickAThemeAnimated(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const SizedBox(width: 20.0, height: 100.0),
        Text(
          'Choose',
          style: TextStyle(color: MyColors.themeColor, fontSize: 25.0),
        ),
        const SizedBox(width: 5.0, height: 100.0),
        DefaultTextStyle(
          style: TextStyle(
            color: MyColors.themeColor,
            fontSize: 25.0,
          ),
          child: AnimatedTextKit(
            repeatForever: true,
            isRepeatingAnimation: true,
            animatedTexts: [
              RotateAnimatedText('a theme'),
              RotateAnimatedText('a colorway'),
              RotateAnimatedText('an aesthetic'),
            ],
          ),
        ),
      ],
    );
  }

  /// Shows a color picker, allowing a user to change their app's theme.
  void _showColorPickerDialog(
    BuildContext context,
  ) {
    showDialogPlus(
        context: context,
        title: _pickAThemeAnimated(context),
        content: BlockPicker(
            availableColors: MyColors.themeChoices,
            pickerColor: MyColors.themeColor,
            onColorChanged: (color) => {c = color}),
        onSubmitTap: () {
          _showRestartAppDialog();
        },
        onCancelTap: () {
          Navigator.pop(context);
        },
        submitText: "Save",
        cancelText: "Back");
  }

  void _showRestartAppDialog() {
    showDialogPlus(
        context: context,
        title: Text("Change Theme", style: TextStyle(color: MyColors.white)),
        content: Text("The app will restart to apply theme change.",
            style: TextStyle(color: MyColors.white, fontSize: 20)),
        onSubmitTap: () {
          MyColors.setThemeColor = c;
          _saveTheme(c.value);
          Phoenix.rebirth(context);
        },
        onCancelTap: () {
          Navigator.pop(context);
        },
        submitText: "Ok",
        cancelText: "Back");
  }

  /// Saves user's selected theme to local storage.
  void _saveTheme(int colorValue) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('themeColor', colorValue);
  }

  /// Takes the user to the myFit privacy policy.
  void _viewPrivacyPolicy() async {
    var url = Uri.parse('https://myfit-app.github.io/');
    if (!await launchUrl(url)) throw 'Could not launch $url';
  }

  Drawer _regularDrawer(String noteCount, ScrollController? sc,
          void Function()? favsOnTap, void Function()? onDeleteTap) =>
      Drawer(
        backgroundColor: MyColors.darkGrey,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: MyColors.themeColor,
              ),
              child: Center(
                child: _colorizeAnimate(
                    context, 'Notes Taken: ${widget.noteCount}'),
              ),
            ),
            ListTile(
                title: Row(
                  children: [
                    Icon(Icons.favorite, color: MyColors.themeColor),
                    const SizedBox(width: 10),
                    Text('Toggle Favorites',
                        style: TextStyle(color: MyColors.white)),
                  ],
                ),
                onTap: favsOnTap ?? favsOnTap),
            ListTile(
              title: Row(
                children: [
                  Icon(Icons.delete_sweep, color: MyColors.themeColor),
                  const SizedBox(width: 10),
                  Text('Delete All Notes',
                      style: TextStyle(color: MyColors.white)),
                ],
              ),
              onTap: onDeleteTap ?? onDeleteTap,
            ),
            ListTile(
              title: Row(
                children: [
                  InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        widget.scrollController!.jumpTo(0);
                      },
                      child:
                          Icon(Icons.arrow_upward, color: MyColors.themeColor)),
                  const SizedBox(width: 15),
                  InkWell(
                      onTap: (() {
                        var sc = widget.scrollController;
                        Navigator.pop(context);
                        sc!.jumpTo(sc.position.maxScrollExtent);
                      }),
                      child: Icon(Icons.arrow_downward,
                          color: MyColors.themeColor)),
                  const SizedBox(width: 15),
                  Text("Skip to Start or End",
                      style: TextStyle(color: MyColors.white))
                ],
              ),
            ),
            ListTile(
              title: Text('myNotes v1.0.0',
                  style: TextStyle(color: MyColors.themeColor)),
            )
          ],
        ),
      );

  Drawer get _endDrawer => Drawer(
        backgroundColor: MyColors.darkGrey,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: MyColors.themeColor,
              ),
              child: Center(
                  child: _colorizeAnimate(
                      context, '${_currentUser!.displayName}')),
            ),
            ListTile(
                title: Row(
                  children: [
                    Icon(Icons.color_lens, color: MyColors.themeColor),
                    const SizedBox(width: 10),
                    Text('Change Theme',
                        style: TextStyle(color: MyColors.white)),
                  ],
                ),
                onTap: () {
                  _showColorPickerDialog(context);
                }),
            ListTile(
              title: Row(
                children: [
                  Icon(Icons.settings, color: MyColors.themeColor),
                  const SizedBox(width: 10),
                  Text('Settings', style: TextStyle(color: MyColors.white)),
                ],
              ),
              onTap: () {
                l.launch(context: context, widget: const SettingsWidget());
              },
            ),
            ListTile(
                title: Row(
                  children: [
                    Icon(Icons.privacy_tip, color: MyColors.themeColor),
                    const SizedBox(width: 10),
                    Text('View Privacy Policy',
                        style: TextStyle(color: MyColors.white)),
                  ],
                ),
                onTap: () {
                  _viewPrivacyPolicy();
                }),
          ],
        ),
      );

  Drawer _drawer(
          {required BuildContext context, required ScrollController? sc}) =>
      !widget.isEndDrawer
          ? _regularDrawer(
              widget.noteCount, sc, widget.favOnTap, widget.deleteOnTap)
          : _endDrawer;

  @override
  Widget build(BuildContext context) {
    return _drawer(context: context, sc: widget.scrollController);
  }
}
