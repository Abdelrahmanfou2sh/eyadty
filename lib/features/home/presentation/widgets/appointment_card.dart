import 'package:eyadty/features/home/cubit/appointment_cubit.dart';
import 'package:eyadty/features/home/cubit/appointment_state.dart';
import 'package:flutter/material.dart';
import 'package:eyadty/features/home/data/appointment_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class AppointmentCard extends StatefulWidget {
  final AppointmentModel appointment;

  const AppointmentCard({Key? key, required this.appointment}) : super(key: key);

  @override
  State<AppointmentCard> createState() => _AppointmentCardState();
}

class _AppointmentCardState extends State<AppointmentCard> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppointmentCubit, AppointmentState>(
      builder: (context, state) {
        bool isLoading = false;
        if (state is AppointmentStatusLoading) {
          isLoading = state.appointmentId == widget.appointment.id;
        }
        return Card(
          elevation: 4,
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ExpansionTile(
            title: Text(
              widget.appointment.patientName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            leading: CircleAvatar(
              backgroundColor: getStatusColor(widget.appointment.status),
              child: getStatusIcon(widget.appointment.status),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '📅 ${widget.appointment.date}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
                Text(
                  '⏰ ${widget.appointment.time}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
                const SizedBox(height: 4),
                InkWell(
                  onTap: () => _makePhoneCall(widget.appointment.phoneNumber),
                  child: Text(
                    '📞 ${widget.appointment.phoneNumber}',
                    style: const TextStyle(fontSize: 14, color: Colors.blueAccent, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                PopupMenuButton<String>(
                  onSelected: (newStatus) {
                    BlocProvider.of<AppointmentCubit>(context).updateAppointmentStatus(widget.appointment.id, newStatus);
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'قادم', child: Text('قادم')),
                    const PopupMenuItem(value: 'مكتمل', child: Text('مكتمل')),
                    const PopupMenuItem(value: 'ملغي', child: Text('ملغي')),
                    const PopupMenuItem(value: 'مؤجل', child: Text('مؤجل')),
                  ],
                  child: isLoading
                      ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                    ),
                  )
                      : Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: getStatusColor(widget.appointment.status),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      widget.appointment.status,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    // Show confirmation dialog
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Delete Appointment'),
                          content: const Text('Are you sure you want to delete this appointment?'),
                          actions: [
                            TextButton(
                              child: const Text('Cancel'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            TextButton(
                              child: const Text('Delete'),
                              onPressed: () {
                                // Delete appointment
                                context.read<AppointmentCubit>().deleteAppointment(widget.appointment.id);
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('نوع الكشف: ${widget.appointment.appointmentType}'),
                    // Add more details here
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 🔹 ألوان الحالات المختلفة
  Color getStatusColor(String status) {
    switch (status) {
      case 'قادم':
        return Colors.orange;
      case 'مكتمل':
        return Colors.green;
      case 'ملغي':
        return Colors.red;
      case 'مؤجل':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  // 🔹 أيقونات لكل حالة
  Icon getStatusIcon(String status) {
    switch (status) {
      case 'قادم':
        return const Icon(Icons.access_time, color: Colors.white);
      case 'مكتمل':
        return const Icon(Icons.check_circle, color: Colors.white);
      case 'ملغي':
        return const Icon(Icons.cancel, color: Colors.white);
      case 'مؤجل':
        return const Icon(Icons.pause_circle_filled, color: Colors.white);
      default:
        return const Icon(Icons.info, color: Colors.white);
    }
  }

  Future<void> requestCallPermission() async {
    var status = await Permission.phone.request();
    if (status.isGranted) {
      print("✔️ إذن الاتصال ممنوح");
    } else {
      print("❌ إذن الاتصال مرفوض");
    }
  }

  void _makePhoneCall(String phoneNumber) async {
    String formattedPhoneNumber = phoneNumber.startsWith('+') ? phoneNumber : '+20$phoneNumber';
    final Uri url = Uri.parse('tel:$formattedPhoneNumber');

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      print("❌ لا يمكن إجراء المكالمة إلى $formattedPhoneNumber");
    }
  }
}