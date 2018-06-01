import 'package:flutter/material.dart';
import '../models/item.dart';
import 'package:flutter/foundation.dart';
import '../providers/app.dart';

class ItemActionSheet extends StatefulWidget{
    const ItemActionSheet({Key key, @required this.item}):super(key: key);
    final Item item;
    @override
    _ItemActionSheetState createState() => _ItemActionSheetState();
}
class _ItemActionSheetState extends State<ItemActionSheet>{
    
    Item item;

    @override
    void initState(){
        super.initState();
        this.item = widget.item;
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
                        onTap: (){},
                    ),
                    ListTile(
                        leading: Icon(Icons.delete),
                        title: Text("Delete"),
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