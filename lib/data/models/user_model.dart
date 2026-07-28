enum UserRole {
  client,
  freelancer;

  static UserRole fromName(String? value) {
    return UserRole.values.firstWhere(
      (r) => r.name == value,
      orElse: () => UserRole.client,
    );
  }
}

class UserModel {
  const UserModel({
    required this.id,
    required this.name,
    this.surname,
    this.age,
    this.gender,
    required this.email,
    required this.role,
    this.avatarUrl,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String? surname;
  final int? age;
  final String? gender; // 'erkek', 'kadin', 'diger'
  final String email;
  final UserRole role;
  final String? avatarUrl;
  final DateTime createdAt;

  String get fullName => surname != null ? '$name $surname' : name;

  // Bir bildirim (report) oluşturulurken bildiren kullanıcının o anki
  // hâlinin anlık görüntüsü (bkz. report_model.dart).
  Map<String, dynamic> toReporterSnapshot() => {
        'userId': id,
        'name': fullName,
        'email': email,
        'avatarUrl': avatarUrl,
        'role': role.name,
      };

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      surname: json['surname'] as String?,
      age: (json['age'] as num?)?.toInt(),
      gender: json['gender'] as String?,
      email: json['email'] as String,
      role: UserRole.fromName(json['role'] as String?),
      avatarUrl: json['avatarUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'surname': surname,
        'age': age,
        'gender': gender,
        'email': email,
        'role': role.name,
        'avatarUrl': avatarUrl,
        'createdAt': createdAt.toIso8601String(),
      };

  UserModel copyWith({
    String? id,
    String? name,
    String? surname,
    int? age,
    String? gender,
    String? email,
    UserRole? role,
    String? avatarUrl,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      surname: surname ?? this.surname,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      email: email ?? this.email,
      role: role ?? this.role,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
