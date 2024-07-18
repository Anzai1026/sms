class User {
  final String id;
  final String? name;
  final String? imagePath;
  final String? email;

  User({
    required this.id,
    this.name,
    this.imagePath,
    this.email,
  });
}
