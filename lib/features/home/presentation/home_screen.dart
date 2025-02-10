import 'package:eyadty/features/home/cubit/appointment_state.dart';
import 'package:eyadty/features/home/presentation/add_appointment.dart';
import 'package:eyadty/features/home/presentation/calendar_screen.dart';
import 'package:eyadty/features/home/presentation/statistics_screen.dart';
import 'package:eyadty/features/home/presentation/widgets/appointment_card.dart';
import 'package:eyadty/features/home/presentation/widgets/shimmer_card.dart';
import 'package:eyadty/features/patient_profile/presentation/views/patients_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../cubit/appointment_cubit.dart';
import '../data/appointment_model.dart';
import 'package:excel/excel.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:eyadty/core/widgets/custom_app_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  late Future<void> _appointmentsFuture;

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  void _loadAppointments() {
    _appointmentsFuture = Future.delayed(Duration.zero, () {
      context.read<AppointmentCubit>().fetchAppointments();
    });
  }

  // تحسين دالة تصدير البيانات لتكون أكثر كفاءة
  Future<void> _exportToExcel() async {
    final state = context.read<AppointmentCubit>().state;
    if (state is! AppointmentLoaded) return;

    try {
      var excel = Excel.createExcel();
      var sheet = excel['المواعيد'];

      // إضافة العناوين
      final headers = [
        'الاسم',
        'رقم التليفون',
        'الحالة',
        'اليوم',
        'الموعد',
        'النوع'
      ];
      sheet.appendRow(headers.map((e) => TextCellValue(e)).toList());

      // إضافة البيانات
      for (var appointment in state.appointments) {
        sheet.appendRow([
          TextCellValue(appointment.patientName),
          TextCellValue(appointment.phoneNumber),
          TextCellValue(appointment.status),
          TextCellValue(appointment.date),
          TextCellValue(appointment.time),
          TextCellValue(appointment.appointmentType),
        ]);
      }

      // حفظ الملف
      final dir = await getApplicationDocumentsDirectory();
      final dateStr = DateFormat('yyyy_MM_dd_HH_mm').format(DateTime.now());
      final excelFile = File('${dir.path}/appointments_$dateStr.xlsx');
      
      await excelFile.writeAsBytes(excel.encode()!);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم تصدير الملف بنجاح إلى: ${excelFile.path}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('حدث خطأ أثناء تصدير الملف')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: _getTitle(),
        actions: _currentIndex == 0
            ? [
                IconButton(
                  icon: const Icon(Icons.file_download),
                  onPressed: _exportToExcel,
                ),
              ]
            : null,
      ),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  String _getTitle() {
    switch (_currentIndex) {
      case 0:
        return 'المواعيد';
      case 1:
        return 'التقويم';
      case 2:
        return 'المرضى';
      case 3:
        return 'الإحصائيات';
      default:
        return '';
    }
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return _buildAppointmentsTab();
      case 1:
        return const CalendarScreen();
      case 2:
        return const Scaffold(
          body: PatientsListScreen(),
        );
      case 3:
        return const StatisticsScreen();
      default:
        return const SizedBox();
    }
  }

  Widget _buildAppointmentsTab() {
    return FutureBuilder(
      future: _appointmentsFuture,
      builder: (context, snapshot) {
        return RefreshIndicator(
          onRefresh: () async {
            _loadAppointments();
            setState(() {});
          },
          child: BlocBuilder<AppointmentCubit, AppointmentState>(
            builder: (context, state) {
              if (state is AppointmentLoading) {
                return ListView.builder(
                  itemCount: 5,
                  padding: const EdgeInsets.all(8),
                  itemBuilder: (context, index) => const ShimmerCard(),
                );
              }

              if (state is AppointmentLoaded) {
                if (state.appointments.isEmpty) {
                  return const Center(
                    child: Text('لا توجد مواعيد'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: state.appointments.length,
                  itemBuilder: (context, index) {
                    return AppointmentCard(
                      appointment: state.appointments[index],
                    );
                  },
                );
              }

              if (state is AppointmentError) {
                return Center(
                  child: Text(state.message),
                );
              }

              return const Center(
                child: Text('حدث خطأ غير متوقع'),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) => setState(() => _currentIndex = index),
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_today),
          label: 'المواعيد',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_month),
          label: 'التقويم',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people),
          label: 'المرضى',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.analytics),
          label: 'الإحصائيات',
        ),
      ],
    );
  }
}
