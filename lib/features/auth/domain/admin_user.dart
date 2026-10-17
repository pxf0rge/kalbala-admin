class AdminUser {
  const AdminUser({
    required this.id,
    required this.phone,
    this.fullName,
    this.avatarUrl,
    this.isBlocked = false,
    this.isAdmin = false,
    this.adminRole,
  });

  final String id;
  final String phone;
  final String? fullName;
  final String? avatarUrl;
  final bool isBlocked;
  final bool isAdmin;
  final String? adminRole;

  String get displayName {
    final name = fullName?.trim();
    if (name != null && name.isNotEmpty) return name;
    return phone;
  }

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      id: json['id'] as String,
      phone: (json['phone'] as String?) ?? '',
      fullName: json['full_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      isBlocked: json['is_blocked'] == true,
      isAdmin: json['is_admin'] == true,
      adminRole: json['admin_role'] as String?,
    );
  }
}
