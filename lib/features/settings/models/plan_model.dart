import 'package:cloud_firestore/cloud_firestore.dart';

class PlanModel {
  final String id;
  final String name;
  final int durationMonths;
  final double price;
  final String shift;
  final String? description;
  final bool isActive;

  const PlanModel({
    required this.id,
    required this.name,
    required this.durationMonths,
    required this.price,
    required this.shift,
    this.description,
    this.isActive = true,
  });

  factory PlanModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return PlanModel(
      id: doc.id,
      name: data['name'] ?? '',
      durationMonths: (data['durationMonths'] as num?)?.toInt() ?? 1,
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      shift: data['shift'] ?? 'Full Day',
      description: data['description'],
      isActive: data['isActive'] ?? true,
    );
  }

  factory PlanModel.fromMap(Map<String, dynamic> data) => PlanModel(
    id: data['id'] as String? ?? '',
    name: data['name'] as String? ?? '',
    durationMonths: (data['durationMonths'] as num?)?.toInt() ?? 1,
    price: (data['price'] as num?)?.toDouble() ?? 0,
    shift: data['shift'] as String? ?? 'Full Day',
    description: data['description'] as String?,
    isActive: data['isActive'] as bool? ?? true,
  );

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'name': name,
      'durationMonths': durationMonths,
      'price': price,
      'shift': shift,
      'description': description,
      'isActive': isActive,
    };
  }

  PlanModel copyWith({
    String? id,
    String? name,
    int? durationMonths,
    double? price,
    String? shift,
    String? description,
    bool? isActive,
  }) {
    return PlanModel(
      id: id ?? this.id,
      name: name ?? this.name,
      durationMonths: durationMonths ?? this.durationMonths,
      price: price ?? this.price,
      shift: shift ?? this.shift,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
    );
  }
}
