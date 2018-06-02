import 'package:flutter/material.dart';
import '../models/item.dart';
import 'package:flutter/foundation.dart';
import '../providers/app.dart';
import '../providers/auth.dart';

class ItemActionSheet extends StatefulWidget{
    const ItemActionSheet({Key key, @required this.item}):super(key: key);
    final Item item;
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
        Scaffold.of(context).showSnackBar(AppProvider().showSnackBar("Item Edited"));
        Navigator.of(context).pop();
    }

    void deleteItem(){
        Scaffold.of(context).showSnackBar(AppProvider().showSnackBar("Item Deleted"));
        Navigator.of(context).pop();
    }

    void showAvailables(){
        Scaffold.of(context).showSnackBar(AppProvider().showSnackBar("Available Shown"));
        Navigator.of(context).pop();
    }

    void borrowItem(){
        Scaffold.of(context).showSnackBar(AppProvider().showSnackBar("Item Borrowed"));
        Navigator.of(context).pop();
    }

    void favouriteItem(){
        Scaffold.of(context).showSnackBar(AppProvider().showSnackBar("Item Favourited"));
        Navigator.of(context).pop();
    }

    void reportItem(){
        Scaffold.of(context).showSnackBar(AppProvider().showSnackBar("Item Reported"));
        Navigator.of(context).pop();
    }
    
    @override
    Widget build(BuildContext context){
        return Container(
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
                        onTap: (){},
                    ),
                    ListTile(
                        leading: Icon(Icons.delete),
                        title: Text("Delete"),
                        enabled: (this.item.user.id == this.userID),
                        onTap: (){},
                    ),
                    ListTile(
                        leading: Icon(Icons.assignment),
                        title: Text("Available"),
                        onTap: (){},
                    ),
                    ListTile(
                        leading: Icon(Icons.add),
                        title: Text("Borrow"),
                        enabled: (this.item.user.id != this.userID),
                        onTap: (){},
                    ),
                    ListTile(
                        leading: Icon(Icons.star_border),
                        title: Text("Favourite"),
                        onTap: (){}, 
                    ),
                    ListTile(
                        leading: Icon(Icons.info_outline),
                        title: Text("Report"),
                        onTap: (){}
                    )
                ],
            ),
        );
    }
}