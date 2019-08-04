import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_lock_screen/flutter_lock_screen.dart';

import 'package:provider/provider.dart';
import 'package:cptoolsflutter/app/CPTFAppInfo.dart';

/*

ーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー

Flutterアプリで、FaceIDを使うには、
iosプロジェクトをXcodeで開いて、

RunnerのInfo.plistに

Privacy - Face ID Usage Descriptionを追加しておくこと。
これが無いと、実行時にクラッシュする。

https://qiita.com/MilanistaDev/items/b0cd432290d18f336766

<key>NSFaceIDUsageDescription</key>
<string>FaceID</string>

ーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー

*/

class PassCodeScreen extends StatefulWidget {
  PassCodeScreen({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _PassCodeScreenState createState() => new _PassCodeScreenState();
}

class _PassCodeScreenState extends State<PassCodeScreen> {
  bool isFingerprint = false;

  int failureCount = 0;

  @override
  initState() {
    super.initState();

    print('initState in PassCode');
    failureCount = 0;

  }

  Future<Null> biometrics() async {
    // be sure you install local_auth package as a dependency
    final LocalAuthentication auth = new LocalAuthentication();
    bool authenticated = false;

    try {
      authenticated = await auth.authenticateWithBiometrics(
          localizedReason: 'Scan your fingerprint to authenticate',
          useErrorDialogs: true,
          stickyAuth: false);
    } on PlatformException catch (e) {
      print(e);
    }
    if (!mounted) return;
    if (authenticated) {
      setState(() {
        isFingerprint = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    // #### 端末に保存してある4桁のパスコード
    var myPass = [-1, -2, -3, -4];//[1, 2, 3, 4];
    String validPasscode = Provider.of<CPTFAppInfo>(context).getAppDictValue(CPTFAppInfo.KEY_PASSCODE_FOR_USER) as String;


    return LockScreen(
        title: widget.title,//"パスコード入力",
        passLength: myPass.length,
        bgImage: '../assets/critter100x100/hide.png',
        // bgImage: '../assets/critter100x100/passcode_bg.jpg',
        fingerPrintImage: '../assets/critter100x100/fingerprint.png',
        showFingerPass: true,
        fingerFunction: biometrics,
        numColor: Colors.blue,
        fingerVerify: isFingerprint,
        borderColor: Colors.white,
        showWrongPassDialog: false, //### ダイアログ表示をやめる。３回間違えたら失敗として画面を繊維する(pop(false))
        wrongPassContent: "パスコードが違います.",
        wrongPassTitle: "エラー",
        wrongPassCancelButtonText: "OK",//"""キャンセル",
        passCodeVerify: (passcode) async {

          String userInput = '';
          for (int i = 0; i < myPass.length; i++) {
            userInput += passcode[i].toString();
          }

          print('valid passcode ' + validPasscode);
          print('current userInput ' + userInput);

          if (validPasscode == userInput) {
            return true;
          }
          else {
            print('invalid');

            failureCount++;
            print('failureCount $failureCount');

            if (failureCount == 3) {

              //#######
              // ３回失敗したので、元の画面いfalseで戻る。
              //#######
              // Navigator.of(context).pop(false);
              // ===> Unhandled Exception: setState() called after dispose():
              // 少ししてから画面繊維
              Future.delayed( Duration(milliseconds: 1000), () {
                Navigator.of(context).pop(false);
              });

              return false;
            }
            return false;
          }

          /*
          for (int i = 0; i < myPass.length; i++) {
            if (passcode[i] != myPass[i]) {
              return false;
            }
          }

          return true;
          */
        },
        onSuccess: () {
          /*Navigator.of(context).pushReplacement(
              new MaterialPageRoute(builder: (BuildContext context) {
                return EmptyPage();
              }));*/
          // GO BACK
          Navigator.of(context).pop(true);
        });
  }
}