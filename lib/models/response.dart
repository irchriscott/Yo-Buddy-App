class ResponseService{

    final String type;
    final dynamic text;

    ResponseService({this.type, this.text});

    factory ResponseService.fromJson(Map<String, dynamic> json){
        return new ResponseService(
            type: json['type'],
            text: json['text']
        );
    }
}