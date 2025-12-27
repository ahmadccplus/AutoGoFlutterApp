class BookingModel {
  final int id;
  final int renterId;
  final int carId;
  final DateTime startDate;
  final DateTime endDate;
  final double totalPrice;
  final double securityDeposit;
  final String status;
  final bool contractSigned;
  final String? contractSignatureUrl;
  final String? paymentIntentId;
  final String paymentStatus;
  final DateTime createdAt;

  BookingModel({
    required this.id,
    required this.renterId,
    required this.carId,
    required this.startDate,
    required this.endDate,
    required this.totalPrice,
    required this.securityDeposit,
    required this.status,
    required this.contractSigned,
    this.contractSignatureUrl,
    this.paymentIntentId,
    required this.paymentStatus,
    required this.createdAt,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] as int,
      renterId: json['renter_id'] as int,
      carId: json['car_id'] as int,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      totalPrice: (json['total_price'] as num).toDouble(),
      securityDeposit: (json['security_deposit'] as num).toDouble(),
      status: json['status'] as String,
      contractSigned: json['contract_signed'] as bool? ?? false,
      contractSignatureUrl: json['contract_signature_url'] as String?,
      paymentIntentId: json['payment_intent_id'] as String?,
      paymentStatus: json['payment_status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'renter_id': renterId,
      'car_id': carId,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'total_price': totalPrice,
      'security_deposit': securityDeposit,
      'status': status,
      'contract_signed': contractSigned,
      'contract_signature_url': contractSignatureUrl,
      'payment_intent_id': paymentIntentId,
      'payment_status': paymentStatus,
      'created_at': createdAt.toIso8601String(),
    };
  }

  int get durationInDays {
    return endDate.difference(startDate).inDays;
  }
}








