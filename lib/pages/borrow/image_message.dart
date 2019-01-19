import 'dart:async';
import 'dart:io';
import 'package:buddyapp/UI/loading_popup.dart';
import 'package:buddyapp/UI/popup.dart';
import 'package:buddyapp/models/borrow.dart';
import 'package:buddyapp/models/user.dart';
import 'package:buddyapp/providers/app.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:multi_image_picker/picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:buddyapp/UI/borrow/camera_image_viewer.dart';
import 'package:buddyapp/providers/notification.dart';
import 'package:flutter_socket_io/flutter_socket_io.dart';
import 'package:flutter_socket_io/socket_io_manager.dart';

class ImageMessage extends StatefulWidget {

    ImageMessage({
        Key key,
        @required this.borrow,
        @required this.sessionToken,
        @required this.session,
        @required this.onSendImages,
        @required this.cameras
    }) : super(key : key);

    final Borrow borrow;
    final String sessionToken;
    final User session;
    final VoidCallback onSendImages;
    final List<CameraDescription> cameras;

    @override
    _ImageMessageState createState() {
        return _ImageMessageState();
    }
}

/// Returns a suitable camera icon for [direction].
IconData getCameraLensIcon(CameraLensDirection direction) {
    switch (direction) {
        case CameraLensDirection.back:
            return  Icons.switch_camera;
        case CameraLensDirection.front:
            return Icons.camera_alt;
        case CameraLensDirection.external:
            return Icons.camera;
    }
    throw ArgumentError('Unknown lens direction');
}

void logError(String code, String message) =>
    print('Error: $code\nError Message: $message');

class _ImageMessageState extends State<ImageMessage> {

    CameraController controller;
    String imagePath;
    String videoPath;
    VideoPlayerController videoController;
    VoidCallback videoPlayerListener;

    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
    List<CameraDescription> cameras;
    List<File> images = [];
    int maxImageNo = 10;
    String _platformMessage = 'No Error';

    int index = 0;
    bool canViewTakenPictures = false;

    SocketIO socketIO;
    PushNotification pushNotification;

    bool isLoadingVisible = false;
    bool canShowPopup = false;

    String _message = "";
    String _type = "";

    int imageFrom = 0;

    @override
    void initState(){
        this.cameras = widget.cameras;
        if(this.cameras.isNotEmpty){
            this.startCamera();
        }
        this.socketIO = SocketIOManager().createSocketIO(AppProvider().socketURL, "");
        this.socketIO.init();
        this.socketIO.connect();

        Timer(Duration(seconds: 1), (){ setState((){
            this.pushNotification = PushNotification(user: this.widget.session, token: this.widget.sessionToken, context: context);
            this.pushNotification.initNotification();
        }); });
        super.initState();
    }

    @override
    void dispose() {
        controller?.dispose();
        super.dispose();
    }

    void startCamera() async{

        this.controller = CameraController(this.cameras[index], ResolutionPreset.high);

        controller.addListener(() {
            if (mounted) setState(() {});
            if (controller.value.hasError) {
                showInSnackBar('Camera error ${controller.value.errorDescription}');
            }
        });

        try {
            await controller.initialize();
        } on CameraException catch (e) {
            _showCameraException(e);
        }

        if (mounted) {
            setState(() {
                index = cameras.indexOf(controller.description);
            });
        }
    }

    Future<void> openImageLibrary() async{

        setState(() {
            images = [];
            imageFrom = 1;
        });

        List<File> resultList = [];
        String error;

        try {
            resultList = await MultiImagePicker.pickImages(maxImages: maxImageNo);
        } catch (e) {
            error = e.message;
        }

        if (!mounted) return;

        setState(() {
            images = resultList;
            if(images.length > 0){

            }
            if (error == null) _platformMessage = 'No Error Dectected';
        });
    }

    void sendBorrowImageMessage() async{
        if(this.images.isNotEmpty){
            BorrowMessage newMessage = BorrowMessage(
                message: "images",
                receiver: (this.widget.session.id == this.widget.borrow.user.id) ? this.widget.borrow.item.user : this.widget.borrow.user,
                isDeleted: false,
                status: "unread",
                imageFiles: this.images
            );
            newMessage.sendImageMessage(this.widget.sessionToken, this.widget.borrow.item.id, this.widget.borrow.id).then((response){
                if(response.type == "success"){
                    this.sendMessageSocket(response.text);
                }
                setState((){ this.isLoadingVisible = false; this._message = (response.type == "success") ? "Images Sent !!!" : response.text; this._type = response.type; this.canShowPopup = true; });
            });
        } else { showInSnackBar("No Image To Send"); }
    }

    void sendMessageSocket(String message) async{
        if (this.socketIO != null) {
            String data = '{"item": "${this.widget.borrow.item.id}","borrow": "${this.widget.borrow.id}","receiver": "${(this.widget.session.id == this.widget.borrow.user.id) ? this.widget.borrow.item.user.id : this.widget.borrow.user.id}","sender": "${this.widget.session.username}","message": "$message","url": "${this.widget.borrow.messagesURL}","path": "${this.widget.borrow.url}","type": "message", "about": "borrow_message"}';
            this.socketIO.sendMessage("messageSent", data);
        }
    }

