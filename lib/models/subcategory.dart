import 'category.dart';

class Subcategory{
    final int id;
    final Category category;
    final String name;

    Subcategory({this.id, this.category, this.name});

    factory Subcategory.fromJson(Map<String, dynamic> json){
        return new Subcategory(
            id: json['id'],
            name: json['name']
        );
    }

}