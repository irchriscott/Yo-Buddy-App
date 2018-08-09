import 'package:flutter/material.dart';
import '../models/category.dart';
import '../models/subcategory.dart';
import '../providers/yobuddy.dart';
import '../UI/categories_select_list.dart';
import '../UI/subcategories_select_list.dart';

class NewItemForm extends StatefulWidget{
    @override
    _NewItemFormState createState() => _NewItemFormState();
}

class _NewItemFormState extends State<NewItemForm> {

    bool isSaving;
    List<Category> categories = [];
    List<Subcategory> subcategories = [];
    String selectedCategory = "";
    String selectedSubcategory = "";

    TextEditingController _itemNameCtrl = TextEditingController();

    @override
    void initState() {
        this.isSaving = false;
        super.initState();
        this.getCategoriesList();
    }

    void saveNewItem(){
        setState(() {
            this.isSaving = true;
        });
    }

    void getCategoriesList(){
        YoBuddyService().getAllCategories().then((data){
            setState(() {
                this.categories = data.toList();
                this.subcategories = data.toList()[0].subcategories.toList();
                this.selectedCategory = this.categories[0].name;
                this.selectedSubcategory = this.subcategories[0].name;
            });
        });
    }

    void openSelectAlertCategory(){

    }

    void openSelectAlertSubcategory(){

    }

    @override
    Widget build(BuildContext context) {

        return Hero(
            tag: "show form",
            child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                    Scaffold(
                        backgroundColor: Colors.white,
                        appBar: AppBar(
                            backgroundColor: Colors.white,
                            automaticallyImplyLeading: false,
                            title: Row(
                                children: <Widget>[
                                    IconButton(
                                        onPressed: (){
                                            Navigator.of(context).pop();
                                        },
                                        icon: Icon(Icons.close, color: Theme.of(context).primaryColor)
                                    ),
                                    Expanded(
                                        child: Text(
                                            "Add New Item",
                                            style: TextStyle(
                                                color: Color(0xFF333333),
                                                fontWeight: FontWeight.bold
                                            ),
                                            textAlign:TextAlign.center,
                                        ),
                                    ),
                                    Container(
                                        child: (this.isSaving) ? Container(
                                            height: 20.0,
                                            width: 20.0,
                                            child: CircularProgressIndicator(
                                                backgroundColor: Color(0xFF666666),
                                                strokeWidth: 1.0,
                                                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF666666)),
                                            )
                                        ) :
                                        InkWell(
                                            onTap: () => this.saveNewItem(),
                                            child: Text("Save".toUpperCase(), style: TextStyle(color: Color(0xFF666666), fontSize: 15.0)),
                                        ),
                                    )
                                ],
                            )
                        ),
                        body: Container(
                            padding: EdgeInsets.all(12.0),
                            color: Colors.white,
                            child: ListView(
                                children: <Widget>[
                                    Container(
                                        padding: EdgeInsets.only(bottom: 8.0),
                                        child: Text("Item Name :"),
                                    ),
                                    Container(
                                        padding: EdgeInsets.only(bottom: 8.0),
                                        child: TextFormField(
                                            controller: _itemNameCtrl,
                                            autofocus: false,
                                            style: TextStyle(
                                                fontSize: 17.0,
                                                color: Colors.black
                                            ),
                                            decoration: InputDecoration(
                                                hintText: 'Enter Item Name',
                                                contentPadding: EdgeInsets.fromLTRB(15.0, 8.0, 15.0, 8.0),
                                                hintStyle: TextStyle(color: Color(0x99999999)),
                                                border: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(5.0)
                                                )
                                            ),
                                        ),
                                    ),
                                    Container(
                                        padding: EdgeInsets.only(bottom: 8.0),
                                        child: Text("Item Category & Subcategory :"),
                                    ),
                                    Container(
                                        child: Row(
                                            children: <Widget>[
                                                Container(
                                                    padding: EdgeInsets.fromLTRB(8.0, 3.0, 8.0, 3.0),
                                                    decoration: BoxDecoration(
                                                        border: Border.all(
                                                            color: Color(0x99999999),
                                                        ),
                                                        borderRadius: BorderRadius.circular(5.0)
                                                    ),
                                                    child: InkWell(
                                                        onTap: () => this.openSelectAlertCategory(),
                                                        child: Container(
                                                            padding: EdgeInsets.all(5.0),
                                                            child: Text(
                                                                this.selectedCategory,
                                                                textAlign: TextAlign.center,
                                                                overflow: TextOverflow.ellipsis,
                                                                style: TextStyle(
                                                                    fontSize: 15.0
                                                                )
                                                            ),
                                                        ),
                                                    ),
                                                ),
                                                SizedBox(width: 10.0),
                                                Expanded(
                                                    child: Container(
                                                        padding: EdgeInsets.fromLTRB(8.0, 3.0, 8.0, 3.0),
                                                        decoration: BoxDecoration(
                                                            border: Border.all(
                                                                color: Color(0x99999999),
                                                            ),
                                                            borderRadius: BorderRadius.circular(5.0)
                                                        ),
                                                        child: InkWell(
                                                            onTap: () => this.openSelectAlertSubcategory(),
                                                            child: Container(
                                                                padding: EdgeInsets.all(5.0),
                                                                child: Text(
                                                                    this.selectedSubcategory,
                                                                    textAlign: TextAlign.center,
                                                                    overflow: TextOverflow.ellipsis,
                                                                    style: TextStyle(
                                                                        fontSize: 15.0
                                                                    )
                                                                ),
                                                            ),
                                                        ),
                                                    ),
                                                ),
                                            ],
                                        ),
                                    )
                                ],
                            )
                        ),
                    ),
                    CategoriesSelectList(categories: this.categories, onChange: () {

                    }),
                ],
            )
        );
    }
}