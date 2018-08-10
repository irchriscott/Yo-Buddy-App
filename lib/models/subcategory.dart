import 'category.dart';
import 'package:flutter/material.dart';

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

    List<Subcategory> getSubcategoryList(dynamic json){
        if(json != null){
            List data = json.toList();
            List<Subcategory> subcategories = List<Subcategory>();
            data.forEach((subcategory){
                subcategories.add(Subcategory.fromJson(subcategory));
            });
            return subcategories;
        }
        return [];
    }

    List<Widget> subcategoriesRadio(VoidCallback onSubcategorySelected(i), List<Subcategory> subcategories, int subcategoryID, String selectedCategory){
        List<Widget> subcategoriesRadios = List<Widget>();
        subcategories.forEach((subcategory){
            subcategoriesRadios.add(
                RadioListTile(
                    value: subcategory.id,
                    groupValue: subcategoryID,
                    onChanged: (i) => onSubcategorySelected(i),
                    title: Text(subcategory.name),
                    subtitle: Text("Category : " + selectedCategory, overflow: TextOverflow.ellipsis),
                )
            );
        });
        return subcategoriesRadios;
    }

}