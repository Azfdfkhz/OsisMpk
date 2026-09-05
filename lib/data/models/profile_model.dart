/// Mirror dari tabel `profiles` (README bagian 26 / schema baris 78-86).
class ProfileModel {
  final String id;
  final String fullName;
  final String? email;
  final String? avatarUrl;
  final String roleName; // ditampilkan di sidebar/app bar, mis. "Bendahara"

  const ProfileModel({
    required this.id,
    required this.fullName,
    this.email,
    this.avatarUrl,
    required this.roleName,
  });

  factory ProfileModel.fromMap(Map<String, dynamic> map) {
    return ProfileModel(
      id: map['id'] as String,
      fullName: map['full_name'] as String? ?? '-',
      email: map['email'] as String?,
      avatarUrl: map['avatar_url'] as String?,
      roleName: map['role_name'] as String? ?? 'Anggota',
    );
  }
}
