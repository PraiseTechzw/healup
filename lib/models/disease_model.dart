enum DiseaseSeverity { mild, moderate, severe, critical }

enum DiseaseCategory {
  infectious,
  chronic,
  acute,
  genetic,
  autoimmune,
  mental,
  cardiovascular,
  respiratory,
  digestive,
  neurological,
  dermatological,
  endocrine,
  musculoskeletal,
  reproductive,
  other,
}

class DiseaseModel {
  final String id;
  final String name;
  final String description;
  final List<String> symptoms;
  final List<String> causes;
  final List<String> riskFactors;
  final List<String> complications;
  final List<String> prevention;
  final List<String> treatments;
  final List<String> medications;
  final DiseaseSeverity severity;
  final DiseaseCategory category;
  final bool isContagious;
  final String incubationPeriod;
  final String recoveryTime;
  final List<String> warningSigns;
  final String whenToSeeDoctor;
  final List<String> diagnosticTests;
  final String imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  DiseaseModel({
    required this.id,
    required this.name,
    required this.description,
    required this.symptoms,
    required this.causes,
    required this.riskFactors,
    required this.complications,
    required this.prevention,
    required this.treatments,
    required this.medications,
    required this.severity,
    required this.category,
    required this.isContagious,
    required this.incubationPeriod,
    required this.recoveryTime,
    required this.warningSigns,
    required this.whenToSeeDoctor,
    required this.diagnosticTests,
    required this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DiseaseModel.fromMap(Map<String, dynamic> data, String id) {
    return DiseaseModel(
      id: id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      symptoms: List<String>.from(data['symptoms'] ?? []),
      causes: List<String>.from(data['causes'] ?? []),
      riskFactors: List<String>.from(data['riskFactors'] ?? []),
      complications: List<String>.from(data['complications'] ?? []),
      prevention: List<String>.from(data['prevention'] ?? []),
      treatments: List<String>.from(data['treatments'] ?? []),
      medications: List<String>.from(data['medications'] ?? []),
      severity: DiseaseSeverity.values.firstWhere(
        (e) => e.toString() == 'DiseaseSeverity.${data['severity']}',
        orElse: () => DiseaseSeverity.mild,
      ),
      category: DiseaseCategory.values.firstWhere(
        (e) => e.toString() == 'DiseaseCategory.${data['category']}',
        orElse: () => DiseaseCategory.other,
      ),
      isContagious: data['isContagious'] ?? false,
      incubationPeriod: data['incubationPeriod'] ?? '',
      recoveryTime: data['recoveryTime'] ?? '',
      warningSigns: List<String>.from(data['warningSigns'] ?? []),
      whenToSeeDoctor: data['whenToSeeDoctor'] ?? '',
      diagnosticTests: List<String>.from(data['diagnosticTests'] ?? []),
      imageUrl: data['imageUrl'] ?? '',
      createdAt: data['createdAt']?.toDate() ?? DateTime.now(),
      updatedAt: data['updatedAt']?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'symptoms': symptoms,
      'causes': causes,
      'riskFactors': riskFactors,
      'complications': complications,
      'prevention': prevention,
      'treatments': treatments,
      'medications': medications,
      'severity': severity.toString().split('.').last,
      'category': category.toString().split('.').last,
      'isContagious': isContagious,
      'incubationPeriod': incubationPeriod,
      'recoveryTime': recoveryTime,
      'warningSigns': warningSigns,
      'whenToSeeDoctor': whenToSeeDoctor,
      'diagnosticTests': diagnosticTests,
      'imageUrl': imageUrl,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  DiseaseModel copyWith({
    String? id,
    String? name,
    String? description,
    List<String>? symptoms,
    List<String>? causes,
    List<String>? riskFactors,
    List<String>? complications,
    List<String>? prevention,
    List<String>? treatments,
    List<String>? medications,
    DiseaseSeverity? severity,
    DiseaseCategory? category,
    bool? isContagious,
    String? incubationPeriod,
    String? recoveryTime,
    List<String>? warningSigns,
    String? whenToSeeDoctor,
    List<String>? diagnosticTests,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DiseaseModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      symptoms: symptoms ?? this.symptoms,
      causes: causes ?? this.causes,
      riskFactors: riskFactors ?? this.riskFactors,
      complications: complications ?? this.complications,
      prevention: prevention ?? this.prevention,
      treatments: treatments ?? this.treatments,
      medications: medications ?? this.medications,
      severity: severity ?? this.severity,
      category: category ?? this.category,
      isContagious: isContagious ?? this.isContagious,
      incubationPeriod: incubationPeriod ?? this.incubationPeriod,
      recoveryTime: recoveryTime ?? this.recoveryTime,
      warningSigns: warningSigns ?? this.warningSigns,
      whenToSeeDoctor: whenToSeeDoctor ?? this.whenToSeeDoctor,
      diagnosticTests: diagnosticTests ?? this.diagnosticTests,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isSevere =>
      severity == DiseaseSeverity.severe ||
      severity == DiseaseSeverity.critical;
  bool get requiresImmediateAttention => severity == DiseaseSeverity.critical;
}


