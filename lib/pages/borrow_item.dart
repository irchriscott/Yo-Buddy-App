import 'dart:async';
import 'package:flutter/material.dart';
import 'package:buddyapp/models/utils.dart';
import 'package:buddyapp/models/user.dart';
import 'package:buddyapp/models/item.dart';
import 'package:buddyapp/models/borrow.dart';
import 'package:buddyapp/providers/auth.dart';
import 'package:buddyapp/providers/notification.dart';
import 'package:buddyapp/UI/currencies_select_list.dart';
import 'package:buddyapp/UI/pers_select_list.dart';
import 'package:buddyapp/UI/text_editor.dart';
import 'package:buddyapp/UI/popup.dart';
import 'package:buddyapp/UI/loading_popup.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:intl/intl.dart';

class BorrowItemForm extends StatefulWidget{
    BorrowItemForm({Key key, @required this.item}) : super(key : key);
    final Item item;
    _BorrowItemState createState() => _BorrowItemState();
}

class _BorrowItemState extends State<BorrowItemForm>{


    bool isSaving = false;
    bool isOverlayVisible = false;
    bool isLoadingVisible = false;
    bool isSaveLoadingVisible = false;

    List<Currency> currencies = [];
    List<Per> pers = [];


    String selectedCurrency = "";
    String selectedPer = "";
    String selectedFromDate = "";

    String _message = "";
    String _type = "";

    bool showCurrencies = false;
    bool showPers = false;
    bool showTextEditor = false;

    TextEditingController _itemPriceCtrl = TextEditingController();
    TextEditingController _itemQuantityCtrl = TextEditingController();
    TextEditingController _borrowDescriptionCtrl = TextEditingController();
    TextEditingController _numberOfTimes = TextEditingController();

    String descriptionTextValue = "Enter Borrow Conditions";
    Color descriptionTextColor = Color(0x99999999);

    String currency = "";
    String per = "";

    User sessionUser;
    int userID;
    String sessionToken;
    PushNotification pushNotification;

    @override
    void initState() {
        this.getUserData();

        this.currencies = Currency().getCurrencies();
        this.pers = Per().getPers();

        this.currency = widget.item.currency;
        this.per = widget.item.per;

        this.selectedCurrency = Currency().getCurrencies().firstWhere((currency) => currency.abbr == widget.item.currency).name;
        this.selectedPer = Per().getPers().firstWhere((per) => per.per == widget.item.per).perName;

        _itemPriceCtrl.text = widget.item.price.toString();

        Timer(Duration(seconds: 1), (){ setState((){
            this.pushNotification = PushNotification(user: this.sessionUser, token: this.sessionToken);
            this.pushNotification.initNotification();
        }); });

        super.initState();
    }

    @override
    void dispose(){
        this.pushNotification.dispose();
        this._itemQuantityCtrl.dispose();
        this._itemPriceCtrl.dispose();
        this._borrowDescriptionCtrl.dispose();
        this._numberOfTimes.dispose();
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

    void openSelectCurrency(){ setState(() { this.showCurrencies = true; }); }

    void openSelectPer(){ setState(() { this.showPers = true; }); }

    void openTextEditor(){ setState(() { this.showTextEditor = true; }); }

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
    
    void setFromDate(String date){ setState((){ this.selectedFromDate = date; }); }

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

    void saveBorrow(){
        setState(() { this.isSaving = true; this.isLoadingVisible = true; });
        if(this._itemPriceCtrl.text != "" && this._numberOfTimes.text != "" && this._itemQuantityCtrl.text != "" && this.selectedFromDate != "") {
            Borrow borrow = Borrow(
                item: this.widget.item,
                price: double.parse(this._itemPriceCtrl.text),
                currency: this.selectedCurrency,
                per: this.selectedPer,
                numbers: int.parse(this._numberOfTimes.text),
                conditions: this._borrowDescriptionCtrl.text,
                count: int.parse(this._itemQuantityCtrl.text),
                fromDate: this.selectedFromDate
            );

            borrow.saveBorrow(this.sessionToken).then((response) {
                setState(() {
                    this._message = response.text;
                    this._type = response.type;
                    this.isSaving = false;
                    this.isLoadingVisible = false;
                    if (response.type == "success") { this.isSaveLoadingVisible = true; }
                    else { this.isOverlayVisible = true; }
                });
            });
        } else {
            setState((){
                this._message = "Fill all Fiels With Right Data !!!";
                this._type = "error";
                this.isSaving = false;
                this.isLoadingVisible = false;
                this.isOverlayVisible = true;
            });
        }
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
                                            "Borrow Item",
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
                                            onTap: () => this.saveBorrow(),
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
                                        child: Text(
                                            this.widget.item.name,
                                            style: TextStyle(
                                                fontSize: 17.0,
                                                fontWeight: FontWeight.bold
                                            ),
                                        ),
                                    ),
                                    Container(
                                        padding: EdgeInsets.only(bottom: 8.0, top: 8.0),
                                        child: Text("Propose Price :"),
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
                                        child: Text("From Date :"),
                                    ),
                                    DateTimePickerFormField(
                                        format: DateFormat("yyyy/M/d HH:mm"),
                                        onChanged: (date) => this.setFromDate(date.toString()),
                                        initialDate: DateTime.now(),
                                        initialTime: TimeOfDay(hour: 9, minute: 0),
                                        decoration: InputDecoration(
                                            hintText: 'YYYY/MM/DD H:M',
                                            contentPadding: EdgeInsets.fromLTRB(15.0, 8.0, 15.0, 8.0),
                                            hintStyle: TextStyle(color: Color(0x99999999)),
                                            border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(5.0)
                                            ),
                                        ),
                                    ),
                                    Container(
                                        padding: EdgeInsets.only(bottom: 8.0, top: 8.0),
                                        child: Text("Number Of Times :"),
                                    ),
                                    Container(
                                        padding: EdgeInsets.only(bottom: 8.0),
                                        child: TextFormField(
                                            controller: _numberOfTimes,
                                            autofocus: false,
                                            keyboardType: TextInputType.numberWithOptions(signed: false, decimal: false),
                                            style: TextStyle(
                                                fontSize: 17.0,
                                                color: Colors.black
                                            ),
                                            decoration: InputDecoration(
                                                hintText: 'Enter Number of Times',
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
                                        child: Text("Conditions Description :"),
                                    ),
                                    Container(
                                        padding: EdgeInsets.only(bottom: 8.0),
                                        child: TextFormField(
                                            controller: _borrowDescriptionCtrl,
                                            autofocus: false,
                                            maxLines: 10,
                                            style: TextStyle(
                                                fontSize: 17.0,
                                                color: Colors.black
                                            ),
                                            decoration: InputDecoration(
                                                hintText: 'Enter Borrow Conditions',
                                                contentPadding: EdgeInsets.fromLTRB(15.0, 8.0, 15.0, 8.0),
                                                hintStyle: TextStyle(color: Color(0x99999999)),
                                                border: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(5.0)
                                                )
                                            ),
                                        ),
                                    ),
                                ],
                            )
                        ),
                    ),
                    (this.showCurrencies == true) ? CurrenciesSelectList(currencies: this.currenciesRadio(), onClose: (){
                        setState(() { this.showCurrencies = false; this.showPers = true; });
                    }) : Container(),
                    (this.showPers == true) ? PersSelectList(pers: this.persRadio(), onClose: (){
                        setState(() { this.showPers = false; });
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