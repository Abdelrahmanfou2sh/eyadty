import 'package:eyadty/features/home/cubit/appointment_cubit.dart';
import 'package:eyadty/features/home/cubit/appointment_state.dart';
import 'package:eyadty/features/home/presentation/widgets/appointment_card.dart';
import 'package:eyadty/features/home/presentation/widgets/shimmer_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();
  String searchQuery = "";
  final TextEditingController _searchController = TextEditingController();
  bool isSearching = false;
  late Future<void> _eventsFuture;

  Map<DateTime, List<dynamic>> _events = {};

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  void _loadEvents() {
    _eventsFuture = Future.delayed(Duration.zero, () async {
      final state = context.read<AppointmentCubit>().state;
      if (state is! AppointmentLoaded) {
        await context.read<AppointmentCubit>().fetchAppointments();
      }
      _updateEvents();
    });
  }

  void _updateEvents() {
    final state = context.read<AppointmentCubit>().state;
    if (state is AppointmentLoaded) {
      final events = <DateTime, List<dynamic>>{};
      for (var appointment in state.appointments) {
        final date = DateTime.parse(appointment.date);
        final key = DateTime(date.year, date.month, date.day);
        if (events[key] == null) events[key] = [];
        events[key]!.add(appointment);
      }
      if (mounted) {
        setState(() {
          _events = events;
        });
      }
    }
  }

  List<dynamic> _getEventsForDay(DateTime day) {
    return _events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _eventsFuture,
      builder: (context, snapshot) {
        return Scaffold(
          appBar: AppBar(
            title: isSearching
                ? TextField(
                    controller: _searchController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'ابحث عن اسم المريض...',
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: Colors.white70),
                    ),
                    style: TextStyle(color: Colors.white),
                    onChanged: (query) {
                      setState(() {
                        searchQuery = query;
                      });
                    },
                  )
                : const Text('التقويم'),
            actions: [
              if (isSearching)
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    setState(() {
                      isSearching = false;
                      searchQuery = "";
                      _searchController.clear();
                    });
                  },
                ),
              IconButton(
                icon: Icon(isSearching ? Icons.close : Icons.search),
                onPressed: () {
                  setState(() {
                    isSearching = !isSearching;
                    if (!isSearching) {
                      searchQuery = "";
                      _searchController.clear();
                    }
                  });
                },
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              await context.read<AppointmentCubit>().fetchAppointments();
              _updateEvents();
            },
            child: Column(
              children: [
                _buildSearchBar(),
                _buildCalendar(),
                Expanded(
                  child: _buildEventsList(),
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.pushNamed(context, '/add-appointment').then((_) {
                _loadEvents();
              });
            },
            child: Icon(Icons.add),
            tooltip: 'إضافة موعد جديد',
          ),
        );
      },
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'بحث عن موعد...',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onChanged: (value) {
          setState(() {
            searchQuery = value;
          });
        },
      ),
    );
  }

  Widget _buildCalendar() {
    return TableCalendar(
      firstDay: DateTime.utc(2023, 1, 1),
      lastDay: DateTime.utc(2025, 12, 31),
      focusedDay: _focusedDay,
      calendarFormat: _calendarFormat,
      selectedDayPredicate: (day) {
        return isSameDay(_selectedDay, day);
      },
      eventLoader: _getEventsForDay,
      startingDayOfWeek: StartingDayOfWeek.saturday,
      calendarStyle: const CalendarStyle(
        outsideDaysVisible: false,
      ),
      onDaySelected: (selectedDay, focusedDay) {
        if (!isSameDay(_selectedDay, selectedDay)) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        }
      },
      onFormatChanged: (format) {
        if (_calendarFormat != format) {
          setState(() {
            _calendarFormat = format;
          });
        }
      },
      onPageChanged: (focusedDay) {
        _focusedDay = focusedDay;
      },
    );
  }

  Widget _buildEventsList() {
    return BlocBuilder<AppointmentCubit, AppointmentState>(
      builder: (context, state) {
        if (state is AppointmentLoading) {
          return ListView.builder(
            itemCount: 3,
            padding: const EdgeInsets.all(8),
            itemBuilder: (context, index) => const ShimmerCard(),
          );
        }

        if (state is AppointmentLoaded) {
          var appointments = _getEventsForDay(_selectedDay!);
          
          if (searchQuery.isNotEmpty) {
            appointments = appointments.where((appointment) {
              final searchLower = searchQuery.toLowerCase();
              return appointment.patientName.toLowerCase().contains(searchLower) ||
                     appointment.phoneNumber.toLowerCase().contains(searchLower) ||
                     appointment.type.toLowerCase().contains(searchLower);
            }).toList();
          }

          if (appointments.isEmpty) {
            return Center(
              child: Text(
                searchQuery.isEmpty
                    ? 'لا توجد مواعيد في هذا اليوم'
                    : 'لا توجد نتائج للبحث',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              return AppointmentCard(
                appointment: appointments[index],
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
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}