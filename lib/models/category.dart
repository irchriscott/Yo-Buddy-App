import 'subcategory.dart';

class Category{
    final int id;
    final String name;
    final String description;
    final String uuid;
    final List<Subcategory> subcategories;
    final int items;

    Category({this.id, this.name, this.description, this.uuid, this.subcategories, this.items});

    factory Category.fromJson(Map<String, dynamic> json){
        return new Category(
            id: json['id'],
            name: json['name'],
            description: json['description'],
            uuid: json['uuid'],
            subcategories: Subcategory().getSubcategoryList(json['subcategories']),
            items: json['items']
        );
    }

    List<Subcategory> getSubcategories(){
        return List<Subcategory>().where((subcategory) => subcategory.category.id == this.id).toList();
    }
}