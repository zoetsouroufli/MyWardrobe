import 'package:flutter/material.dart';

class FriendAvatar extends StatelessWidget {
  final String imagePath;

  const FriendAvatar({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 38,
      backgroundImage: AssetImage(imagePath),
    );
  }
}
