//import 'package:flutter/material.dart';
//import 'package:zefyr/zefyr.dart';
//
//
//class RichTextEditorYB extends StatefulWidget {
//
//    RichTextEditorYB({Key key, @required this.controller, @required this.focusNode, @required this.saveDescription}) : super(key : key);
//
//    final ZefyrController controller;
//    final FocusNode focusNode;
//    final VoidCallback saveDescription;
//
//    @override
//    _RichTextEditorYB createState() => new _RichTextEditorYB();
//}
//
//class _RichTextEditorYB extends State<RichTextEditorYB> {
//
//    @override
//    Widget build(BuildContext context) {
//
//        final theme = new ZefyrThemeData(
//            toolbarTheme: ZefyrToolbarTheme.fallback(context).copyWith(
//                color: Colors.grey.shade800,
//                toggleColor: Colors.grey.shade900,
//                iconColor: Colors.white,
//                disabledIconColor: Colors.grey.shade500,
//            ),
//        );
//
//        final done = [new FlatButton(onPressed: widget.saveDescription, child: Text('SAVE'))];
//
//        return Scaffold(
//            resizeToAvoidBottomPadding: true,
//            appBar: AppBar(
//                automaticallyImplyLeading: false,
//                elevation: 1.0,
//                backgroundColor: Colors.grey.shade200,
//                brightness: Brightness.light,
//                actions: done,
//                title: Text("Add Item Description", style: TextStyle(color: Color(0xFF666666), fontWeight: FontWeight.bold)),
//            ),
//            body: ZefyrTheme(
//                data: theme,
//                child: ZefyrEditor(
//                    controller: widget.controller,
//                    focusNode: widget.focusNode,
//                    enabled: true,
//                    imageDelegate: new CustomImageDelegate(),
//                ),
//            ),
//        );
//    }
//}
//
//
//class CustomImageDelegate extends ZefyrDefaultImageDelegate {
//
//    @override
//    ImageProvider createImageProvider(String imageSource) {
//        // We use custom "asset" scheme to distinguish asset images from other files.
//        if (imageSource.startsWith('asset://')) {
//            return new AssetImage(imageSource.replaceFirst('asset://', ''));
//        } else {
//            return super.createImageProvider(imageSource);
//        }
//    }
//}

//(this.showTextEditor == true) ? RichTextEditorYB(controller: this._itemDescriptionCtrl, focusNode: this._focusNode, saveDescription: (){
//    setState(() {
//        this.showTextEditor = false;
//        this.descriptionTextValue = this._itemDescriptionCtrl.plainTextEditingValue.text != "" ? this._itemDescriptionCtrl.plainTextEditingValue.text : "Enter Item Description";
//        this.descriptionTextColor = this._itemDescriptionCtrl.plainTextEditingValue.text != "" ? Color(0xFF333333) : Color(0xFF666666);
//    });
//}) : Container()

//child: InkWell(
//    onTap: openTextEditor,
//    child: Container(
//        height: 180.0,
//        padding: EdgeInsets.fromLTRB(15.0, 8.0, 15.0, 8.0),
//        child: Text(this.descriptionTextValue, style: TextStyle(color: this.descriptionTextColor, fontSize: 17.0)),
//        decoration: BoxDecoration(
//            borderRadius: BorderRadius.circular(5.0),
//            border: Border.all(width: 1.0, color: Color(0xFF333333))
//        ),
//    )
//),

//final ZefyrController _itemDescriptionCtrl = ZefyrController(NotusDocument());
//final FocusNode _focusNode = new FocusNode();

//import 'package:zefyr/zefyr.dart';