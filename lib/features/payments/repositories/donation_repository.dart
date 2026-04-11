import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:ngo_volunteer_management/domain/entities/donation.entity.dart';
import 'package:ngo_volunteer_management/shared/data/repositories.dart';

class DonationRepository implements IDonationRepository {
  final String _collectionPath = 'donations';
  FirebaseFirestore? _firestore;

  DonationRepository() {
    // Defer Firestore access until first use
    if (Firebase.apps.isNotEmpty) {
      _firestore = FirebaseFirestore.instance;
    }
  }

  FirebaseFirestore get _db {
    if (_firestore == null) {
      // Try to get Firestore instance; if fails, throw a clearer error
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
  Future<List<DonationEntity>> getAll() async {
    final snapshot = await _db
        .collection(_collectionPath)
        .orderBy('date', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => DonationEntity.fromMap({'id': doc.id, ...doc.data()}))
        .toList();
  }

  @override
  Stream<List<DonationEntity>> watchAll() {
    return _db
        .collection(_collectionPath)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => DonationEntity.fromMap({'id': doc.id, ...doc.data()}))
          .toList();
    });
  }

  @override
  Future<DonationEntity> add(DonationEntity donation) async {
    final docRef = await _db.collection(_collectionPath).add(donation.toMap());
    return donation.copyWith(id: docRef.id);
  }

  @override
  Future<DonationEntity> generateReceipt(String donationId, String receiptNumber) async {
    final docRef = _db.collection(_collectionPath).doc(donationId);
    
    await docRef.update({
      'receiptGenerated': true,
      'receiptNumber': receiptNumber,
    });

    final updatedDoc = await docRef.get();
    return DonationEntity.fromMap({'id': updatedDoc.id, ...updatedDoc.data()!});
  }
}