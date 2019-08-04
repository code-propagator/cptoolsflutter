import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

import 'package:cptoolsflutter/login/InputLockScreen.dart';

class CPTFNewPassCode extends StatefulWidget {
  CPTFNewPassCode({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _CPTFNewPassCodeState createState() => new _CPTFNewPassCodeState();
}

class _CPTFNewPassCodeState extends State<CPTFNewPassCode> {
  bool isFingerprint = false;

  var myPass = [-1, -2, -3, -4];
  String myPassString = null;

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

    return InputLockScreen(
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
        showWrongPassDialog: true,
        wrongPassContent: "パスコードが違います.",
        wrongPassTitle: "エラー",
        wrongPassCancelButtonText: "キャンセル",
        passCodeVerify: (passcode) async {
          /*
          for (int i = 0; i < myPass.length; i++) {
            if (passcode[i] != myPass[i]) {
              return false;
            }
          }
          */

          //#### 入力取得用なのでmyPassに入力値をコピーする。
          myPassString = '';
          for (int i = 0; i < myPass.length; i++) {
            myPass[i] = passcode[i];

            myPassString += (passcode[i].toString());
          }

          // ４桁入力値を取得できたので、検証不要（成功）とする
          return true;
        },
        onSuccess: () {
          /*Navigator.of(context).pushReplacement(
              new MaterialPageRoute(builder: (BuildContext context) {
                return EmptyPage();
              }));*/

          print('put passcode to MyAppInfo ' + myPassString);
          // Provider.of<MyAppInfo>(context).setAppDictValue(MyAppInfo.KEY_NEEDS_UPDATE_PASSCODE_VALUE_NOW, myPassString);

          // https://qiita.com/ryunosukeheaven/items/9e43298955a371221393
          // 入力した値をpopの引数に入れて返す。

          Navigator.of(context).pop(myPassString);

        });
  }
}