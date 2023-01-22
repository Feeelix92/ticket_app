import 'package:flutter/material.dart';
import 'package:ticket_app/colors.dart';

class DynamicDropdownButton extends StatefulWidget {
  const DynamicDropdownButton({
    Key? key,
    required List<String> list,
  })  : _list = list,
        super(key: key);
  final List<String> _list;

  @override
  State<DynamicDropdownButton> createState() => _DynamicDropdownButtonState();
}

class _DynamicDropdownButtonState extends State<DynamicDropdownButton> {
  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: widget._list.first,
      icon: Icon(Icons.arrow_downward, color: accentColor1),
      elevation: 16,
      style: TextStyle(color: accentColor1),
      underline: Container(
        height: 2,
        color: secondaryColor,
      ),
      onChanged: (String? value) {
        // This is called when the user selects an item.
        setState(() {
          widget._list.first = value!;
        });
      },
      items: widget._list.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }
}
