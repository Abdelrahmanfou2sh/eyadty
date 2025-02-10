import 'package:cloud_firestore/cloud_firestore.dart';

class Document {
  final String documentName;
  final String documentUrl;
  final DateTime uploadDate;

  Document({
    required this.documentName,
    required this.documentUrl,
    required this.uploadDate,
  });

  Map<String, dynamic> toJson() => {
    'documentName': documentName,
    'documentUrl': documentUrl,
    'uploadDate': uploadDate,
  };

  factory Document.fromJson(Map<String, dynamic> json) => Document(
    documentName: json['documentName'],
    documentUrl: json['documentUrl'],
    uploadDate: (json['uploadDate'] as Timestamp).toDate(),
  );
}