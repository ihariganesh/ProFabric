import 'package:flutter/material.dart';

class EcoFlowToggle extends StatefulWidget {
  final bool initialValue;
  final ValueChanged<bool> onChanged;

  const EcoFlowToggle({
    Key? key,
    this.initialValue = false,
    required this.onChanged,
  }) : super(key: key);

  @override
  _EcoFlowToggleState createState() => _EcoFlowToggleState();
}

class _EcoFlowToggleState extends State<EcoFlowToggle> {
  late bool _isEcoMode;

  @override
  void initState() {
    super.initState();
    _isEcoMode = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: _isEcoMode ? Colors.green.shade50 : Colors.white,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: _isEcoMode ? Colors.green : Colors.grey.shade300,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              Icons.eco,
              color: _isEcoMode ? Colors.green : Colors.grey,
              size: 32,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "EcoFlow Mode",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Optimize suppliers for lowest carbon footprint.",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: _isEcoMode,
              activeColor: Colors.green,
              onChanged: (val) {
                setState(() {
                  _isEcoMode = val;
                });
                widget.onChanged(val);
              },
            ),
          ],
        ),
      ),
    );
  }
}
