import 'package:eyadty/features/home/cubit/appointment_cubit.dart';
import 'package:eyadty/features/home/data/appointment_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:eyadty/core/widgets/custom_app_bar.dart';

class AddAppointmentScreen extends StatefulWidget {
  const AddAppointmentScreen({super.key});

  @override
  _AddAppointmentScreenState createState() => _AddAppointmentScreenState();
}

class _AddAppointmentScreenState extends State<AddAppointmentScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _occurrencesController = TextEditingController();
  String _appointmentType = 'كشف';
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  final _formKey = GlobalKey<FormState>();

  // متغيرات التكرار
  bool _isRecurring = false;
  String _recurrenceType = 'daily';
  int _recurrenceInterval = 1;
  DateTime? _recurrenceEndDate;
  bool _useEndDate = true;

  final List<String> _appointmentTypes = ['كشف', 'متابعة', 'استشارة', 'طوارئ'];
  final Map<String, String> _recurrenceTypes = {
    'daily': 'يومي',
    'weekly': 'أسبوعي',
    'monthly': 'شهري',
  };

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    _occurrencesController.dispose();
    super.dispose();
  }

  void _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  void _pickEndDate() async {
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء اختيار تاريخ الموعد أولاً')),
      );
      return;
    }

    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate!.add(const Duration(days: 1)),
      firstDate: _selectedDate!.add(const Duration(days: 1)),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (pickedDate != null) {
      setState(() {
        _recurrenceEndDate = pickedDate;
      });
    }
  }

  void _pickTime() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (pickedTime != null) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  Widget _buildRecurrenceSection() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: _isRecurring ? null : 0,
      child: _isRecurring
          ? Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'خيارات التكرار',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    
                    // نوع التكرار
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'نوع التكرار',
                        border: OutlineInputBorder(),
                      ),
                      value: _recurrenceType,
                      items: _recurrenceTypes.entries.map((entry) {
                        return DropdownMenuItem(
                          value: entry.key,
                          child: Text(entry.value),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _recurrenceType = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // الفاصل الزمني
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: 'كل',
                              border: const OutlineInputBorder(),
                              suffixText: _recurrenceType == 'daily'
                                  ? 'يوم'
                                  : _recurrenceType == 'weekly'
                                      ? 'أسبوع'
                                      : 'شهر',
                            ),
                            keyboardType: TextInputType.number,
                            initialValue: '1',
                            onChanged: (value) {
                              setState(() {
                                _recurrenceInterval = int.tryParse(value) ?? 1;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // نوع الانتهاء
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<bool>(
                            title: const Text('تاريخ انتهاء'),
                            value: true,
                            groupValue: _useEndDate,
                            onChanged: (value) {
                              setState(() {
                                _useEndDate = value!;
                              });
                            },
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<bool>(
                            title: const Text('عدد مرات'),
                            value: false,
                            groupValue: _useEndDate,
                            onChanged: (value) {
                              setState(() {
                                _useEndDate = value!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // تفاصيل الانتهاء
                    if (_useEndDate)
                      InkWell(
                        onTap: _pickEndDate,
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'تاريخ الانتهاء',
                            border: OutlineInputBorder(),
                          ),
                          child: Text(
                            _recurrenceEndDate == null
                                ? 'اختر تاريخ الانتهاء'
                                : '${_recurrenceEndDate!.year}-${_recurrenceEndDate!.month}-${_recurrenceEndDate!.day}',
                          ),
                        ),
                      )
                    else
                      TextFormField(
                        controller: _occurrencesController,
                        decoration: const InputDecoration(
                          labelText: 'عدد مرات التكرار',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                  ],
                ),
              ),
            )
          : const SizedBox(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'إضافة موعد جديد',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'اسم المريض',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال اسم المريض';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'رقم الهاتف',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
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
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'نوع الكشف',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.medical_services),
                ),
                value: _appointmentType,
                items: _appointmentTypes.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _appointmentType = newValue!;
                  });
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _pickDate,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'التاريخ',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          _selectedDate == null
                              ? 'اختر التاريخ'
                              : '${_selectedDate!.year}-${_selectedDate!.month}-${_selectedDate!.day}',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: _pickTime,
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'الوقت',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.access_time),
                        ),
                        child: Text(
                          _selectedTime == null
                              ? 'اختر الوقت'
                              : _selectedTime!.format(context),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // خيار التكرار
              SwitchListTile(
                title: const Text('موعد متكرر'),
                value: _isRecurring,
                onChanged: (bool value) {
                  setState(() {
                    _isRecurring = value;
                  });
                },
              ),
              
              // قسم خيارات التكرار
              _buildRecurrenceSection(),
              
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate() &&
                        _selectedDate != null &&
                        _selectedTime != null) {
                      final appointment = AppointmentModel(
                        id: '',
                        patientName: _nameController.text,
                        phoneNumber: _phoneController.text,
                        date: '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}',
                        time: _selectedTime!.format(context),
                        appointmentType: _appointmentType,
                        status: 'في الانتظار',
                        recurrence: _isRecurring
                            ? RecurrencePattern(
                                type: _recurrenceType,
                                interval: _recurrenceInterval,
                                endDate: _useEndDate ? _recurrenceEndDate : null,
                                occurrences: !_useEndDate
                                    ? int.tryParse(_occurrencesController.text)
                                    : null,
                              )
                            : null,
                      );

                      context
                          .read<AppointmentCubit>()
                          .addAppointment(appointment);

                      Navigator.pop(context);
                    } else if (_selectedDate == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('الرجاء اختيار التاريخ'),
                        ),
                      );
                    } else if (_selectedTime == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('الرجاء اختيار الوقت'),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'إضافة موعد',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
