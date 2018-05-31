import 'subcategory.dart';

class Category{
    final int id;
    final String name;
    final String description;

    Category({this.id, this.name, this.description});

    factory Category.fromJson(Map<String, dynamic> json){
        return new Category(
            id: json['id'],
            name: json['name'],
            description: json['description']
        );
    }

    List<Subcategory> getSubcategories(){
        return List<Subcategory>().where((subcategory) => subcategory.category.id == this.id).toList();
    }
}