class User {
  String name;
  String uid;
  String? imagePath;

  User({
    required this.name,
    required this.uid,
    this.imagePath,
  });
}
