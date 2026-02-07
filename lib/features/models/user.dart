class User {
  final String id;
  final String username;
  final String password;
  final String name;

  User({
    required this.id,
    required this.username,
    required this.password,
    required this.name,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'password': password,
        'name': name,
      };

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'],
        username: json['username'],
        password: json['password'],
        name: json['name'],
      );
}
