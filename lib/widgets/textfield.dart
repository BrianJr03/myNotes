import '/util/dialog.dart';
import '/util/colors.dart';

import 'package:flutter/material.dart';

SizedBox textField({
  required Key key,
  required BuildContext context,
  required TextEditingController contr,
  int maxLines = 1,
  int? maxLength,
  double fontSize = 14,
  double? width,
  bool enabled = true,
  bool showBorder = true,
  bool? showPasswordIcons,
  bool showCounterText = true,
  bool obscureText = false,
  bool isPasswordVisible = false,
  String hintText = "Enter Value",
  String? Function(String?)? validator,
  Color textColor = Colors.white,
  TextInputType kbType = TextInputType.text,
  void Function()? visibilityIconOnTap,
}) {
  return SizedBox(
      width: width ?? MediaQuery.of(context).size.width * 0.85,
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(15, 0, 15, 0),
        child: SizedBox(
          width: MediaQuery.of(context).size.width / 2,
          child: TextFormField(
            key: key,
            maxLines: maxLines,
            maxLength: maxLength,
            enabled: enabled,
            keyboardType: kbType,
            style: TextStyle(color: textColor, fontSize: fontSize),
            validator: validator ??
                (value) {
                  if (value == null || value.isEmpty) {
                    return "Please provide a value";
                  }
                  return null;
                },
            controller: contr,
            obscureText: obscureText,
            cursorColor: MyColors.themeColor,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: const TextStyle(color: Colors.grey),
              counterText: showCounterText ? null : "",
              counterStyle: TextStyle(color: MyColors.themeColor),
              isDense: true,
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: showBorder ? MyColors.themeColor : MyColors.darkGrey,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: showBorder ? MyColors.themeColor : MyColors.darkGrey,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              suffixIcon: showPasswordIcons == true
                  ? Padding(
                      padding: const EdgeInsetsDirectional.only(end: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          IconButton(
                            onPressed: () {
                              showDialogPlus(
                                  context: context,
                                  title: Text("Password Requirements",
                                      style: TextStyle(color: MyColors.white)),
                                  content: Text(
                                      'Password must contain at least\n\n'
                                      '- Eight characters\n'
                                      '- One letter\n'
                                      '- One number\n'
                                      '- One special character',
                                      style: TextStyle(
                                          fontSize: 20, color: MyColors.white)),
                                  onSubmitTap: () {
                                    Navigator.pop(context);
                                  },
                                  onCancelTap: null,
                                  submitText: "OK",
                                  cancelText: "");
                            },
                            icon: Icon(Icons.info,
                                size: 20, color: MyColors.themeColor),
                          ),
                          IconButton(
                            key: const Key("Create.confirmPWVisibility"),
                            onPressed: visibilityIconOnTap,
                            icon: Icon(
                              isPasswordVisible
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              size: 20,
                              color: MyColors.themeColor,
                            ),
                          ),
                        ],
                      ))
                  : null,
            ),
          ),
        ),
      ));
}
