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
            builder: (context, child) =>
                MediaQuery(data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true), child: child),
            home: SplashScreenPage()
        );
    }
}

