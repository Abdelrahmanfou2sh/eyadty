import 'package:eyadty/features/home/cubit/appointment_cubit.dart';
import 'package:eyadty/features/home/cubit/appointment_state.dart';
import 'package:eyadty/features/home/data/appointment_model.dart';
import 'package:eyadty/features/patient_profile/presentation/cubit/patient_profile_cubit.dart';
import 'package:eyadty/features/patient_profile/presentation/cubit/patient_proflie_sate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:eyadty/core/widgets/custom_app_bar.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({Key? key}) : super(key: key);

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  String? selectedDateFilter = 'الشهر';
  String? selectedAppointmentType;
  
  // استخدام Future للتحميل المتأخر للبيانات
  Future<void>? _patientStatsFuture;
  Future<void>? _appointmentStatsFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _patientStatsFuture = Future.delayed(Duration.zero, () {
      context.read<PatientProfileCubit>().loadPatients();
    });
    
    _appointmentStatsFuture = Future.delayed(Duration.zero, () {
      context.read<AppointmentCubit>().fetchAppointments();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'الإحصائيات',
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _loadData();
          });
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // إحصائيات المرضى
              FutureBuilder(
                future: _patientStatsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return _buildPatientStatistics(theme);
                },
              ),
              const SizedBox(height: 24),
              
              // إحصائيات المواعيد
              FutureBuilder(
                future: _appointmentStatsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return _buildAppointmentStatistics(theme);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPatientStatistics(ThemeData theme) {
    return BlocBuilder<PatientProfileCubit, PatientProfileState>(
      builder: (context, state) {
        if (state is PatientsLoaded) {
          final cubit = context.read<PatientProfileCubit>();
          final newPatientsThisMonth = cubit.getNewPatientsCount();
          final growthRate = cubit.getPatientGrowthRate();
          final monthlyStats = cubit.getNewPatientsPerMonth(monthsCount: 6);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'إحصائيات المرضى',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              
              // بطاقات الإحصائيات
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'مرضى جدد هذا الشهر',
                      value: newPatientsThisMonth.toString(),
                      trend: growthRate,
                      icon: Icons.person_add,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _StatCard(
                      title: 'إجمالي المرضى',
                      value: state.patients.length.toString(),
                      icon: Icons.people,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // رسم بياني للمرضى الجدد
              if (monthlyStats.isNotEmpty) ...[
                Text(
                  'المرضى الجدد في الـ 6 أشهر الماضية',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(show: false),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: true),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              if (value.toInt() >= 0 && value.toInt() < monthlyStats.length) {
                                final date = monthlyStats[value.toInt()].key;
                                return Text(
                                  DateFormat.MMM().format(date),
                                  style: theme.textTheme.bodySmall,
                                );
                              }
                              return const Text('');
                            },
                          ),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: monthlyStats.asMap().entries.map((entry) {
                            return FlSpot(
                              entry.key.toDouble(),
                              entry.value.value.toDouble(),
                            );
                          }).toList(),
                          isCurved: true,
                          color: theme.primaryColor,
                          barWidth: 3,
                          isStrokeCapRound: true,
                          dotData: FlDotData(show: true),
                          belowBarData: BarAreaData(
                            show: true,
                            color: theme.primaryColor.withOpacity(0.1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          );
        } else if (state is PatientProfileLoading) {
          return const Center(child: CircularProgressIndicator());
        } else {
          return const Center(
            child: Text('لا توجد بيانات متاحة'),
          );
        }
      },
    );
  }

  Widget _buildAppointmentStatistics(ThemeData theme) {
    return BlocBuilder<AppointmentCubit, AppointmentState>(
      builder: (context, state) {
        if (state is AppointmentLoaded) {
          final appointments = state.appointments;
          final now = DateTime.now();
          
          // حساب المواعيد اليوم
          final todayAppointments = appointments.where((app) {
            final appDate = DateTime.parse(app.date);
            return appDate.year == now.year && 
                   appDate.month == now.month && 
                   appDate.day == now.day;
          }).length;

          // حساب المواعيد هذا الأسبوع
          final weekStart = now.subtract(Duration(days: now.weekday - 1));
          final weekAppointments = appointments.where((app) {
            final appDate = DateTime.parse(app.date);
            return appDate.isAfter(weekStart) && 
                   appDate.isBefore(weekStart.add(const Duration(days: 7)));
          }).length;

          // حساب المواعيد هذا الشهر
          final monthStart = DateTime(now.year, now.month, 1);
          final monthAppointments = appointments.where((app) {
            final appDate = DateTime.parse(app.date);
            return appDate.isAfter(monthStart) && 
                   appDate.isBefore(DateTime(now.year, now.month + 1, 0));
          }).length;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'إحصائيات المواعيد',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'مواعيد اليوم',
                      value: todayAppointments.toString(),
                      icon: Icons.today,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _StatCard(
                      title: 'مواعيد الأسبوع',
                      value: weekAppointments.toString(),
                      icon: Icons.calendar_view_week,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'مواعيد الشهر',
                      value: monthAppointments.toString(),
                      icon: Icons.calendar_month,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _StatCard(
                      title: 'إجمالي المواعيد',
                      value: appointments.length.toString(),
                      icon: Icons.calendar_today,
                    ),
                  ),
                ],
              ),
            ],
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final double? trend;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.value,
    this.trend,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: theme.primaryColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: theme.textTheme.headlineMedium,
            ),
            if (trend != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    trend! >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                    color: trend! >= 0 ? Colors.green : Colors.red,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${trend!.abs().toStringAsFixed(1)}%',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: trend! >= 0 ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}