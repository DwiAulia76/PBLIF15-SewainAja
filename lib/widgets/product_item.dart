import 'package:flutter/material.dart';
class ProductItem extends StatelessWidget {
  final String name;
  const ProductItem({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(child: Text(name)),
          Container(
            width: 30,
            height: 30,
            color: Colors.grey.shade300, // Placeholder image
          ),
        ],
      ),
    );
  }
}
