import 'package:flutter/material.dart';
import 'dart:async';
import 'login.dart';
import '../providers/session.dart';
import 'tabs.dart';

class SplashScreenPage extends StatefulWidget{
    @override
    _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreenPage> with SingleTickerProviderStateMixin{
    
    final String title = "yo boddy";
    bool isLoggedIn;

    Animation<double> _fontAnimation;
    AnimationController _fontAnimationController;

    @override
    void initState(){
        super.initState();
        _fontAnimationController = new AnimationController(duration: new Duration(milliseconds: 500), vsync: this);
        _fontAnimation = new CurvedAnimation(parent: _fontAnimationController, curve: Curves.bounceOut);
        _fontAnimation.addListener(() => setState((){}));
        _fontAnimationController.forward();
        Timer(Duration(seconds: 5), (){ _onTap(); });
        
        DatabaseHelper().isLoggedIn().then((value){
            this.isLoggedIn = value;
        });
    }

    void _onTap(){ 
        Navigator.push(
            context, 
            new MaterialPageRoute(builder: (BuildContext context) => this.isLoggedIn ? TabsPage() : LoginPage())
        );
    }

    @override
    Widget build(BuildContext context){
        return new Material(
            color: Color(0xFFCC8400),
            child: new InkWell(
                onTap: _onTap,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                        Text(
                            this.title.toUpperCase(),
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: _fontAnimation.value * 50.0,
                                fontWeight: FontWeight.bold
                            ),
                        )
                    ],
                ),
            )
        );
    } 
}