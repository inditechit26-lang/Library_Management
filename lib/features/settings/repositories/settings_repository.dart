import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/services/firestore_service.dart';
import '../../../core/utils/error_handler.dart';
import '../models/plan_model.dart';

abstract class BaseSettingsRepository {
  Stream<Map<String, dynamic>> watchLibraryInfo();
  Stream<Map<String, dynamic>> watchLibraryConfig();
  Stream<List<PlanModel>> watchPlans();
  Future<void> updateLibraryInfo(Map<String, dynamic> data);
  Future<void> updateLibraryConfig(Map<String, dynamic> data);
  Future<void> addOrUpdatePlan(PlanModel plan);
  Future<void> deletePlan(String planId);
}

class SettingsRepository implements BaseSettingsRepository {
  SettingsRepository(this._service);
  final FirestoreService _service;

  Stream<Map<String, dynamic>> _watchMap(String field) =>
      _service.library.snapshots().map(
        (snapshot) => Map<String, dynamic>.from(
          snapshot.data()?[field] as Map? ?? const <String, dynamic>{},
        ),
      );

  @override
  Stream<Map<String, dynamic>> watchLibraryInfo() => _watchMap('libraryInfo');

  @override
  Stream<Map<String, dynamic>> watchLibraryConfig() =>
      _watchMap('configuration');

  @override
  Stream<List<PlanModel>> watchPlans() => watchLibraryConfig().map(
    (configuration) => (configuration['plans'] as List? ?? const [])
        .whereType<Map>()
        .map((plan) => PlanModel.fromMap(Map<String, dynamic>.from(plan)))
        .toList(),
  );

  @override
  Future<void> updateLibraryInfo(Map<String, dynamic> data) =>
      _updateMap('libraryInfo', data);

  @override
  Future<void> updateLibraryConfig(Map<String, dynamic> data) =>
      _updateMap('configuration', data);

  Future<void> _updateMap(String field, Map<String, dynamic> data) async {
    try {
      await _service.firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(_service.library);
        final current = Map<String, dynamic>.from(
          snapshot.data()?[field] as Map? ?? const <String, dynamic>{},
        )..addAll(data);
        current['updatedAt'] = FieldValue.serverTimestamp();
        transaction.update(_service.library, {field: current});
      });
    } catch (error, stackTrace) {
      throw ErrorHandler.handle(error, stackTrace);
    }
  }

  @override
  Future<void> addOrUpdatePlan(PlanModel plan) => _mutatePlans((plans) {
    final index = plans.indexWhere((item) => item['id'] == plan.id);
    if (index < 0) {
      plans.add(plan.toFirestore());
    } else {
      plans[index] = plan.toFirestore();
    }
  });

  @override
  Future<void> deletePlan(String planId) => _mutatePlans(
    (plans) => plans.removeWhere((plan) => plan['id'] == planId),
  );

  Future<void> _mutatePlans(
    void Function(List<Map<String, dynamic>> plans) mutate,
  ) async {
    await _service.firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(_service.library);
      final configuration = Map<String, dynamic>.from(
        snapshot.data()?['configuration'] as Map? ?? const <String, dynamic>{},
      );
      final plans = (configuration['plans'] as List? ?? const [])
          .whereType<Map>()
          .map((plan) => Map<String, dynamic>.from(plan))
          .toList();
      mutate(plans);
      configuration['plans'] = plans;
      configuration['updatedAt'] = FieldValue.serverTimestamp();
      transaction.update(_service.library, {'configuration': configuration});
    });
  }
}
