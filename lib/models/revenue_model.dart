enum PaymentStatus { pending, completed, failed, refunded, cancelled }

enum PaymentMethod { card, bank_transfer, wallet, cash }

class Revenue {
  final String id;
  final String doctorId;
  final String appointmentId;
  final String patientId;
  final String patientName;
  final double amount;
  final double platformFee;
  final double doctorEarnings;
  final PaymentStatus status;
  final PaymentMethod method;
  final String? transactionId;
  final String? paymentGateway;
  final DateTime paymentDate;
  final String? notes;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  Revenue({
    required this.id,
    required this.doctorId,
    required this.appointmentId,
    required this.patientId,
    required this.patientName,
    required this.amount,
    required this.platformFee,
    required this.doctorEarnings,
    required this.status,
    required this.method,
    this.transactionId,
    this.paymentGateway,
    required this.paymentDate,
    this.notes,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Revenue.fromMap(Map<String, dynamic> data, String id) {
    return Revenue(
      id: id,
      doctorId: data['doctorId'] ?? '',
      appointmentId: data['appointmentId'] ?? '',
      patientId: data['patientId'] ?? '',
      patientName: data['patientName'] ?? '',
      amount: (data['amount'] ?? 0.0).toDouble(),
      platformFee: (data['platformFee'] ?? 0.0).toDouble(),
      doctorEarnings: (data['doctorEarnings'] ?? 0.0).toDouble(),
      status: PaymentStatus.values.firstWhere(
        (e) => e.toString() == 'PaymentStatus.${data['status']}',
        orElse: () => PaymentStatus.pending,
      ),
      method: PaymentMethod.values.firstWhere(
        (e) => e.toString() == 'PaymentMethod.${data['method']}',
        orElse: () => PaymentMethod.card,
      ),
      transactionId: data['transactionId'],
      paymentGateway: data['paymentGateway'],
      paymentDate: data['paymentDate']?.toDate() ?? DateTime.now(),
      notes: data['notes'],
      metadata: data['metadata'] != null
          ? Map<String, dynamic>.from(data['metadata'])
          : null,
      createdAt: data['createdAt']?.toDate() ?? DateTime.now(),
      updatedAt: data['updatedAt']?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'doctorId': doctorId,
      'appointmentId': appointmentId,
      'patientId': patientId,
      'patientName': patientName,
      'amount': amount,
      'platformFee': platformFee,
      'doctorEarnings': doctorEarnings,
      'status': status.toString().split('.').last,
      'method': method.toString().split('.').last,
      'transactionId': transactionId,
      'paymentGateway': paymentGateway,
      'paymentDate': paymentDate,
      'notes': notes,
      'metadata': metadata,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  Revenue copyWith({
    String? id,
    String? doctorId,
    String? appointmentId,
    String? patientId,
    String? patientName,
    double? amount,
    double? platformFee,
    double? doctorEarnings,
    PaymentStatus? status,
    PaymentMethod? method,
    String? transactionId,
    String? paymentGateway,
    DateTime? paymentDate,
    String? notes,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Revenue(
      id: id ?? this.id,
      doctorId: doctorId ?? this.doctorId,
      appointmentId: appointmentId ?? this.appointmentId,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      amount: amount ?? this.amount,
      platformFee: platformFee ?? this.platformFee,
      doctorEarnings: doctorEarnings ?? this.doctorEarnings,
      status: status ?? this.status,
      method: method ?? this.method,
      transactionId: transactionId ?? this.transactionId,
      paymentGateway: paymentGateway ?? this.paymentGateway,
      paymentDate: paymentDate ?? this.paymentDate,
      notes: notes ?? this.notes,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class RevenueSummary {
  final double totalEarnings;
  final double totalPlatformFees;
  final double netEarnings;
  final int totalTransactions;
  final int completedTransactions;
  final int pendingTransactions;
  final double monthlyEarnings;
  final double weeklyEarnings;
  final double dailyEarnings;
  final List<Revenue> recentTransactions;
  final Map<String, double> earningsByMonth;
  final Map<String, int> transactionsByMonth;

  RevenueSummary({
    required this.totalEarnings,
    required this.totalPlatformFees,
    required this.netEarnings,
    required this.totalTransactions,
    required this.completedTransactions,
    required this.pendingTransactions,
    required this.monthlyEarnings,
    required this.weeklyEarnings,
    required this.dailyEarnings,
    required this.recentTransactions,
    required this.earningsByMonth,
    required this.transactionsByMonth,
  });

  factory RevenueSummary.fromMap(Map<String, dynamic> data) {
    return RevenueSummary(
      totalEarnings: (data['totalEarnings'] ?? 0.0).toDouble(),
      totalPlatformFees: (data['totalPlatformFees'] ?? 0.0).toDouble(),
      netEarnings: (data['netEarnings'] ?? 0.0).toDouble(),
      totalTransactions: data['totalTransactions'] ?? 0,
      completedTransactions: data['completedTransactions'] ?? 0,
      pendingTransactions: data['pendingTransactions'] ?? 0,
      monthlyEarnings: (data['monthlyEarnings'] ?? 0.0).toDouble(),
      weeklyEarnings: (data['weeklyEarnings'] ?? 0.0).toDouble(),
      dailyEarnings: (data['dailyEarnings'] ?? 0.0).toDouble(),
      recentTransactions:
          (data['recentTransactions'] as List<dynamic>?)
              ?.map((e) => Revenue.fromMap(e as Map<String, dynamic>, ''))
              .toList() ??
          [],
      earningsByMonth: Map<String, double>.from(data['earningsByMonth'] ?? {}),
      transactionsByMonth: Map<String, int>.from(
        data['transactionsByMonth'] ?? {},
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'totalEarnings': totalEarnings,
      'totalPlatformFees': totalPlatformFees,
      'netEarnings': netEarnings,
      'totalTransactions': totalTransactions,
      'completedTransactions': completedTransactions,
      'pendingTransactions': pendingTransactions,
      'monthlyEarnings': monthlyEarnings,
      'weeklyEarnings': weeklyEarnings,
      'dailyEarnings': dailyEarnings,
      'recentTransactions': recentTransactions.map((e) => e.toMap()).toList(),
      'earningsByMonth': earningsByMonth,
      'transactionsByMonth': transactionsByMonth,
    };
  }
}


