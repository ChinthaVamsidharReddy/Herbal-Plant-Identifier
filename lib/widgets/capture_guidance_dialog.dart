import 'package:flutter/material.dart';

class CaptureGuidanceDialog extends StatelessWidget {
  const CaptureGuidanceDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Capture Tips"),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("• Capture single leaf"),
          Text("• Avoid cluttered background"),
          Text("• Use good lighting"),
          Text("• Keep camera steady"),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("OK"),
        ),
      ],
    );
  }
}
