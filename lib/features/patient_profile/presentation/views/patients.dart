import 'package:eyadty/features/patient_profile/data/patient_model.dart';
import 'package:eyadty/features/patient_profile/presentation/cubit/patient_profile_cubit.dart';
import 'package:eyadty/features/patient_profile/presentation/cubit/patient_proflie_sate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class PatientProfileScreen extends StatefulWidget {
  final String patientId;

  const PatientProfileScreen({Key? key, required this.patientId}) : super(key: key);

  @override
  State<PatientProfileScreen> createState() => _PatientProfileScreenState();
}

class _PatientProfileScreenState extends State<PatientProfileScreen> {
  @override
  void initState() {
    super.initState();
    context.read<PatientProfileCubit>().loadPatient(widget.patientId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ملف المريض'),
        centerTitle: true,
        backgroundColor: Colors.blue[700],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.read<PatientProfileCubit>().uploadDocument(widget.patientId);
        },
        backgroundColor: Colors.blue[700],
        child: const Icon(Icons.upload_file),
      ),
      body: BlocConsumer<PatientProfileCubit, PatientProfileState>(
        listener: (context, state) {
          if (state is DocumentUploaded) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('تم رفع المستند بنجاح!')),
            );
          } else if (state is PatientProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is PatientProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is PatientProfileLoaded) {
            final patient = state.patient;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.blue[700],
                                radius: 30,
                                child: Text(
                                  patient.name.substring(0, 1).toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 24,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      patient.name,
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'العمر: ${patient.age} سنة',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue[50],
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  patient.bloodType,
                                  style: TextStyle(
                                    color: Colors.blue[700],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 32),
                          _buildInfoRow(Icons.phone, 'رقم الهاتف', patient.phoneNumber),
                          const SizedBox(height: 12),
                          _buildInfoRow(Icons.emergency, 'رقم الطوارئ', patient.emergencyContact),
                          const SizedBox(height: 12),
                          _buildInfoRow(Icons.location_on, 'العنوان', patient.address),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'التشخيص الطبي',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            patient.medicalDiagnosis,
                            style: const TextStyle(fontSize: 16),
                          ),
                          if (patient.notes.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            const Text(
                              'ملاحظات',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              patient.notes,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  if (patient.allergies.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildListCard('الحساسية', patient.allergies),
                  ],
                  if (patient.chronicDiseases.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildListCard('الأمراض المزمنة', patient.chronicDiseases),
                  ],
                  const SizedBox(height: 16),
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'المستندات',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextButton.icon(
                                onPressed: () {
                                  context.read<PatientProfileCubit>().uploadDocument(widget.patientId);
                                },
                                icon: const Icon(Icons.upload_file),
                                label: const Text('إضافة مستند'),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.blue[700],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (patient.documents.isEmpty)
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                  'لا توجد مستندات',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            )
                          else
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: patient.documents.length,
                              separatorBuilder: (context, index) => const Divider(height: 16),
                              itemBuilder: (context, index) {
                                final document = patient.documents[index];
                                return ListTile(
                                  leading: Icon(
                                    _getDocumentIcon(document.type),
                                    color: Colors.blue[700],
                                  ),
                                  title: Text(document.documentName),
                                  subtitle: Text(
                                    'تم الرفع: ${DateFormat('yyyy-MM-dd').format(document.uploadDate)}',
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.download),
                                    onPressed: () {
                                      // Handle document download
                                    },
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'لا توجد بيانات متاحة',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildListCard(String title, List<String> items) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: items.map((item) => Chip(
                label: Text(item),
                backgroundColor: Colors.blue[50],
                labelStyle: TextStyle(
                  color: Colors.blue[700],
                ),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getDocumentIcon(String type) {
    switch (type.toLowerCase()) {
      case 'prescription':
        return Icons.medical_services;
      case 'lab_result':
        return Icons.science;
      case 'x_ray':
        return Icons.image;
      default:
        return Icons.description;
    }
  }
}