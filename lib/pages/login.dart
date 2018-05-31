import 'package:flutter/material.dart';
import '../providers/app.dart';
import '../providers/auth.dart';
import '../UI/popup.dart';
import '../pages/tabs.dart';

class LoginPage extends StatefulWidget{
    @override
    _LoginPageState createState() => new _LoginPageState();
}

class _LoginPageState extends State<LoginPage>{

    @override
    void initState(){
        super.initState();
    }

    final String title = "yo buddy";
    bool isOverlayVisible = false;
    String _message = "message";
    String _type = "error";

    TextEditingController email = new TextEditingController();
    TextEditingController password = new TextEditingController();
    
    void authenticateUser()  {
        var auth = Authentication().authenticate(email.text, password.text);
        auth.then((value){
            if(value.type == "error"){
                AppProvider().alert(context, "Error", value.text);
            } else {
                this.setState((){
                    this._message = value.text;
                    this._type = value.type;
                    this.isOverlayVisible = true;
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
                                Padding(
                                    padding: EdgeInsets.symmetric(vertical: 20.0),
                                    child: Material(
                                        borderRadius: BorderRadius.circular(4.0),
                                        shadowColor: Color(0x66666666),
                                        elevation: 5.0,
                                        child: MaterialButton(
                                            color: Color(0xFFCC8400),
                                            child: Text(
                                                'Log In'.toUpperCase(), 
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 18.0
                                                ),
                                            ),
                                            minWidth: 200.0,
                                            height: 45.0,
                                            onPressed: (){
                                                authenticateUser();
                                            },
                                        ),
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
                                        borderRadius: BorderRadius.circular(4.0),
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