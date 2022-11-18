import 'package:flutter/material.dart';
import 'package:ticket_app/colors.dart';

class BoldStyledText extends StatelessWidget {
  const BoldStyledText({
    Key? key,
    required String text,
  })  : _text = text,
        super(key: key);

  final String _text;

  @override
  Widget build(BuildContext context) {
    return Text(
      _text,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        color: accentColor1,
        fontSize: 18,
      ),
    );
  }
}
