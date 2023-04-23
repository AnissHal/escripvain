import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:escripvain/api/requests.dart';
import 'package:escripvain/constants.dart';
import 'package:escripvain/pages/home_page.dart';
import 'package:escripvain/pages/startup_page.dart';
import 'package:uuid/uuid.dart';

import 'models/user.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();

  uuid = prefs.getString('token');

  if (uuid == null) {
    String uuidGen = const Uuid().v4();
    uuid = uuidGen;
    prefs.setString('token', uuidGen);
  }

  String? userPref = prefs.getString('user');
  if (userPref != null) {
    user = User.fromApi(jsonDecode(userPref));
  } else {
    fetchUser(uuid as String).then((value) {
      if (value != null) {
        user = value;
      } else {
        prefs.remove('user');
        user = null;
      }
    });
  }
  // print(user);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reconnaissance automatique de la parole',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: user == null ? const StartupPage() : const HomePage(),
    );
  }
}
