import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:firebase_core/firebase_core.dart';
import 'package:menu_denario/initial_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
        apiKey: "AIzaSyCGgaI2hxuYbr8yiqHuPStscPHlV08pmso",
        appId: "1:414051585564:web:1a01eea9c4ed991ae459d9",
        messagingSenderId: "414051585564",
        projectId: "cafe-galia"),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Mi Denario',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            primarySwatch: Colors.grey,
            colorScheme: const ColorScheme.light().copyWith(
              background: Colors.white,
            )),
        home: InitialConfig(Uri.base.queryParameters[
            'id'])); //Uri.base.queryParameters['id'])); //'VTam7iYZhiWiAFs3IVRBaLB5s3m2'
  }
}
