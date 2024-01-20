class UserModel {
  final String? id;
  final String? nama;
  final String? email;
  final String? password;
  final String? gambar;
  final String? level;

  UserModel({
    this.id,
    this.nama,
    this.email,
    this.password,
    this.gambar,
    this.level,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      nama: json['nama'],
      email: json['email'],
      password: json['password'],
      gambar: json['gambar'],
      level: json['level'],
    );
  }
}
