import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:buddyapp/models/category.dart';
import 'package:buddyapp/models/subcategory.dart';
import 'package:buddyapp/models/utils.dart';
import 'package:buddyapp/models/user.dart';
import 'package:buddyapp/models/item.dart';
import 'package:buddyapp/providers/yobuddy.dart';
import 'package:buddyapp/providers/auth.dart';
import 'package:buddyapp/providers/app.dart';
import 'package:buddyapp/providers/notification.dart';
import 'package:buddyapp/UI/categories_select_list.dart';
import 'package:buddyapp/UI/subcategories_select_list.dart';
import 'package:buddyapp/UI/currencies_select_list.dart';
import 'package:buddyapp/UI/pers_select_list.dart';
import 'package:buddyapp/UI/text_editor.dart';
import 'package:buddyapp/UI/popup.dart';
import 'package:buddyapp/UI/loading_popup.dart';

class EditItemForm extends StatefulWidget{

    EditItemForm({Key key, @required this.item}) : super(key : key);

    final Item item;

    @override
    _EditItemFormState createState() => _EditItemFormState();
}

class _EditItemFormState extends State<EditItemForm> {

    bool isSaving = false;
    bool isOverlayVisible = false;
    bool isLoadingVisible = false;
    bool isSaveLoadingVisible = false;
    bool isAvailable;

    List<Category> categories = [];
    List<Subcategory> subcategories = [];
    List<Currency> currencies = [];
    List<Per> pers = [];

    String _platformMessage = 'No Error';
    List<File> images = [];
    int maxImageNo = 10;
    bool selectSingleImage = false;

    String selectedCategory = "";
    String selectedSubcategory = "";
    String selectedCurrency = "";
    String selectedPer = "";

    String _message = "";
    String _type = "";

    bool showCategories = false;
    bool showSubcategories = false;
    bool showCurrencies = false;
    bool showPers = false;
    bool showTextEditor = false;

    TextEditingController _itemNameCtrl = TextEditingController();
    TextEditingController _itemPriceCtrl = TextEditingController();
    TextEditingController _itemQuantityCtrl = TextEditingController();
    TextEditingController _itemDescriptionCtrl = TextEditingController();

    List<ItemImage> itemImages = [];

    String descriptionTextValue = "Enter Item Description";
    Color descriptionTextColor = Color(0x99999999);

    int categoryID = 0;
    int subcategoryID = 0;
    String currency = "";
    String per = "";

    User sessionUser;
    int userID;
    String sessionToken;
    PushNotification pushNotification;

    @override
    void initState() {
        this.getCategoriesList();
        this.getUserData();

        this.currencies = Currency().getCurrencies();
        this.pers = Per().getPers();

        this.currency = widget.item.currency;
        this.per = widget.item.per;

        this.selectedCurrency = Currency().getCurrencies().firstWhere((currency) => currency.abbr == widget.item.currency).name;
        this.selectedPer = Per().getPers().firstWhere((per) => per.per == widget.item.per).perName;

        _itemNameCtrl.text = widget.item.name;
        _itemPriceCtrl.text = widget.item.price.toString();
        _itemQuantityCtrl.text = widget.item.count.toString();
        _itemDescriptionCtrl.text = widget.item.description;
        isAvailable = widget.item.isAvailable;

        this.itemImages = widget.item.images;

        Timer(Duration(seconds: 1), (){ setState((){
            this.pushNotification = PushNotification(user: this.sessionUser, token: this.sessionToken, context: context);
            this.pushNotification.initNotification();
        }); });

        super.initState();
    }

    @override
    void dispose(){
        this._itemNameCtrl.dispose();
        this._itemPriceCtrl.dispose();
        this._itemQuantityCtrl.dispose();
        this._itemDescriptionCtrl.dispose();
        this.pushNotification.dispose();
        super.dispose();
    }

    void _setUser(User user){ this.sessionUser = user; }

    void _setUserID(int id){ this.userID = id; }

    void _setSessionToken(String token){ this.sessionToken = token; }

    void getUserData(){
        Authentication().getSessionUser().then((value) => _setUserID(value.id));
        Authentication().getSessionUser().then((value) => _setUser(value));
        Authentication().getUserToken().then((value) => _setSessionToken(value));
    }

