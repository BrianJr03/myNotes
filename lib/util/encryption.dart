import 'package:encrypt/encrypt.dart';

final _key = Key.fromUtf8('jsg5sf22mKq09syb3Fgah3m2Nhs53adL');
final iv = IV.fromLength(16);
final encrypter = Encrypter(AES(_key));