    @override
    Widget build(BuildContext context) {
        return Material(
            child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                    Scaffold(
                        key: _scaffoldKey,
                        body: Container(
                            child: Container(
                                child: Center(
                                    child: _cameraPreviewWidget(),
                                ),
                            ),
                            decoration: BoxDecoration(
                                color: Colors.black,
                            ),
                        ),
                    ),
                    _captureControlRowWidget(),
                    Positioned(
                        bottom: 33.0,
                        right: 30.0,
                        child: Container(
                            child: InkWell(
                                onTap: controller != null && controller.value.isRecordingVideo ? null : onNewCameraSelected,
                                child: Icon(
                                    getCameraLensIcon(this.cameras[index].lensDirection),
                                    color: Colors.white,
                                    size: 40.0,
                                )
                            )
                        ),
                    ),
                    Positioned(
                        bottom: 35.0,
                        left: 30.0,
                        child: Container(
                            child: InkWell(
                                onTap: () => this.openImageLibrary(),
                                child: Icon(
                                    Icons.image,
                                    color: Colors.white,
                                    size: 40.0,
                                )
                            )
                        ),
                    ),
                    Positioned(
                        child: Container(
                            child: IconButton(
                                icon: Icon(Icons.close),
                                color: Colors.white,
                                iconSize: 30.0,
                                onPressed: () { Navigator.of(context).pop(); },
                            ),
                            decoration: BoxDecoration(
                                color: Color.fromRGBO(0,0,0,0.0),
                                shape: BoxShape.circle
                            ),
                        ),
                        top: 10.0,
                        left: 10.0
                    ),
                    (this.canViewTakenPictures == true) ? CameraImageViewPage(
                        images: this.images,
                        onImageViewClose: (){
                            setState((){ 
                                this.canViewTakenPictures = false;
                                this.images.forEach((image){
                                    image.deleteSync(recursive: true);
                                });
                                this.images.clear();
                            });
                        },
                        onAddMore: (){ setState((){ this.canViewTakenPictures = false; }); },
                        onImagesSend: (){
                            setState((){ this.isLoadingVisible = true; this.canViewTakenPictures = false; });
                            this.sendBorrowImageMessage();
                        },
                        receiver: (this.widget.session.id == this.widget.borrow.user.id) ? this.widget.borrow.item.user.name : this.widget.borrow.user.name,
                        imageFrom: this.imageFrom,
                    ) : Container(),
                    (canShowPopup == true) ? PopupOverlay(message: this._message, type: this._type, onTap: (){
                        setState(() { this.canShowPopup = false;});
                        if(this._type == "success") {
                            this.widget.onSendImages();
                        } else {
                            setState((){ this.canViewTakenPictures = false; this.canShowPopup = false; });
                        }
                    }) : Container(),
                    (isLoadingVisible == true) ? LoadingOverlay() : Container()
                ],
            )
        );
    }

    /// Display the preview from the camera (or a message if the preview is not available).
    Widget _cameraPreviewWidget() {
        if (controller == null || !controller.value.isInitialized) {
            return Text(
                'Tap a camera',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 24.0,
                    fontWeight: FontWeight.w900,
                ),
            );
        } else {
            final size = MediaQuery.of(context).size;
            final deviceRatio = size.width / size.height;
            return Transform.scale(
                scale: controller.value.aspectRatio / deviceRatio,
                child: Center(
                    child: AspectRatio(
                        aspectRatio: controller.value.aspectRatio,
                        child: CameraPreview(controller),
                    ),
                ),
            );
        }
    }

    /// Display the thumbnail of the captured image or video.
    Widget _thumbnailWidget() {
        return Expanded(
            child: Align(
                alignment: Alignment.centerRight,
                child: videoController == null && imagePath == null
                    ? null
                    : SizedBox(
                    child: (videoController == null)
                        ? Image.file(File(imagePath))
                        : Container(
                        child: Center(
                            child: AspectRatio(
                                aspectRatio: videoController.value.size != null
                                    ? videoController.value.aspectRatio
                                    : 1.0,
                                child: VideoPlayer(videoController)),
                        ),
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.pink)),
                    ),
                    width: 64.0,
                    height: 64.0,
                ),
            ),
        );
    }

    /// Display the control bar with buttons to take pictures and record videos.
    Widget _captureControlRowWidget() {
        final left = (MediaQuery.of(context).size.width - 80.0) / 2;
        return Positioned(
            bottom: 15.0,
            left: left,
            child: Center(
                child: Center(
                    child: Container(
                        width: 80.0,
                        height: 80.0,
                        decoration: BoxDecoration(
                            border: Border.all(
                                style: BorderStyle.solid,
                                width: 1.0,
                                color: Color(0xFF999999)
                            ),
                            shape: BoxShape.circle
                        ),
                        child: Container(
                            width: 79.0,
                            height: 79.0,
                            decoration: BoxDecoration(
                                border: Border.all(
                                    style: BorderStyle.solid,
                                    width: 4.0,
                                    color: Colors.white
                                ),
                                shape: BoxShape.circle,
                            ),
                            child: Container(
                                child: InkWell(
                                    onTap: controller != null &&
                                        controller.value.isInitialized &&
                                        !controller.value.isRecordingVideo
                                        ? onTakePictureButtonPressed
                                        : null,
                                    child: Container(
                                        width: 75.0,
                                        height: 75.0,
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                style: BorderStyle.solid,
                                                width: 1.0,
                                                color: Color(0xFF999999)
                                            ),
                                            shape: BoxShape.circle,
                                        )
                                    )
                                ),
                            ),
                        ),
                    ),
                )
            )
        );
    }

    /// Display a row of toggle to select the camera (or a message if no camera is available).
    String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

    void showInSnackBar(String message) {
        _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(message)));
    }

    void onNewCameraSelected() async {
        if (controller != null) {
            await controller.dispose();
        }

        if(cameras.isNotEmpty){
            if(cameras.length > 1){
                if(index == 0){
                    controller = CameraController(cameras[1], ResolutionPreset.high);
                } else {
                    controller = CameraController(cameras[0], ResolutionPreset.high);
                }
            } else {
                controller = CameraController(cameras[0], ResolutionPreset.high);
            }
        }

        // If the controller is updated then update the UI.
        controller.addListener(() {
            if (mounted) setState(() {});
            if (controller.value.hasError) {
                showInSnackBar('Camera error ${controller.value.errorDescription}');
            }
        });

        try {
            await controller.initialize();
        } on CameraException catch (e) {
            _showCameraException(e);
        }

        if (mounted) {
            setState(() {
                index = cameras.indexOf(controller.description);
            });
        }
    }

    void onTakePictureButtonPressed() {
        takePicture().then((String filePath) {
            if (mounted) {
                setState(() {
                    imagePath = filePath;
                    videoController?.dispose();
                    videoController = null;
                });
                if (filePath != null) {
                    this.images.add(File(filePath));
                    setState((){ imageFrom = 1; this.canViewTakenPictures = true; });
                    showInSnackBar('Picture Saved !!!');
                }
            }
        });
    }

    void onVideoRecordButtonPressed() {
        startVideoRecording().then((String filePath) {
            if (mounted) setState(() {});
            if (filePath != null) showInSnackBar('Saving Video...');
        });
    }

    void onStopButtonPressed() {
        stopVideoRecording().then((_) {
            if (mounted) setState(() {});
            showInSnackBar('Video Recorded !!!');
        });
    }

    Future<String> startVideoRecording() async {
        if (!controller.value.isInitialized) {
            showInSnackBar('Error: select a camera first.');
            return null;
        }

        final Directory extDir = await getApplicationDocumentsDirectory();
        final String dirPath = '${extDir.path}/videos';
        await Directory(dirPath).create(recursive: true);
        final String filePath = '$dirPath/yb_video_${timestamp()}.mp4';

        if (controller.value.isRecordingVideo) {
            // A recording is already started, do nothing.
            return null;
        }

        try {
            videoPath = filePath;
            await controller.startVideoRecording(filePath);
        } on CameraException catch (e) {
            _showCameraException(e);
            return null;
        }
        return filePath;
    }

    Future<void> stopVideoRecording() async {
        if (!controller.value.isRecordingVideo) {
            return null;
        }

        try {
            await controller.stopVideoRecording();
        } on CameraException catch (e) {
            _showCameraException(e);
            return null;
        }

        await _startVideoPlayer();
    }

    Future<void> _startVideoPlayer() async {
        final VideoPlayerController vcontroller =
        VideoPlayerController.file(File(videoPath));
        videoPlayerListener = () {
            if (videoController != null && videoController.value.size != null) {
                // Refreshing the state to update video player with the correct ratio.
                if (mounted) setState(() {});
                videoController.removeListener(videoPlayerListener);
            }
        };
        vcontroller.addListener(videoPlayerListener);
        await vcontroller.setLooping(true);
        await vcontroller.initialize();
        await videoController?.dispose();
        if (mounted) {
            setState(() {
                imagePath = null;
                videoController = vcontroller;
            });
        }
        await vcontroller.play();
    }

    Future<String> takePicture() async {
        if (!controller.value.isInitialized) {
            showInSnackBar('Error: select a camera first.');
            return null;
        }
        final Directory extDir = await getApplicationDocumentsDirectory();
        final String dirPath = '${extDir.path}/images';
        await Directory(dirPath).create(recursive: true);
        final String filePath = '$dirPath/yb_image_${timestamp()}.jpg';

        if (controller.value.isTakingPicture) {
            // A capture is already pending, do nothing.
            return null;
        }

        try {
            await controller.takePicture(filePath);
        } on CameraException catch (e) {
            _showCameraException(e);
            return null;
        }
        return filePath;
    }

    void _showCameraException(CameraException e) {
        logError(e.code, e.description);
        showInSnackBar('Error: ${e.code}\n${e.description}');
    }
}