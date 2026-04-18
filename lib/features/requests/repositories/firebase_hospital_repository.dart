import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../shared/data/entities.dart';
import '../../../shared/data/repositories.dart';

class FirebaseHospitalRepository implements IHospitalRepository {
  final _db = FirebaseFirestore.instance;
  static const _collection = 'hospitals';

  @override
  Future<List<HospitalEntity>> getAll() async {
    final snapshot = await _db.collection(_collection).get();
    return snapshot.docs.map((doc) => _fromFirestore(doc)).toList();
  }

  @override
  Stream<List<HospitalEntity>> watchAll() {
    return _db.collection(_collection).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => _fromFirestore(doc)).toList();
    });
  }

  @override
  Future<HospitalEntity> add(HospitalEntity hospital) async {
    final docRef = _db.collection(_collection).doc();
    final newHospital = hospital.copyWith(id: docRef.id);
    await docRef.set(_toFirestore(newHospital));
    return newHospital;
  }

  @override
  Future<void> delete(String id) async {
    await _db.collection(_collection).doc(id).delete();
  }

  HospitalEntity _fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return HospitalEntity(
      id: doc.id,
      name: data['name'] ?? '',
      address: data['address'] ?? '',
      city: data['city'] ?? 'Mumbai',
    );
  }

  Map<String, dynamic> _toFirestore(HospitalEntity hospital) {
    return {
      'name': hospital.name,
      'address': hospital.address,
      'city': hospital.city,
    };
  }
}
