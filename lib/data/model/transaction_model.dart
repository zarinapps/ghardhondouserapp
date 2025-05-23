import 'package:ebroker/utils/Extensions/lib/adaptive_type.dart';

class TransactionModel {
  TransactionModel({
    this.id,
    this.transactionId,
    this.amount,
    this.paymentGateway,
    this.packageId,
    this.customerId,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  TransactionModel.fromMap(Map<String, dynamic> json) {
    id = json['id'] as int?;
    transactionId = json['transaction_id']?.toString() ?? '';
    amount = json['amount'];
    paymentGateway = json['payment_gateway']?.toString() ?? '';
    packageId = Adapter.forceInt(json['package_id']);
    customerId = Adapter.forceInt(json['customer_id']);
    status = json['status'];
    createdAt = json['created_at']?.toString() ?? '';
    updatedAt = json['updated_at']?.toString() ?? '';
  }
  int? id;
  String? transactionId;
  dynamic amount;
  String? paymentGateway;
  int? packageId;
  int? customerId;
  dynamic status;
  String? createdAt;
  String? updatedAt;

  Map<String, dynamic> toMap() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['transaction_id'] = transactionId;
    data['amount'] = amount;
    data['payment_gateway'] = paymentGateway;
    data['package_id'] = packageId;
    data['customer_id'] = customerId;
    data['status'] = status;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}
