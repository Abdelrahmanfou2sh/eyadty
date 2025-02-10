import 'package:eyadty/features/home/cubit/appointment_cubit.dart';
import 'package:eyadty/features/home/cubit/appointment_state.dart';
import 'package:eyadty/features/home/presentation/widgets/appointment_card.dart';
import 'package:eyadty/features/home/presentation/widgets/shimmer_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';

class AppointmentList extends StatefulWidget {
  const AppointmentList({Key? key}) : super(key: key);

  @override
  State<AppointmentList> createState() => _AppointmentListState();
}

class _AppointmentListState extends State<AppointmentList> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TableCalendar(
          firstDay: DateTime.utc(2010, 10, 16),
          lastDay: DateTime.utc(2030, 3, 14),
          focusedDay: _focusedDay,
          calendarFormat: _calendarFormat,
          selectedDayPredicate: (day) {
            return isSameDay(_selectedDay, day);
          },
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
        ),
        Expanded(
          child: BlocBuilder<AppointmentCubit, AppointmentState>(
            builder: (context, state) {
              if (state is AppointmentLoading) {
                // Show Shimmer Effect
                return ListView.builder(
                  itemCount: 5, // Number of shimmer cards to show
                  itemBuilder: (context, index) {
                    return const ShimmerCard();
                  },
                );
              } else if (state is AppointmentLoaded) {
                // Show Appointment Cards
                final filteredAppointments = _selectedDay == null
                    ? state.appointments
                    : state.appointments.where((appointment) => isSameDay(DateTime.parse(appointment.date), _selectedDay)).toList();
                return ListView.builder(
                  itemCount: filteredAppointments.length,
                  itemBuilder: (context, index) {
                    return  AppointmentCard(appointment: filteredAppointments[index]);
                  },
                );
              } else if (state is AppointmentError) {
                // Show Error Message
                return Center(child:  Text('Error: ${state.message}'));
              } else {
                // Show Empty State
                return const Center(child: Text('No appointments found'));
              }
            },
          ),
        ),
      ],
    );
  }
}