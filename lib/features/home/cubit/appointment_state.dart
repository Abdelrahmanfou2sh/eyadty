import 'package:equatable/equatable.dart';
import 'package:eyadty/features/home/data/appointment_model.dart';

abstract class AppointmentState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AppointmentInitial extends AppointmentState {}

class AppointmentLoading extends AppointmentState {}

class AppointmentLoaded extends AppointmentState {
  final List<AppointmentModel> appointments;

  AppointmentLoaded(this.appointments);

  @override
  List<Object?> get props => [appointments];
}
class AppointmentStatusLoading extends AppointmentState {
  final String appointmentId;

  AppointmentStatusLoading({required this.appointmentId});

  @override
  List<Object> get props => [appointmentId];
}

class AppointmentError extends AppointmentState {
  final String message;

  AppointmentError(this.message);

  @override
  List<Object?> get props => [message];
}
