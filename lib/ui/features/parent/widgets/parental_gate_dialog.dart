import 'dart:math';

import 'package:flutter/material.dart';

import 'package:alphabet_adventure/ui/core/app_colors.dart';
import 'package:alphabet_adventure/ui/core/app_fonts.dart';

/// Parental Gate dialog (PRS Section 14 & 32) requiring solving a math challenge before granting adult access.
class ParentalGateDialog extends StatefulWidget {
  const ParentalGateDialog({super.key});

  /// Displays the parental gate dialog. Returns `true` if passed, `false` otherwise.
  static Future<bool> verify(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const ParentalGateDialog(),
    );
    return result ?? false;
  }

  @override
  State<ParentalGateDialog> createState() => _ParentalGateDialogState();
}

class _ParentalGateDialogState extends State<ParentalGateDialog> {
  late int _num1;
  late int _num2;
  late int _expectedAnswer;
  String _input = '';
  String? _error;

  @override
  void initState() {
    super.initState();
    final random = Random();
    _num1 = 6 + random.nextInt(7); // 6 to 12
    _num2 = 5 + random.nextInt(8); // 5 to 12
    _expectedAnswer = _num1 + _num2;
  }

  void _onVerify() {
    final parsed = int.tryParse(_input.trim());
    if (parsed == _expectedAnswer) {
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _error = 'Incorrect answer. Please try again.';
        _input = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      title: Row(
        children: [
          const Icon(Icons.lock_rounded, color: AppColors.primary, size: 28),
          const SizedBox(width: 8),
          Text(
            'Grown-Ups Only',
            style: AppFonts.fredoka(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Please solve the math question to continue:',
            style: AppFonts.fredoka(
              fontSize: 16,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.bgSky,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$_num1 + $_num2 = ?',
              style: AppFonts.fredoka(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            autofocus: true,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              hintText: 'Enter answer',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              filled: true,
              fillColor: Colors.white,
              errorText: _error,
            ),
            style: AppFonts.fredoka(fontSize: 22, fontWeight: FontWeight.bold),
            onChanged: (val) => _input = val,
            onSubmitted: (_) => _onVerify(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            'Cancel',
            style: AppFonts.fredoka(
              fontSize: 16,
              color: AppColors.textMuted,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: _onVerify,
          child: Text(
            'Enter',
            style: AppFonts.fredoka(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
