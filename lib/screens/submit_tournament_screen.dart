import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../tournament/models/tournament_format.dart';
import '../tournament/models/skill_level.dart';
import '../core/theme/golfie_colors.dart';
import '../widgets/golfie/golfie_index.dart';

class SubmitTournamentScreen extends StatefulWidget {
  const SubmitTournamentScreen({super.key});

  @override
  State<SubmitTournamentScreen> createState() => _SubmitTournamentScreenState();
}

class _SubmitTournamentScreenState extends State<SubmitTournamentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _courseNameController = TextEditingController();
  final _courseLocationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _feeController = TextEditingController();
  final _capacityController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  TournamentFormat? _format;
  SkillLevel? _minSkill;

  @override
  void dispose() {
    _nameController.dispose();
    _courseNameController.dispose();
    _courseLocationController.dispose();
    _descriptionController.dispose();
    _feeController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    setState(() {
      _nameController.clear();
      _courseNameController.clear();
      _courseLocationController.clear();
      _descriptionController.clear();
      _feeController.clear();
      _capacityController.clear();
      _startDate = null;
      _endDate = null;
      _format = null;
      _minSkill = null;
    });
  }

  Future<void> _pickStartDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked.isBefore(_endDate ?? picked)) {
      setState(() => _startDate = picked);
    }
  }

  Future<void> _pickEndDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _endDate = picked);
    }
  }

  void _handleAIBenefit() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('AI helper coming soon.')),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate() && _startDate != null && _endDate != null && _format != null && _minSkill != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Submitted for approval. Admin will review shortly.'),
          backgroundColor: GolfieColors.ink,
        ),
      );
      _resetForm();
    } else {
      List<String> missing = [];
      if (_startDate == null) missing.add('start date');
      if (_endDate == null) missing.add('end date');
      if (_format == null) missing.add('format');
      if (_minSkill == null) missing.add('min skill');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill all required fields: ${missing.join(', ')}'),
        ),
      );
    }
  }

  Widget _buildTextField({required String label, required TextEditingController controller, bool readOnly = false, TextInputType type = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        suffixIcon: readOnly ? const Icon(Icons.info_outlined) : null,
      ),
      validator: (value) => value == null || value.isEmpty ? 'Please enter $label' : null,
    );
  }

  Widget _buildDropdownList<T>({
    required List<T> items,
    required T? selectedValue,
    required String Function(T item) labelProvider,
    required ValueChanged<T?> onSelect,
  }) {
    return DropdownButtonFormField<T>(
      value: selectedValue,
      items: items.map((item) => DropdownMenuItem(
        value: item,
        child: Text(labelProvider(item)),
      )).toList(),
      onChanged: (newValue) {
        onSelect(newValue);
      },
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
      ),
      validator: (_) => selectedValue == null ? 'Please select an option' : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Submit New Tournament')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildTextField(label: 'Tournament Name', controller: _nameController),
            const SizedBox(height: 16),
            _buildTextField(label: 'Course Name', controller: _courseNameController),
            const SizedBox(height: 16),
            _buildTextField(label: 'Course Location', controller: _courseLocationController),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Description (max 500 chars)',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.help_outline),
              ),
              validator: (v) => v != null && v.length > 500 ? 'Max 500 chars' : null,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: GolfieGhostButton(
                    label: 'Generate Description',
                    icon: Icons.create,
                    onPressed: _handleAIBenefit,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Format selection
            _buildDropdownList<TournamentFormat>(
              items: TournamentFormat.values,
              selectedValue: _format,
              labelProvider: (f) {
                switch (f) {
                  case TournamentFormat.matchPlay: return 'Match Play';
                  case TournamentFormat.stableford: return 'Stableford';
                  case TournamentFormat.scramble: return 'Scramble';
                  case TournamentFormat.bestBall: return 'Best Ball';
                  case TournamentFormat.championship: return 'Championship';
                }
                return '';
              },
              onSelect: (value) => setState(() => _format = value),
            ),
            const SizedBox(height: 16),
            // Min Skill Level
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Min Skill Level:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 16,
                  children: [
                    Radio<SkillLevel>(value: SkillLevel.beginner, groupValue: _minSkill, onChanged: (v) => setState(() => _minSkill = v)),
                    const Text('Beginner'),
                    Radio<SkillLevel>(value: SkillLevel.casual, groupValue: _minSkill, onChanged: (v) => setState(() => _minSkill = v)),
                    const Text('Casual'),
                    Radio<SkillLevel>(value: SkillLevel.competitive, groupValue: _minSkill, onChanged: (v) => setState(() => _minSkill = v)),
                    const Text('Competitive'),
                    Radio<SkillLevel>(value: SkillLevel.pro, groupValue: _minSkill, onChanged: (v) => setState(() => _minSkill = v)),
                    const Text('Pro'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Max Fee
            _buildTextField(label: 'Max Fee (Rp)', controller: _feeController, type: TextInputType.number),
            const SizedBox(height: 16),
            // Date Range
            ListTile(
              title: const Text('Start Date'),
              subtitle: _startDate != null ? Text(DateFormat('d MMM yyyy').format(_startDate!)) : const Text('Tap to choose'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _pickStartDate(context),
            ),
            ListTile(
              title: const Text('End Date'),
              subtitle: _endDate != null ? Text(DateFormat('d MMM yyyy').format(_endDate!)) : const Text('Tap to choose'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _pickEndDate(context),
            ),
            const SizedBox(height: 16),
            // Max Capacity
            _buildTextField(label: 'Max Capacity', controller: _capacityController, type: TextInputType.number),
            const SizedBox(height: 24),
            SubmitButton(onPressed: _submitForm),
          ],
        ),
      ),
    );
  }
}

class SubmitButton extends StatelessWidget {
  final VoidCallback onPressed;
  const SubmitButton({super.key, required this.onPressed});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: GolfiePillButton(
        label: 'Submit Tournament',
        onPressed: onPressed,
      ),
    );
  }
}
