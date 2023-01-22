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
  String dropdownValue = "...";

  @override
  initState() {
    super.initState();
    dropdownValue = widget._list.first;
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      isExpanded: true,
      value: dropdownValue,
      icon: Icon(Icons.arrow_downward, color: accentColor1),
      elevation: 16,
      style: TextStyle(color: accentColor1),
      underline: Container(
        height: 1,
        color: secondaryColor,
      ),
      onChanged: (String? value) {
        // This is called when the user selects an item.
        setState(() {
          dropdownValue = value!;
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
