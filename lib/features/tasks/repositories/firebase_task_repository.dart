import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:ngo_volunteer_management/core/enums/app_enums.dart';
import 'package:ngo_volunteer_management/shared/data/entities.dart';
import 'package:ngo_volunteer_management/shared/data/repositories.dart';

class FirebaseTaskRepository implements ITaskRepository {
  final String _collectionPath = 'tasks';
  FirebaseFirestore? _firestore;

  FirebaseTaskRepository() {
    if (Firebase.apps.isNotEmpty) {
      _firestore = FirebaseFirestore.instance;
    }
  }

  FirebaseFirestore get _db {
    if (_firestore == null) {
      try {
        _firestore = FirebaseFirestore.instance;
      } catch (e) {
        debugPrint('Firebase not initialized: $e');
        rethrow;
      }
    }
    return _firestore!;
  }

  @override
  Future<List<TaskEntity>> getAll() async {
    final snapshot = await _db.collection(_collectionPath).get();
    return snapshot.docs.map((doc) => _fromMap(doc.data())).toList();
  }

  @override
  Stream<List<TaskEntity>> watchAll() {
    return _db.collection(_collectionPath).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => _fromMap(doc.data())).toList();
    });
  }

  @override
  Future<List<TaskEntity>> getByAssignee(int assigneeId, AssigneeType type) async {
    final snapshot = await _db
        .collection(_collectionPath)
        .where('assignedToId', isEqualTo: assigneeId)
        .where('assignedToType', isEqualTo: type.name)
        .get();
    return snapshot.docs.map((doc) => _fromMap(doc.data())).toList();
  }

  @override
  Stream<List<TaskEntity>> watchByAssignee(int assigneeId, AssigneeType type) {
    return _db
        .collection(_collectionPath)
        .where('assignedToId', isEqualTo: assigneeId)
        .where('assignedToType', isEqualTo: type.name)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => _fromMap(doc.data())).toList();
    });
  }

  @override
  Future<TaskEntity> add(TaskEntity task) async {
    await _db
        .collection(_collectionPath)
        .doc(task.id.toString())
        .set(_toMap(task));
    return task;
  }

  @override
  Future<TaskEntity> update(TaskEntity task) async {
    await _db
        .collection(_collectionPath)
        .doc(task.id.toString())
        .update(_toMap(task));
    return task;
  }

  @override
  Future<TaskEntity> updateStatus(int taskId, TaskStatus status) async {
    await _db
        .collection(_collectionPath)
        .doc(taskId.toString())
        .update({'status': status.name});
    final doc = await _db.collection(_collectionPath).doc(taskId.toString()).get();
    return _fromMap(doc.data()!);
  }

  Map<String, dynamic> _toMap(TaskEntity t) => {
        'id': t.id,
        'title': t.title,
        'description': t.description,
        'deadline': t.deadline,
        'assignedToId': t.assignedToId,
        'assignedToName': t.assignedToName,
        'assignedToType': t.assignedToType.name,
        'status': t.status.name,
        'requiresUpload': t.requiresUpload,
        'createdAt': t.createdAt,
        if (t.uploadedImage != null) 'uploadedImage': t.uploadedImage,
        if (t.submittedAt != null) 'submittedAt': t.submittedAt,
      };

  TaskEntity _fromMap(Map<String, dynamic> map) => TaskEntity(
        id: map['id'] as int,
        title: map['title'] as String,
        description: map['description'] as String,
        deadline: map['deadline'] as String,
        assignedToId: map['assignedToId'] as int,
        assignedToName: map['assignedToName'] as String,
        assignedToType: enumValueOr(
          AssigneeType.values,
          map['assignedToType'] as String,
          AssigneeType.volunteer,
        ),
        status: enumValueOr(
          TaskStatus.values,
          map['status'] as String,
          TaskStatus.pending,
        ),
        requiresUpload: map['requiresUpload'] as bool? ?? false,
        createdAt: map['createdAt'] as String,
        uploadedImage: map['uploadedImage'] as String?,
        submittedAt: map['submittedAt'] as String?,
      );

  T enumValueOr<T extends Enum>(List<T> values, String name, T fallback) {
    try {
      return values.firstWhere((e) => e.name == name);
    } catch (_) {
      return fallback;
    }
  }
}
