import 'package:flutter/material.dart';

class FabricSimDialog extends StatelessWidget {
  final Map<String, dynamic> orderConfig;

  const FabricSimDialog({Key? key, required this.orderConfig}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: const [
          Icon(Icons.auto_graph, color: Colors.blueAccent),
          SizedBox(width: 8),
          Text("FabricSim Digital Twin"),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Simulating entire order lifecycle against selected partners...",
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 16),
          // Mocked up response layout
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text("⚠️ Predicted Delay: 12%", style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text("- Bottleneck expected at stitching unit due to volume."),
                SizedBox(height: 4),
                Text("✓ Timeline: 45 Days (Optimized)"),
              ],
            ),
          )
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("CLOSE"),
        ),
        ElevatedButton(
          onPressed: () {
            // Confirm Order taking simulate results into account
            Navigator.of(context).pop(true);
          },
          child: const Text("PROCEED WITH ORDER"),
        ),
      ],
    );
  }
}
