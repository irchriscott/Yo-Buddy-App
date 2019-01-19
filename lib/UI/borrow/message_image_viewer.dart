import 'package:flutter/material.dart';
import 'package:buddyapp/models/borrow.dart';
import 'package:flutter/foundation.dart';
import 'package:buddyapp/providers/app.dart';
import 'package:buddyapp/libraries/carousel.dart';
import 'package:flutter_advanced_networkimage/flutter_advanced_networkimage.dart';
import 'package:flutter_advanced_networkimage/zoomable_widget.dart';
import 'package:flutter_advanced_networkimage/transition_to_image.dart';

class MessageImageViewPage extends StatefulWidget{

    MessageImageViewPage({
        Key key,
        @required this.images,
        @required this.onImageViewClose,
        @required this.sender
    }) : super(key:key);

    final List<BorrowMessageImage> images;
    final VoidCallback onImageViewClose;
    final String sender;

    @override
    _MessageImageViewPage createState() => _MessageImageViewPage();
}

class _MessageImageViewPage extends State<MessageImageViewPage>{

    List<BorrowMessageImage> images;
    List<SingleImagePage> imagesViewer = [];

    @override
    void initState() {
        super.initState();
        this.images = widget.images;
        this.getImageViewPages();
    }

    void getImageViewPages(){
        this.widget.images.forEach((image){
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
                                return Builder(
                                    builder: (BuildContext context) {
                                        return Hero(
                                            tag: this.images[this.imagesViewer.indexOf(i)].image.path,
                                            child: Container(
                                                width: MediaQuery.of(context).size.width,
                                                child: i
                                            ),
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
                        right: 10.0
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
                                    Expanded(
                                        child: Text(
                                            this.widget.sender,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 20.0
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                        ),
                                    ),
                                    Container(
                                        child: IconButton(
                                            onPressed: () {},
                                            icon: Icon(IconData(0xf41f, fontFamily: 'ionicon'), color: Colors.white),
                                            iconSize: 35.0,
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

    final BorrowMessageImage image;

    @override
    Widget build(BuildContext context) {
        TransitionToImage imageTransition = TransitionToImage(
            AdvancedNetworkImage(AppProvider().baseURL + image.image.path, useDiskCache: true),
            placeholder: CircularProgressIndicator(),
            reloadWidget: Icon(Icons.replay)
        );
        return Container(
            child: ZoomableWidget(
                minScale: 0.3,
                maxScale: 2.0,
                child: Image(
                    image: AdvancedNetworkImage(AppProvider().baseURL + image.image.path),
                    fit: BoxFit.fitWidth
                ),
                //child: imageTransition,
                tapCallback: imageTransition.reloadImage()
            )
        );
    }
}