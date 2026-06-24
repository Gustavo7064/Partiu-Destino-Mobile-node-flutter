class User {
  final int id;
  final String name;
  final String email;
  final String? role;
  final String? profileImage;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.role,
    this.profileImage,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'],
        name: json['name'],
        email: json['email'],
        role: json['role'],
        profileImage: json['profile_image'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'role': role,
        'profile_image': profileImage,
      };
}
