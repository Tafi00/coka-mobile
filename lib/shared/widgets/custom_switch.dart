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
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Hiển thị %',
          style: TextStyle(fontSize: 12, color: Color(0xFF646A73)),
        ),
        Switch(
          value: _value,
          onChanged: (value) {
            setState(() {
              _value = value;
            });
            widget.onChanged(value);
          },
          activeColor: const Color(0xFF5C33F0),
        ),
      ],
    );
  }
}
