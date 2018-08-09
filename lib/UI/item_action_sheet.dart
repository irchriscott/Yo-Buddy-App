import 'package:flutter/material.dart';
import '../models/item.dart';
import 'package:flutter/foundation.dart';
import '../providers/app.dart';
import '../providers/auth.dart';

class ItemActionSheet extends StatefulWidget{
    const ItemActionSheet({Key key, @required this.item, @required this.scaffoldContext}):super(key: key);
    final Item item;
    final BuildContext scaffoldContext;
    @override
    _ItemActionSheetState createState() => _ItemActionSheetState();
}
class _ItemActionSheetState extends State<ItemActionSheet>{
    
    Item item;
    int userID;

    @override
    void initState(){
        super.initState();
        this.item = widget.item;
        this.getUserData();
    }

    void _setUserID(int id){
        this.userID = id;
    }

    void getUserData(){
        Authentication().getSessionUser().then((value) => _setUserID(value.id));
    }

    void editItem(){
        Scaffold.of(widget.scaffoldContext).showSnackBar(AppProvider().showSnackBar("Item Edited"));
        Navigator.of(context).pop();
    }

    void deleteItem(){
        Scaffold.of(widget.scaffoldContext).showSnackBar(AppProvider().showSnackBar("Item Deleted"));
        Navigator.of(context).pop();
    }

    void showAvailable(){
        Scaffold.of(widget.scaffoldContext).showSnackBar(AppProvider().showSnackBar("Available Shown"));
        Navigator.of(context).pop();
    }

    void borrowItem(){
        Scaffold.of(widget.scaffoldContext).showSnackBar(AppProvider().showSnackBar("Item Borrowed"));
        Navigator.of(context).pop();
    }

    void favouriteItem(){
        Scaffold.of(widget.scaffoldContext).showSnackBar(AppProvider().showSnackBar("Item Favourited"));
        Navigator.of(context).pop();
    }

    void reportItem(){
        Scaffold.of(widget.scaffoldContext).showSnackBar(AppProvider().showSnackBar("Item Reported"));
        Navigator.of(context).pop();
    }
    
    @override
    Widget build(BuildContext context){
        return Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8.0),
                    topRight: Radius.circular(8.0)
                )
            ),
            child: Column(
                children: <Widget>[
                    Container(
                        padding: EdgeInsets.only(top: 10.0),
                        child: Text("Menu Item", textAlign: TextAlign.left)
                    ),
                    ListTile(
                        leading: Icon(Icons.edit),
                        title: Text("Edit"),
                        enabled: (this.item.user.id == this.userID),
                        onTap: () => this.editItem(),
                    ),
                    ListTile(
                        leading: Icon(Icons.delete),
                        title: Text("Delete"),
                        enabled: (this.item.user.id == this.userID),
                        onTap: () => this.editItem(),
                    ),
                    ListTile(
                        leading: Icon(Icons.assignment),
                        title: Text("Available"),
                        onTap: () => this.showAvailable(),
                    ),
                    ListTile(
                        leading: Icon(Icons.add),
                        title: Text("Borrow"),
                        enabled: (this.item.user.id != this.userID),
                        onTap: () => this.borrowItem(),
                    ),
                    ListTile(
                        leading: Icon(Icons.star_border),
                        title: Text("Favourite"),
                        onTap: () => this.favouriteItem(),
                    ),
                    ListTile(
                        leading: Icon(Icons.info_outline),
                        title: Text("Report"),
                        onTap: () => this.reportItem()
                    )
                ],
            ),
        );
    }
}