import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:ngo_volunteer_management/core/enums/app_enums.dart';
import 'package:ngo_volunteer_management/shared/data/entities.dart';
import 'package:ngo_volunteer_management/utils/app_formatters.dart';

// Note: For mobile, we use specific logic to avoid dart:io on web.
// We import it conditionally or use absolute byte data where possible.

class FirebaseDocumentStorageRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  
  // Use the default instance to ensure it picks up the login session automatically
  FirebaseStorage get _storage => FirebaseStorage.instance;
  
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
  Future<PlatformFile?> pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'xlsx', 'xls', 'png', 'jpg', 'jpeg'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return null;
    return result.files.first;
  }

  /// Upload a picked file with progress support.
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
      if (file.bytes == null) throw Exception('File data missing');
      uploadTask = storageRef.putData(
        file.bytes!,
        SettableMetadata(contentType: _getMimeType(ext)),
      );
    } else {
      uploadTask = storageRef.putFile(
        File(file.path!),
        SettableMetadata(contentType: _getMimeType(ext)),
      );
    }

    if (onProgress != null) {
      uploadTask.snapshotEvents.listen((snap) {
        final total = snap.totalBytes;
        if (total > 0) onProgress(snap.bytesTransferred / total);
      });
    }

    final snap = await uploadTask;
    final downloadUrl = await snap.ref.getDownloadURL();
    final sizeLabel = _formatBytes(file.size);

    final docData = {
      'title': safeTitle,
      'category': _categoryFromExt(ext),
      'fileType': _fileTypeFromExt(ext).name,
      'size': sizeLabel,
      'uploadDate': AppFormatters.today(),
      'uploadedBy': uploadedBy,
      'downloadUrl': downloadUrl,
      'storagePath': 'documents/$fileName',
    };

    final docRef = await _db.collection(_collection).add(docData);

    return DocumentEntity(
      id: docRef.id,
      title: safeTitle,
      category: _categoryFromExt(ext),
      fileType: _fileTypeFromExt(ext),
      size: sizeLabel,
      uploadDate: AppFormatters.today(),
      downloadUrl: downloadUrl,
    );
  }

  /// Combined pick+upload (wrapper for legacy use if any)
  Future<DocumentEntity?> pickAndUpload({required String uploadedBy}) async {
    final file = await pickFile();
    if (file == null) return null;
    return uploadFile(file: file, customTitle: file.name, uploadedBy: uploadedBy);
  }

  /// Upload raw bytes directly (used for generated documents like MOU Acceptance)
  Future<String> uploadBytes({
    required Uint8List bytes,
    required String fileName,
    required String contentType,
  }) async {
    final storageRef = _storage.ref().child('documents/$fileName');
    await storageRef.putData(bytes, SettableMetadata(contentType: contentType));
    return await storageRef.getDownloadURL();
  }


  /// Replace an existing document
  Future<void> replaceDocument({
    required DocumentEntity existing,
    required String uploadedBy,
  }) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'xlsx', 'xls', 'png', 'jpg', 'jpeg'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;
    
    // Delete old file if exists
    try {
      final snap = await _db.collection(_collection).doc(existing.id).get();
      final oldPath = (snap.data() as Map<String, dynamic>?)?['storagePath'] as String?;
      if (oldPath != null) await _storage.ref().child(oldPath).delete();
    } catch (_) {}

    final file = result.files.first;
    final String fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.name}';
    final storageRef = _storage.ref().child('documents/$fileName');
    
    if (file.bytes == null) throw Exception('File data missing');
    
    await storageRef.putData(
      file.bytes!,
      SettableMetadata(contentType: _getMimeType(file.extension))
    );
    
    final downloadUrl = await storageRef.getDownloadURL();

    await _db.collection(_collection).doc(existing.id).update({
      'title': file.name,
      'size': _formatBytes(file.size),
      'uploadDate': AppFormatters.today(),
      'uploadedBy': uploadedBy,
      'fileType': _fileTypeFromExt(file.extension?.toLowerCase() ?? '').name,
      'downloadUrl': downloadUrl,
      'storagePath': 'documents/$fileName',
    });
  }

  Future<void> updateTitle(String docId, String newTitle) async {
    await _db.collection(_collection).doc(docId).update({
      'title': newTitle,
    });
  }

  Future<void> deleteDocument(DocumentEntity doc) async {
    try {
      final snap = await _db.collection(_collection).doc(doc.id).get();
      final path = (snap.data() as Map<String, dynamic>?)?['storagePath'] as String?;
      if (path != null) await _storage.ref().child(path).delete();
    } catch (_) {}
    
    await _db.collection(_collection).doc(doc.id).delete();
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

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String _categoryFromExt(String ext) {
    return switch (ext) {
      'pdf' || 'doc' || 'docx' => 'Documents',
      'xlsx' || 'xls'          => 'Reports',
      'png' || 'jpg' || 'jpeg' => 'Images',
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

  String? _getMimeType(String? ext) {
    return switch (ext?.toLowerCase()) {
      'pdf'        => 'application/pdf',
      'docx'       => 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      'doc'        => 'application/msword',
      'xlsx'       => 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      'xls'        => 'application/vnd.ms-excel',
      'png'        => 'image/png',
      'jpg' || 'jpeg' => 'image/jpeg',
      _            => 'application/octet-stream',
    };
  }
}

