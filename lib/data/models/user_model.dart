class UserModel {
  final int id;
  final String name;
  final String email;
  final String role;
  final String? university;
  final String? major;
  final String? phone;
  final String? avatar;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.university,
    this.major,
    this.phone,
    this.avatar,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: json['role'],
      university: json['university'],
      major: json['major'],
      phone: json['phone'],
      avatar: json['avatar'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'university': university,
      'major': major,
      'phone': phone,
      'avatar': avatar,
    };
  }
}