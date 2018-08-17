import 'package:flutter/material.dart';
import 'package:buddyapp/pages/splash.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  
    @override
    Widget build(BuildContext context) {
        return new MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'YO BUDDY',
            theme: new ThemeData(
                primaryColor: Color(0xFFCC8400),
                brightness: Brightness.light,
                primarySwatch: Colors.orange,
                fontFamily: 'poppins'
            ),
            home: SplashScreenPage()
        );
    }
}

