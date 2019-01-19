import 'dart:io';
import 'package:flutter/material.dart';
import 'package:buddyapp/models/borrow.dart';
import 'package:flutter/foundation.dart';
import 'package:buddyapp/providers/app.dart';
import 'package:buddyapp/libraries/carousel.dart';

class CameraImageViewPage extends StatefulWidget{

    CameraImageViewPage({
        Key key,
        @required this.images,
        @required this.onImageViewClose,
        @required this.onImagesSend,
        @required this.onAddMore,
        @required this.receiver,
        @required this.imageFrom
    }) : super(key:key);

    final List<File> images;
    final VoidCallback onImageViewClose;
    final VoidCallback onImagesSend;
    final VoidCallback onAddMore;
    final String receiver;
    final int imageFrom;

    @override
    _CameraImageViewPage createState() => _CameraImageViewPage();
}

class _CameraImageViewPage extends State<CameraImageViewPage>{

    List<File> images;
    List<SingleImagePage> imagesViewer = [];

    @override
    void initState() {
        super.initState();
        this.images = widget.images;
        this.getImageViewPages();
    }

    void getImageViewPages(){
        this.widget.images.reversed.forEach((image){
            this.imagesViewer.add(SingleImagePage(image: image));
        });
    }

    @override
    Widget build(BuildContext context){
        return Material(
            color: Colors.black,
            child: Stack(
                children: <Widget>[
                    Center(
                        child: CarouselSlider(
                            items: imagesViewer.map((i) {
                                return new Builder(
                                    builder: (BuildContext context) {
                                        return Container(
                                            width: MediaQuery.of(context).size.width,
                                            child: i
                                        );
                                    },
                                );
                            }).toList(),
                            viewportFraction: 1.0,
                            aspectRatio: 1.0,
                            height: MediaQuery.of(context).size.height,
                            autoPlayCurve: Curves.elasticInOut
                        )
                    ),
                    Positioned(
                        child: Container(
                            child: IconButton(
                                icon: Icon(Icons.close),
                                color: Colors.white,
                                onPressed: () => widget.onImageViewClose(),
                            ),
                            decoration: BoxDecoration(
                                color: Color.fromRGBO(0,0,0,.4),
                                shape: BoxShape.circle
                            ),
                        ),
                        top: 10.0,
                        left: 10.0
                    ),
                    Positioned(
                        bottom: 0.0,
                        left: 0.0,
                        right: 0.0,
                        child: Container(
                            padding: EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                    end: const Alignment(0.0, -1.0),
                                    begin: const Alignment(0.0, -0.4),
                                    colors: const <Color>[const Color(0x60000000), const Color(0x00000000)],
                                ),
                            ),
                            child: Row(
                                children: <Widget>[
                                    (widget.imageFrom == 0) ? Container(
                                        padding: EdgeInsets.only(right: 10.0),
                                        child: IconButton(
                                            onPressed: () => widget.onAddMore(),
                                            icon: Icon(Icons.add, color: Colors.white),
                                            iconSize: 30.0,
                                            color: Color(0xFF333333),
                                        )
                                    ) : Container(),
                                    Expanded(
                                        child: Text(
                                            "Send to ${this.widget.receiver}",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 20.0
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                        ),
                                    ),
                                    Container(
                                        child: IconButton(
                                            onPressed: () => widget.onImagesSend(),
                                            icon: Icon(Icons.send, color: Colors.white),
                                            iconSize: 30.0,
                                            color: Color(0xFF333333),
                                        )
                                    )
                                ],
                            ),
                        )
                    )
                ],
            )
        );
    }
}

class SingleImagePage extends Container{

    SingleImagePage({Key key, @required this.image});

    final File image;

    @override
    Widget build(BuildContext context) {

        return Container(
            child: Center(
                child: Image.file(image, fit: BoxFit.fill),
            )
        );
    }
}