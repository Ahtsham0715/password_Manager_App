import 'dart:async';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_gradients/flutter_gradients.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:password_manager/loginscreen.dart';
import 'package:flutter/services.dart';
import 'package:icons_helper/icons_helper.dart';

class passwordspage extends StatefulWidget {
  final String currentuser;
  passwordspage(this.currentuser);
  @override
  _passwordspageState createState() => _passwordspageState();
}

class _passwordspageState extends State<passwordspage> {
  Box box;
  Box users;

  final _myformKey = GlobalKey<FormState>();

  Widget custominfodialog() {
    return AlertDialog(
      actions: [
        Text(
          "Long press on Password Tile to delete it",
          style: TextStyle(
            fontSize: 20.0,
            // color: Colors.white,
          ),
        ),
        Center(
          child: Container(
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
          ),
        )
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    box = Hive.box("passwords");
    users = Hive.box("users");
    Timer.run(() {
      showDialog(context: context, builder: (_) => custominfodialog());
    });
  }

  TextEditingController password = new TextEditingController();
  TextEditingController appname = new TextEditingController();

  Widget deletepassword(dltappname) {
    return AlertDialog(
      insetPadding: EdgeInsets.all(50.0),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              decoration: ShapeDecoration(
                shape: StadiumBorder(),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white54,
                    Colors.grey[400],
                  ],
                ),
              ),
              child: MaterialButton(
                shape: StadiumBorder(),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'No',
                  style: TextStyle(
                    fontSize: 20.0,
                    // color: Colors.white,
                  ),
                ),
                // color: Colors.white70,
                hoverColor: Colors.black,
              ),
            ),
            Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.1)),
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
                  box.delete(dltappname);
                  Navigator.pop(context);
                  final snackBar = SnackBar(
                    content: Text(
                      'Password Deleted Successfully',
                      style: TextStyle(
                        fontSize: 20.0,
                        color: Colors.white,
                      ),
                    ),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                },
                child: Text(
                  'Confirm',
                  style: TextStyle(
                    fontSize: 20.0,
                    color: Colors.white,
                  ),
                ),
                // color: Colors.red,
                hoverColor: Colors.black,
              ),
            ),
          ],
        ),
      ],
      title: Center(
        child: Text(
          'Are you sure??? ',
          style: TextStyle(
            fontSize: 20.0,
            // color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget customwidget(name, pass) {
    var myappname = name.toString().toLowerCase().trim();
    return Container(
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(),
        gradient: FlutterGradients.solidStone(),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
        minLeadingWidth: 50.0,
        title: Text(
          '$name',
          style: TextStyle(
            fontSize: 25.0,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Text(
            'Click Icon to copy your password to clipboard',
            style: TextStyle(
              fontSize: 16.0,
              color: Colors.white,
            ),
          ),
        ),
        leading: Icon(
          getIconUsingPrefix(name: "fa." + myappname),
          size: 40.0,
          color: Colors.white,
        ),
        trailing: IconButton(
          onPressed: () {
            Clipboard.setData(ClipboardData(text: pass)).then((value) {
              final snackBar = SnackBar(
                content: Text(
                  'Password copied to clipboard',
                  style: TextStyle(
                    fontSize: 19.0,
                    color: Colors.white,
                  ),
                ),
              );
              ScaffoldMessenger.of(context).showSnackBar(snackBar);
            });
          },
          tooltip: "Copy Password",
          icon: Icon(
            Icons.copy,
            size: 50.0,
            color: Colors.white,
          ),
        ),
        onLongPress: () {
          showDialog(context: context, builder: (_) => deletepassword(name));
        },
      ),
    );
  }

  Widget deleteccountdialogbox() {
    return AlertDialog(
      actions: [
        Padding(padding: EdgeInsets.all(10.0)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              decoration: ShapeDecoration(
                shape: StadiumBorder(),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white54,
                    Colors.grey[400],
                  ],
                ),
              ),
              child: MaterialButton(
                shape: StadiumBorder(),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'No',
                  style: TextStyle(
                    fontSize: 20.0,
                    // color: Colors.white,
                  ),
                ),
                // color: Colors.white70,
                hoverColor: Colors.black,
              ),
            ),
            Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.1)),
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
                  users.clear();
                  box.clear();
                  Navigator.pop(context);
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (BuildContext context) => LoginScreen()));
                  final snackBar = SnackBar(
                    content: Text(
                      'Account deleted Successfully',
                      style: TextStyle(
                        fontSize: 20.0,
                        color: Colors.white,
                      ),
                    ),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(snackBar);
                },
                child: Text(
                  'Confirm',
                  style: TextStyle(
                    fontSize: 20.0,
                    color: Colors.white,
                  ),
                ),
                // color: Colors.red,
                hoverColor: Colors.black,
              ),
            ),
          ],
        ),
      ],
      title: Center(
        child: Text(
          'Do you want to delete your account',
          style: TextStyle(
            fontSize: 20.0,
            // color: Colors.white,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 110.0,
        centerTitle: true,
        title: Text(
          widget.currentuser,
          style: TextStyle(
            fontSize: 25.0,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          onPressed: () {
            showDialog(
                context: context,
                builder: (_) => AlertDialog(
                      actions: [
                        Padding(padding: EdgeInsets.all(5.0)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Container(
                              decoration: ShapeDecoration(
                                shape: StadiumBorder(),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.white54,
                                    Colors.grey[400],
                                  ],
                                ),
                              ),
                              child: MaterialButton(
                                shape: StadiumBorder(),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  'No',
                                  style: TextStyle(
                                    fontSize: 20.0,
                                    // color: Colors.white,
                                  ),
                                ),
                                hoverColor: Colors.black,
                              ),
                            ),
                            Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal:
                                        MediaQuery.of(context).size.width *
                                            0.12)),
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
                                  box.clear();
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  'Confirm',
                                  style: TextStyle(
                                    fontSize: 20.0,
                                    color: Colors.white,
                                  ),
                                ),
                                hoverColor: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ],
                      title: Center(
                        child: Text(
                          'Do you want to delete all saved passwords??? ',
                          style: TextStyle(
                            fontSize: 20.0,
                            // color: Colors.white,
                          ),
                        ),
                      ),
                    ));
          },
          icon: Icon(
            Icons.delete,
            size: 30.0,
          ),
          // color: Colors.black,
          tooltip: "Delete all",
        ),
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                  context: context, builder: (_) => deleteccountdialogbox());
            },
            tooltip: "Delete Account",
            icon: Icon(
              Icons.person_remove,
              size: 30.0,
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                    builder: (BuildContext context) => LoginScreen())),
            icon: Icon(
              Icons.logout,
              size: 30.0,
            ),
            // color: Colors.black,
            tooltip: "Logout",
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (_) => AlertDialog(
                    insetPadding: EdgeInsets.all(30.0),
                    actions: [
                      Form(
                        key: _myformKey,
                        child: Column(
                          children: [
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.85,
                              child: TextFormField(
                                controller: appname,
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                validator: RequiredValidator(
                                    errorText: "appname Required"),
                                decoration: InputDecoration(
                                  labelText: 'App name',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                              ),
                            ),
                            Padding(padding: EdgeInsets.all(5.0)),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.85,
                              child: TextFormField(
                                controller: password,
                                obscureText: true,
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                validator: RequiredValidator(
                                    errorText: "Password Required"),
                                decoration: InputDecoration(
                                  labelText: 'password',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(padding: EdgeInsets.all(5.0)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            decoration: ShapeDecoration(
                              shape: StadiumBorder(),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.deepPurple,
                                  Colors.blue,
                                ],
                              ),
                            ),
                            child: MaterialButton(
                              onPressed: () {
                                if (_myformKey.currentState.validate()) {
                                  box.put(appname.text, password.text);
                                  Navigator.of(context).pop();
                                  appname.clear();
                                  password.clear();
                                }
                              },
                              child: Text(
                                'Update',
                                style: TextStyle(
                                  fontSize: 20.0,
                                  color: Colors.white,
                                ),
                              ),
                              hoverColor: Colors.black,
                              shape: StadiumBorder(),
                            ),
                          ),
                          Container(
                            decoration: ShapeDecoration(
                              shape: StadiumBorder(),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.yellow,
                                  Colors.green,
                                ],
                              ),
                            ),
                            child: MaterialButton(
                              onPressed: () {
                                if (_myformKey.currentState.validate()) {
                                  box.put(appname.text, password.text);
                                  appname.clear();
                                  password.clear();
                                  Navigator.pop(context);
                                }
                              },
                              child: Text(
                                'Add',
                                style: TextStyle(
                                  fontSize: 20.0,
                                  color: Colors.white,
                                ),
                              ),
                              hoverColor: Colors.black,
                              shape: StadiumBorder(),
                            ),
                          ),
                        ],
                      ),
                    ],
                    title: Center(
                      child: Text(
                        'Add new password',
                        style: TextStyle(
                          fontSize: 20.0,
                          // color: Colors.white,
                        ),
                      ),
                    ),
                    contentPadding: EdgeInsets.all(25.0),
                  ));
        },
        tooltip: "Add, update and delete password",
        child: Icon(
          Icons.add,
        ),
        backgroundColor: Colors.blueGrey,
      ),
      body: ValueListenableBuilder(
        valueListenable: box.listenable(),
        builder: (context, Box passwords, _) {
          if (passwords.keys.toList().length == 0) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.no_encryption,
                      size: 100.0,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    "No Passwords to show.\nclick '+' button to add\nnew password",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 25.0,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            );
          } else {
            return ListView.separated(
              itemBuilder: (context, index) {
                final key = passwords.keys.toList()[index];
                final value = passwords.get(key);
                return customwidget(key, value);
              },
              separatorBuilder: (_, index) => Divider(
                thickness: 0.1,
                height: 5.0,
              ),
              itemCount: passwords.keys.toList().length,
            );
          }
        },
      ),
    );
  }
}
