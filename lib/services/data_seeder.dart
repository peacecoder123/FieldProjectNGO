import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Seeds Firestore with consistent demo data on first launch (or when version changes).
///
/// KEY RULE: Every entity's `id` MUST match the corresponding `users` doc ID
/// so that the logged-in user's ID maps correctly to their profile and tasks.
///
///  User doc "1" → Rahul Verma      (volunteer, id=1)
///  User doc "2" → Dr. Anjali Mehta (member,    id=2)
///  User doc "3" → Priya Sharma     (admin,     id=3)
///  User doc "0" → Vikram Bose      (superAdmin, id=0)
///
Future<void> seedFirestoreIfEmpty() async {
  final prefs = await SharedPreferences.getInstance();
  // Bump version to force re-seed when data schema changes.
  const currentVersion = 'v6';

  final seededVersion = prefs.getString('firestore_seeded_v') ?? '';
  if (seededVersion == currentVersion) return;

  try {
    final db = FirebaseFirestore.instance;

    // ── Users (Auth) ────────────────────────────────────────────
    // Doc ID = string of `id`. FirebaseAuthRepository reads int.tryParse(doc.id).
    final users = [
      {'id': 0, 'name': 'Vikram Bose',      'email': 'vikram@hopeconnect.org',  'password': 'vikram123',  'role': 'superAdmin', 'avatar': 'VB'},
      {'id': 3, 'name': 'Priya Sharma',     'email': 'priya@hopeconnect.org',   'password': 'priya123',   'role': 'admin',      'avatar': 'PS'},
      {'id': 2, 'name': 'Dr. Anjali Mehta', 'email': 'anjali@hopeconnect.org',  'password': 'anjali123',  'role': 'member',     'avatar': 'AM'},
      {'id': 1, 'name': 'Rahul Verma',      'email': 'rahul@hopeconnect.org',   'password': 'rahul123',   'role': 'volunteer',  'avatar': 'RV'},
    ];

    // ── Volunteers ──────────────────────────────────────────────
    // `id` MUST equal the user doc id for that person.
    final volunteers = [
      {
        'id': 1, 'name': 'Rahul Verma', 'email': 'rahul@hopeconnect.org',
        'phone': '9876543210', 'address': 'Bandra, Mumbai',
        'joinDate': '2024-01-15', 'status': 'active',
        'assignedAdmin': 'Priya Sharma',
        'taskIds': [1, 2], 'tenure': 'Jan 2025',
        'skills': ['Teaching', 'Healthcare'], 'avatar': 'RV',
        'mentorId': 2, 'mentorName': 'Dr. Anjali Mehta',
      },
      {
        'id': 4, 'name': 'Sneha Kulkarni', 'email': 'sneha@hopeconnect.org',
        'phone': '9123456780', 'address': 'Pune, Maharashtra',
        'joinDate': '2024-03-10', 'status': 'active',
        'assignedAdmin': 'Priya Sharma',
        'taskIds': [3], 'tenure': 'Mar 2025',
        'skills': ['Cooking', 'Event Management'], 'avatar': 'SK',
        'mentorId': 2, 'mentorName': 'Dr. Anjali Mehta',
      },
      {
        'id': 5, 'name': 'Aditya Verma', 'email': 'aditya@hopeconnect.org',
        'phone': '9988776655', 'address': 'Andheri, Mumbai',
        'joinDate': '2023-11-20', 'status': 'inactive',
        'assignedAdmin': 'Priya Sharma',
        'taskIds': [], 'tenure': 'Nov 2024',
        'skills': ['Photography', 'Design'], 'avatar': 'AV',
      },
      {
        'id': 6, 'name': 'Meera Nair', 'email': 'meera@hopeconnect.org',
        'phone': '9871234560', 'address': 'Thane, Mumbai',
        'joinDate': '2024-06-05', 'status': 'active',
        'assignedAdmin': 'Priya Sharma',
        'taskIds': [4, 5], 'tenure': 'Jun 2025',
        'skills': ['Counselling', 'Communication'], 'avatar': 'MN',
      },
    ];

    // ── Members ─────────────────────────────────────────────────
    // `id` MUST equal the user doc id for that person.
    final members = [
      {
        'id': 2, 'name': 'Dr. Anjali Mehta', 'email': 'anjali@hopeconnect.org',
        'phone': '9871234567', 'address': 'Colaba, Mumbai',
        'joinDate': '2022-04-01', 'renewalDate': '2026-04-01',
        'status': 'active', 'membershipType': 'eightyG',
        'taskIds': [7, 8], 'isPaid': true, 'avatar': 'AM',
      },
      {
        'id': 7, 'name': 'Suresh Patil', 'email': 'suresh@hopeconnect.org',
        'phone': '9823456789', 'address': 'Nagpur, Maharashtra',
        'joinDate': '2021-08-15', 'renewalDate': '2025-08-15',
        'status': 'active', 'membershipType': 'nonEightyG',
        'taskIds': [9], 'isPaid': false, 'avatar': 'SP',
      },
      {
        'id': 8, 'name': 'Kavita Rao', 'email': 'kavita@hopeconnect.org',
        'phone': '9934567890', 'address': 'Vashi, Navi Mumbai',
        'joinDate': '2023-01-10', 'renewalDate': '2026-01-10',
        'status': 'active', 'membershipType': 'eightyG',
        'taskIds': [], 'isPaid': true, 'avatar': 'KR',
      },
    ];

    // ── Tasks ─────────────────────────────────────────────────
    // `assignedToId` MUST match the volunteer/member `id` above.
    final tasks = [
      // Rahul Verma's volunteer tasks (assignedToId=1)
      {
        'id': 1, 'title': 'Food Drive Distribution',
        'description': 'Coordinate food distribution at Dharavi community centre. Manage volunteers and ensure orderly queues.',
        'deadline': '2025-04-15', 'assignedToId': 1,
        'assignedToName': 'Rahul Verma', 'assignedToType': 'volunteer',
        'status': 'submitted', 'requiresUpload': true,
        'uploadedImage': 'food_drive.jpg', 'submittedAt': '2025-04-10',
        'createdAt': '2025-03-20',
      },
      {
        'id': 2, 'title': 'Health Camp Setup',
        'description': 'Set up medical equipment and registration desks at Govandi.',
        'deadline': '2025-05-01', 'assignedToId': 1,
        'assignedToName': 'Rahul Verma', 'assignedToType': 'volunteer',
        'status': 'approved', 'requiresUpload': false,
        'createdAt': '2025-03-25',
      },
      // Sneha Kulkarni tasks (assignedToId=4)
      {
        'id': 3, 'title': 'Cooking Workshop',
        'description': 'Teach basic nutrition to 30 women at Dharavi skill centre.',
        'deadline': '2025-04-20', 'assignedToId': 4,
        'assignedToName': 'Sneha Kulkarni', 'assignedToType': 'volunteer',
        'status': 'pending', 'requiresUpload': true, 'createdAt': '2025-03-28',
      },
      // Meera Nair tasks (assignedToId=6)
      {
        'id': 4, 'title': 'Counselling Session',
        'description': 'One-on-one counselling for 10 youth at Thane NGO centre.',
        'deadline': '2025-03-30', 'assignedToId': 6,
        'assignedToName': 'Meera Nair', 'assignedToType': 'volunteer',
        'status': 'submitted', 'requiresUpload': false,
        'submittedAt': '2025-03-28', 'createdAt': '2025-03-01',
      },
      {
        'id': 5, 'title': 'Documentation Drive',
        'description': 'Help families obtain Aadhaar cards and ration cards.',
        'deadline': '2025-05-10', 'assignedToId': 6,
        'assignedToName': 'Meera Nair', 'assignedToType': 'volunteer',
        'status': 'pending', 'requiresUpload': false, 'createdAt': '2025-04-01',
      },
      // Dr. Anjali Mehta member tasks (assignedToId=2)
      {
        'id': 7, 'title': 'Medical Camp Report',
        'description': 'Submit detailed report of the Q1 medical camp activities including patient count and diagnoses.',
        'deadline': '2025-04-30', 'assignedToId': 2,
        'assignedToName': 'Dr. Anjali Mehta', 'assignedToType': 'member',
        'status': 'pending', 'requiresUpload': true, 'createdAt': '2025-04-01',
      },
      {
        'id': 8, 'title': 'Donor Outreach',
        'description': 'Contact 5 new potential donors for the annual fundraiser.',
        'deadline': '2025-05-15', 'assignedToId': 2,
        'assignedToName': 'Dr. Anjali Mehta', 'assignedToType': 'member',
        'status': 'submitted', 'requiresUpload': false,
        'submittedAt': '2025-04-12', 'createdAt': '2025-04-02',
      },
      // Suresh Patil member task (assignedToId=7)
      {
        'id': 9, 'title': 'Community Survey',
        'description': 'Conduct needs-assessment survey in Nagpur ward 12.',
        'deadline': '2025-04-25', 'assignedToId': 7,
        'assignedToName': 'Suresh Patil', 'assignedToType': 'member',
        'status': 'approved', 'requiresUpload': false, 'createdAt': '2025-03-20',
      },
    ];

    // ── Joining Letters ──────────────────────────────────────────
    final joiningLetters = [
      {'id': 1, 'name': 'Rahul Verma',      'type': 'volunteer', 'requestDate': '2025-03-10', 'status': 'pending',   'tenure': 'March 2025',  'isNewMember': false},
      {'id': 2, 'name': 'Sneha Kulkarni',   'type': 'volunteer', 'requestDate': '2025-03-18', 'status': 'approved',  'tenure': 'April 2025',  'isNewMember': false, 'generatedBy': 'Priya Sharma'},
      {'id': 3, 'name': 'Dr. Anjali Mehta', 'type': 'member',    'requestDate': '2025-03-05', 'status': 'approved',  'tenure': 'FY 2025-26', 'isNewMember': false, 'generatedBy': 'Priya Sharma'},
    ];

    // ── General Requests ─────────────────────────────────────────
    final generalRequests = [
      {'id': 1, 'requestType': 'joiningLetter', 'requesterName': 'Rahul Verma',      'requesterType': 'volunteer', 'requestDate': '2025-03-10', 'status': 'pending',  'details': 'Requesting joining letter for March 2025.'},
      {'id': 2, 'requestType': 'certificate',   'requesterName': 'Dr. Anjali Mehta', 'requesterType': 'member',    'requestDate': '2025-03-15', 'status': 'approved', 'details': 'Certificate of Appreciation for Q1 medical camp.'},
      {'id': 3, 'requestType': 'joiningLetter', 'requesterName': 'Sneha Kulkarni',   'requesterType': 'volunteer', 'requestDate': '2025-03-18', 'status': 'pending',  'details': 'Requesting joining letter for April 2025.'},
    ];

    // ── MOU Requests ─────────────────────────────────────────────
    final mouRequests = [
      {'id': 1, 'patientName': 'Ramesh Kumar', 'patientAge': 58, 'disease': 'Cardiac Surgery',  'hospital': 'KEM Hospital Mumbai', 'requestDate': '2025-03-12', 'status': 'pending',  'requesterName': 'Dr. Anjali Mehta', 'phone': '9876543200', 'address': 'Worli, Mumbai',    'bloodGroup': 'B+'},
      {'id': 2, 'patientName': 'Sunita Devi',  'patientAge': 42, 'disease': 'Kidney Dialysis', 'hospital': 'Hinduja Hospital',    'requestDate': '2025-02-28', 'status': 'approved', 'requesterName': 'Dr. Anjali Mehta', 'phone': '9823456701', 'address': 'Dharavi, Mumbai', 'bloodGroup': 'O+'},
    ];

    // ── Meetings ─────────────────────────────────────────────────
    final meetings = [
      {'id': 1, 'title': 'Monthly Core Committee Meeting', 'date': '2025-04-20', 'time': '10:00 AM', 'attendees': ['Dr. Anjali Mehta', 'Suresh Patil', 'Priya Sharma'], 'status': 'upcoming'},
      {'id': 2, 'title': 'Q1 Review & Planning Session',   'date': '2025-03-28', 'time': '11:00 AM', 'attendees': ['Dr. Anjali Mehta', 'Vikram Bose', 'Priya Sharma'],  'status': 'completed', 'summary': 'Reviewed Q1 targets: food drives achieved 94% reach. Medical camp treated 320 patients. Decided to increase volunteer intake by 20% in Q2.', 'addedBy': 'Dr. Anjali Mehta'},
    ];

    // ── Clean up stale docs from old seeder versions ─────────────────────────
    // Old seeder had wrong IDs (e.g. Rahul Verma was at users/"4", volunteers/"1")
    // We must delete them so Firestore queries (which go by email) don't find double entries.
    final staleCleanup = [
      db.collection('users').doc('4'),       // Old Rahul Verma user doc (was id=4)
      db.collection('users').doc('2'),       // Old Priya Sharma user doc (was id=2)
      db.collection('users').doc('3'),       // Old Anjali user doc (was id=3)
    ];
    for (final ref in staleCleanup) {
      try { await ref.delete(); } catch (_) {}
    }
    debugPrint('🧹 Cleaned up stale Firestore docs');

    // Write all collections (individual sets to avoid 500-item batch limit)
    for (final u in users)            { await db.collection('users').doc(u['id'].toString()).set(u); }
    for (final v in volunteers)       { await db.collection('volunteers').doc(v['id'].toString()).set(v); }
    for (final m in members)          { await db.collection('members').doc(m['id'].toString()).set(m); }
    for (final t in tasks)            { await db.collection('tasks').doc(t['id'].toString()).set(t); }
    for (final j in joiningLetters)   { await db.collection('joining_letter_requests').doc(j['id'].toString()).set(j); }
    for (final g in generalRequests)  { await db.collection('general_requests').doc(g['id'].toString()).set(g); }
    for (final m in mouRequests)      { await db.collection('mou_requests').doc(m['id'].toString()).set(m); }
    for (final m in meetings)         { await db.collection('meetings').doc(m['id'].toString()).set(m); }

    await prefs.setString('firestore_seeded_v', currentVersion);
    debugPrint('✅ Firestore re-seeded successfully (version: $currentVersion)');
  } catch (e, st) {
    debugPrint('❌ Firestore seeding failed: $e\n$st');
  }
}
