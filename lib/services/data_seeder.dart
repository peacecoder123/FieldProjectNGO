import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:ngo_volunteer_management/shared/data/mock_data_source.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Seeds Firestore with mock data on first launch.
///
/// Call this in main.dart after Firebase.initializeApp() to populate
/// all Firestore collections with the mock data.
///
/// This is a one-time operation — it checks a flag in SharedPreferences
/// to avoid re-seeding on subsequent launches.
Future<void> seedFirestoreIfEmpty() async {
  final prefs = await SharedPreferences.getInstance();
  final seeded = prefs.getBool('firestore_seeded') ?? false;
  if (seeded) return;

  try {
    final db = FirebaseFirestore.instance;
    final batch = db.batch();

    // ── Volunteers ─────────
    for (final v in MockDataSource.volunteers) {
      batch.set(db.collection('volunteers').doc(v.id.toString()), {
        'id': v.id,
        'name': v.name,
        'email': v.email,
        'phone': v.phone,
        'address': v.address,
        'joinDate': v.joinDate,
        'status': v.status.name,
        'assignedAdmin': v.assignedAdmin,
        'taskIds': v.taskIds,
        'tenure': v.tenure,
        'skills': v.skills,
        'avatar': v.avatar,
      });
    }

    // ── Members ────────────
    for (final m in MockDataSource.members) {
      batch.set(db.collection('members').doc(m.id.toString()), {
        'id': m.id,
        'name': m.name,
        'email': m.email,
        'phone': m.phone,
        'address': m.address,
        'joinDate': m.joinDate,
        'renewalDate': m.renewalDate,
        'status': m.status.name,
        'membershipType': m.membershipType.name,
        'taskIds': m.taskIds,
        'isPaid': m.isPaid,
        'avatar': m.avatar,
      });
    }

    // ── Tasks ──────────────
    for (final t in MockDataSource.tasks) {
      final data = <String, dynamic>{
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
      };
      if (t.uploadedImage != null) data['uploadedImage'] = t.uploadedImage!;
      if (t.submittedAt != null) data['submittedAt'] = t.submittedAt!;
      batch.set(db.collection('tasks').doc(t.id.toString()), data);
    }

    // ── Donations ──────────
    for (final d in MockDataSource.donations) {
      batch.set(db.collection('donations').doc(d.id.toString()), {
        'id': d.id,
        'donorName': d.donorName,
        'amount': d.amount,
        'date': d.date,
        'type': d.type.name,
        'receiptGenerated': d.receiptGenerated,
        'purpose': d.purpose,
        'is80G': d.is80G,
        if (d.receiptNumber != null) 'receiptNumber': d.receiptNumber!,
      });
    }

    // ── General Requests ───
    for (final r in MockDataSource.generalRequests) {
      batch.set(
        db.collection('general_requests').doc(r.id.toString()),
        {
          'id': r.id,
          'requestType': r.requestType.name,
          'requesterName': r.requesterName,
          'requesterType': r.requesterType,
          'requestDate': r.requestDate,
          'status': r.status.name,
          'details': r.details,
        },
      );
    }

    // ── MOU Requests ──────
    for (final r in MockDataSource.mouRequests) {
      batch.set(db.collection('mou_requests').doc(r.id.toString()), {
        'id': r.id,
        'patientName': r.patientName,
        'patientAge': r.patientAge,
        'disease': r.disease,
        'hospital': r.hospital,
        'requestDate': r.requestDate,
        'status': r.status.name,
        'requesterName': r.requesterName,
        'phone': r.phone,
        'address': r.address,
        'bloodGroup': r.bloodGroup,
      });
    }

    // ── Joining Letters ───
    for (final r in MockDataSource.joiningLetterRequests) {
      final data = <String, dynamic>{
        'id': r.id,
        'name': r.name,
        'type': r.type.name,
        'requestDate': r.requestDate,
        'status': r.status.name,
        'tenure': r.tenure,
        'isNewMember': r.isNewMember,
      };
      if (r.generatedBy != null) data['generatedBy'] = r.generatedBy!;
      batch.set(
        db.collection('joining_letter_requests').doc(r.id.toString()),
        data,
      );
    }

    // ── Meetings ───────────
    for (final m in MockDataSource.meetings) {
      final data = <String, dynamic>{
        'id': m.id,
        'title': m.title,
        'date': m.date,
        'time': m.time,
        'attendees': m.attendees,
        'status': m.status.name,
      };
      if (m.summary != null) data['summary'] = m.summary!;
      if (m.addedBy != null) data['addedBy'] = m.addedBy!;
      batch.set(db.collection('meetings').doc(m.id.toString()), data);
    }

    // ── Users (Auth) ───────
    final users = [
      {
        'id': 1,
        'name': 'Vikram Kapoor',
        'email': 'vikram@hopeconnect.org',
        'password': 'vikram123',
        'role': 'superAdmin',
        'avatar': null,
      },
      {
        'id': 2,
        'name': 'Priya Sharma',
        'email': 'priya@hopeconnect.org',
        'password': 'priya123',
        'role': 'admin',
        'avatar': null,
      },
      {
        'id': 3,
        'name': 'Anjali Patel',
        'email': 'anjali@hopeconnect.org',
        'password': 'anjali123',
        'role': 'member',
        'avatar': null,
      },
      {
        'id': 4,
        'name': 'Rahul Verma',
        'email': 'rahul@hopeconnect.org',
        'password': 'rahul123',
        'role': 'volunteer',
        'avatar': null,
      },
    ];

    for (final u in users) {
      batch.set(db.collection('users').doc(u['id'].toString()), u);
    }

    // ── Execute batch ──────
    await batch.commit();
    await prefs.setBool('firestore_seeded', true);
    debugPrint('Firestore seeded with mock data');
  } catch (e, st) {
    debugPrint('Failed to seed Firestore: $e');
    debugPrint('Stack: $st');
  }
}