    void updateItem(){
        Item item = Item(
            id: widget.item.id,
            name: this._itemNameCtrl.text,
            category: this.categories.firstWhere((category) => category.id == this.categoryID),
            subcategory: this.subcategories.firstWhere((subcategory) => subcategory.id == this.subcategoryID),
            price: this._itemPriceCtrl.text != "" ? double.parse(this._itemPriceCtrl.text) : 0.0,
            currency: this.currency,
            per: this.per,
            description: this._itemDescriptionCtrl.text,
            count: this._itemQuantityCtrl.text != "" ? int.parse(this._itemQuantityCtrl.text) : 0,
            imageFiles: this.images,
            isAvailable: this.isAvailable
        );
        setState(() {
            this.isSaving = true;
            this.isLoadingVisible = true;
        });
        item.saveOrUpdateItem(this.userID.toString(), this.sessionToken).then((response){
            setState((){
                this.isLoadingVisible = false;
                this._message = response.text;
                this._type = response.type;
                this.isSaveLoadingVisible = true;
                this.isSaving = false;
            });
        });
    }

    void getCategoriesList(){
        YoBuddyService().getAllCategories().then((data){
            setState(() {
                this.categories = data.toList();
                this.subcategories = data.toList()[0].subcategories.toList();

                this.selectedCategory = widget.item.category.name;
                this.selectedSubcategory = widget.item.subcategory.name;

                this.categoryID = widget.item.category.id;
                this.subcategoryID = widget.item.subcategory.id;
            });
        });
    }

    void openSelectAlertCategory(){ setState(() { this.showCategories = true; }); }

    void openSelectAlertSubcategory(){ setState(() { this.showSubcategories = true; }); }

    void openSelectCurrency(){ setState(() { this.showCurrencies = true; }); }

    void openSelectPer(){ setState(() { this.showPers = true; }); }

    void openTextEditor(){ setState(() { this.showTextEditor = true; }); }

    void onCategorySelected(int value){
        setState(() {
            Category category = this.categories.firstWhere((cat) => cat.id == value);
            this.categoryID = value;

            this.subcategories = category.subcategories.toList();
            this.selectedCategory = category.name;

            this.selectedSubcategory = category.subcategories.toList()[0].name;
            this.subcategoryID = category.subcategories.toList()[0].id;
        });
    }

    void onSubcategorySelected(int value){
        setState(() {
            this.subcategoryID = value;
            Subcategory subcategory = this.subcategories.firstWhere((subcategory) => subcategory.id == value);
            this.selectedSubcategory = subcategory.name;
        });
    }

    void onCurrencySelected(String value){
        setState(() {
            this.currency = value;
            Currency currency = this.currencies.firstWhere((currency) => currency.abbr == value);
            this.selectedCurrency = currency.name;
        });
    }

    void onPerSelected(String value){
        setState(() {
            this.per = value;
            Per per = this.pers.firstWhere((per) => per.per == value);
            this.selectedPer = per.perName;
        });
    }

    void onIsAvailableChanged(bool x){ setState((){ this.isAvailable = x; }); }

    List<Widget> categoriesRadio(){
        List<Widget> categoriesRadios = List<Widget>();
        this.categories.forEach((category){
            categoriesRadios.add(
                RadioListTile(
                    value: category.id,
                    groupValue: categoryID,
                    onChanged: (i) => this.onCategorySelected(i),
                    title: Text(category.name),
                    subtitle: Text(category.description, overflow: TextOverflow.ellipsis),
                )
            );
        });
        return categoriesRadios;
    }

    List<Widget> subcategoriesRadio(){
        List<Widget> subcategoriesRadios = List<Widget>();
        this.subcategories.forEach((subcategory){
            subcategoriesRadios.add(
                RadioListTile(
                    value: subcategory.id,
                    groupValue: subcategoryID,
                    onChanged: (i) => this.onSubcategorySelected(i),
                    title: Text(subcategory.name),
                    subtitle: Text("Category : " + this.selectedCategory, overflow: TextOverflow.ellipsis),
                )
            );
        });
        return subcategoriesRadios;
    }

    List<Widget> currenciesRadio(){
        List<Widget> currenciesRadios = List<Widget>();
        this.currencies.forEach((currency){
            currenciesRadios.add(
                RadioListTile(
                    value: currency.abbr,
                    groupValue: this.currency,
                    onChanged: (i) => this.onCurrencySelected(i),
                    title: Text(currency.name),
                    subtitle: Text(currency.abbr, overflow: TextOverflow.ellipsis),
                )
            );
        });
        return currenciesRadios;
    }

    List<Widget> persRadio(){
        List<Widget> persRadio = List<Widget>();
        this.pers.forEach((per){
            persRadio.add(
                RadioListTile(
                    value: per.per,
                    groupValue: this.per,
                    onChanged: (i) => this.onPerSelected(i),
                    title: Text(per.perName),
                    subtitle: Text(per.description, overflow: TextOverflow.ellipsis),
                )
            );
        });
        return persRadio;
    }

