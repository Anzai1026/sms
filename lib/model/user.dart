class User {
  String name;
  String id;
  String? imagePath;

  User({
    required this.name,
    required this.id,
    this.imagePath,
  });
}
