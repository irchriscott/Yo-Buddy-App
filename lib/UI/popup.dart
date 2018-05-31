import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class PopupOverlay extends StatefulWidget{
    const PopupOverlay({
        Key key,
        @required this.type,
        @required this.message,
        @required this.onTap
    }):super(key:key);

    final String type;
    final String message;
    final VoidCallback onTap;

    @override
    _PopupOverlayState createState() => _PopupOverlayState(type: this.type, message: this.message);
}

class _PopupOverlayState extends State<PopupOverlay> with SingleTickerProviderStateMixin{
    
    _PopupOverlayState({@required this.type, @required this.message});

    Animation<double> _iconAnimation;
    AnimationController _iconAnimationController;

    @override
    void initState(){
        super.initState();
        _iconAnimationController = new AnimationController(duration: new Duration(seconds: 2), vsync: this);
        _iconAnimation = new CurvedAnimation(parent: _iconAnimationController, curve: Curves.elasticOut);
        _iconAnimation.addListener(() => setState((){}));
        _iconAnimationController.forward();
    }
    
    final String type;
    final String message;

    @override
    Widget build(BuildContext context){
        return new Material(
            color: Color.fromRGBO(0,0,0,0.7),
            child: InkWell(
                onTap: widget.onTap,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                        Container(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle
                            ),
                            child: Transform.rotate(
                                angle: _iconAnimation.value * 2 * pi,
                                child: Icon(this.type == "success" ? Icons.done : Icons.clear, color: Color(0xFFCC8400), size: _iconAnimation.value * 80.0,)
                            )
                        ),
                        Padding(padding: EdgeInsets.only(bottom: 20.0),),
                        Text(
                            this.message,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 25.0,
                           ),
                        )
                    ],
                ),
            ),
        );
    }
}