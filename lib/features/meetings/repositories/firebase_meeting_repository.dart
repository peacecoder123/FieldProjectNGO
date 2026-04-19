import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:ngo_volunteer_management/core/enums/app_enums.dart';
import 'package:ngo_volunteer_management/shared/data/entities.dart';
import 'package:ngo_volunteer_management/shared/data/repositories.dart';

class FirebaseMeetingRepository implements IMeetingRepository {
  final String _collectionPath = 'meetings';
  FirebaseFirestore? _firestore;

  FirebaseMeetingRepository() {
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
  Future<List<MeetingEntity>> getAll() async {
    final snapshot = await _db.collection(_collectionPath).get();
    return snapshot.docs.map((doc) => _fromMap(doc.id, doc.data())).toList();
  }

  @override
  Stream<List<MeetingEntity>> watchAll() {
    return _db.collection(_collectionPath).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => _fromMap(doc.id, doc.data())).toList();
    });
  }

  @override
  Future<MeetingEntity> addMeeting(MeetingEntity meeting) async {
    final docRef = await _db.collection(_collectionPath).add(_toMap(meeting));
    return meeting.copyWith(id: docRef.id);
  }

  @override
  Future<MeetingEntity> addSummary(
    String meetingId, {
    required String summary,
    required String addedBy,
    List<String>? attendees,
  }) async {
    await _db.collection(_collectionPath).doc(meetingId).update({
      'summary': summary,
      'addedBy': addedBy,
      'status': MeetingStatus.completed.name,
      if (attendees != null) 'attendees': attendees,
    });
    final doc = await _db.collection(_collectionPath).doc(meetingId).get();
    return _fromMap(doc.id, doc.data()!);
  }

  @override
  Future<MeetingEntity> markCompleted(String meetingId, {required String summaryAssignedTo}) async {
    await _db.collection(_collectionPath).doc(meetingId).update({
      'status': MeetingStatus.completed.name,
      'summaryAssignedTo': summaryAssignedTo,
    });
    final doc = await _db.collection(_collectionPath).doc(meetingId).get();
    return _fromMap(doc.id, doc.data()!);
  }

  Map<String, dynamic> _toMap(MeetingEntity m) => {
        'title': m.title,
        'date': m.date,
        'time': m.time,
        'attendees': m.attendees,
        'status': m.status.name,
        if (m.summary != null) 'summary': m.summary,
        if (m.addedBy != null) 'addedBy': m.addedBy,
        if (m.link != null) 'link': m.link,
        if (m.summaryAssignedTo != null) 'summaryAssignedTo': m.summaryAssignedTo,
      };

  MeetingEntity _fromMap(String id, Map<String, dynamic> map) => MeetingEntity(
        id: id,
        title: map['title'] as String? ?? 'Untitled',
        date: map['date'] as String? ?? '',
        time: map['time'] as String? ?? '',
        attendees: (map['attendees'] as List<dynamic>?)?.cast<String>() ?? [],
        status: enumValueOr(
          MeetingStatus.values,
          map['status'] as String? ?? '',
          MeetingStatus.upcoming,
        ),
        summary: map['summary'] as String?,
        addedBy: map['addedBy'] as String?,
        link: map['link'] as String?,
        summaryAssignedTo: map['summaryAssignedTo'] as String?,
      );

  T enumValueOr<T extends Enum>(List<T> values, String name, T fallback) {
    try {
      return values.firstWhere((e) => e.name == name);
    } catch (_) {
      return fallback;
    }
  }
}
