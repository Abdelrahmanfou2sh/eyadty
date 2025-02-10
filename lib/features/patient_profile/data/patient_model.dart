import 'package:cloud_firestore/cloud_firestore.dart';

class Patient {
  final String? id;
  final String name;
  final String phoneNumber;
  final String address;
  final String medicalDiagnosis;
  final String gender;
  final DateTime dateOfBirth;
  final String bloodType;
  final List<String> allergies;
  final List<String> chronicDiseases;
  final List<Document> documents;
  final DateTime createdAt;
  final DateTime? lastVisit;
  final String emergencyContact;
  final String notes;

  Patient({
    this.id,
    required this.name,
    required this.phoneNumber,
    required this.address,
    required this.medicalDiagnosis,
    required this.gender,
    required this.dateOfBirth,
    required this.bloodType,
    this.allergies = const [],
    this.chronicDiseases = const [],
    this.documents = const [],
    DateTime? createdAt,
    this.lastVisit,
    required this.emergencyContact,
    this.notes = '',
  }) : createdAt = createdAt ?? DateTime.now();

  int get age {
    final today = DateTime.now();
    var age = today.year - dateOfBirth.year;
    if (today.month < dateOfBirth.month || 
        (today.month == dateOfBirth.month && today.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phoneNumber': phoneNumber,
      'address': address,
      'medicalDiagnosis': medicalDiagnosis,
      'gender': gender,
      'dateOfBirth': Timestamp.fromDate(dateOfBirth),
      'bloodType': bloodType,
      'allergies': allergies,
      'chronicDiseases': chronicDiseases,
      'documents': documents.map((doc) => doc.toMap()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
      'lastVisit': lastVisit != null ? Timestamp.fromDate(lastVisit!) : null,
      'emergencyContact': emergencyContact,
      'notes': notes,
    };
  }

  factory Patient.fromMap(Map<String, dynamic> map, String id) {
    return Patient(
      id: id,
      name: map['name'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      address: map['address'] ?? '',
      medicalDiagnosis: map['medicalDiagnosis'] ?? '',
      gender: map['gender'] ?? '',
      dateOfBirth: map['dateOfBirth'] != null 
          ? (map['dateOfBirth'] as Timestamp).toDate()
          : DateTime.now(),
      bloodType: map['bloodType'] ?? 'غير محدد',
      allergies: List<String>.from(map['allergies'] ?? []),
      chronicDiseases: List<String>.from(map['chronicDiseases'] ?? []),
      documents: map['documents'] != null
          ? List<Document>.from(
              map['documents'].map((doc) => Document.fromMap(doc)))
          : [],
      createdAt: map['createdAt'] != null 
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      lastVisit: map['lastVisit'] != null 
          ? (map['lastVisit'] as Timestamp).toDate()
          : null,
      emergencyContact: map['emergencyContact'] ?? '',
      notes: map['notes'] ?? '',
    );
  }

  Patient copyWith({
    String? id,
    String? name,
    String? phoneNumber,
    String? address,
    String? medicalDiagnosis,
    String? gender,
    DateTime? dateOfBirth,
    String? bloodType,
    List<String>? allergies,
    List<String>? chronicDiseases,
    List<Document>? documents,
    DateTime? createdAt,
    DateTime? lastVisit,
    String? emergencyContact,
    String? notes,
  }) {
    return Patient(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      medicalDiagnosis: medicalDiagnosis ?? this.medicalDiagnosis,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      bloodType: bloodType ?? this.bloodType,
      allergies: allergies ?? this.allergies,
      chronicDiseases: chronicDiseases ?? this.chronicDiseases,
      documents: documents ?? this.documents,
      createdAt: createdAt ?? this.createdAt,
      lastVisit: lastVisit ?? this.lastVisit,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      notes: notes ?? this.notes,
    );
  }
}

class Document {
  final String documentName;
  final DateTime uploadDate;
  final String downloadUrl;
  final String type; 
  final String notes;

  Document({
    required this.documentName,
    required this.uploadDate,
    required this.downloadUrl,
    required this.type,
    this.notes = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'documentName': documentName,
      'uploadDate': Timestamp.fromDate(uploadDate),
      'downloadUrl': downloadUrl,
      'type': type,
      'notes': notes,
    };
  }

  factory Document.fromMap(Map<String, dynamic> map) {
    return Document(
      documentName: map['documentName'] ?? '',
      uploadDate: (map['uploadDate'] as Timestamp).toDate(),
      downloadUrl: map['downloadUrl'] ?? '',
      type: map['type'] ?? '',
      notes: map['notes'] ?? '',
    );
  }
}