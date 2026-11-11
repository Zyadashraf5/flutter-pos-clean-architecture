import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/utils/firestore_safe.dart';

enum OrderTypeFirestore { cash, credit, bankTransfer, eWallet }

class OrderFirestoreModel {
  const OrderFirestoreModel({
    required this.id,
    required this.orderNumber,
    required this.orderType,
    required this.subtotal,
    required this.taxAmount,
    required this.total,
    required this.paidAmount,
    required this.remainingAmount,
    required this.createdAt,
    required this.createdByUid,
    this.createdByName,
    this.createdByEmail,
  });

  final String id;
  final String orderNumber;
  final OrderTypeFirestore orderType;
  final double subtotal;
  final double taxAmount;
  final double total;
  final double paidAmount;
  final double remainingAmount;
  final DateTime createdAt;
  final String createdByUid;
  final String? createdByName;
  final String? createdByEmail;

  Map<String, dynamic> toFirestore() => {
    'id': id,
    'orderNumber': orderNumber,
    'orderType': orderType.name,
    'subtotal': FirestoreSafe.doubleValue(subtotal),
    'taxAmount': FirestoreSafe.doubleValue(taxAmount),
    'total': FirestoreSafe.doubleValue(total),
    'paidAmount': FirestoreSafe.doubleValue(paidAmount),
    'remainingAmount': FirestoreSafe.doubleValue(remainingAmount),
    'createdAt': Timestamp.fromDate(createdAt),
    'createdByUid': createdByUid,
    if (createdByName != null) 'createdByName': createdByName,
    if (createdByEmail != null) 'createdByEmail': createdByEmail,
  };

  factory OrderFirestoreModel.fromFirestore(Map<String, dynamic> data) {
    return OrderFirestoreModel(
      id: data['id'] as String,
      orderNumber: data['orderNumber'] as String,
      orderType: OrderTypeFirestore.values.firstWhere(
        (e) => e.name == data['orderType'],
        orElse: () => OrderTypeFirestore.cash,
      ),
      subtotal: (data['subtotal'] as num).toDouble(),
      taxAmount: (data['taxAmount'] as num).toDouble(),
      total: (data['total'] as num).toDouble(),
      paidAmount: (data['paidAmount'] as num).toDouble(),
      remainingAmount: (data['remainingAmount'] as num).toDouble(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      createdByUid:
          data['createdByUid'] as String? ?? data['createdBy'] as String? ?? '',
      createdByName: data['createdByName'] as String?,
      createdByEmail: data['createdByEmail'] as String?,
    );
  }
}
