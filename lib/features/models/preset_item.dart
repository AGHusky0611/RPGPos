class PresetItem {
  final String id;
  final String name;
  final double price;

  PresetItem({
    required this.id,
    required this.name,
    required this.price,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price': price,
      };

  factory PresetItem.fromJson(Map<String, dynamic> json) => PresetItem(
        id: json['id'],
        name: json['name'],
        price: (json['price'] as num).toDouble(),
      );

  PresetItem copyWith({
    String? id,
    String? name,
    double? price,
  }) {
    return PresetItem(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
    );
  }
}