    Future<void> pickImages() async {
        setState(() {
            images = [];
        });

        List resultList = [];
        String error;

        try {
            resultList = await MultiImagePicker.pickImages(maxImages: maxImageNo);
        } catch (e) {
            error = e.message;
        }

        if (!mounted) return;

        setState(() {
            images = resultList;
            if (error == null) _platformMessage = 'No Error Dectected';
        });
    }

    Future<void> deleteItemImage(ItemImage image, int index){
        showDialog<Null>(
            context: context,
            barrierDismissible: false, // user must tap button!
            builder: (BuildContext context) {
                return AlertDialog(
                    title: Text("Delete Item Image", style: TextStyle(fontWeight: FontWeight.bold)),
                    content: SingleChildScrollView(
                        child: ListBody(
                            children: <Widget>[
                                Text("Do you really want to delete this image ?"),
                            ],
                        ),
                    ),
                    actions: <Widget>[
                        FlatButton(
                            child: Text("YES", style: TextStyle(color: Color(0xFFCC8400))),
                            onPressed: () {
                                setState((){
                                    this.isLoadingVisible = true;
                                });
                                image.deleteImage(widget.item.id.toString(), sessionToken).then((response){
                                    setState(() {
                                        if(response.type == "success") this.itemImages.removeAt(index);
                                        this._message = response.text;
                                        this._type = response.type;
                                        this.isLoadingVisible = false;
                                        this.isOverlayVisible = true;
                                    });
                                });
                                Navigator.of(context).pop();
                            },
                        ),
                        FlatButton(
                            child: Text("NO", style: TextStyle(color: Colors.redAccent)),
                            onPressed: () { Navigator.of(context).pop(); },
                        ),
                    ],
                );
            },
        );
        return null;
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
                                            "Edit Item",
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
                                            onTap: () => this.updateItem(),
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
                                    ),
                                    Container(
                                        padding: EdgeInsets.only(bottom: 8.0, top: 8.0),
                                        child: Text("Item Borrow Price :"),
                                    ),
                                    Container(
                                        padding: EdgeInsets.only(bottom: 8.0),
                                        child: TextFormField(
                                            controller: _itemPriceCtrl,
                                            autofocus: false,
                                            keyboardType: TextInputType.numberWithOptions(signed: false, decimal: false),
                                            style: TextStyle(
                                                fontSize: 17.0,
                                                color: Colors.black
                                            ),
                                            decoration: InputDecoration(
                                                hintText: 'Enter Item Price',
                                                contentPadding: EdgeInsets.fromLTRB(15.0, 8.0, 15.0, 8.0),
                                                hintStyle: TextStyle(color: Color(0x99999999)),
                                                border: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(5.0)
                                                )
                                            ),
                                        ),
                                    ),
                                    Container(
                                        child: Row(
                                            children: <Widget>[
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
                                                            onTap: () => this.openSelectCurrency(),
                                                            child: Container(
                                                                padding: EdgeInsets.all(5.0),
                                                                child: Text(
                                                                    this.selectedCurrency,
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
                                                SizedBox(width: 10.0),
                                                Container(
                                                    padding: EdgeInsets.fromLTRB(8.0, 3.0, 8.0, 3.0),
                                                    decoration: BoxDecoration(
                                                        border: Border.all(
                                                            color: Color(0x99999999),
                                                        ),
                                                        borderRadius: BorderRadius.circular(5.0)
                                                    ),
                                                    child: InkWell(
                                                        onTap: () => this.openSelectPer(),
                                                        child: Container(
                                                            padding: EdgeInsets.all(5.0),
                                                            child: Text(
                                                                this.selectedPer,
                                                                textAlign: TextAlign.center,
                                                                overflow: TextOverflow.ellipsis,
                                                                style: TextStyle(
                                                                    fontSize: 15.0
                                                                )
                                                            ),
                                                        ),
                                                    ),
                                                ),
                                            ],
                                        ),
                                    ),
                                    Container(
                                        padding: EdgeInsets.only(bottom: 8.0, top: 8.0),
                                        child: Text("Item Quantity :"),
                                    ),
                                    Container(
                                        padding: EdgeInsets.only(bottom: 8.0),
                                        child: TextFormField(
                                            controller: _itemQuantityCtrl,
                                            autofocus: false,
                                            keyboardType: TextInputType.numberWithOptions(signed: false, decimal: false),
                                            style: TextStyle(
                                                fontSize: 17.0,
                                                color: Colors.black
                                            ),
                                            decoration: InputDecoration(
                                                hintText: 'Enter Item Quantity',
                                                contentPadding: EdgeInsets.fromLTRB(15.0, 8.0, 15.0, 8.0),
                                                hintStyle: TextStyle(color: Color(0x99999999)),
                                                border: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(5.0)
                                                )
                                            ),
                                        ),
                                    ),
                                    Container(
                                        padding: EdgeInsets.only(bottom: 8.0, top: 8.0),
                                        child: Text("Item Description :"),
                                    ),
                                    Container(
                                        padding: EdgeInsets.only(bottom: 8.0),
                                        child: TextFormField(
                                            controller: _itemDescriptionCtrl,
                                            autofocus: false,
                                            maxLines: 10,
                                            style: TextStyle(
                                                fontSize: 17.0,
                                                color: Colors.black
                                            ),
                                            decoration: InputDecoration(
                                                hintText: 'Enter Item Description',
                                                contentPadding: EdgeInsets.fromLTRB(15.0, 8.0, 15.0, 8.0),
                                                hintStyle: TextStyle(color: Color(0x99999999)),
                                                border: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(5.0)
                                                )
                                            ),
                                        ),
                                    ),
                                    Container(
                                        child: CheckboxListTile(
                                            value: this.isAvailable,
                                            title: Text("Is Available"),
                                            onChanged: (x) => onIsAvailableChanged(x),
                                        )
                                    ),
                                    Container(
                                        padding: EdgeInsets.only(bottom: 8.0, top: 8.0),
                                        child: Text("Item Images :"),
                                    ),
                                    Container(
                                        padding: EdgeInsets.only(bottom: 10.0),
                                        child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: <Widget>[
                                                itemImages.length <= 0 ? Container() : SizedBox(
                                                    width: 400.0,
                                                    height: 200.0,
                                                    child: ListView.builder(
                                                        scrollDirection: Axis.horizontal,
                                                        itemBuilder: (BuildContext context, int index) =>
                                                            InkWell(
                                                                onLongPress: () => this.deleteItemImage(itemImages[index], index),
                                                                child: Padding(
                                                                    padding: EdgeInsets.all(5.0),
                                                                    child: Image.network(itemImages[index].imageUrl)
                                                                ),
                                                            ),
                                                        itemCount: itemImages.length,
                                                    ),
                                                ),
                                            ],
                                        ),
                                    ),
                                    Container(
                                        child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: <Widget>[
                                                images.length <= 0 ? Container() : SizedBox(
                                                    width: 400.0,
                                                    height: 200.0,
                                                    child: ListView.builder(
                                                        scrollDirection: Axis.horizontal,
                                                        itemBuilder: (BuildContext context, int index) =>
                                                            Padding(
                                                                padding: EdgeInsets.all(5.0),
                                                                child: Image.file(images[index])
                                                            ),
                                                        itemCount: images.length,
                                                    ),
                                                ),
                                                Container(
                                                    padding: EdgeInsets.only(top: 8.0),
                                                    child: Row(
                                                        children: <Widget>[
                                                            Expanded(
                                                                child: RaisedButton.icon(
                                                                    onPressed: pickImages,
                                                                    icon: Icon(Icons.image),
                                                                    label: Text("Add Item Images".toUpperCase()),
                                                                ),
                                                            ),
                                                        ],
                                                    ),
                                                ),
                                            ],
                                        ),
                                    ),
                                ],
                            )
                        ),
                    ),
                    (this.showCategories == true) ? CategoriesSelectList(categories: this.categoriesRadio(), onClose: (){
                        setState(() {
                            this.showCategories = false;
                            this.showSubcategories = true;
                        });
                    }) : Container(),
                    (this.showSubcategories == true) ? SubcategoriesSelectList(subcategories: this.subcategoriesRadio(), onClose: (){
                        setState(() {
                            this.showSubcategories = false;
                        });
                    }) : Container(),
                    (this.showCurrencies == true) ? CurrenciesSelectList(currencies: this.currenciesRadio(), onClose: (){
                        setState(() {
                            this.showCurrencies = false;
                            this.showPers = true;
                        });
                    }) : Container(),
                    (this.showPers == true) ? PersSelectList(pers: this.persRadio(), onClose: (){
                        setState(() {
                            this.showPers = false;
                        });
                    }) : Container(),
                    (isOverlayVisible == true) ? PopupOverlay(message: this._message, type: this._type, onTap: (){ setState(() { this.isOverlayVisible = false; }); }) : Container(),
                    (isSaveLoadingVisible == true) ? PopupOverlay(message: this._message, type: this._type, onTap: (){
                        setState(() { this.isSaveLoadingVisible = false;});
                        if(this._type == "success") Navigator.of(context).pop();
                    }) : Container(),
                    (isLoadingVisible == true) ? LoadingOverlay() : Container()
                ],
            )
        );
    }
}