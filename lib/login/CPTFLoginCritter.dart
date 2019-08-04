import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:cptoolsflutter/db/CPTFEntity.dart';
import 'package:cptoolsflutter/db/CPTFAppDB.dart';
import 'package:cptoolsflutter/app/CPTFAppInfo.dart';

/*
MIT License

Copyright (c) 2019 Code Propagator

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software,
and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies
or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

// https://github.com/tattwei46/flutter_login_demo

class CPTFLoginCritter extends StatefulWidget {
  CPTFLoginCritter({Key key, this.title, this.listData, this.auth, this.onSignedIn}) : super(key: key);

  final String title;
  final String listData;

  // final BaseAuth auth;
  final auth;

  final VoidCallback onSignedIn;

  final String instruction = 'ユーザIDとパスワードを入力して下さい。';
  final String labelUserID = 'ユーザID';
  final String labelPassword = 'パスワード';
  final String labelRequired = '必須入力';



  @override
  CPTFLoginCritterState createState() => CPTFLoginCritterState();
}

enum FormMode { LOGIN, SIGNUP }

class CPTFLoginCritterState extends State<CPTFLoginCritter> {
  final _formKey = new GlobalKey<FormState>();

  // String _email;
  String _userId;
  String _password;
  String _passCode;

  TextEditingController _userIdController;
  TextEditingController _passwordController;

  String _errorMessage;

  // Initial form is login form
  FormMode _formMode = FormMode.SIGNUP;// FormMode.LOGIN;
  bool _isIos;
  bool _isLoading;

  @override
  void initState() {
    _errorMessage = "";
    _isLoading = false;
    super.initState();

    //---------------------------
    _checkAccount();
  }

  Future <String> wait(int milli){
    return Future.delayed( Duration(milliseconds: milli), () async {
      return DateTime.now().toString();
    });
  }

  _checkAccount() async {
    //########################
    // GUIの表示が完了してcontextが有効になるまでに、少し待つ必要がある。
    // initState直後にダイアログを即時表示しようとするとクラッシュするので注意。
    await wait(500);
    //########################
    print('-------------------');
    print('check Account');

    //#####
    Account account = await Provider.of<CPTFAppInfo>(context).checkAccount();
    print(account);
    //#####

    if (account == null) {
      setState(() {
        _userId = null;
        _password = null;
        _passCode = null;
      });
    } else {
      print('Found existing Account');
      setState(() {
        _userId = account.UserId;
        _password = account.Password;
        _passCode = account.SimplePassword;
      });
    }
    print('----------------');

    // https://stackoverflow.com/questions/43214271/how-do-i-supply-an-initial-value-to-a-text-field
    _userIdController = TextEditingController(text: _userId == null ? '' : _userId);
    _passwordController = TextEditingController(text: _password == null ? '' : _password);


    // #### for Critter
    _userIdController.addListener(userIdListener);
    _passwordController.addListener(passwordListener);
    _textFocus.addListener(userIdListener);
    _textFocus2.addListener(passwordListener);
  }

  // Check if form is valid before perform login or signup
  bool _validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  // Perform login or signup
  void _validateAndSubmit() async {
    setState(() {
      _errorMessage = "";
      _isLoading = true;
    });
    if (_validateAndSave()) {
      // String userId = "";
      try {
        if (_formMode == FormMode.LOGIN) {
          // userId = await widget.auth.signIn(_email, _password);

          // print('Signed in: $userId');
        } else {
          // userId = await widget.auth.signUp(_email, _password);

          // widget.auth.sendEmailVerification();
          // _showVerifyEmailSentDialog();
          // print('Signed up user: $userId');

          print('INPUT _userId ' + (_userId == null ? 'INVALID USER ID' : _userId));
          print('_password ' + (_password == null ? 'NULL PASSWORD' : _password));
          print('_passCode ' + (_passCode == null ? 'NULL PASSCODE' : _passCode));


          print('CHECK OR SAVE ACCOUNT HERE');
          Account entity = Account.fromMap({
            fUserId: _userId,
            fPassword: _password,
            fSimplePassword: _passCode
          });
          Account saved = await Provider.of<CPTFAppInfo>(context).saveAccount(entity) as Account;
          print(saved);

          print('check ssave result');
          if (saved == null) {
            print('save is null');

            _showAlertMessage(context,
                'エラー',
                'アカウント登録に失敗しました。\nアプリを再起動してやり直して下さい。',
                'OK');
          } else {
            print('save is not null');

            if (saved.SimplePassword == null || saved.SimplePassword == '') {
              print('missing pass code');

              _showAlertMessage(context,
                  'アカウント設定',
                  'アカウント・パスワードを保存しました。',
                  'OK');

            } else {

              print('already has passcode');

              _showAlertMessage(context,
                  'アカウント設定',
                  'ユーザ： ${saved.UserId} のアカウント・パスワードを保存しました。',
                  'OK');
              // Navigator.of(context).pop();
              // ==> call pop not here but callback on dialog
            }
          }
        }
        setState(() {
          _isLoading = false;
        });

        //if (userId != null && userId.length > 0 && _formMode == FormMode.LOGIN) {
        //  widget.onSignedIn();
        //}

      } catch (e) {
        print('Error: $e');
        setState(() {
          _isLoading = false;

          // [VERBOSE-2:ui_dart_state.cc(148)] Unhandled Exception: NoSuchMethodError: Class 'NoSuchMethodError' has no instance getter 'details'.
          if (_isIos) {
            _errorMessage = 'エラー'; //e.details == null ? '' : e.details.toString();
          } else
            _errorMessage = 'エラー';// e.message == null ? '' : e.message.toString();
        }
        );
      }
    }
  }


  void _changeFormToSignUp() {
    _formKey.currentState.reset();
    _errorMessage = "";
    setState(() {
      _formMode = FormMode.SIGNUP;
    });
  }

  void _changeFormToLogin() {
    _formKey.currentState.reset();
    _errorMessage = "";
    setState(() {
      _formMode = FormMode.LOGIN;
    });
  }

  @override
  Widget build(BuildContext context) {
    _isIos = Theme.of(context).platform == TargetPlatform.iOS;
    return new Scaffold(
        appBar: new AppBar(
          title: new Text(widget.title),
        ),
        body: Stack(
          children: <Widget>[
            _showBody(),
            _showCircularProgress(),
          ],
        ));
  }

  Widget _showCircularProgress(){
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    } return Container(height: 0.0, width: 0.0,);

  }

  void _showVerifyEmailSentDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Verify your account"),
          content: new Text("Link to verify account has been sent to your email"),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Dismiss"),
              onPressed: () {
                _changeFormToLogin();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _showBody(){
    return new Container(
        padding: EdgeInsets.all(4.0),
        child: new Form(
          key: _formKey,
          child: new ListView(
            shrinkWrap: true,
            children: <Widget>[

              Card(child:

              Column(
                  mainAxisSize: MainAxisSize.min,
                  children:<Widget>[
                    Text('', style:TextStyle(fontSize: 5)),
                    _showLogo(),
                    Text(widget.instruction, style:TextStyle(fontSize: 12), textAlign: TextAlign.center,),

                    // _showEmailInput(),
                    _showUserIdInput(),

                    Row(
                        mainAxisSize: MainAxisSize.min,
                        children:<Widget>[

                          //Expanded(child:
                          _showPasswordInput(),
                          //),

                          IconButton(
                            icon: Icon(Icons.remove_red_eye),
                            tooltip: 'パスワード表示',
                            onPressed: () {
                              setState(() {
                                _obscurePasswordString = !_obscurePasswordString;
                                critter();
                              });
                            },
                          )
                        ]),

                    _showPrimaryButton(),
                  ])),

              // _showSecondaryButton(),

              // パスコード
              Card(child:Column(mainAxisSize: MainAxisSize.min,
                  children:<Widget>[
                    Text('アプリ操作用のパスコードを設定して下さい。', style:TextStyle(fontSize: 12)),
                    _showPrimaryPasscodeButton(),
                  ])),


              _showErrorMessage(),
            ],
          ),
        ));
  }

  Widget _showErrorMessage() {
    if (_errorMessage != null && _errorMessage.length > 0) {
      return new Text(
        _errorMessage,
        style: TextStyle(
            fontSize: 13.0,
            color: Colors.red,
            height: 1.0,
            fontWeight: FontWeight.w300),
      );
    } else {
      return new Container(
        height: 0.0,
      );
    }
  }

  Widget _showLogo() {
    /*
    return new Hero(
      tag: 'hero',
      child: FlutterLogo(size: 100.0),
    );
    */

    return Image(
        width: 100,
        height: 100,
        image: AssetImage(_critterImage)
    );
  }

  /*
  Widget _showEmailInput() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 100.0, 0.0, 0.0),
      child: new TextFormField(
        maxLines: 1,
        keyboardType: TextInputType.emailAddress,
        autofocus: false,
        decoration: new InputDecoration(
            hintText: 'Email',
            icon: new Icon(
              Icons.mail,
              color: Colors.grey,
            )),
        validator: (value) {
          if (value.isEmpty) {
            setState(() {
              _isLoading = false;
            });
            return 'Email can\'t be empty';
          }
        },
        onSaved: (value) => _email = value,
      ),
    );
  }
  */

  FocusNode _textFocus = FocusNode();
  FocusNode _textFocus2 = FocusNode();

  String _critterImage = '../assets/critter100x100/face.png';

  critter() {

    String img = '../assets/critter100x100/face.png';

    bool hasFocus = _textFocus.hasFocus;
    bool hasFocus2 = _textFocus2.hasFocus;

    if (hasFocus) {
      print('FOCUS ON USER ID');

      // 現在の入力値
      String s = _userIdController.text;
      int len = s.length;

      if (len >= 0 && len <= 3) {
        img = '../assets/critter100x100/normal/' + '0' + len.toString() + 'normal.png';
      } else if (len <= 9) {
        img = '../assets/critter100x100/openeye/' + '0' + len.toString() + 'openeye.png';
      } else if (len <= 20) {
        img = '../assets/critter100x100/openeye/' + len.toString() + 'openeye.png';
      } else {
        img = '../assets/critter100x100/openeye/20openeye.png';
      }

    } else {
      print('NOT FOCUS ON USER ID');
    }

    if (hasFocus2) {
      print('FOCUS ON PASSWORD');

      // 現在の入力値
      String s = _passwordController.text;
      int len = s.length;

      img = _obscurePasswordString == true ?
      '../assets/critter100x100/hide.png' :
      '../assets/critter100x100/peek.png';

    } else {
      print('NOT FOCUS ON PASSWORD');
    }


    setState(() {
      _critterImage = img;
    });
  }

  userIdListener () {
    print('current userId text is ${_userIdController.text}');
    critter();
  }

  passwordListener () {
    print('current userId text is ${_passwordController.text}');
    critter();
  }

  Widget _showUserIdInput() {
    return Padding(
        padding: const EdgeInsets.fromLTRB(40.0, 10.0, 60.0, 0.0),
        child: Container(width: 200, child:TextFormField(
          // initialValue: _userId == null ? '' : _userId,// ### 使用不可
            controller: _userIdController,
            focusNode: _textFocus,
            maxLines: 1,
            keyboardType: TextInputType.text,
            autofocus: false,
            decoration: InputDecoration(
                hintText: widget.labelUserID,
                icon: Icon(
                  Icons.tag_faces,
                  color: Colors.grey,
                )),
            validator: (value) {
              if (value.isEmpty) {
                setState(() {
                  _isLoading = false;
                });
                return widget.labelRequired;
              }
            },
            onSaved: (value) => _userId = value
        ),)
    );
  }

  bool _obscurePasswordString = true;

  Widget _showPasswordInput() {
    return Padding(
        padding: const EdgeInsets.fromLTRB(40.0, 10.0, 10.0, 0.0),
        child: Container(width: 200, child:TextFormField(
          // initialValue: _password == null ? '' : _password,
          controller: _passwordController,
          focusNode: _textFocus2,
          maxLines: 1,
          obscureText: _obscurePasswordString,
          autofocus: false,
          decoration: InputDecoration(
              hintText: widget.labelPassword,
              icon: new Icon(
                Icons.lock,
                color: Colors.grey,
              )),
          validator: (value) {
            if (value.isEmpty) {
              setState(() {
                _isLoading = false;
              });
              return widget.labelRequired;
            }
          },
          onSaved: (value) => _password = value,
        ),
        )
    );
  }

  /*
  Widget _showSecondaryButton() {
    return new FlatButton(
      child: _formMode == FormMode.LOGIN
          ? new Text('Create an account',
          style: new TextStyle(fontSize: 18.0, fontWeight: FontWeight.w300))
          : new Text('Have an account? Sign in',
          style:
          new TextStyle(fontSize: 18.0, fontWeight: FontWeight.w300)),
      onPressed: _formMode == FormMode.LOGIN
          ? _changeFormToSignUp
          : _changeFormToLogin,
    );
  }
  */

  Widget _showPrimaryButton() {
    return new Padding(
        padding: EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 20.0),
        child: SizedBox(
          height: 40.0,
          child: new RaisedButton(
            elevation: 5.0,
            shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
            color: Colors.teal,
            child: _formMode == FormMode.LOGIN
                ? new Text('Login',
                style: new TextStyle(fontSize: 20.0, color: Colors.white))
                : new Text('保存',
                style: new TextStyle(fontSize: 20.0, color: Colors.white)),
            onPressed: _validateAndSubmit,
          ),
        ));
  }

  void _showAlertMessage(BuildContext context, String title, String message, String yes) {
    // flutter defined function
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: new Text(title),
        content: new Text(message),
        actions: <Widget>[
          // usually buttons at the bottom of the dialog
          new FlatButton(
            child: new Text(yes),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  //---------------------------------
  // パスコード

  Widget _showPrimaryPasscodeButton() {
    return new Padding(
        padding: EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 20.0),
        child: SizedBox(
          height: 40.0,
          child: new RaisedButton(
            elevation: 5.0,
            shape: new RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
            color: Colors.teal,
            child: _formMode == FormMode.LOGIN
                ? new Text('Login',
                style: new TextStyle(fontSize: 20.0, color: Colors.white))
                : new Text('パスコード登録',
                style: new TextStyle(fontSize: 20.0, color: Colors.white)),
            onPressed: _gotoNewPasscodePage,
          ),
        ));
  }

  void _gotoNewPasscodePage() async {

    // パスコード編集時点のデータベース格納値を取得する。
    Account account = await Provider.of<CPTFAppInfo>(context).checkAccount();
    print(account);
    if (account == null) {
      _showAlertMessage(context, ''
          'エラー',
          'アカウント登録を先に実行して下さい。',
          'OK');
      return;
    }

    // ### 偏在の値
    setState(() {
      _userId = account.UserId;
      _password = account.Password;
      _passCode = account.SimplePassword;
    });

    // https://qiita.com/ryunosukeheaven/items/9e43298955a371221393
    print('push to new passcode input gage...');
    print(_userId);
    print(_password);
    print(_passCode == null ? 'NO PASSCODE' : _passCode);

    // Unhandled Exception: type 'MaterialPageRoute<dynamic>' is not a subtype of type 'Route<String>'
    String newPasscode = await Navigator.of(context).pushNamed('/newpasscode') as String;
    // ===> as String　の記述が必須。

    print('after new passcode input page...' + newPasscode);
    print('update passcode for user ' + _userId);
    setState(() {
      _passCode = newPasscode;
    });

    print('SAVE TO DATABASE');
    print(_userId);
    print(_password);
    print(newPasscode);

    Account entity = Account.fromMap({
      fUserId: _userId,
      fPassword: _password,
      fSimplePassword: newPasscode
    });
    Account saved = await Provider.of<CPTFAppInfo>(context).saveAccount(entity) as Account;
    print(saved.UserId);
    print(saved.Password);
    print(saved.SimplePassword);
    if (saved == null) {
      _showAlertMessage(context,
          'エラー',
          'アカウント登録に失敗しました。\nアプリを再起動してやり直して下さい。',
          'OK');
    } else {

      if (saved.SimplePassword == null || saved.SimplePassword == '') {

        _showAlertMessage(context,
            'エラー',
            'パスコード登録をやり直して下さい。',
            'OK');

      } else {

        _showAlertMessage(context,
            'パスコード登録',
            'ユーザ： ${saved.UserId} にパスコードを設定しました。',
            'OK');

        // 画面繊維はダイアログのボタンハンドラですること。
        // Navigator.of(context).pop();
      }
    }
  }
}