import 'package:flutter/material.dart';

class SwitchRow extends StatefulWidget {
  final Function(bool) onChanged;
  final bool initialValue;

  const SwitchRow({
    super.key,
    required this.onChanged,
    this.initialValue = true,
  });

  @override
  State<SwitchRow> createState() => _SwitchRowState();
}

class _SwitchRowState extends State<SwitchRow> {
  late bool _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Switch(
          thumbIcon: const WidgetStatePropertyAll(Icon(Icons.percent)),
          activeTrackColor: const Color(0xFF483ac1),
          value: _value,
          onChanged: (value) {
            setState(() {
              _value = value;
            });
            widget.onChanged(_value);
          },
        ),
      ],
    );
  }
}
