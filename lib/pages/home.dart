import 'note_editor.dart';

import '/util/drawer.dart';
import '/util/colors.dart';
import '/util/dialog.dart';
import '/util/launch.dart';
import '/util/toasted.dart';

import '/pages/welcome.dart';

import '/widgets/note.dart';
import '/widgets/textfield.dart';

import '/api/local_auth_api.dart';

import '/firebase/fire_auth.dart';
import '/firebase/firestore.dart';

import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeWidget extends StatefulWidget {
  const HomeWidget({Key? key}) : super(key: key);

  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  /// Indicates if the FAB is visible.
  bool _isFabVisible = true;

  bool _isShowingFavorites = false;

  final _sc = ScrollController();

  final List<Note> _noteList = [];

  final List<Note> _favNoteList = [];

  final _formKey = GlobalKey<FormState>();

  final _quickAddTitleContr = TextEditingController();
  final _quickAddBodyContr = TextEditingController();
  final _passcodeContr = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getUserNotes();
  }

  String _formatDate(DateTime date) => DateFormat("MMMM d, yyyy").format(date);

  final Stream<QuerySnapshot> _userNotesStream =
      FireStore.getUserNoteCollection()
          .orderBy("date", descending: true)
          .snapshots();

  /// Pre-loads previously completed daily goals stored in Firestore.
  void _getUserNotes() async {
    await _userNotesStream.forEach(((snapshot) {
      _noteList.clear();
      _favNoteList.clear();
      for (var document in snapshot.docs) {
        var title = document.get("title").toString();
        var body = document.get("body").toString();
        var date = document.get("date").toString();
        var passcode = document.get("passcode").toString();
        var bodyTextSize = document.get("bodyFontSize").toString();
        var textColorValue = document.get("textColorValue").toString();
        var isStarred = document.get("isStarred").toString();
        var isLocked = document.get("isLocked").toString();
        Note note = Note(
            title: title,
            date: date,
            body: body,
            passcode: passcode,
            bodyFontSize: double.parse(bodyTextSize),
            textColorValue: int.parse(textColorValue),
            isStarred: isStarred.parseBool(),
            isLocked: isLocked.parseBool());
        setState(() {
          _noteList.add(note);
        });
        if (isStarred.parseBool()) {
          setState(() {
            _favNoteList.add(note);
          });
        }
      }
    }));
  }

  void _launchNoteEditor({
    required String mode,
    required Note note,
  }) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => NoteEditor(
                note: note,
                mode: mode,
              )),
    );
    _quickAddTitleContr.clear();
    _quickAddBodyContr.clear();
    if (result != null) {
      String editorMode = result[0];
      Note noteFromEditor = result[1];
      _favNoteList.clear();
      _noteList.clear();
      if (editorMode == "save") {
        FireStore.addNote(noteFromEditor);
      } else {
        FireStore.updateNote(noteFromEditor);
      }
    }
  }

  Widget _buildGridView(
          {required ScrollController scrollController,
          required List<Note> notesList}) =>
      GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: .6,
            mainAxisSpacing: 15,
            crossAxisSpacing: 15,
          ),
          padding: const EdgeInsets.all(15),
          controller: scrollController,
          itemCount: notesList.length,
          itemBuilder: (context, index) {
            var note = notesList[index];
            return _buildNote(context: context, note: note);
          });

  Widget _buildNote({required BuildContext context, required Note note}) =>
      InkWell(
        onLongPress: (() {
          _openDeleteNoteDialog(note);
        }),
        child: Container(
          padding: const EdgeInsets.all(16),
          color: MyColors.themeColor,
          child: GridTile(
            header: Row(
              children: [
                IconButton(
                    icon: note.isStarred
                        ? Icon(
                            Icons.star_outlined,
                            size: 27,
                            color: MyColors.white,
                          )
                        : Icon(Icons.star_outline,
                            size: 27, color: MyColors.white),
                    onPressed: () {
                      _favNoteList.clear();
                      _noteList.clear();
                      note.isStarred = !note.isStarred;
                      FireStore.updateNote(note);
                    }),
                const Spacer(),
                note.isLocked
                    ? _lockInkWell(
                        note,
                        Icon(
                          Icons.lock,
                          size: 27,
                          color: MyColors.white,
                        ))
                    : _lockInkWell(note,
                        Icon(Icons.lock_open, size: 27, color: MyColors.white))
              ],
            ),
            footer: InkWell(
              onTap: () async {
                _openLockedNoteDialog(note);
              },
              child: Text(
                _formatDate(DateTime.parse(note.date)),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: MyColors.white),
              ),
            ),
            child: Center(
                child: InkWell(
              onTap: () async {
                _openLockedNoteDialog(note);
              },
              child: Text(note.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 25, color: MyColors.white)),
            )),
          ),
        ),
      );

  void _openDeleteNoteDialog(Note note) {
    showDialogPlus(
        context: context,
        title: Text("Delete Note", style: TextStyle(color: MyColors.white)),
        content: _deleteNoteDialogText(note),
        onSubmitTap: () async {
          if (note.isLocked && note.passcode == "biometrics") {
            var isAuthenticated = await LocalAuthApi.authenticate(
                "Please provide biometrics or system pin to delete this Note");
            if (isAuthenticated) {
              if (mounted) {
                Navigator.pop(context);
              }
              setState(() {
                _noteList.remove(note);
                if (note.isStarred) {
                  _favNoteList.remove(note);
                }
              });
              FireStore.deleteNote(note);
            }
          } else if (note.isLocked && int.tryParse(note.passcode!) != null) {
            _openPasscodeDialog(
                note: note,
                mode: "delete",
                onForgotPwTap: (() async {
                  _passcodeContr.clear();
                  final isAvailableAndAuthenticated =
                      await LocalAuthApi.authenticate(
                          "Use biometrics or system pin to delete this Note");
                  if (isAvailableAndAuthenticated) {
                    if (mounted) {
                      Navigator.pop(context);
                    }
                    setState(() {
                      _noteList.remove(note);
                      if (note.isStarred) {
                        _favNoteList.remove(note);
                      }
                    });
                    FireStore.deleteNote(note);
                    showToast(msg: "Note has been deleted");
                  }
                }),
                onSubmitTap: () {
                  var attemptedPasscode = _passcodeContr.text;
                  if (int.tryParse(attemptedPasscode.toString()) != null) {
                    if (attemptedPasscode.length >= 4) {
                      if (attemptedPasscode == note.passcode) {
                        _passcodeContr.clear();
                        _noteList.remove(note);
                        FireStore.deleteNote(note);
                        // Clears 1st dialog
                        Navigator.pop(context);
                        // Clears 2nd dialog
                        Navigator.pop(context);
                      } else {
                        showToast(msg: "Incorrect passcode");
                      }
                    } else {
                      showToast(msg: "Use at least 4 digits");
                    }
                  } else {
                    showToast(msg: "Use digits only");
                  }
                });
          } else {
            setState(() {
              _noteList.remove(note);
              if (note.isStarred) {
                _favNoteList.remove(note);
              }
            });
            FireStore.deleteNote(note);
            Navigator.pop(context);
          }
        },
        onCancelTap: () {
          Navigator.pop(context);
        },
        submitText: "Delete",
        cancelText: "Back");
  }

  void _openLockedNoteDialog(Note note) async {
    if (!note.isLocked) {
      _launchNoteEditor(
        note: note,
        mode: "update",
      );
    } else if (note.passcode == "biometrics" || note.passcode == "null") {
      final isAvailableAndAuthenticated = await LocalAuthApi.authenticate(
          "Open this Note with biometrics or your system pin");
      if (isAvailableAndAuthenticated) {
        _launchNoteEditor(
          note: note,
          mode: "update",
        );
      }
    } else {
      _openPasscodeDialog(
          note: note,
          mode: "open",
          onForgotPwTap: (() async {
            _passcodeContr.clear();
            final isAvailableAndAuthenticated = await LocalAuthApi.authenticate(
                "Use biometrics or system pin to unlock this Note");
            if (isAvailableAndAuthenticated) {
              FireStore.updateNoteField(
                  note.noteID, {"isLocked": false, "passcode": null});
              showToast(msg: "Note has been unlocked");
            }
            if (!mounted) {
              return;
            }
            Navigator.pop(context);
          }),
          onSubmitTap: () {
            var attemptedPasscode = _passcodeContr.text;
            if (int.tryParse(attemptedPasscode.toString()) != null) {
              if (attemptedPasscode.length >= 4) {
                if (attemptedPasscode == note.passcode) {
                  _passcodeContr.clear();
                  Navigator.pop(context);
                  _launchNoteEditor(
                    note: note,
                    mode: "update",
                  );
                } else {
                  showToast(msg: "Incorrect passcode");
                }
              } else {
                showToast(msg: "Use at least 4 digits");
              }
            } else {
              showToast(msg: "Use digits only");
            }
          });
    }
  }

  void _openPasscodeDialog(
      {required Note note,
      required String mode,
      required void Function()? onForgotPwTap,
      required void Function()? onSubmitTap}) {
    showDialogPlus(
        context: context,
        title: Text("Locked Note", style: TextStyle(color: MyColors.white)),
        content: Column(
          children: [
            Text("Enter the passcode to $mode this Note",
                style: TextStyle(color: MyColors.white, fontSize: 20)),
            const SizedBox(height: 15),
            textField(
                key: const Key(""),
                context: context,
                contr: _passcodeContr,
                maxLines: 1,
                maxLength: 6,
                showCounterText: true,
                kbType: TextInputType.number),
            const SizedBox(height: 15),
            ElevatedButton(
                style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(MyColors.themeColor)),
                onPressed: onForgotPwTap,
                child: const Text("Forgot Pin"))
          ],
        ),
        onSubmitTap: onSubmitTap,
        onCancelTap: () {
          _passcodeContr.clear();
          Navigator.pop(context);
        },
        submitText: "Enter",
        cancelText: "Back");
  }

  void _openQuickAddDialog() {
    showDialogPlus(
      context: context,
      title: Text(
        "Quick Add",
        style: TextStyle(color: MyColors.themeColor),
      ),
      content: Form(
        key: _formKey,
        child: Column(
          children: [
            textField(
                key: const Key(""),
                maxLength: Note.titleMaxLength,
                context: context,
                hintText: "Title",
                contr: _quickAddTitleContr,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter a title";
                  }
                  return null;
                }),
            const SizedBox(height: 15),
            textField(
                key: const Key(""),
                context: context,
                hintText: "Body",
                maxLines: 15,
                kbType: TextInputType.multiline,
                contr: _quickAddBodyContr,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter body text";
                  }
                  return null;
                }),
          ],
        ),
      ),
      // User presses 'Add'
      onSubmitTap: () {
        if (_formKey.currentState!.validate()) {
          _submitQuickNote();
        }
      },
      // User presses 'Expand'
      onCancelTap: () {
        Navigator.pop(context);
        _launchNoteEditor(
            mode: "save",
            note: Note(
                title: _quickAddTitleContr.text,
                date: DateTime.now().toString(),
                passcode: null,
                body: _quickAddBodyContr.text,
                isStarred: false,
                isLocked: false));
      },
      submitText: "Add",
      cancelText: "Expand",
    );
  }

  void _openDeleteAllNotesDialog() {
    showDialogPlus(
        context: context,
        title:
            Text("Delete All Notes", style: TextStyle(color: MyColors.white)),
        content: deleteNotesDialogText(option: "all"),
        onSubmitTap: () async {
          if (_noteList.isNotEmpty) {
            final isAuthenticated = await LocalAuthApi.authenticate(
                "Use biometrics or system pin to delete all Notes");
            if (isAuthenticated) {
              FireStore.deleteAllNotes();
              setState(() {
                _noteList.clear();
                _favNoteList.clear();
              });
              showToast(msg: "All Notes has been deleted");
            }
          } else {
            showToast(msg: "No Notes to delete");
          }
          if (mounted) {
            // Clears dialog
            Navigator.pop(context);
            // Closes drawer
            Navigator.pop(context);
          }
        },
        onCancelTap: () => Navigator.pop(context),
        submitText: "Delete",
        cancelText: "Back");
  }

  void _submitQuickNote() {
    FireStore.addNote(Note(
        title: _quickAddTitleContr.text,
        body: _quickAddBodyContr.text,
        date: DateTime.now().toString(),
        passcode: null,
        isStarred: false,
        isLocked: false));
    _quickAddTitleContr.clear();
    _quickAddBodyContr.clear();
    _favNoteList.clear();
    _noteList.clear();
    Navigator.pop(context);
  }

  InkWell _lockInkWell(
    Note note,
    Widget widget,
  ) =>
      InkWell(
        onTap: () {
          _openLockedNoteDialog(note);
        },
        child: widget,
      );

  Text _deleteNoteDialogText(Note note) {
    return Text.rich(TextSpan(
        text: "Are you sure you want to delete your ",
        style: TextStyle(fontSize: 20, color: MyColors.white),
        children: [
          TextSpan(
              text: "'${note.title}'",
              style: TextStyle(fontSize: 20, color: MyColors.themeColor)),
          TextSpan(
              text: " Note?\n\nThis can't be undone.",
              style: TextStyle(fontSize: 20, color: MyColors.white))
        ]));
  }

  @override
  void dispose() {
    super.dispose();
    _quickAddTitleContr.dispose();
    _quickAddBodyContr.dispose();
    _passcodeContr.dispose();
    _sc.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        showDialogPlus(
            context: context,
            title: Text("Sign Out",
                style: TextStyle(fontSize: 20, color: MyColors.white)),
            content: Text(
                "You will be signed out.\n\nAll progress will be saved.",
                style: TextStyle(fontSize: 20, color: MyColors.white)),
            onSubmitTap: () {
              FireAuth.signOut();
              returnToWidget(context: context, widget: const WelcomeWidget());
              return Future.value(false);
            },
            onCancelTap: () {
              Navigator.pop(context);
            },
            submitText: "Sign Out",
            cancelText: "Back");
        return Future.value(false);
      },
      child: Scaffold(
        appBar: AppBar(
          title: InkWell(
            onTap: () {
              setState(() {
                _isShowingFavorites = !_isShowingFavorites;
              });
            },
            child: Text(!_isShowingFavorites ? 'MyNotes' : "Favorites",
                style: TextStyle(color: MyColors.themeColor)),
          ),
          centerTitle: true,
          actions: [
            Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () => Scaffold.of(context).openEndDrawer(),
                tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
              ),
            ),
          ],
          leading: Builder(builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(
                Icons.note_outlined,
              ),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
            );
          }),
          iconTheme: IconThemeData(color: MyColors.themeColor),
          backgroundColor: MyColors.darkGrey,
          elevation: 0.0,
        ),
        drawer: DrawerWidget(
          noteCount: _noteList.length.toString(),
          scrollController: _sc,
          favOnTap: () {
            setState(() {
              _isShowingFavorites = !_isShowingFavorites;
            });
            Navigator.pop(context);
          },
          deleteOnTap: () {
            _openDeleteAllNotesDialog();
          },
        ),
        drawerEdgeDragWidth: MediaQuery.of(context).size.width / 2,
        endDrawer: DrawerWidget(isEndDrawer: true, scrollController: _sc),
        backgroundColor: MyColors.darkGrey,
        body: NotificationListener<UserScrollNotification>(
            onNotification: (n) {
              if (n.direction == ScrollDirection.forward) {
                if (!_isFabVisible) setState(() => _isFabVisible = true);
              } else if (n.direction == ScrollDirection.reverse) {
                if (_isFabVisible) setState(() => _isFabVisible = false);
              }
              return true;
            },
            child: !_isShowingFavorites
                ? _noteList.isNotEmpty
                    ? _buildGridView(
                        scrollController: _sc, notesList: _noteList)
                    : Center(
                        child: Text("No Notes Recorded!",
                            style: TextStyle(
                                fontSize: 30, color: MyColors.themeColor)),
                      )
                : _favNoteList.isNotEmpty
                    ? _buildGridView(
                        scrollController: _sc, notesList: _favNoteList)
                    : Center(
                        child: Text("No Favorite Notes!",
                            style: TextStyle(
                                fontSize: 30, color: MyColors.themeColor)),
                      )),
        floatingActionButton: _isFabVisible && !_isShowingFavorites
            ? FloatingActionButton(
                tooltip: "Add Note",
                onPressed: () {
                  _openQuickAddDialog();
                  _sc.jumpTo(_sc.position.maxScrollExtent);
                },
                backgroundColor: MyColors.darkGrey,
                foregroundColor: MyColors.themeColor,
                child: const Icon(
                  Icons.note_add,
                  size: 35,
                ))
            : null,
      ),
    );
  }
}

extension BoolParsing on String {
  bool parseBool() {
    if (toLowerCase() == 'true') {
      return true;
    } else if (toLowerCase() == 'false') {
      return false;
    }
    throw '"$this" can not be parsed to boolean.';
  }
}
