import 'dart:async';
import 'package:buddyapp/providers/app.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:buddyapp/models/utils.dart';
import 'package:buddyapp/models/user.dart';
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
import 'package:flutter_socket_io/flutter_socket_io.dart';
import 'package:flutter_socket_io/socket_io_manager.dart';

class UpdateBorrowItemForm extends StatefulWidget{

    UpdateBorrowItemForm({Key key, @required this.borrow, @required this.onUpdateSuccess}) : super(key : key);
    final Borrow borrow;
    final VoidCallback onUpdateSuccess;

    _UpdateBorrowItemState createState() => _UpdateBorrowItemState();
}

class _UpdateBorrowItemState extends State<UpdateBorrowItemForm>{


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
    TextEditingController _reasonsCtrl = TextEditingController();
    TextEditingController _fromDateCtrl = TextEditingController();

    String descriptionTextValue = "Enter Borrow Conditions";
    Color descriptionTextColor = Color(0x99999999);

    String currency = "";
    String per = "";

    User sessionUser;
    int userID;
    String sessionToken;

    SocketIO socketIO;
    PushNotification pushNotification;

    @override
    void initState() {
        this.getUserData();

        this.currencies = Currency().getCurrencies();
        this.pers = Per().getPers();

        this.currency = widget.borrow.currency;
        this.per = widget.borrow.per;

        this.selectedCurrency = Currency().getCurrencies().firstWhere((currency) => currency.abbr == widget.borrow.currency).name;
        this.selectedPer = Per().getPers().firstWhere((per) => per.per == widget.borrow.per).perName;
        this.selectedFromDate = widget.borrow.fromDate;

        _itemPriceCtrl.text = widget.borrow.price.toString();
        _itemQuantityCtrl.text = widget.borrow.count.toString();
        _reasonsCtrl.text = widget.borrow.reasons;
        _borrowDescriptionCtrl.text = widget.borrow.conditions;
        _numberOfTimes.text = widget.borrow.numbers.toString();
        _fromDateCtrl.text = DateFormat("yyyy-M-d HH:mm").format(DateTime.parse(this.widget.borrow.fromDate));

        Timer(Duration(seconds: 1), (){ setState((){
            this.pushNotification = PushNotification(user: this.sessionUser, token: this.sessionToken, context: context);
            this.pushNotification.initNotification();
        }); });

        this.socketIO = SocketIOManager().createSocketIO(AppProvider().socketURL, "");
        this.socketIO.init();
        this.socketIO.connect();

        super.initState();
    }

    @override
    void dispose(){
        this.pushNotification.dispose();
        this._itemQuantityCtrl.dispose();
        this._itemPriceCtrl.dispose();
        this._borrowDescriptionCtrl.dispose();
        this._numberOfTimes.dispose();
        this._reasonsCtrl.dispose();
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

    void updateBorrow(){
        setState(() { this.isSaving = true; this.isLoadingVisible = true; });
        if(this._itemPriceCtrl.text != "" && this._numberOfTimes.text != "" && this._itemQuantityCtrl.text != "" && this.selectedFromDate != "") {
            Borrow borrow = Borrow(
                id: widget.borrow.id,
                item: this.widget.borrow.item,
                price: double.parse(this._itemPriceCtrl.text),
                currency: this.currency,
                per: this.per,
                numbers: int.parse(this._numberOfTimes.text),
                conditions: this._borrowDescriptionCtrl.text,
                count: int.parse(this._itemQuantityCtrl.text),
                fromDate: this.selectedFromDate,
                status: this.widget.borrow.status,
                lastUpdateBy: this.sessionUser
            );

            borrow.updateBorrow(this.sessionToken).then((response) {
                setState(() {
                    this._message = response.text;
                    this._type = response.type;
                    this.isSaving = false;
                    this.isLoadingVisible = false;
                    if (response.type == "success") { 
                        this.isSaveLoadingVisible = true;
                        this.sendMessageSocket(response.text);
                        this.sendNotificationSocket();
                    }
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


    void sendMessageSocket(String message) async{
        if (this.socketIO != null) {
            String data = '{"item": "${this.widget.borrow.item.id}","borrow": "${this.widget.borrow.id}","receiver": "${(this.sessionUser.id == this.widget.borrow.user.id) ? this.widget.borrow.item.user.id : this.widget.borrow.user.id}","sender": "${this.sessionUser.username}","message": "$message","url": "${this.widget.borrow.messagesURL}","path": "${this.widget.borrow.url}","type": "message", "about": "borrow_message"}';
            this.socketIO.sendMessage("messageSent", data);
        }
    }

    void sendNotificationSocket() async{
        if(this.socketIO != null){
            String data = (this.sessionUser.id == this.widget.borrow.user.id) ? "${this.widget.borrow.item.user.id.toString()}" : "${this.widget.borrow.user.id.toString()}";
            this.socketIO.sendMessage("setNotification", data);
        }
    }

    @override
    Widget build(BuildContext context) {
        return Stack(
            fit: StackFit.expand,
            children: <Widget>[
                Scaffold(
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
                                    title: Text("Update Borrow Item"),
                                    centerTitle: true,
                                    background: Stack(
                                        fit: StackFit.expand,
                                        children: <Widget>[
                                            Image(
                                                image: NetworkImage(AppProvider().baseURL + this.widget.borrow.item.images[0].image.path),
                                                fit: BoxFit.fitWidth,
                                                height: 200.0,
                                            ),
                                            DecoratedBox(
                                                decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                        begin: Alignment(0.0, -1.0),
                                                        end: Alignment(0.0, -0.4),
                                                        colors: <Color>[const Color(0x90000000), const Color(0x00000000)],
                                                    ),
                                                ),
                                            ),
                                        ],
                                    ),
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
                                                onTap: () => this.updateBorrow(),
                                                child: Text("Update".toUpperCase(), style: TextStyle(color: Colors.white, fontSize: 14.0)),
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
                                            color: Colors.white,
                                            child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: <Widget>[
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
                                                        format: DateFormat("yyyy-M-d HH:mm"),
                                                        onChanged: (date) => this.setFromDate(date.toString()),
                                                        controller: _fromDateCtrl,
                                                        initialDate: DateTime.parse(this.widget.borrow.fromDate),
                                                        initialTime: (this.widget.borrow.per.toLowerCase() != "hour") ? TimeOfDay(hour: 9, minute: 0) : DateTime.parse(this.selectedFromDate),
                                                        decoration: InputDecoration(
                                                            hintText: DateFormat("yyyy-M-d HH:mm").format(DateTime.parse(this.widget.borrow.fromDate)),
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
                                        )
                                    ]
                                )
                            )
                        ],
                    )
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
                    if(this._type == "success") {
                        this.widget.onUpdateSuccess();
                    }
                }) : Container(),
                (isLoadingVisible == true) ? LoadingOverlay() : Container()
            ],
        );
    }
}