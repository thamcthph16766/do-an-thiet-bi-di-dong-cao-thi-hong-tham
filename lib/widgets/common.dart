import 'package:flutter/material.dart';

/// Hộp thoại xác nhận, trả về true nếu người dùng đồng ý.
Future<bool> confirmDialog(BuildContext context,
    {required String title,
    required String message,
    String ok = 'Đồng ý',
    bool danger = false}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Huỷ')),
        FilledButton(
          style: danger
              ? FilledButton.styleFrom(backgroundColor: Colors.red.shade600)
              : null,
          onPressed: () => Navigator.pop(context, true),
          child: Text(ok),
        ),
      ],
    ),
  );
  return result ?? false;
}

/// Thanh tiến độ bo tròn.
class RoundedProgress extends StatelessWidget {
  final double value;
  final Color? color;
  final double height;
  const RoundedProgress(
      {super.key, required this.value, this.color, this.height = 8});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(height / 2),
      child: LinearProgressIndicator(
        value: value.clamp(0.0, 1.0).toDouble(),
        minHeight: height,
        color: color,
        backgroundColor: (color ?? Theme.of(context).colorScheme.primary)
            .withAlpha(40),
      ),
    );
  }
}

/// Ô thống kê nhỏ: biểu tượng + giá trị + nhãn.
class StatBox extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const StatBox(
      {super.key,
      required this.label,
      required this.value,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 8),
            Text(value,
                style: text.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(label, style: text.bodySmall),
          ],
        ),
      ),
    );
  }
}
