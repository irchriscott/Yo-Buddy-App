import 'package:flutter/material.dart';
import 'dart:async';
import 'login.dart';
import 'package:buddyapp/providers/session.dart';
import 'tabs.dart';

class SplashScreenPage extends StatefulWidget{
    @override
    _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreenPage> with SingleTickerProviderStateMixin{
    
    final String title = "Yo Buddy";
    bool isLoggedIn = false;

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
        return Material(
            color: Color(0xFFCC8400),
            child: Hero(
                tag: "splash",
                child: InkWell(
                    onTap: _onTap,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                            Container(
                                width: 70.0,
                                height: 70.0,
                                padding: EdgeInsets.only(bottom: 15.0),
                                child: Image(
                                    image: AssetImage("assets/images/yobuddy.png"),
                                    fit: BoxFit.fitHeight
                                ),
                            ),
                            Text(
                                this.title.toUpperCase(),
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: _fontAnimation.value * 40.0,
                                    fontWeight: FontWeight.bold
                                ),
                            )
                        ],
                    ),
                )
            )
        );
    } 
}