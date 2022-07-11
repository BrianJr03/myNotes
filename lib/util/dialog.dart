import '/util/colors.dart';

import 'package:flutter/material.dart';

/// Shows confirmation dialog to user.
///
/// Best used to prevent a user from accidentally performing
/// a significant action such as account deletion.
///
/// [onSubmitTap] is executed when a user confirms their action.
/// The dialog is closed before any other code is executed.
/// If null, a button will not be present.
///
/// [onCancelTap] is executed when a user cancels their action.
/// The dialog is closed before any other code is executed.
/// If null, a button will not be present.
///
/// [submitText] is displayed as a button to confirm action. Ex: 'OK'
///
/// [cancelText] is displayed as a button to cancel action. Ex: 'BACK'
void showDialogPlus({
  required BuildContext context,
  required Widget title,
  required Widget content,
  required Function()? onSubmitTap,
  required Function()? onCancelTap,
  required String submitText,
  required String cancelText,
}) {
  showDialog(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: title,
      backgroundColor: MyColors.darkGrey,
      content:
          SingleChildScrollView(scrollDirection: Axis.vertical, child: content),
      actions: <Widget>[
        if (onCancelTap != null)
          TextButton(
            onPressed: onCancelTap,
            child: Text(cancelText, style: TextStyle(color: MyColors.white)),
          ),
        if (onSubmitTap != null)
          TextButton(
            onPressed: onSubmitTap,
            child:
                Text(submitText, style: TextStyle(color: MyColors.themeColor)),
          ),
      ],
    ),
  );
}

/// Returns notes deletion warning text.
Text deleteNotesDialogText({String? option}) {
  return Text.rich(TextSpan(
      text: "This will be ",
      style: TextStyle(fontSize: 20, color: MyColors.white),
      children: [
        TextSpan(
            text: 'permanent',
            style: TextStyle(fontSize: 20, color: MyColors.themeColor)),
        TextSpan(
            text: option == "all"
                ? ' and all of your Notes will be deleted.'
                : " and your Note will be deleted.",
            style: TextStyle(fontSize: 20, color: MyColors.white))
      ]));
}
