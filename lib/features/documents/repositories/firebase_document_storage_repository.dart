import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:ngo_volunteer_management/core/enums/app_enums.dart';
import 'package:ngo_volunteer_management/shared/data/entities.dart';
import 'package:ngo_volunteer_management/utils/app_formatters.dart';

class FirebaseDocumentStorageRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  static const String _collection = 'documents';

  /// Stream of all documents ordered by upload date descending
  Stream<List<DocumentEntity>> watchAll() {
    return _db
        .collection(_collection)
        .orderBy('uploadDate', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => _fromDoc(d)).toList());
  }

  Future<List<DocumentEntity>> getAll() async {
    final snap = await _db
        .collection(_collection)
        .orderBy('uploadDate', descending: true)
        .get();
    return snap.docs.map((d) => _fromDoc(d)).toList();
  }

  /// Pick a file and return the raw file info without uploading.
  /// Returns null if the user cancelled.
  Future<PlatformFile?> pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'xlsx', 'xls', 'png', 'jpg'],
    );
    if (result == null || result.files.isEmpty) return null;
    return result.files.first;
  }

  /// Upload an already-picked file with an explicitly provided [customTitle].
  Future<DocumentEntity> uploadFile({
    required PlatformFile file,
    required String customTitle,
    required String uploadedBy,
    void Function(double progress)? onProgress,
  }) async {
    final ext = file.extension?.toLowerCase() ?? 'pdf';
    final safeTitle = customTitle.trim().isEmpty ? file.name : customTitle.trim();
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.name}';
    final storageRef = _storage.ref().child('documents/$fileName');

    UploadTask uploadTask;
    if (kIsWeb) {
      uploadTask = storageRef.putData(
        file.bytes!,
        SettableMetadata(contentType: _mimeType(ext)),
      );
    } else {
      uploadTask = storageRef.putFile(
        File(file.path!),
        SettableMetadata(contentType: _mimeType(ext)),
      );
    }

    // Stream progress back to the caller
    if (onProgress != null) {
      uploadTask.snapshotEvents.listen((snap) {
        final total = snap.totalBytes;
        if (total > 0) {
          onProgress(snap.bytesTransferred / total);
        }
      });
    }

    final snap = await uploadTask;
    final downloadUrl = await snap.ref.getDownloadURL();
    final sizeLabel = _formatBytes(file.size);
    final category = _categoryFromExt(ext);
    final fileType = _fileTypeFromExt(ext);

    final docData = {
      'title': safeTitle,
      'category': category,
      'fileType': fileType.name,
      'size': sizeLabel,
      'uploadDate': AppFormatters.today(),
      'downloadUrl': downloadUrl,
      'uploadedBy': uploadedBy,
      'storagePath': 'documents/$fileName',
    };

    final docRef = await _db.collection(_collection).add(docData);

    return DocumentEntity(
      id: docRef.id,
      title: safeTitle,
      category: category,
      fileType: fileType,
      size: sizeLabel,
      uploadDate: AppFormatters.today(),
      downloadUrl: downloadUrl,
    );
  }

  /// Legacy combined pick+upload (kept for replace flow).
  Future<DocumentEntity?> pickAndUpload({required String uploadedBy}) async {
    final file = await pickFile();
    if (file == null) return null;
    return uploadFile(file: file, customTitle: file.name, uploadedBy: uploadedBy);
  }

  /// Replace an existing document
  Future<void> replaceDocument({
    required DocumentEntity existing,
    required String uploadedBy,
  }) async {
    // Delete old storage file
    if (existing.downloadUrl != null && existing.downloadUrl!.isNotEmpty) {
      try {
        final ref = _storage.refFromURL(existing.downloadUrl!);
        await ref.delete();
      } catch (_) {}
    }

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'xlsx', 'xls', 'png', 'jpg'],
    );
    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    final ext = file.extension?.toLowerCase() ?? 'pdf';
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.name}';
    final storageRef = _storage.ref().child('documents/$fileName');

    UploadTask uploadTask;
    if (kIsWeb) {
      uploadTask = storageRef.putData(file.bytes!, SettableMetadata(contentType: _mimeType(ext)));
    } else {
      uploadTask = storageRef.putFile(File(file.path!), SettableMetadata(contentType: _mimeType(ext)));
    }

    final snap = await uploadTask;
    final downloadUrl = await snap.ref.getDownloadURL();

    // Update Firestore record
    final querySnap = await _db
        .collection(_collection)
        .where('downloadUrl', isEqualTo: existing.downloadUrl)
        .limit(1)
        .get();

    if (querySnap.docs.isNotEmpty) {
      await querySnap.docs.first.reference.update({
        'title': file.name,
        'downloadUrl': downloadUrl,
        'size': _formatBytes(file.size),
        'uploadDate': AppFormatters.today(),
        'uploadedBy': uploadedBy,
        'storagePath': 'documents/$fileName',
        'fileType': _fileTypeFromExt(ext).name,
      });
    }
  }

  Future<void> deleteDocument(DocumentEntity doc) async {
    if (doc.downloadUrl != null && doc.downloadUrl!.isNotEmpty) {
      try {
        final ref = _storage.refFromURL(doc.downloadUrl!);
        await ref.delete();
      } catch (_) {}
    }

    final querySnap = await _db
        .collection(_collection)
        .where('downloadUrl', isEqualTo: doc.downloadUrl)
        .limit(1)
        .get();

    for (final d in querySnap.docs) {
      await d.reference.delete();
    }
  }

  DocumentEntity _fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DocumentEntity(
      id: doc.id,
      title: data['title'] as String? ?? 'Untitled',
      category: data['category'] as String? ?? 'General',
      fileType: DocumentFileType.values.firstWhere(
        (f) => f.name == (data['fileType'] as String? ?? 'pdf'),
        orElse: () => DocumentFileType.pdf,
      ),
      size: data['size'] as String? ?? '',
      uploadDate: data['uploadDate'] as String? ?? '',
      downloadUrl: data['downloadUrl'] as String?,
    );
  }

  String _mimeType(String ext) {
    return switch (ext) {
      'pdf'  => 'application/pdf',
      'doc'  => 'application/msword',
      'docx' => 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      'xlsx' => 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      'xls'  => 'application/vnd.ms-excel',
      'png'  => 'image/png',
      'jpg'  => 'image/jpeg',
      _      => 'application/octet-stream',
    };
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String _categoryFromExt(String ext) {
    return switch (ext) {
      'pdf' || 'doc' || 'docx' => 'Documents',
      'xlsx' || 'xls'          => 'Reports',
      'png' || 'jpg'           => 'Images',
      _                        => 'General',
    };
  }

  DocumentFileType _fileTypeFromExt(String ext) {
    return switch (ext) {
      'pdf'           => DocumentFileType.pdf,
      'xlsx' || 'xls' => DocumentFileType.xlsx,
      'jpg' || 'jpeg' => DocumentFileType.jpg,
      'png'           => DocumentFileType.png,
      _               => DocumentFileType.doc,
    };
  }
}
