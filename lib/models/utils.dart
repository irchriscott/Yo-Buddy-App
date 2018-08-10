class Currency{

    String name;
    String abbr;

    Currency({this.name, this.abbr});

    List<Currency> getCurrencies(){
        List<Currency> currencies = new List<Currency>();
        currencies.add(Currency(name: "Ugandian Shilling", abbr: "UGX"));
        currencies.add(Currency(name: "Franc Congolais", abbr: "FC"));
        currencies.add(Currency(name: "United States Dollars", abbr: "USD"));
        return currencies;
    }
}

class Per{

    String per;
    String description;
    Per({this.per, this.description});

    String get perName => "Per " + this.per;

    List<Per> getPers(){
        List<Per> pers = new List();
        pers.add(Per(per: "Hour", description: "60 minutes"));
        pers.add(Per(per: "Day", description: "24 hours, 1440 minutes"));
        pers.add(Per(per: "Week", description: "7 days, 168 hours"));
        pers.add(Per(per: "Month", description: "30 days, 4 weeks"));
        pers.add(Per(per: "Year", description: "12 months, 360 days"));
        return pers;
    }
}