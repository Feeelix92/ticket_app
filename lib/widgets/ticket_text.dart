import '../colors.dart';
import 'package:flutter/material.dart';

class TicketText extends StatefulWidget {
  const TicketText({
    Key? key,
    required String text,
  }) : _text = text, super(key: key);
  final String _text;

  @override
  State<TicketText> createState() => _TicketTextState();
}

class _TicketTextState extends State<TicketText> {
  @override
  Widget build(BuildContext context) {
    return Text(widget._text,
        style: TextStyle(
          color: accentColor1,
        ));
  }
}