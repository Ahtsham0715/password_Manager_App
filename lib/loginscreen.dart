import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gradients/flutter_gradients.dart';
import 'package:password_manager/password.dart';
import 'package:password_manager/resetpassword.dart';
import 'package:password_manager/signupscreen.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:crypto/crypto.dart';
import 'package:mailer2/mailer.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:math';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  Box usersbox;
  Box passwords;

  bool submitValid = false;

  final LocalAuthentication auth = LocalAuthentication();
  bool _canCheckBiometrics = false;
  List<BiometricType> _availableBiometrics;
  String _authorized = 'Not Authorized';
  bool _isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    usersbox = Hive.box("users");
    passwords = Hive.box("passwords");
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    bool canCheckBiometrics;
    try {
      canCheckBiometrics = await auth.canCheckBiometrics;
    } on PlatformException catch (e) {
      canCheckBiometrics = false;
      print(e);
    }
    if (!mounted) return;

    setState(() {
      _canCheckBiometrics = canCheckBiometrics;
    });
  }

  Future<void> _getAvailableBiometrics() async {
    List<BiometricType> availableBiometrics;
    try {
      availableBiometrics = await auth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      availableBiometrics = <BiometricType>[];
      print(e);
    }
    if (!mounted) return;

    setState(() {
      _availableBiometrics = availableBiometrics;
      print(_availableBiometrics);
    });
  }

  Future<void> _authenticate() async {
    bool authenticated = false;
    try {
      setState(() {
        _isAuthenticating = true;
        _authorized = 'Authenticating';
      });
      authenticated = await auth.authenticate(
          localizedReason: 'Let OS determine authentication method',
          options: AuthenticationOptions(
             useErrorDialogs: true,
          stickyAuth: true
          ),
         );
      setState(() {
        _isAuthenticating = false;
      });
    } on PlatformException catch (e) {
      print(e);
      setState(() {
        _isAuthenticating = false;
        _authorized = "Error - ${e.message}";
      });
      return;
    }
    if (!mounted) return;

    setState(
        () => _authorized = authenticated ? 'Authorized' : 'Not Authorized');
  }

  Future<void> _authenticateWithBiometrics() async {
    bool authenticated = false;
    try {
      setState(() {
        _isAuthenticating = true;
        _authorized = 'Authenticating';
      });
      authenticated = await auth.authenticate(
          localizedReason: 'Scan your fingerprint to authenticate',
          options: AuthenticationOptions(
            useErrorDialogs: true,
          stickyAuth: true,
          biometricOnly: true
          )
          );
      setState(() {
        _isAuthenticating = false;
        _authorized = 'Authenticating';
      });
    } on PlatformException catch (e) {
      print(e);
      setState(() {
        _isAuthenticating = false;
        _authorized = "Error - ${e.message}";
        print(_authorized);
        // Navigator.of(context).pushReplacement(MaterialPageRoute(
        //     builder: (BuildContext context) =>
        //         passwordspage(usersbox.getAt(0))));
      });
      return;
    }
    if (!mounted) return;

    final String message = authenticated ? 'Authorized' : 'Not Authorized';
    setState(() {
      _authorized = message;
      print(message);
      if (_authorized == 'Authorized') {
        if (usersbox.keys.toList().length != 0) {
          Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (BuildContext context) =>
                  passwordspage(usersbox.keyAt(0))));
        } else {
          showDialog(
              context: context,
              builder: (_) => customerrordialog("Account doesn't exist"));
          // _authenticateWithBiometrics();
        }
      }
    });
  }

  final _loginkey = GlobalKey<FormState>();
  final _emailkey = GlobalKey<FormState>();

  TextEditingController enteredusername = new TextEditingController();
  TextEditingController enteredpassword = new TextEditingController();
  TextEditingController _emailcontroller = TextEditingController();
  TextEditingController _otpcontroller = TextEditingController();

  var otp;

  void customsnackbar(texttodisplay) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          texttodisplay,
          style: TextStyle(
            fontSize: 20.0,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void hashfunction(data) {
    print('hash function called');
    var hashed = sha256.convert(utf8.encode(data));
    print("$hashed");
  }

  void verify() {
    print("verify function");
    if (otp.toString() == _otpcontroller.text) {
      _emailcontroller.clear();
      _otpcontroller.clear();
      Navigator.pop(context);
      otp = 0;
      Navigator.of(context).push(MaterialPageRoute(
        builder: (BuildContext context) => ResetPassword(),
      ));
    } else {
      customsnackbar("Invalid OTP...Try again");
    }
  }

  ///a void funtion to send the OTP to the user
  void sendOtp() async {
    if (_emailkey.currentState.validate()) {
      otp = Random().nextInt(99999 - 13333);
      var options = new GmailSmtpOptions()
        ..username = 'mymanager1123@gmail.com'
        ..password = 'bhakkar43';
      var emailTransport = new SmtpTransport(options);

      // Create our mail/envelope.
      var envelope = new Envelope()
        ..from = 'mymanager1123@gmail.com'
        ..recipients.add(_emailcontroller.text)
        ..subject = 'Password reset verification'
        ..text =
            'This email is in the reponse of your reset password request in our password manager app. please verify the given OTP\n\n $otp';

      // Email it.
      emailTransport
          .send(envelope)
          .then((envelope) => {
                print('Email sent!'),
                customsnackbar(
                    'Email sent successfully check spam folder if not found in inbox'),
              })
          .catchError((e) => {
                print('Error occurred: $e'),
                customsnackbar(
                    'Error occurred while sending email. please try again'),
              });
    }
  }

  Widget deleteccountdialogbox() {
    return AlertDialog(
      title: Center(
        child: Text(
          'Verify Your Email',
          style: TextStyle(
            fontSize: 20.0,
            // color: Colors.white,
          ),
        ),
      ),
      actions: [
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.85,
          child: Form(
            key: _emailkey,
            child: TextFormField(
              controller: _emailcontroller,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (val) => MatchValidator(
                      errorText: "email doesn't match with provided one")
                  .validateMatch(val, usersbox.get('user_email')),
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
          ),
        ),
        Center(
          child: Padding(
            padding: EdgeInsets.all(15.0),
            child: TextButton(
              onPressed: () {
                sendOtp();
              },
              child: Text(
                "Send OTP",
                style: TextStyle(
                  color: Colors.blueGrey,
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.85,
          child: TextFormField(
            controller: _otpcontroller,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: RequiredValidator(errorText: "OTP required"),
            decoration: InputDecoration(
              labelText: 'OTP',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Center(
            child: TextButton(
              onPressed: () {
                verify();
              },
              child: Text(
                'Submit',
                style: TextStyle(
                  fontSize: 20.0,
                  color: Colors.blueGrey,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget customerrordialog(errtext) {
    return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0)),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.35,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 70, 10, 10),
                child: Column(
                  children: [
                    Text(
                      'Warning !!!',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.035,
                    ),
                    Text(
                      errtext,
                      style: TextStyle(fontSize: 22),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.06,
                    ),
                    Container(
                      decoration: ShapeDecoration(
                        shape: StadiumBorder(),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.orangeAccent,
                            Colors.redAccent,
                          ],
                        ),
                      ),
                      child: MaterialButton(
                        shape: StadiumBorder(),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        // color: Colors.redAccent,
                        child: Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 25.0,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            Positioned(
                top: -60,
                child: CircleAvatar(
                  backgroundColor: Colors.redAccent,
                  radius: 60,
                  child: Icon(
                    Icons.assistant_photo,
                    color: Colors.white,
                    size: 50,
                  ),
                )),
          ],
        ));
  }

  void signing(uname, passw) {
    var rpass = usersbox.get(uname);
    var hashedpass = sha256.convert(utf8.encode(passw));
    print(hashedpass);
    if (_loginkey.currentState.validate()) {
      if (rpass != null && rpass == hashedpass.toString()) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (BuildContext context) => passwordspage(uname)));
      } else if (rpass == null) {
        showDialog(
            context: context,
            builder: (_) => customerrordialog("Account doesn't exist"));
      } else {
        showDialog(
            context: context,
            builder: (_) => customerrordialog("Incorrect Password"));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.13,
            width: MediaQuery.of(context).size.width,
            decoration: ShapeDecoration(
              shape: RoundedRectangleBorder(),
              gradient: FlutterGradients.warmFlame(
                tileMode: TileMode.clamp,
                type: GradientType.linear,
              ),
            ),
            margin: EdgeInsets.only(
                bottom: MediaQuery.of(context).size.height * 0.04),
            child: Center(
              child: Text(
                'Password Manager',
                style: TextStyle(
                  fontSize: 30.0,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Sign In',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(15.0),
                ),
                Form(
                  key: _loginkey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.85,
                        child: TextFormField(
                          controller: enteredusername,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator:
                              RequiredValidator(errorText: "Username Required"),
                          decoration: InputDecoration(
                            labelText: 'Username',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.85,
                        child: TextFormField(
                          controller: enteredpassword,
                          obscureText: true,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator:
                              RequiredValidator(errorText: "Password Required"),
                          decoration: InputDecoration(
                            labelText: 'Password',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(35.0),
                      ),
                      !_canCheckBiometrics
                          ? Container(
                              width: MediaQuery.of(context).size.width * 0.85,
                              height:
                                  MediaQuery.of(context).size.height * 0.065,
                              decoration: ShapeDecoration(
                                shape: StadiumBorder(),
                                gradient: FlutterGradients.warmFlame(
                                  tileMode: TileMode.clamp,
                                  type: GradientType.linear,
                                ),
                              ),
                              child: MaterialButton(
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                shape: StadiumBorder(),
                                onPressed: () => signing(
                                    enteredusername.text, enteredpassword.text),
                                child: Text(
                                  'Sign In',
                                  style: TextStyle(
                                    fontSize: 20.0,
                                    // color: Colors.white,
                                  ),
                                ),
                                hoverColor: Colors.black,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.65,
                                  height: MediaQuery.of(context).size.height *
                                      0.065,
                                  margin: EdgeInsets.symmetric(horizontal: 7.0),
                                  decoration: ShapeDecoration(
                                    shape: StadiumBorder(),
                                    gradient: FlutterGradients.warmFlame(
                                      tileMode: TileMode.clamp,
                                      type: GradientType.linear,
                                    ),
                                  ),
                                  child: MaterialButton(
                                    materialTapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    shape: StadiumBorder(),
                                    onPressed: () => signing(
                                        enteredusername.text,
                                        enteredpassword.text),
                                    child: Text(
                                      'Sign In',
                                      style: TextStyle(
                                        fontSize: 20.0,
                                        // color: Colors.white,
                                      ),
                                    ),
                                    hoverColor: Colors.black,
                                  ),
                                ),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.15,
                                  height: MediaQuery.of(context).size.height *
                                      0.075,
                                  decoration: ShapeDecoration(
                                    shape: StadiumBorder(),
                                    // gradient: FlutterGradients.warmFlame(
                                    //   tileMode: TileMode.clamp,
                                    //   type: GradientType.linear,
                                    // ),
                                  ),
                                  child: IconButton(
                                    onPressed: () {
                                      _authenticateWithBiometrics();
                                    },
                                    tooltip: "Fingerprint Login",
                                    icon: Icon(
                                      Icons.fingerprint_sharp,
                                      color: Colors.black,
                                      size: 45.0,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(25.0),
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.85,
                  height: MediaQuery.of(context).size.height * 0.06,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have account? ",
                        style: TextStyle(
                          fontSize: 20.0,
                          // color: Colors.blue[700],
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  SignupScreen()));
                        },
                        child: Text(
                          'Sign Up',
                          style: TextStyle(
                            fontSize: 20.0,
                            color: Colors.blue[800],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.07,
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.85,
                  height: MediaQuery.of(context).size.height * 0.06,
                  decoration: ShapeDecoration(
                    shape: StadiumBorder(),
                    gradient: FlutterGradients.colorfulPeach(),
                  ),
                  child: MaterialButton(
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: StadiumBorder(),
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (_) => deleteccountdialogbox());
                      // Navigator.of(context).push(MaterialPageRoute(
                      //   builder: (BuildContext context) => ResetPassword(),
                      // ));
                    },
                    child: Text(
                      'Forgot Password',
                      style: TextStyle(
                        fontSize: 18.0,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
