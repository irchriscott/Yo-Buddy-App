import 'subcategory.dart';
import 'package:flutter/material.dart';

class Category{
    final int id;
    final String name;
    final String icon;
    final String description;
    final String uuid;
    final List<Subcategory> subcategories;
    final int items;

    Category({this.id, this.name, this.icon, this.description, this.uuid, this.subcategories, this.items});

    factory Category.fromJson(Map<String, dynamic> json){
        return new Category(
            id: json['id'],
            name: json['name'],
            icon: json['icon'],
            description: json['description'],
            uuid: json['uuid'],
            subcategories: Subcategory().getSubcategoryList(json['subcategories']),
            items: json['items']
        );
    }

    List<Subcategory> getSubcategories(){
        return List<Subcategory>().where((subcategory) => subcategory.category.id == this.id).toList();
    }

    List<Widget> categoriesRadio(VoidCallback onCategoryChanged(i),  List<Category> categories, int categoryID){
        List<Widget> categoriesRadios = List<Widget>();
        categories.forEach((category){
            categoriesRadios.add(
                RadioListTile(
                    value: category.id,
                    groupValue: categoryID,
                    onChanged: (i) => onCategoryChanged(i),
                    title: Text(category.name),
                    subtitle: Text(category.description, overflow: TextOverflow.ellipsis),
                )
            );
        });
        return categoriesRadios;
    }
}