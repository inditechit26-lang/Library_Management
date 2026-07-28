import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/utils/error_handler.dart';
import '../models/plan_model.dart';

abstract class BaseSettingsRepository {
  Stream<Map<String, dynamic>> watchLibraryInfo(String libraryId);
  Stream<Map<String, dynamic>> watchLibraryConfig(String libraryId);
  Stream<List<PlanModel>> watchPlans(String libraryId);
  Future<void> updateLibraryInfo(String libraryId, Map<String, dynamic> data);
  Future<void> updateLibraryConfig(String libraryId, Map<String, dynamic> data);
  Future<void> addOrUpdatePlan(String libraryId, PlanModel plan);
  Future<void> deletePlan(String libraryId, String planId);
}

class SettingsRepository implements BaseSettingsRepository {
  final FirebaseFirestore _firestore;

  SettingsRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  DocumentReference _infoRef(String libraryId) {
    return _firestore.collection('libraries').doc(libraryId).collection('info').doc('general');
  }

  DocumentReference _configRef(String libraryId) {
    return _firestore.collection('libraries').doc(libraryId).collection('config').doc('settings');
  }

  CollectionReference _plansRef(String libraryId) {
    return _firestore.collection('libraries').doc(libraryId).collection('plans');
  }

  @override
  Stream<Map<String, dynamic>> watchLibraryInfo(String libraryId) {
    return _infoRef(libraryId).snapshots().map((doc) => doc.data() as Map<String, dynamic>? ?? {});
  }

  @override
  Stream<Map<String, dynamic>> watchLibraryConfig(String libraryId) {
    return _configRef(libraryId).snapshots().map((doc) => doc.data() as Map<String, dynamic>? ?? {});
  }

  @override
  Stream<List<PlanModel>> watchPlans(String libraryId) {
    return _plansRef(libraryId).snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => PlanModel.fromFirestore(doc)).toList());
  }

  @override
  Future<void> updateLibraryInfo(String libraryId, Map<String, dynamic> data) async {
    try {
      await _infoRef(libraryId).set(data, SetOptions(merge: true));
    } catch (e, stack) {
      throw ErrorHandler.handle(e, stack);
    }
  }

  @override
  Future<void> updateLibraryConfig(String libraryId, Map<String, dynamic> data) async {
    try {
      await _configRef(libraryId).set(data, SetOptions(merge: true));
    } catch (e, stack) {
      throw ErrorHandler.handle(e, stack);
    }
  }

  @override
  Future<void> addOrUpdatePlan(String libraryId, PlanModel plan) async {
    try {
      await _plansRef(libraryId).doc(plan.id).set(plan.toFirestore(), SetOptions(merge: true));
    } catch (e, stack) {
      throw ErrorHandler.handle(e, stack);
    }
  }

  @override
  Future<void> deletePlan(String libraryId, String planId) async {
    try {
      await _plansRef(libraryId).doc(planId).delete();
    } catch (e, stack) {
      throw ErrorHandler.handle(e, stack);
    }
  }
}
