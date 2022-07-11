// ignore_for_file: prefer_initializing_formals

class Note {
  String title = "";
  String body = "";
  String date = "";
  String? passcode;
  double bodyFontSize = 14;
  int textColorValue = 0xFFFFFFFF;
  bool isStarred = false;
  bool isLocked = false;
  Note(
      {required String title,
      required String body,
      required String date,
      String? passcode,
      double bodyFontSize = 14,
      int textColorValue = 0xFFFFFFFF,
      required bool isStarred,
      required bool isLocked}) {
    this.title = title;
    this.body = body;
    this.date = date;
    this.passcode = passcode;
    this.bodyFontSize = bodyFontSize;
    this.textColorValue = textColorValue;
    this.isStarred = isStarred;
    this.isLocked = isLocked;
  }

  static int titleMaxLength = 15;

  String get noteID => "Note @ $date";

  Map<String, dynamic> get toMap => {
        "title": title,
        "date": date,
        "body": body,
        "passcode": passcode,
        "bodyFontSize": bodyFontSize,
        "textColorValue": textColorValue,
        "isStarred": isStarred,
        "isLocked": isLocked
      };
}
