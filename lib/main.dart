import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:password_manager/loginscreen.dart';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_gradients/flutter_gradients.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var document = await getApplicationDocumentsDirectory();
  Hive.init(document.path);
  await Hive.openBox("passwords");
  await Hive.openBox("users");
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Password Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.blueGrey,
        brightness: Brightness.light,
      ),
      home: FirstPage(),
    );
  }
}

class FirstPage extends StatefulWidget {
  @override
  _FirstPageState createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  @override
  void initState() {
    super.initState();
    Timer(
        Duration(seconds: 3),
        () => Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (BuildContext context) => LoginScreen())));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0.0),
          ),
          gradient: FlutterGradients.warmFlame(
            tileMode: TileMode.decal,
            type: GradientType.sweep,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock,
                size: 250.0,
              ),
              Text(
                "Password Manager",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 35.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
