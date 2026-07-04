import 'package:flutter/cupertino.dart';
import 'package:two_are_one/core/texts.dart';

class DetailsScreen extends StatefulWidget {
  const DetailsScreen({super.key});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Texts(text: "details screen",),
    );
  }
}
