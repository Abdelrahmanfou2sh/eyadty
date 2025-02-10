import 'package:eyadty/features/patient_profile/data/patient_model.dart';
import 'package:eyadty/features/patient_profile/presentation/cubit/patient_profile_cubit.dart';
import 'package:eyadty/features/patient_profile/presentation/cubit/patient_proflie_sate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class CreatePatientScreen extends StatefulWidget {
  const CreatePatientScreen({Key? key}) : super(key: key);

  @override
  State<CreatePatientScreen> createState() => _CreatePatientScreenState();
}

class _CreatePatientScreenState extends State<CreatePatientScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _diagnosisController = TextEditingController();
  final _emergencyContactController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedGender;
  String? _selectedBloodType;
  final List<String> _allergies = [];
  final List<String> _chronicDiseases = [];
  final _allergyController = TextEditingController();
  final _diseaseController = TextEditingController();

  final List<String> _bloodTypes = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
  final List<String> _genders = ['ذكر', 'أنثى'];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _diagnosisController.dispose();
    _emergencyContactController.dispose();
    _notesController.dispose();
    _allergyController.dispose();
    _diseaseController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue[700]!,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _addAllergy() {
    if (_allergyController.text.isNotEmpty) {
      setState(() {
        _allergies.add(_allergyController.text);
        _allergyController.clear();
      });
    }
  }

  void _addChronicDisease() {
    if (_diseaseController.text.isNotEmpty) {
      setState(() {
        _chronicDiseases.add(_diseaseController.text);
        _diseaseController.clear();
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate() && _selectedDate != null && _selectedGender != null && _selectedBloodType != null) {
      final patient = Patient(
        name: _nameController.text,
        phoneNumber: _phoneController.text,
        address: _addressController.text,
        medicalDiagnosis: _diagnosisController.text,
        gender: _selectedGender!,
        dateOfBirth: _selectedDate!,
        bloodType: _selectedBloodType!,
        allergies: _allergies,
        chronicDiseases: _chronicDiseases,
        emergencyContact: _emergencyContactController.text,
        notes: _notesController.text,
      );
      context.read<PatientProfileCubit>().createPatient(patient);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء ملء جميع الحقول المطلوبة')),
      );
    }
  }

  Widget _buildChipsSection(String title, List<String> items, VoidCallback onAdd, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            ...items.map((item) => Chip(
              label: Text(item),
              onDeleted: () {
                setState(() {
                  items.remove(item);
                });
              },
            )).toList(),
            SizedBox(
              width: 150,
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'إضافة جديد',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: onAdd,
                  ),
                ),
                onSubmitted: (_) => onAdd(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إضافة مريض جديد'),
        centerTitle: true,
        backgroundColor: Colors.blue[700],
      ),
      body: BlocConsumer<PatientProfileCubit, PatientProfileState>(
        listener: (context, state) {
          if (state is PatientCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('تم إضافة المريض بنجاح!')),
            );
            Navigator.pop(context);
          } else if (state is PatientProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is PatientProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'الاسم',
                      hintText: 'أدخل اسم المريض',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: const Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'الرجاء إدخال الاسم';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedGender,
                          decoration: InputDecoration(
                            labelText: 'الجنس',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            prefixIcon: const Icon(Icons.people),
                          ),
                          items: _genders.map((gender) {
                            return DropdownMenuItem(
                              value: gender,
                              child: Text(gender),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedGender = value;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedBloodType,
                          decoration: InputDecoration(
                            labelText: 'فصيلة الدم',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            prefixIcon: const Icon(Icons.bloodtype),
                          ),
                          items: _bloodTypes.map((type) {
                            return DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedBloodType = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () => _selectDate(context),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'تاريخ الميلاد',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        prefixIcon: const Icon(Icons.calendar_today),
                      ),
                      child: Text(
                        _selectedDate != null
                            ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
                            : 'اختر تاريخ الميلاد',
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneController,
                    decoration: InputDecoration(
                      labelText: 'رقم الهاتف',
                      hintText: 'أدخل رقم الهاتف',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: const Icon(Icons.phone),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'الرجاء إدخال رقم الهاتف';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _emergencyContactController,
                    decoration: InputDecoration(
                      labelText: 'رقم الطوارئ',
                      hintText: 'أدخل رقم للطوارئ',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: const Icon(Icons.emergency),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'الرجاء إدخال رقم للطوارئ';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _addressController,
                    decoration: InputDecoration(
                      labelText: 'العنوان',
                      hintText: 'أدخل العنوان',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: const Icon(Icons.location_on),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'الرجاء إدخال العنوان';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _diagnosisController,
                    decoration: InputDecoration(
                      labelText: 'التشخيص الطبي',
                      hintText: 'أدخل التشخيص الطبي',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: const Icon(Icons.medical_services),
                    ),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'الرجاء إدخال التشخيص الطبي';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildChipsSection(
                    'الحساسية',
                    _allergies,
                    _addAllergy,
                    _allergyController,
                  ),
                  const SizedBox(height: 16),
                  _buildChipsSection(
                    'الأمراض المزمنة',
                    _chronicDiseases,
                    _addChronicDisease,
                    _diseaseController,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _notesController,
                    decoration: InputDecoration(
                      labelText: 'ملاحظات',
                      hintText: 'أدخل أي ملاحظات إضافية',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: const Icon(Icons.note),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[700],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'إضافة المريض',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}