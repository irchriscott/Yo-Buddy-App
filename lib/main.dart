import 'package:flutter/material.dart';
import 'pages/splash.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  
    @override
    Widget build(BuildContext context) {
        return new MaterialApp(
            title: 'YO BUDDY',
            theme: new ThemeData(
                primaryColor: Color(0xFFCC8400),
                brightness: Brightness.light,
                primarySwatch: Colors.orange,
                fontFamily: 'didact'
            ),
            home: SplashScreenPage()
        );
    }
}

