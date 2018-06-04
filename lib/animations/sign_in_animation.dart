import 'package:flutter/material.dart';
import 'dart:async';

class StaggerAnimation extends StatelessWidget {
    StaggerAnimation({Key key, this.buttonController}): buttonSqueezeAnimation = new Tween(
        begin: 320.0,
        end: 70.0,
    ).animate(
        new CurvedAnimation(
            parent: buttonController,
            curve: new Interval(
                0.0,
                0.150,
            ),
        ),
    ),
    buttonZoomOut = new Tween(
        begin: 70.0,
        end: 1000.0,
    ).animate(
        new CurvedAnimation(
            parent: buttonController,
            curve: new Interval(
                0.550,
                0.999,
                curve: Curves.bounceOut,
            ),
        ),
    ),
    containerCircleAnimation = new EdgeInsetsTween(
        begin: const EdgeInsets.only(bottom: 50.0),
        end: const EdgeInsets.only(bottom: 0.0),
    ).animate(
        new CurvedAnimation(
            parent: buttonController,
            curve: new Interval(
                0.500,
                0.800,
                curve: Curves.ease,
            ),
        ),
    ),
    super(key: key);

    final AnimationController buttonController;
    final Animation<EdgeInsets> containerCircleAnimation;
    final Animation buttonSqueezeAnimation;
    final Animation buttonZoomOut;

    Future<Null> _playAnimation() async {
        try {
            await buttonController.forward();
            await buttonController.reverse();
        } on TickerCanceled {}
    }

    Widget _buildAnimation(BuildContext context, Widget child) {
        return Padding(
            padding: EdgeInsets.symmetric(vertical: 20.0),
            child: MaterialButton(
                onPressed: () {
                  _playAnimation();
                },
                child: Material(
                    shadowColor: Color(0xFF666666),
                    elevation: 5.0,
                    child: Hero(
                        tag: "fade",
                        child: buttonZoomOut.value <= 300
                            ? Container(
                            width: buttonZoomOut.value == 45
                                ? buttonSqueezeAnimation.value
                                : buttonZoomOut.value,
                            height: 45.0, //buttonZoomOut.value == 70 ? 45.0 : buttonZoomOut.value,
                            alignment: FractionalOffset.center,
                            decoration: BoxDecoration(
                                color: const Color(0xFFCC8400),
                                borderRadius: buttonZoomOut.value < 300
                                    ? new BorderRadius.all(const Radius.circular(10.0))
                                    : new BorderRadius.all(const Radius.circular(22.5)),
                            ),
                            child: buttonSqueezeAnimation.value > 75.0 ? new Text(
                                "Log In".toUpperCase(),
                                style: new TextStyle(
                                    color: Colors.white,
                                    fontSize: 18.0
                                ),
                            ) : buttonZoomOut.value < 300.0 ? new CircularProgressIndicator(
                                value: null,
                                strokeWidth: 2.0,
                                valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),
                            ) : null
                        ) : new Container(
                            width: buttonZoomOut.value,
                            height: 45.0,
                            decoration: new BoxDecoration(
                              shape: buttonZoomOut.value < 300
                                  ? BoxShape.circle
                                  : BoxShape.rectangle,
                              color: const Color(0xFFCC8400),
                            ),
                        ),
                    )
                )
            ),
        );
    }

  @override
  Widget build(BuildContext context) {
      return new AnimatedBuilder(
          builder: _buildAnimation,
          animation: buttonController,
      );
    }
}
