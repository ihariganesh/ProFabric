import 'package:flutter/material.dart';
import '../../ai_widgets/ecoflow_toggle.dart';
import '../../ai_widgets/fabricsim_dialog.dart';
import 'order_timeline_stepper.dart';

class BuyerDashboard extends StatefulWidget {
  const BuyerDashboard({Key? key}) : super(key: key);

  @override
  _BuyerDashboardState createState() => _BuyerDashboardState();
}

class _BuyerDashboardState extends State<BuyerDashboard> {
  bool _ecoMode = false;

  void _runFabricSim() {
    showDialog(
      context: context,
      builder: (_) => FabricSimDialog(
        orderConfig: {"eco_mode": _ecoMode, "volume": 5000},
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Buyer Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {},
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text(
            "Welcome, Buyer",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          
          EcoFlowToggle(
            initialValue: _ecoMode,
            onChanged: (val) {
              setState(() {
                _ecoMode = val;
              });
            },
          ),
          
          const SizedBox(height: 20),
          
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Draft Order #10042", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  const Text("Volume: 5,000 units | Fabric: Organic Cotton"),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.psychology),
                    label: const Text("Run FabricSim & Confirm"),
                    onPressed: _runFabricSim,
                  )
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          const Text(
            "Active Orders Tracker",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Card(
            child: OrderTimelineStepper(
              orderId: "10042",
              initialState: "CREATED",
            ),
          )
        ],
      ),
    );
  }
}
