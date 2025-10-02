import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:healup/models/user_model.dart';
import 'package:healup/services/database_service.dart';
import 'package:healup/services/validation_service.dart';
import 'package:healup/services/error_service.dart';

class MedicalInfoScreen extends StatefulWidget {
  final UserModel userModel;

  const MedicalInfoScreen({Key? key, required this.userModel})
    : super(key: key);

  @override
  _MedicalInfoScreenState createState() => _MedicalInfoScreenState();
}

class _MedicalInfoScreenState extends State<MedicalInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _allergiesController = TextEditingController();
  final _conditionsController = TextEditingController();
  final _medicationsController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();

  bool _isLoading = false;
  List<String> _allergies = [];
  List<String> _conditions = [];
  List<String> _medications = [];
  double? _height;
  double? _weight;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    _allergies = List.from(widget.userModel.allergies);
    _conditions = List.from(widget.userModel.medicalConditions);
    _medications = List.from(widget.userModel.medications);
    _height = widget.userModel.height;
    _weight = widget.userModel.weight;

    _heightController.text = _height?.toString() ?? '';
    _weightController.text = _weight?.toString() ?? '';
  }

  @override
  void dispose() {
    _allergiesController.dispose();
    _conditionsController.dispose();
    _medicationsController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Medical Information',
          style: GoogleFonts.lato(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.purple[600],
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveMedicalInfo,
            child: Text(
              'Save',
              style: GoogleFonts.lato(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildVitalStatsSection(),
                    SizedBox(height: 24),
                    _buildAllergiesSection(),
                    SizedBox(height: 24),
                    _buildConditionsSection(),
                    SizedBox(height: 24),
                    _buildMedicationsSection(),
                    SizedBox(height: 24),
                    _buildBMISection(),
                    SizedBox(height: 100),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildVitalStatsSection() {
    return _buildSection(
      title: 'Vital Statistics',
      icon: FontAwesomeIcons.chartLine,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _heightController,
                label: 'Height (cm)',
                icon: Icons.height,
                keyboardType: TextInputType.number,
                validator: ValidationService.validateHeight,
                onChanged: (value) {
                  _height = double.tryParse(value);
                },
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: _buildTextField(
                controller: _weightController,
                label: 'Weight (kg)',
                icon: Icons.monitor_weight,
                keyboardType: TextInputType.number,
                validator: ValidationService.validateWeight,
                onChanged: (value) {
                  _weight = double.tryParse(value);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAllergiesSection() {
    return _buildSection(
      title: 'Allergies',
      icon: FontAwesomeIcons.exclamationTriangle,
      children: [
        _buildListInput(
          controller: _allergiesController,
          label: 'Add Allergy',
          icon: Icons.warning,
          items: _allergies,
          onAdd: _addAllergy,
          onRemove: _removeAllergy,
          placeholder: 'e.g., Peanuts, Shellfish, Penicillin',
        ),
        if (_allergies.isNotEmpty) ...[
          SizedBox(height: 16),
          _buildItemsList(_allergies, _removeAllergy, Colors.red),
        ],
      ],
    );
  }

  Widget _buildConditionsSection() {
    return _buildSection(
      title: 'Medical Conditions',
      icon: FontAwesomeIcons.heartPulse,
      children: [
        _buildListInput(
          controller: _conditionsController,
          label: 'Add Medical Condition',
          icon: Icons.medical_services,
          items: _conditions,
          onAdd: _addCondition,
          onRemove: _removeCondition,
          placeholder: 'e.g., Diabetes, Hypertension, Asthma',
        ),
        if (_conditions.isNotEmpty) ...[
          SizedBox(height: 16),
          _buildItemsList(_conditions, _removeCondition, Colors.orange),
        ],
      ],
    );
  }

  Widget _buildMedicationsSection() {
    return _buildSection(
      title: 'Current Medications',
      icon: FontAwesomeIcons.pills,
      children: [
        _buildListInput(
          controller: _medicationsController,
          label: 'Add Medication',
          icon: Icons.medication,
          items: _medications,
          onAdd: _addMedication,
          onRemove: _removeMedication,
          placeholder: 'e.g., Insulin, Metformin, Lisinopril',
        ),
        if (_medications.isNotEmpty) ...[
          SizedBox(height: 16),
          _buildItemsList(_medications, _removeMedication, Colors.blue),
        ],
      ],
    );
  }

  Widget _buildBMISection() {
    final bmi = _calculateBMI();
    final bmiCategory = _getBMICategory(bmi);

    return _buildSection(
      title: 'Body Mass Index (BMI)',
      icon: FontAwesomeIcons.weightScale,
      children: [
        Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: _getBMIColor(bmi).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _getBMIColor(bmi).withOpacity(0.3)),
          ),
          child: Column(
            children: [
              if (bmi != null) ...[
                Text(
                  '${bmi.toStringAsFixed(1)}',
                  style: GoogleFonts.lato(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: _getBMIColor(bmi),
                  ),
                ),
                Text(
                  bmiCategory,
                  style: GoogleFonts.lato(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: _getBMIColor(bmi),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'BMI Range: ${_getBMIRange(bmi)}',
                  style: GoogleFonts.lato(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ] else ...[
                Icon(Icons.info_outline, size: 48, color: Colors.grey[400]),
                SizedBox(height: 8),
                Text(
                  'Enter height and weight to calculate BMI',
                  style: GoogleFonts.lato(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ],
          ),
        ),
        SizedBox(height: 16),
        _buildBMIScale(),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.purple[600], size: 20),
              SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.lato(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.purple[600]),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.purple[600]!),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
    );
  }

  Widget _buildListInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required List<String> items,
    required Function(String) onAdd,
    required Function(String) onRemove,
    required String placeholder,
  }) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              labelText: label,
              hintText: placeholder,
              prefixIcon: Icon(icon, color: Colors.purple[600]),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.purple[600]!),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            onFieldSubmitted: (value) {
              if (value.trim().isNotEmpty) {
                onAdd(value.trim());
                controller.clear();
              }
            },
          ),
        ),
        SizedBox(width: 8),
        ElevatedButton(
          onPressed: () {
            if (controller.text.trim().isNotEmpty) {
              onAdd(controller.text.trim());
              controller.clear();
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple[600],
            foregroundColor: Colors.white,
            shape: CircleBorder(),
            padding: EdgeInsets.all(12),
          ),
          child: Icon(Icons.add, size: 20),
        ),
      ],
    );
  }

  Widget _buildItemsList(
    List<String> items,
    Function(String) onRemove,
    Color color,
  ) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((item) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                item,
                style: GoogleFonts.lato(
                  fontSize: 14,
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(width: 4),
              GestureDetector(
                onTap: () => onRemove(item),
                child: Icon(Icons.close, size: 16, color: color),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBMIScale() {
    return Column(
      children: [
        Text(
          'BMI Categories',
          style: GoogleFonts.lato(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 12),
        Row(
          children: [
            _buildBMICategory('Underweight', '< 18.5', Colors.blue),
            _buildBMICategory('Normal', '18.5 - 24.9', Colors.green),
            _buildBMICategory('Overweight', '25 - 29.9', Colors.orange),
            _buildBMICategory('Obese', '≥ 30', Colors.red),
          ],
        ),
      ],
    );
  }

  Widget _buildBMICategory(String label, String range, Color color) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 2),
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: GoogleFonts.lato(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 2),
            Text(
              range,
              style: GoogleFonts.lato(fontSize: 8, color: color),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  double? _calculateBMI() {
    if (_height != null && _weight != null && _height! > 0) {
      final heightInMeters = _height! / 100;
      return _weight! / (heightInMeters * heightInMeters);
    }
    return null;
  }

  String _getBMICategory(double? bmi) {
    if (bmi == null) return 'Unknown';
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal weight';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  Color _getBMIColor(double? bmi) {
    if (bmi == null) return Colors.grey;
    if (bmi < 18.5) return Colors.blue;
    if (bmi < 25) return Colors.green;
    if (bmi < 30) return Colors.orange;
    return Colors.red;
  }

  String _getBMIRange(double bmi) {
    if (bmi < 18.5) return '< 18.5';
    if (bmi < 25) return '18.5 - 24.9';
    if (bmi < 30) return '25 - 29.9';
    return '≥ 30';
  }

  void _addAllergy(String allergy) {
    if (!_allergies.contains(allergy)) {
      setState(() {
        _allergies.add(allergy);
      });
    }
  }

  void _removeAllergy(String allergy) {
    setState(() {
      _allergies.remove(allergy);
    });
  }

  void _addCondition(String condition) {
    if (!_conditions.contains(condition)) {
      setState(() {
        _conditions.add(condition);
      });
    }
  }

  void _removeCondition(String condition) {
    setState(() {
      _conditions.remove(condition);
    });
  }

  void _addMedication(String medication) {
    if (!_medications.contains(medication)) {
      setState(() {
        _medications.add(medication);
      });
    }
  }

  void _removeMedication(String medication) {
    setState(() {
      _medications.remove(medication);
    });
  }

  Future<void> _saveMedicalInfo() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final updatedUser = widget.userModel.copyWith(
        allergies: _allergies,
        medicalConditions: _conditions,
        medications: _medications,
        height: _height,
        weight: _weight,
        updatedAt: DateTime.now(),
      );

      await DatabaseService.updateUser(updatedUser);

      ErrorService.showSuccessSnackBar(
        context,
        'Medical information updated successfully!',
      );
      Navigator.pop(context, true);
    } catch (e) {
      ErrorService.showErrorSnackBar(
        context,
        'Failed to update medical information: $e',
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
