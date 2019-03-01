import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
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

class NewItemForm extends StatefulWidget{
    @override
    _NewItemFormState createState() => _NewItemFormState();
}

class _NewItemFormState extends State<NewItemForm> {

    bool isSaving = false;
    bool isLoadingVisible = false;
    bool isSaveLoadingVisible = false;

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

    bool showCategories = false;
    bool showSubcategories = false;
    bool showCurrencies = false;
    bool showPers = false;
    bool showTextEditor = false;

    TextEditingController _itemNameCtrl = TextEditingController();
    TextEditingController _itemPriceCtrl = TextEditingController();
    TextEditingController _itemQuantityCtrl = TextEditingController();
    TextEditingController _itemDescriptionCtrl = TextEditingController();
    TextEditingController _itemSaleValueCtrl = TextEditingController();

    String descriptionTextValue = "Enter Item Description";
    Color descriptionTextColor = Color(0x99999999);

    String _message = "";
    String _type = "";

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
        this.isSaving = false;
        super.initState();
        this.getCategoriesList();
        this.getUserData();

        this.currencies = Currency().getCurrencies();
        this.pers = Per().getPers();

        this.currency = Currency().getCurrencies()[0].abbr;
        this.per = Per().getPers()[0].per;

        this.selectedCurrency = Currency().getCurrencies()[0].name;
        this.selectedPer = Per().getPers()[0].perName;

        Timer(Duration(seconds: 1), (){ setState((){
            this.pushNotification = PushNotification(user: this.sessionUser, token: this.sessionToken, context: context);
            this.pushNotification.initNotification();
        }); });

        _itemQuantityCtrl.text = "1";
    }

    @override
    void dispose(){
        this._itemNameCtrl.dispose();
        this._itemPriceCtrl.dispose();
        this._itemQuantityCtrl.dispose();
        this._itemDescriptionCtrl.dispose();
        this._itemSaleValueCtrl.dispose();
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

    void saveNewItem(){
        Item item = Item(
            name: this._itemNameCtrl.text,
            category: this.categories.firstWhere((category) => category.id == this.categoryID),
            subcategory: this.subcategories.firstWhere((subcategory) => subcategory.id == this.subcategoryID),
            price: this._itemPriceCtrl.text != "" ? double.parse(this._itemPriceCtrl.text) : 0.0,
            currency: this.currency,
            per: this.per,
            description: this._itemDescriptionCtrl.text,
            count: this._itemQuantityCtrl.text != "" ? int.parse(this._itemQuantityCtrl.text) : 0,
            imageFiles: this.images,
            saleValue: this._itemSaleValueCtrl.text != "" ? double.parse(this._itemSaleValueCtrl.text) : 0.0,
            isAvailable: true
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

                this.selectedCategory = this.categories[0].name;
                this.selectedSubcategory = this.subcategories[0].name;

                this.categoryID = this.categories[0].id;
                this.subcategoryID = this.subcategories[0].id;
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
            if (error == null) _platformMessage = 'No Error Dectected';
        });
    }

    @override
    Widget build(BuildContext context) {
        return Stack(
            fit: StackFit.expand,
            children: <Widget>[
                Scaffold(
                    backgroundColor: Colors.white,
                    body: CustomScrollView(
                        slivers: <Widget>[
                            SliverAppBar(
                                expandedHeight: 200.0,
                                pinned: true,
                                floating: false,
                                snap: false,
                                leading: IconButton(
                                    onPressed: (){
                                        Navigator.of(context).pop();
                                    },
                                    icon: Icon(Icons.close, color: Colors.white)
                                ),
                                flexibleSpace: FlexibleSpaceBar(
                                    title: Text("Add New Item"),
                                    centerTitle: true,
                                ),
                                actions: <Widget>[
                                    Container(
                                        child: (this.isSaving) ? Container(
                                            padding: EdgeInsets.only(right: 20.0),
                                            height: 20.0,
                                            width: 20.0,
                                            child: Center(
                                                child: CupertinoActivityIndicator(radius: 10.0)
                                            )
                                        ) :
                                        Container(
                                            padding: EdgeInsets.only(top: 18.0, right: 12.0),
                                            child: InkWell(
                                                onTap: () => this.saveNewItem(),
                                                child: Text("Save".toUpperCase(), style: TextStyle(color: Colors.white, fontSize: 14.0)),
                                            ),
                                        )
                                    )
                                ],
                            ),
                            SliverList(
                                delegate: SliverChildListDelegate(
                                    <Widget>[
                                        Container(
                                            padding: EdgeInsets.all(12.0),
                                            child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                                        child: Text("Sale Value (Currency For Price):"),
                                                    ),
                                                    Container(
                                                        padding: EdgeInsets.only(bottom: 8.0),
                                                        child: TextFormField(
                                                            controller: _itemSaleValueCtrl,
                                                            autofocus: false,
                                                            keyboardType: TextInputType.numberWithOptions(signed: false, decimal: false),
                                                            style: TextStyle(
                                                                fontSize: 17.0,
                                                                color: Colors.black
                                                            ),
                                                            decoration: InputDecoration(
                                                                hintText: 'Enter Sale Value',
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
                                        )
                                    ]
                                )
                            )
                        ],
                    )
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
                (isSaveLoadingVisible == true) ? PopupOverlay(message: this._message, type: this._type, onTap: (){
                    setState(() { this.isSaveLoadingVisible = false;});
                    if(this._type == "success") Navigator.of(context).pop();
                }) : Container(),
                (isLoadingVisible == true) ? LoadingOverlay() : Container()
            ],
        );
    }
}