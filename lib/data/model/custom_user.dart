class CustomUser {
  final String id;
  final String name;
  final String position;
  final bool condition;
  final String image;

  CustomUser({
    required this.id,
    required this.name,
    required this.position,
    required this.condition,
    required this.image,
  });

  factory CustomUser.fromJson(Map<String, dynamic> json) {
    return CustomUser(
      id: json['custom_userID'],
      name: json['name'],
      position: json['position'],
      condition: json['condition'],
      image: json['image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "custom_userID": id,
      'name': name,
      'position': position,
      'condition': condition,
      'image': image,
    };
  }

  CustomUser copyWith({
    String? id,
    String? name,
    String? position,
    bool? condition,
    String? image,
  }) {
    return CustomUser(
      id: id ?? this.id,
      name: name ?? this.name,
      position: position ?? this.position,
      condition: condition ?? this.condition,
      image: image ?? this.image,
    );
  }
}

class Condition {
  final String userId;
  final bool condition;

  Condition({
    required this.userId,
    required this.condition,
  });

  factory Condition.fromJson(Map<String, dynamic> json) {
    return Condition(
      userId: json['custom_userID'],
      condition: json['condition'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "custom_userID": userId,
      'condition': condition,
    };
  }

  Condition copyWith({
    String? userId,
    bool? condition,
  }) {
    return Condition(
      userId: userId ?? this.userId,
      condition: condition ?? this.condition,
    );
  }
}
