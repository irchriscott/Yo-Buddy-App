import 'package:buddyapp/models/user.dart';
import 'package:buddyapp/pages/borrow/borrow_item.dart';
import 'package:buddyapp/pages/item/available.dart';
import 'package:flutter/material.dart';
import 'package:buddyapp/models/item.dart';
import 'package:flutter/foundation.dart';
import 'package:buddyapp/providers/app.dart';
import 'package:buddyapp/providers/auth.dart';
import 'package:buddyapp/pages/item/edit_item.dart';

class ItemActionSheet extends StatefulWidget{

    const ItemActionSheet({Key key, @required this.item, @required this.scaffoldContext, @required this.context, @required this.session, @required this.sessionToken}):super(key: key);

    final Item item;
    final BuildContext scaffoldContext;
    final context;
    final User session;
    final String sessionToken;

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
        Navigator.of(context).pop();
        Navigator.push(
            widget.context,
            MaterialPageRoute(builder: (BuildContext context) => EditItemForm(item:  this.item))
        );
    }

    void deleteItem(){
        Navigator.of(context).pop();
        Scaffold.of(widget.scaffoldContext).showSnackBar(AppProvider().showSnackBar("Item Deleted"));
    }

    void showAvailable(){
        Navigator.of(context).pop();
        Navigator.push(
            widget.context,
            MaterialPageRoute(builder: (BuildContext context) => ItemsAvailablePage(item:  this.item))
        );
    }

    void borrowItem(){
        Navigator.of(context).pop();
        Navigator.push(
            context,
            MaterialPageRoute(builder: (BuildContext context) => BorrowItemForm(item:  this.item))
        );
    }

    void favouriteItem() async{
        Navigator.of(context).pop();
        this.item.favouriteItem(this.widget.sessionToken, this.widget.session.id.toString()).then((response){
            Scaffold.of(widget.scaffoldContext).showSnackBar(AppProvider().showSnackBar(response.text));
        });
    }

    void reportItem(){
        Navigator.of(context).pop();
        Scaffold.of(widget.scaffoldContext).showSnackBar(AppProvider().showSnackBar("Item Reported"));
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
                        onTap: editItem,
                    ),
                    ListTile(
                        leading: Icon(Icons.delete),
                        title: Text("Delete"),
                        enabled: (this.item.user.id == this.userID),
                        onTap: editItem,
                    ),
                    ListTile(
                        leading: Icon(Icons.assignment),
                        title: Text("Available"),
                        onTap: showAvailable,
                    ),
                    ListTile(
                        leading: Icon(Icons.add),
                        title: Text("Borrow"),
                        enabled: (this.item.user.id != this.userID),
                        onTap: borrowItem,
                    ),
                    ListTile(
                        leading: Icon(Icons.star_border),
                        title: Text("Favourite"),
                        onTap: favouriteItem,
                    ),
                    ListTile(
                        leading: Icon(Icons.info_outline),
                        title: Text("Report"),
                        onTap: reportItem
                    )
                ],
            ),
        );
    }
}