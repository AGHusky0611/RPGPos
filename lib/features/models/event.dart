import 'preset_item.dart';

class Event {
  final String id;
  final String name;
  final String description;
  final DateTime createdAt;
  final String createdBy;
  bool isActive;
  List<PresetItem> presetItems;

  Event({
    required this.id,
    required this.name,
    required this.description,
    required this.createdAt,
    required this.createdBy,
    this.isActive = true,
    List<PresetItem>? presetItems,
  }) : presetItems = presetItems ?? [];

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'createdAt': createdAt.toIso8601String(),
        'createdBy': createdBy,
        'isActive': isActive,
        'presetItems': presetItems.map((e) => e.toJson()).toList(),
      };

  factory Event.fromJson(Map<String, dynamic> json) => Event(
        id: json['id'],
        name: json['name'],
        description: json['description'],
        createdAt: DateTime.parse(json['createdAt']),
        createdBy: json['createdBy'],
        isActive: json['isActive'] ?? true,
        presetItems: json['presetItems'] != null
            ? (json['presetItems'] as List)
                .map((e) => PresetItem.fromJson(e))
                .toList()
            : [],
      );

  Event copyWith({
    String? id,
    String? name,
    String? description,
    DateTime? createdAt,
    String? createdBy,
    bool? isActive,
    List<PresetItem>? presetItems,
  }) {
    return Event(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      isActive: isActive ?? this.isActive,
      presetItems: presetItems ?? this.presetItems,
    );
  }
}
