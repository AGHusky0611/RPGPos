import 'item.dart';

class Transaction {
  final String id;
  final String eventId;
  final String eventName;
  final List<Item> items;
  final double totalAmount;
  final DateTime createdAt;
  final String createdBy;
  final String? notes;

  Transaction({
    required this.id,
    required this.eventId,
    required this.eventName,
    required this.items,
    required this.totalAmount,
    required this.createdAt,
    required this.createdBy,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'eventId': eventId,
        'eventName': eventName,
        'items': items.map((e) => e.toJson()).toList(),
        'totalAmount': totalAmount,
        'createdAt': createdAt.toIso8601String(),
        'createdBy': createdBy,
        'notes': notes,
      };

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
        id: json['id'],
        eventId: json['eventId'],
        eventName: json['eventName'],
        items: (json['items'] as List).map((e) => Item.fromJson(e)).toList(),
        totalAmount: (json['totalAmount'] as num).toDouble(),
        createdAt: DateTime.parse(json['createdAt']),
        createdBy: json['createdBy'],
        notes: json['notes'],
      );
}
