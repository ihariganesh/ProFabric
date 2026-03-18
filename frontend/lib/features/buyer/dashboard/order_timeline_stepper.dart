import 'package:flutter/material.dart';
import '../../../core/services/websocket_service.dart';

class OrderTimelineStepper extends StatefulWidget {
  final String orderId;
  final String initialState;

  const OrderTimelineStepper({
    Key? key,
    required this.orderId,
    required this.initialState,
  }) : super(key: key);

  @override
  _OrderTimelineStepperState createState() => _OrderTimelineStepperState();
}

class _OrderTimelineStepperState extends State<OrderTimelineStepper> {
  late WebSocketService _wsService;
  late String _currentState;

  // Align this with the OrderState enum from the backend
  final List<String> _stages = [
    "CREATED",
    "SAMPLE_REQUESTED",
    "SAMPLE_SENT",
    "SAMPLE_APPROVED",
    "FABRIC_SOURCED",
    "PRINTING",
    "STITCHING",
    "PACKAGING",
    "SHIPPED",
    "DELIVERED"
  ];

  @override
  void initState() {
    super.initState();
    _currentState = widget.initialState;
    _wsService = WebSocketService();
    _wsService.connectToOrder(widget.orderId);

    // Listen to real-time state changes
    _wsService.stream?.listen((data) {
      if (data['event'] == 'STATE_UPDATE' && data['order_id'] == widget.orderId) {
        setState(() {
          _currentState = data['new_state'];
        });
      }
    });
  }

  @override
  void dispose() {
    _wsService.disconnect();
    super.dispose();
  }

  int get _currentStepIndex {
    final index = _stages.indexOf(_currentState);
    return index == -1 ? 0 : index;
  }

  @override
  Widget build(BuildContext context) {
    return Stepper(
      physics: const ClampingScrollPhysics(),
      currentStep: _currentStepIndex,
      controlsBuilder: (context, details) => const SizedBox.shrink(), // Read-only visual for buyers UI
      steps: _stages.map((stage) {
        final stepIndex = _stages.indexOf(stage);
        final isCompleted = stepIndex < _currentStepIndex;
        final isActive = stepIndex == _currentStepIndex;

        return Step(
          title: Text(
            stage.replaceAll("_", " "),
            style: TextStyle(
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive ? Colors.blue : (isCompleted ? Colors.green : Colors.grey),
            ),
          ),
          content: isActive
              ? const Text("This phase is currently in progress by the supply partner.")
              : const SizedBox.shrink(),
          isActive: isActive,
          state: isCompleted ? StepState.complete : StepState.indexed,
        );
      }).toList(),
    );
  }
}
