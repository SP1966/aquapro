import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

class ChemicalLogScreen extends StatefulWidget {
  final ChemicalReading? existingReading;

  const ChemicalLogScreen({super.key, this.existingReading});

  @override
  State<ChemicalLogScreen> createState() => _ChemicalLogScreenState();
}

class _ChemicalLogScreenState extends State<ChemicalLogScreen> {
  late TextEditingController _phCtrl;
  late TextEditingController _chlorineCtrl;
  late TextEditingController _alkalinityCtrl;
  late TextEditingController _calciumCtrl;
  late TextEditingController _cyanuricCtrl;
  late TextEditingController _saltCtrl;
  late TextEditingController _notesCtrl;
  bool _isSaltPool = false;

  @override
  void initState() {
    super.initState();
    final r = widget.existingReading;
    _phCtrl = TextEditingController(text: r?.ph.toString() ?? '');
    _chlorineCtrl = TextEditingController(text: r?.chlorine.toString() ?? '');
    _alkalinityCtrl = TextEditingController(text: r?.alkalinity.toString() ?? '');
    _calciumCtrl = TextEditingController(text: r?.calciumHardness.toString() ?? '');
    _cyanuricCtrl = TextEditingController(text: r?.cyanuricAcid.toString() ?? '');
    _saltCtrl = TextEditingController(text: r?.saltLevel?.toString() ?? '');
    _notesCtrl = TextEditingController(text: r?.notes ?? '');
    _isSaltPool = r?.saltLevel != null;
  }

  @override
  void dispose() {
    _phCtrl.dispose();
    _chlorineCtrl.dispose();
    _alkalinityCtrl.dispose();
    _calciumCtrl.dispose();
    _cyanuricCtrl.dispose();
    _saltCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Chemicals'),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('Save',
                style: TextStyle(
                    color: AppTheme.accent,
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Banner
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.07),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: AppTheme.primary, size: 16),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Enter values from your test kit. All units are ppm unless noted.',
                    style:
                        TextStyle(color: AppTheme.primary, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          _SectionLabel(label: 'Core Parameters'),
          const SizedBox(height: 12),

          _ChemInput(
            controller: _phCtrl,
            label: 'pH',
            hint: 'e.g. 7.4',
            idealRange: 'Ideal: 7.2 – 7.6',
            unit: '',
          ),
          const SizedBox(height: 12),
          _ChemInput(
            controller: _chlorineCtrl,
            label: 'Free Chlorine',
            hint: 'e.g. 2.0',
            idealRange: 'Ideal: 1.0 – 3.0 ppm',
            unit: 'ppm',
          ),
          const SizedBox(height: 12),
          _ChemInput(
            controller: _alkalinityCtrl,
            label: 'Total Alkalinity',
            hint: 'e.g. 100',
            idealRange: 'Ideal: 80 – 120 ppm',
            unit: 'ppm',
          ),

          const SizedBox(height: 24),
          _SectionLabel(label: 'Additional Parameters'),
          const SizedBox(height: 12),

          _ChemInput(
            controller: _calciumCtrl,
            label: 'Calcium Hardness',
            hint: 'e.g. 280',
            idealRange: 'Ideal: 200 – 400 ppm',
            unit: 'ppm',
          ),
          const SizedBox(height: 12),
          _ChemInput(
            controller: _cyanuricCtrl,
            label: 'Cyanuric Acid (Stabilizer)',
            hint: 'e.g. 40',
            idealRange: 'Ideal: 30 – 60 ppm',
            unit: 'ppm',
          ),

          const SizedBox(height: 20),
          Row(
            children: [
              Switch(
                value: _isSaltPool,
                onChanged: (v) => setState(() => _isSaltPool = v),
                activeColor: AppTheme.primary,
              ),
              const SizedBox(width: 8),
              const Text('Salt Pool',
                  style: TextStyle(color: AppTheme.textPrimary)),
            ],
          ),
          if (_isSaltPool) ...[
            const SizedBox(height: 12),
            _ChemInput(
              controller: _saltCtrl,
              label: 'Salt Level',
              hint: 'e.g. 3200',
              idealRange: 'Ideal: 2700 – 3400 ppm',
              unit: 'ppm',
            ),
          ],

          const SizedBox(height: 24),
          _SectionLabel(label: 'Notes'),
          const SizedBox(height: 12),
          TextField(
            controller: _notesCtrl,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText:
                  'Added chemicals, observations, recommendations...',
            ),
            style: const TextStyle(color: AppTheme.textPrimary),
          ),

          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.check, size: 18),
            label: const Text('Save Reading'),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  void _save() {
    final ph = double.tryParse(_phCtrl.text);
    final chlorine = double.tryParse(_chlorineCtrl.text);
    final alkalinity = double.tryParse(_alkalinityCtrl.text);
    final calcium = double.tryParse(_calciumCtrl.text);
    final cyanuric = double.tryParse(_cyanuricCtrl.text);

    if (ph == null || chlorine == null || alkalinity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter pH, chlorine, and alkalinity'),
          backgroundColor: AppTheme.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final reading = ChemicalReading(
      timestamp: DateTime.now(),
      ph: ph,
      chlorine: chlorine,
      alkalinity: alkalinity,
      calciumHardness: calcium ?? 0,
      cyanuricAcid: cyanuric ?? 0,
      saltLevel: _isSaltPool ? double.tryParse(_saltCtrl.text) : null,
      notes: _notesCtrl.text.isEmpty ? null : _notesCtrl.text,
    );

    Navigator.pop(context, reading);
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(label,
        style: const TextStyle(
            color: AppTheme.primary,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5));
  }
}

class _ChemInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final String idealRange;
  final String unit;

  const _ChemInput({
    required this.controller,
    required this.label,
    required this.hint,
    required this.idealRange,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label,
                style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
            const Spacer(),
            Text(idealRange,
                style: const TextStyle(
                    color: AppTheme.textMuted, fontSize: 11)),
          ],
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
          ],
          decoration: InputDecoration(
            hintText: hint,
            suffixText: unit.isEmpty ? null : unit,
            suffixStyle: const TextStyle(color: AppTheme.textMuted),
          ),
          style: const TextStyle(color: AppTheme.textPrimary, fontSize: 15),
        ),
      ],
    );
  }
}
