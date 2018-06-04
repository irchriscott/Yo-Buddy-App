import 'dart:async';
import 'package:flutter/material.dart';
import '../providers/app.dart';
import '../providers/auth.dart';
import '../UI/popup.dart';
import '../pages/tabs.dart';

class LoginPage extends StatefulWidget{
    @override
    _LoginPageState createState() => new _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin{

    AnimationController _loginButtonController;
    var animationStatus = 0;

    @override
    void initState(){
        super.initState();
        _loginButtonController = new AnimationController(duration: new Duration(milliseconds: 3000), vsync: this);
    }

    @override
    void dispose() {
        _loginButtonController.dispose();
        super.dispose();
    }

    Future<Null> _playAnimation() async {
        setState(() {
            animationStatus = 1;
        });
        try {
            await _loginButtonController.forward();
            await _loginButtonController.reverse();
        } on TickerCanceled {}
    }

    final String title = "yo buddy";
    bool isOverlayVisible = false;
    String _message = "message";
    String _type = "error";

    TextEditingController email = new TextEditingController();
    TextEditingController password = new TextEditingController();
    
    void authenticateUser()  {
        _playAnimation();
        var auth = Authentication().authenticate(email.text, password.text);
        auth.then((value){
            if(value.type == "error"){
                AppProvider().alert(context, "Error", value.text);
                this.setState((){
                    animationStatus = 0;
                });
            } else {
                this.setState((){
                    this._message = value.text;
                    this._type = value.type;
                    this.isOverlayVisible = true;
                    animationStatus = 0;
                });
            }
        });
    }

    final VoidCallback navigateSignup = (){
        print("GREAT");
    };

    @override
    Widget build(BuildContext context){

        return new Stack(
            fit: StackFit.expand,
            children: <Widget>[
                Scaffold(
                    backgroundColor: Colors.white,
                    body: Center(
                        child: ListView(
                            shrinkWrap: true,
                            padding: EdgeInsets.only(left: 20.0, right: 20.0),
                            children: <Widget>[
                                Hero(
                                    tag: 'hero',
                                    child: Center(
                                        child: new Text(
                                            title.toUpperCase(),
                                            style: new TextStyle(
                                                fontSize: 45.0, 
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFFCC8400)
                                            ),
                                        ),
                                    ) ,
                                ),
                                SizedBox(height: 48.0,),
                                TextFormField(
                                    controller: email,
                                    keyboardType: TextInputType.emailAddress,
                                    autofocus: false,
                                    style: TextStyle(
                                        fontSize: 20.0,
                                        color: Colors.black
                                    ),
                                    decoration: InputDecoration(
                                        hintText: 'Enter Email Address',
                                        contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                                        hintStyle: TextStyle(color: Color(0x99999999)),
                                        border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10.0)
                                        )
                                    ),
                                ),
                                SizedBox(height: 8.0),
                                TextFormField(
                                    controller: password,
                                    autofocus: false,
                                    obscureText: true,
                                    style: TextStyle(
                                        fontSize: 20.0,
                                        color: Colors.black
                                    ),
                                    decoration: InputDecoration(
                                        hintText: 'Enter Password',
                                        contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                                        hintStyle: TextStyle(color: Color(0x99999999)),
                                        border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10.0)
                                        )
                                    ),
                                ),
                                SizedBox(height: 10.0),
                                (animationStatus == 0) ? InkWell(
                                    child: Padding(
                                        padding: EdgeInsets.symmetric(vertical: 20.0),
                                        child: Material(
                                            borderRadius: BorderRadius.circular(10.0),
                                            shadowColor: Color(0x66666666),
                                            elevation: 5.0,
                                            child: Container(
                                                color: Color(0xFFCC8400),
                                                child: Center(
                                                    child: Text(
                                                        'Log In'.toUpperCase(),
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 18.0
                                                        ),
                                                    ),
                                                ),
                                                height: 45.0
                                            ),
                                        ),
                                    ),
                                    onTap: () => authenticateUser(),
                                ) : Padding(
                                    padding: EdgeInsets.symmetric(vertical: 20.0),
                                    child: Center(
                                        child: Material(
                                            elevation: 5.0,
                                            shadowColor: Color(0xFF666666),
                                            borderRadius: BorderRadius.circular(22.5),
                                            child: Container(
                                                padding: EdgeInsets.all(8.0),
                                                height: 37.0,
                                                width: 37.0,
                                                decoration: BoxDecoration(
                                                    color: Color(0xFFCC8400),
                                                    shape: BoxShape.circle
                                                ),
                                                child: CircularProgressIndicator(
                                                    backgroundColor: Color(0xFFFFFFFF),
                                                    strokeWidth: 1.0
                                                ),
                                            ),
                                        )
                                    ),
                                ),
                                FlatButton(
                                    child: Text(
                                        'Forgot your password ?',
                                        style: TextStyle(
                                            color: Colors.black45,
                                            fontSize: 18.0
                                        ),
                                    ),
                                    onPressed: (){},
                                ),
                                Padding(
                                    padding: EdgeInsets.symmetric(vertical: 20.0),
                                    child: Material(
                                        borderRadius: BorderRadius.circular(0.0),
                                        elevation: 5.0,
                                        child: OutlineButton(
                                            color: Colors.white,
                                            padding: EdgeInsets.only(top: 12.0, bottom: 12.0),
                                            child: Text(
                                                'Sign Up'.toUpperCase(),
                                                style: TextStyle(
                                                    color: Color(0xFFCC8400),
                                                    fontSize: 18.0
                                                ),
                                            ),
                                            borderSide: BorderSide(
                                                style: BorderStyle.solid, 
                                                color: Color(0xFFCC8400),
                                                width: 5.0
                                            ),
                                            textColor: Color(0xFFCC8400),
                                            onPressed: (){
                                                navigateSignup();
                                            },
                                        ),
                                    ),
                                )
                            ],
                        ),
                    ),
                ),
                isOverlayVisible == true ? PopupOverlay(
                  message: this._message, 
                  type: this._type, 
                  onTap: (){
                      this.isOverlayVisible = false;
                      Navigator.of(context).push(new MaterialPageRoute(builder: (BuildContext context) => new TabsPage()));
                  }) : Container(),
            ],
        );
    }
}