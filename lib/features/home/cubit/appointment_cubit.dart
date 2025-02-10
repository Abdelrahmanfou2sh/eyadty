import 'package:eyadty/features/home/data/appointment_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'appointment_state.dart';

class AppointmentCubit extends Cubit<AppointmentState> {
  AppointmentCubit() : super(AppointmentInitial());

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> fetchAppointments() async {
    emit(AppointmentLoading());
    try {
      QuerySnapshot snapshot = await _firestore.collection('appointments').get();
      List<AppointmentModel> appointments = snapshot.docs
          .map((doc) => AppointmentModel.fromJson(
              doc.id, doc.data() as Map<String, dynamic>))
          .toList();
      emit(AppointmentLoaded(appointments));
    } catch (e) {
      emit(AppointmentError('فشل في تحميل المواعيد'));
    }
  }

  Future<void> addAppointment(AppointmentModel appointment) async {
    try {
      // إذا كان الموعد متكرر، نقوم بإنشاء سلسلة المواعيد
      if (appointment.recurrence != null) {
        List<AppointmentModel> recurringAppointments = appointment.generateRecurringAppointments();
        
        // إضافة الموعد الأصلي أولاً
        DocumentReference docRef = await _firestore.collection('appointments').add(appointment.toJson());
        String parentAppointmentId = docRef.id;
        
        // إضافة المواعيد المتكررة
        for (var recAppointment in recurringAppointments) {
          await _firestore.collection('appointments').add(
            recAppointment.copyWith(parentAppointmentId: parentAppointmentId).toJson(),
          );
        }
        
        // تحديث حالة التطبيق
        if (state is AppointmentLoaded) {
          List<AppointmentModel> currentAppointments = List.from((state as AppointmentLoaded).appointments);
          currentAppointments.add(appointment.copyWith(id: parentAppointmentId));
          currentAppointments.addAll(recurringAppointments.map(
            (a) => a.copyWith(parentAppointmentId: parentAppointmentId),
          ));
          emit(AppointmentLoaded(currentAppointments));
        }
      } else {
        // إضافة موعد عادي
        DocumentReference docRef = await _firestore.collection('appointments').add(appointment.toJson());
        String newAppointmentId = docRef.id;
        AppointmentModel newAppointment = appointment.copyWith(id: newAppointmentId);
        if (state is AppointmentLoaded) {
          List<AppointmentModel> currentAppointments = List.from((state as AppointmentLoaded).appointments);
          currentAppointments.add(newAppointment);
          emit(AppointmentLoaded(currentAppointments));
        }
      }
    } catch (e) {
      emit(AppointmentError('فشل في إضافة الموعد'));
    }
  }

  Future<void> deleteAppointment(String id, {bool deleteRecurring = false}) async {
    try {
      if (deleteRecurring) {
        // حذف جميع المواعيد المرتبطة
        QuerySnapshot recurringAppointments = await _firestore
            .collection('appointments')
            .where('parentAppointmentId', isEqualTo: id)
            .get();
        
        // حذف المواعيد المتكررة
        for (var doc in recurringAppointments.docs) {
          await doc.reference.delete();
        }
        
        // حذف الموعد الأصلي
        await _firestore.collection('appointments').doc(id).delete();
        
        if (state is AppointmentLoaded) {
          List<AppointmentModel> currentAppointments = List.from((state as AppointmentLoaded).appointments);
          currentAppointments.removeWhere(
            (appointment) => appointment.id == id || appointment.parentAppointmentId == id,
          );
          emit(AppointmentLoaded(currentAppointments));
        }
      } else {
        // حذف موعد واحد فقط
        await _firestore.collection('appointments').doc(id).delete();
        if (state is AppointmentLoaded) {
          List<AppointmentModel> currentAppointments = List.from((state as AppointmentLoaded).appointments);
          currentAppointments.removeWhere((appointment) => appointment.id == id);
          emit(AppointmentLoaded(currentAppointments));
        }
      }
    } catch (e) {
      emit(AppointmentError('فشل في حذف الموعد'));
    }
  }

  Future<void> updateAppointmentStatus(String id, String status) async {
    try {
      await _firestore.collection('appointments').doc(id).update({'status': status});
      if (state is AppointmentLoaded) {
        List<AppointmentModel> currentAppointments = List.from((state as AppointmentLoaded).appointments);
        int index = currentAppointments.indexWhere((appointment) => appointment.id == id);
        if (index != -1) {
          currentAppointments[index] = currentAppointments[index].copyWith(status: status);
          emit(AppointmentLoaded(currentAppointments));
        }
      }
    } catch (e) {
      emit(AppointmentError('فشل في تحديث حالة الموعد'));
    }
  }
}