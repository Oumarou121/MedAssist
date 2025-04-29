import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:med_assist/Models/treat.dart';
import 'package:med_assist/Models/user.dart';

class AddTreatmentPage extends StatefulWidget {
  final AppUserData userData;
  final ManagersTreats managersTreats;

  const AddTreatmentPage({
    Key? key,
    required this.userData,
    required this.managersTreats,
  }) : super(key: key);

  @override
  State<AddTreatmentPage> createState() => _AddTreatmentPageState();
}

class _AddTreatmentPageState extends State<AddTreatmentPage> {
  List<Medicine> medicines = [];
  TextEditingController titleController = TextEditingController();
  List<TextEditingController> nameControllers = [];
  List<TextEditingController> durationControllers = [];
  List<TextEditingController> doseControllers = [];
  List<TextEditingController> frequencyControllers = [];
  List<TextEditingController> intervaleControllers = [];
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _addMedicine();
  }

  @override
  void dispose() {
    titleController.dispose();
    for (var controller in [
      ...nameControllers,
      ...durationControllers,
      ...doseControllers,
      ...frequencyControllers,
      ...intervaleControllers,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addMedicine() {
    setState(() {
      medicines.add(
        Medicine(
          name: "",
          duration: 0,
          count: 0,
          dose: "",
          frequencyType: FrequencyType.daily,
          frequency: 0,
          intervale: 0,
          createAt: DateTime.now(),
        ),
      );
      nameControllers.add(TextEditingController());
      durationControllers.add(TextEditingController());
      doseControllers.add(TextEditingController());
      frequencyControllers.add(TextEditingController());
      intervaleControllers.add(TextEditingController());
    });
  }

  void _removeMedicine(int index) {
    setState(() {
      medicines.removeAt(index);
      nameControllers.removeAt(index);
      durationControllers.removeAt(index);
      doseControllers.removeAt(index);
      frequencyControllers.removeAt(index);
      intervaleControllers.removeAt(index);
    });
  }

  void _saveTreatment() {
    if (formKey.currentState!.validate()) {
      bool allValid = true;
      for (var medicine in medicines) {
        final isValid = medicine.formKey.currentState?.validate() ?? false;
        if (!isValid) {
          allValid = false;
        }
      }

      if (allValid) {
        List<Medicine> meds = [];
        for (int i = 0; i < nameControllers.length; i++) {
          final name = nameControllers[i].text.trim();
          final durationText = durationControllers[i].text.trim();
          final dose = doseControllers[i].text.trim();
          final frequencyText = frequencyControllers[i].text.trim();
          final intervaleText = intervaleControllers[i].text.trim();

          final duration = int.tryParse(durationText);
          final frequency = int.tryParse(frequencyText);
          final intervale = int.tryParse(intervaleText);

          if (name.isNotEmpty &&
              dose.isNotEmpty &&
              duration != null &&
              frequency != null &&
              intervale != null) {
            meds.add(
              Medicine(
                name: name,
                duration: duration,
                count: 0,
                dose: dose,
                frequency: frequency,
                frequencyType: medicines[i].frequencyType,
                intervale: intervale,
                createAt: DateTime.now(),
              ),
            );
          }
        }

        if (meds.isNotEmpty) {
          Treat newTreatment = Treat(
            authorUid: widget.userData.uid,
            authorName: '${'mr/ms'.tr()} ${widget.userData.name}',
            code: 'TREAT-${DateTime.now().millisecondsSinceEpoch}',
            title: titleController.text.trim(),
            medicines: meds,
            createdAt: DateTime.now(),
            isPublic: false,
            followers: [widget.managersTreats.uid],
          );

          widget.managersTreats.addTreatment(newTreatment);

          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('success_add_treatment'.tr()),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add a treatment")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildModernFormField(
                controller: titleController,
                label: 'treatment_title'.tr(),
                icon: Iconsax.health,
                validator: (value) => value!.isEmpty ? 'required'.tr() : null,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'prescribed_medications'.tr(),
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _addMedicine,
                    icon: const Icon(
                      Iconsax.add,
                      size: 18,
                      color: Colors.white,
                    ),
                    label: Text(
                      'add'.tr(),
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00C853),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Column(
                children: List.generate(medicines.length, (index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: _buildMedicineForm(medicines[index], index),
                  );
                }),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _saveTreatment,
                  icon: const Icon(Iconsax.add, size: 20, color: Colors.white),
                  label: Text(
                    'add_treatment'.tr(),
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00C853),
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMedicineForm(Medicine medicine, int index) {
    return Form(
      key: medicine.formKey,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                "${'medicine'.tr()} ${index + 1}",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () => _removeMedicine(index),
                icon: const Icon(Iconsax.note_remove, color: Colors.red),
              ),
            ],
          ),
          _buildModernFormField(
            controller: nameControllers[index],
            label: 'medicine_name'.tr(),
            icon: Iconsax.heart,
            validator: (value) => value!.isEmpty ? 'required'.tr() : null,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildModernFormField(
                  controller: doseControllers[index],
                  label: 'dose'.tr(),
                  icon: Iconsax.d_cube_scan,
                  validator: (value) => value!.isEmpty ? 'required'.tr() : null,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildModernFormField(
                  controller: durationControllers[index],
                  label: 'duration'.tr(),
                  icon: Iconsax.calendar,
                  keyboardType: TextInputType.number,
                  validator: (value) => value!.isEmpty ? 'required'.tr() : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildModernFormField(
            controller: frequencyControllers[index],
            label: 'frequency'.tr(),
            icon: Iconsax.clock,
            keyboardType: TextInputType.number,
            validator: (value) => value!.isEmpty ? 'required'.tr() : null,
          ),
          const SizedBox(height: 16),
          _buildModernFormField(
            controller: intervaleControllers[index],
            label: 'interval'.tr(),
            icon: Iconsax.timer,
            keyboardType: TextInputType.number,
            validator: (value) => value!.isEmpty ? 'required'.tr() : null,
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<FrequencyType>(
            value: medicine.frequencyType,
            decoration: InputDecoration(
              labelText: 'frequency_type'.tr(),
              prefixIcon: const Icon(Iconsax.repeat),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              filled: true,
              fillColor: Colors.grey.shade100,
            ),
            items:
                FrequencyType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.unitLabel),
                  );
                }).toList(),
            onChanged: (value) {
              setState(() {
                medicine.frequencyType = value!;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildModernFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        filled: true,
        fillColor: Colors.grey.shade100,
      ),
    );
  }
}
