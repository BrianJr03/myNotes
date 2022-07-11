import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '/pages/home.dart';

import '/util/launch.dart';
import '/util/colors.dart';
import '/util/dialog.dart';
import '/util/toasted.dart';

import '/api/local_auth_api.dart';

import '/widgets/note.dart';
import '/widgets/textfield.dart';

import '/firebase/firestore.dart';

import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

class NoteEditor extends StatefulWidget {
  final Note note;
  final String mode;
  const NoteEditor({Key? key, required this.note, required this.mode})
      : super(key: key);

  @override
  State<NoteEditor> createState() => _NoteEditorState();
}

class _NoteEditorState extends State<NoteEditor> {
  bool _isStarred = false;
  bool _isLocked = false;
  bool _usingBiometrics = false;

  String? _passcode;
  String _noteID = "";

  double _bodyFontSize = 14;

  int _textColorValue = 0xFFFFFFFF;

  final now = DateTime.now();
  final _formKey = GlobalKey<FormState>();
  final _titleContr = TextEditingController();
  final _bodyContr = TextEditingController();
  final _passcodeContr = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initAttributes();
  }

  void _initAttributes() {
    _isStarred = widget.note.isStarred;
    _isLocked = widget.note.isLocked;
    _passcode = widget.note.passcode;
    _bodyFontSize = widget.note.bodyFontSize;
    _textColorValue = widget.note.textColorValue;
    _noteID = widget.note.noteID;
    if (_passcode == null || _passcode == "null") {
      _isLocked = false;
    }
    if (_passcode == "biometrics") {
      _usingBiometrics = true;
    }
    _titleContr.text = (widget.note.title.isNotEmpty) ? widget.note.title : "";
    _bodyContr.text = (widget.note.body.isNotEmpty) ? widget.note.body : "";
  }

  SizedBox get _backButton => SizedBox(
        child: IconButton(
          icon: const Icon(Icons.arrow_back, size: 30),
          color: MyColors.themeColor,
          onPressed: () {
            FocusManager.instance.primaryFocus?.unfocus();
            Navigator.pop(context);
          },
        ),
      );

  SizedBox get _changeTextColorIcon => SizedBox(
        child: IconButton(
          icon: const Icon(Icons.color_lens, size: 25),
          color: Color(_textColorValue),
          onPressed: () {
            FocusManager.instance.primaryFocus?.unfocus();
            _showColorPickerDialog(context);
          },
        ),
      );

  SizedBox get _starIcon => SizedBox(
        child: IconButton(
          icon: _isStarred
              ? const Icon(Icons.star_outlined, size: 25)
              : const Icon(Icons.star_outline, size: 25),
          color: MyColors.themeColor,
          onPressed: () {
            FocusManager.instance.primaryFocus?.unfocus();
            setState(() {
              _isStarred = !_isStarred;
            });
          },
        ),
      );

  SizedBox get _lockIcon => SizedBox(
        child: IconButton(
          icon: _isLocked
              ? const Icon(Icons.lock, size: 25)
              : const Icon(Icons.lock_open, size: 25),
          color: MyColors.themeColor,
          onPressed: () async {
            _openNoteLockDialog();
          },
        ),
      );

  SizedBox get _abcCapsIcon => SizedBox(
        child: IconButton(
          icon: const Icon(Icons.abc, size: 35),
          color: MyColors.themeColor,
          onPressed: () {
            _toggleBodyTextSize();
          },
        ),
      );

  SizedBox get _saveIcon {
    return SizedBox(
      child: IconButton(
        icon: const Icon(Icons.save, size: 25),
        color: MyColors.themeColor,
        onPressed: () {
          _saveNote();
        },
      ),
    );
  }

  SizedBox get _deleteIcon => SizedBox(
        child: IconButton(
          icon: const Icon(Icons.delete_forever, size: 30),
          color: MyColors.themeColor,
          onPressed: () {
            _openDeleteNoteDialog();
          },
        ),
      );

  Row get _headerIconRow =>
      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
        _backButton,
        _changeTextColorIcon,
        _starIcon,
        _lockIcon,
        _abcCapsIcon,
        _saveIcon,
        _deleteIcon,
        const SizedBox(width: 10)
      ]);

  SizedBox get _titleTextField => textField(
      key: const Key(""),
      maxLines: 1,
      textColor: Color(_textColorValue),
      maxLength: Note.titleMaxLength,
      width: MediaQuery.of(context).size.width,
      context: context,
      contr: _titleContr,
      hintText: "Title",
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Please enter a title";
        }
        return null;
      });

  SizedBox get _bodyTextField => textField(
      key: const Key(""),
      context: context,
      contr: _bodyContr,
      maxLines: 12,
      maxLength: 400,
      showBorder: false,
      showCounterText: false,
      fontSize: _bodyFontSize,
      textColor: Color(_textColorValue),
      kbType: TextInputType.multiline,
      width: MediaQuery.of(context).size.width,
      hintText: "Body",
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Please enter a body text";
        }
        return null;
      });

  void _showColorPickerDialog(
    BuildContext context,
  ) {
    showDialogPlus(
        context: context,
        title: const Text("Choose text color"),
        content: BlockPicker(
            availableColors: MyColors.themeChoices,
            pickerColor: Color(_textColorValue),
            onColorChanged: (color) => {
                  setState(() {
                    _textColorValue = color.value;
                  })
                }),
        onSubmitTap: () {
          Navigator.pop(context);
        },
        onCancelTap: null,
        submitText: "Save",
        cancelText: "");
  }

  void _toggleBodyTextSize() {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _bodyFontSize += 14;
      if (_bodyFontSize > 42) {
        _bodyFontSize = 14;
      }
    });
  }

  void _saveNote() {
    _passcode = _passcodeContr.text;
    FocusManager.instance.primaryFocus?.unfocus();
    if (_formKey.currentState!.validate()) {
      Note note = Note(
          title: _titleContr.text,
          date: widget.note.date,
          body: _bodyContr.text,
          passcode: _passcode!.isNotEmpty && !_usingBiometrics
              ? _passcode
              : _usingBiometrics
                  ? "biometrics"
                  : null,
          bodyFontSize: _bodyFontSize,
          textColorValue: _textColorValue,
          isStarred: _isStarred,
          isLocked: _isLocked);
      _passcodeContr.clear();
      Navigator.pop(context, [widget.mode, note]);
    }
  }

  void _openNoteLockDialog() {
    if (_isLocked) {
      showDialogPlus(
          context: context,
          title:
              Text("Delete Passcode", style: TextStyle(color: MyColors.white)),
          content: Text("Do you wish to remove your lock?",
              style: TextStyle(color: MyColors.white, fontSize: 20)),
          onSubmitTap: () {
            setState(() {
              _isLocked = false;
              _passcode = null;
            });
            FireStore.updateNoteField(
                _noteID, {"isLocked": _isLocked, "passcode": _passcode});
            Navigator.pop(context);
          },
          onCancelTap: () {
            Navigator.pop(context);
          },
          submitText: "CONFIRM",
          cancelText: "BACK");
    } else {
      showDialogPlus(
          context: context,
          title: Text("Set Passcode", style: TextStyle(color: MyColors.white)),
          content: Column(
            children: [
              Text(
                  "Enter a passcode to lock this Note.\n\n"
                  "You can also use biometrics.",
                  style: TextStyle(color: MyColors.white, fontSize: 20)),
              const SizedBox(height: 25),
              textField(
                  key: const Key(""),
                  context: context,
                  contr: _passcodeContr,
                  maxLines: 1,
                  maxLength: 6,
                  showCounterText: true,
                  hintText: "ex: 1234",
                  kbType: TextInputType.number),
              const SizedBox(height: 15),
              IconButton(
                  onPressed: () async {
                    _passcodeContr.clear();
                    if (!mounted) return;
                    Navigator.of(context).pop();
                    FocusManager.instance.primaryFocus?.unfocus();
                    final isAvailableAndAuthenticated =
                        await LocalAuthApi.authenticate(
                            "Lock this Note with biometrics or your system pin");
                    setState(() {
                      _isLocked = isAvailableAndAuthenticated;
                      _usingBiometrics = isAvailableAndAuthenticated;
                    });
                    if (isAvailableAndAuthenticated) {
                      showToast(msg: "Save this Note to lock with biometrics");
                    }
                  },
                  icon: Icon(Icons.fingerprint,
                      size: 50, color: MyColors.themeColor))
            ],
          ),
          onSubmitTap: () {
            if (int.tryParse(_passcodeContr.text.toString()) != null) {
              if (_passcodeContr.text.length >= 4) {
                setState(() {
                  _isLocked = true;
                  _usingBiometrics = false;
                });
                showToast(msg: "Save this Note to lock with passcode");
                Navigator.pop(context);
              } else {
                showToast(msg: "Use at least 4 digits");
              }
            } else {
              showToast(msg: "Use digits only");
            }
          },
          onCancelTap: () {
            _passcodeContr.clear();
            Navigator.pop(context);
          },
          submitText: "Confirm",
          cancelText: "Back");
    }
  }

  void _openDeleteNoteDialog() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (_titleContr.text.isNotEmpty || _bodyContr.text.isNotEmpty) {
      showDialogPlus(
          context: context,
          title: Text("Clear Fields", style: TextStyle(color: MyColors.white)),
          content: Text(
            "This will clear both fields.",
            style: TextStyle(fontSize: 20, color: MyColors.white),
          ),
          onSubmitTap: () {
            _titleContr.clear();
            _bodyContr.clear();
            Navigator.pop(context);
          },
          onCancelTap: () {
            Navigator.pop(context);
          },
          submitText: "Clear",
          cancelText: "Back");
    } else {
      showDialogPlus(
          context: context,
          title: Text("Delete Note", style: TextStyle(color: MyColors.white)),
          content: deleteNotesDialogText(),
          onSubmitTap: () {
            _titleContr.clear();
            _bodyContr.clear();
            FireStore.deleteNote(widget.note);
            returnToWidget(
                context: context,
                animationType: PageTransitionType.rightToLeftWithFade,
                widget: const HomeWidget());
          },
          onCancelTap: () {
            Navigator.pop(context);
          },
          submitText: "Clear",
          cancelText: "Back");
    }
  }

  @override
  dispose() {
    super.dispose();
    _titleContr.dispose();
    _bodyContr.dispose();
    _passcodeContr.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: MyColors.darkGrey,
        body: SafeArea(
            child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                _headerIconRow,
                const SizedBox(height: 15),
                _titleTextField,
                const SizedBox(height: 20),
                _bodyTextField
              ],
            ),
          ),
        )),
      ),
    );
    // );
  }
}
