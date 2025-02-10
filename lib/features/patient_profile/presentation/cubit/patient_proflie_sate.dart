import 'package:eyadty/features/patient_profile/data/patient_model.dart';

abstract class PatientProfileState {}

class PatientProfileInitial extends PatientProfileState {}

class PatientProfileLoading extends PatientProfileState {}

class PatientsLoaded extends PatientProfileState {
  final List<Patient> patients;

  PatientsLoaded(this.patients);
}

class PatientProfileLoaded extends PatientProfileState {
  final Patient patient;

  PatientProfileLoaded(this.patient);
}

class PatientCreated extends PatientProfileState {
  final String patientId;

  PatientCreated(this.patientId);
}

class DocumentUploaded extends PatientProfileState {
  DocumentUploaded();
}

class UploadProgress extends PatientProfileState {
  final double progress;

  UploadProgress(this.progress);
}

class PatientProfileError extends PatientProfileState {
  final String message;

  PatientProfileError(this.message);
}