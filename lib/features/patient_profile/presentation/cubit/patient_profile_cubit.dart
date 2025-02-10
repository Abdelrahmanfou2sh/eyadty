import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eyadty/features/patient_profile/data/patient_model.dart';
import 'package:eyadty/features/patient_profile/presentation/cubit/patient_proflie_sate.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PatientProfileCubit extends Cubit<PatientProfileState> {
  PatientProfileCubit() : super(PatientProfileInitial());

  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;

  Future<void> loadPatients() async {
    emit(PatientProfileLoading());
    try {
      final snapshot = await _firestore.collection('patients').get();
      final patients = snapshot.docs.map((doc) => Patient.fromMap(doc.data(), doc.id)).toList();
      emit(PatientsLoaded(patients));
    } catch (e) {
      emit(PatientProfileError(e.toString()));
    }
  }

  Future<void> loadPatient(String patientId) async {
    emit(PatientProfileLoading());
    try {
      final doc = await _firestore.collection('patients').doc(patientId).get();
      final patient = Patient.fromMap(doc.data()!, doc.id);
      emit(PatientProfileLoaded(patient));
    } catch (e) {
      emit(PatientProfileError(e.toString()));
    }
  }

  Future<void> createPatient(Patient patient) async {
    emit(PatientProfileLoading());
    try {
      final docRef = await _firestore.collection('patients').add(patient.toMap());
      emit(PatientCreated(docRef.id));
    } catch (e) {
      emit(PatientProfileError(e.toString()));
    }
  }

  Future<void> uploadDocument(String patientId) async {
    emit(PatientProfileLoading());
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result != null) {
        File file = File(result.files.single.path!);
        String fileName = result.files.single.name;
        final ref = _storage.ref().child('patient_documents/$patientId/$fileName');
        final uploadTask = ref.putFile(file);
        uploadTask.snapshotEvents.listen((event) {
          final progress = event.bytesTransferred / event.totalBytes;
          emit(UploadProgress(progress));
        });
        await uploadTask.whenComplete(() => null);
        final downloadUrl = await ref.getDownloadURL();
        final document = Document(
          documentName: fileName,
          uploadDate: DateTime.now(),
          downloadUrl: downloadUrl,
          type: 'general',
        );
        await _firestore.collection('patients').doc(patientId).update({
          'documents': FieldValue.arrayUnion([document.toMap()])
        });
        emit(DocumentUploaded());
      } else {
        emit(PatientProfileError('No file selected'));
      }
    } catch (e) {
      emit(PatientProfileError(e.toString()));
    }
  }

  Stream<int> getPatientsCount() {
    return _firestore.collection('patients').snapshots().map((snapshot) => snapshot.docs.length);
  }

  // إضافة دوال جديدة للإحصائيات
  int getNewPatientsCount({DateTime? startDate, DateTime? endDate}) {
    if (state is! PatientsLoaded) return 0;
    final patients = (state as PatientsLoaded).patients;
    
    final now = DateTime.now();
    startDate ??= DateTime(now.year, now.month, 1);
    endDate ??= DateTime(now.year, now.month + 1, 0);

    return patients.where((patient) {
      return patient.createdAt.isAfter(startDate!) && 
             patient.createdAt.isBefore(endDate!);
    }).length;
  }

  List<MapEntry<DateTime, int>> getNewPatientsPerMonth({int monthsCount = 12}) {
    if (state is! PatientsLoaded) return [];
    final patients = (state as PatientsLoaded).patients;
    
    final now = DateTime.now();
    final List<MapEntry<DateTime, int>> monthlyStats = [];

    for (int i = 0; i < monthsCount; i++) {
      final month = DateTime(now.year, now.month - i, 1);
      final endOfMonth = DateTime(month.year, month.month + 1, 0);
      
      final count = patients.where((patient) {
        return patient.createdAt.isAfter(month) && 
               patient.createdAt.isBefore(endOfMonth);
      }).length;
      
      monthlyStats.add(MapEntry(month, count));
    }

    return monthlyStats.reversed.toList();
  }

  double getPatientGrowthRate() {
    if (state is! PatientsLoaded) return 0;
    final patients = (state as PatientsLoaded).patients;
    
    final now = DateTime.now();
    final thisMonth = patients.where((patient) {
      final startDate = DateTime(now.year, now.month, 1);
      final endDate = DateTime(now.year, now.month + 1, 0);
      return patient.createdAt.isAfter(startDate) && 
             patient.createdAt.isBefore(endDate);
    }).length;
    
    final lastMonth = patients.where((patient) {
      final startDate = DateTime(now.year, now.month - 1, 1);
      final endDate = DateTime(now.year, now.month, 0);
      return patient.createdAt.isAfter(startDate) && 
             patient.createdAt.isBefore(endDate);
    }).length;

    if (lastMonth == 0) return 0;
    return ((thisMonth - lastMonth) / lastMonth) * 100;
  }
}