import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class LoadingOverlay extends StatefulWidget{
    @override
    _LoadingOverlayState createState() => _LoadingOverlayState();
}

class _LoadingOverlayState extends State<LoadingOverlay>{
    @override
    Widget build(BuildContext context) {
        return new Material(
            color: Color.fromRGBO(0,0,0,0.7),
            child: Container(
                child: Center(
                    child: CupertinoActivityIndicator(radius: 15.0)
                ),
            ),
        );
    }
}