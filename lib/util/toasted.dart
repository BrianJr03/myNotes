import '/util/colors.dart';

import 'package:fluttertoast/fluttertoast.dart';

void showToast({required String msg}) {
  Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      timeInSecForIosWeb: 1,
      backgroundColor: MyColors.darkGrey,
      textColor: MyColors.themeColor,
      fontSize: 16.0);
}
