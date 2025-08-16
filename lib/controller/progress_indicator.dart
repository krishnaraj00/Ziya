import 'package:flutter/material.dart';

class StepProgressHeader extends StatelessWidget {
  final int currentStep;
  final void Function(int) onStepTap;

  const StepProgressHeader({
    super.key,
    required this.currentStep,
    required this.onStepTap,
  });

  @override
  Widget build(BuildContext context) {
    final steps = ["Personal Info", "Interests", "Verify"];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(steps.length, (index) {
            return Expanded(
              child: GestureDetector(
                onTap: () => onStepTap(index),
                child: Column(
                  children: [
                    Text(
                      steps[index],
                      style: TextStyle(
                        color: currentStep == index ? Colors.blue : Colors.grey,
                        fontWeight: currentStep == index ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      height: 3,
                      width: double.infinity,
                      color: currentStep == index ? Colors.blue : Colors.transparent,
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: (currentStep + 1) / steps.length,
          minHeight: 6,
          backgroundColor: Colors.grey[300],
          color: Colors.blue,
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
