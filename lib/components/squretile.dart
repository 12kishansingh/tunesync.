import 'package:flutter/material.dart';

class SquareTile extends StatelessWidget {
  final String imagepath;
  final Function()? onTap;
  const SquareTile({
    super.key,
    required this.imagepath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.white,
          ),
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey[200],
        ),
        child: Image.asset(
          imagepath,
          height: 40,
        ),
      ),
    );
  }
}
