import 'package:flutter/material.dart';

class CustomSearchBar extends StatelessWidget {
  final String hintText;

  const CustomSearchBar({
    Key? key,
    this.hintText = 'Search shops & products', // default value
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}