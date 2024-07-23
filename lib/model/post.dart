class Post {
  final String id; // 投稿IDを追加
  final String userId;
  final String imageUrl;
  final String description;
  final String title; // タイトルを追加

  Post({
    required this.id,
    required this.userId,
    required this.imageUrl,
    required this.description,
    required this.title,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'], // IDを追加
      userId: json['userId'],
      imageUrl: json['imageUrl'],
      description: json['description'],
      title: json['title'], // タイトルを追加
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id, // IDを追加
      'userId': userId,
      'imageUrl': imageUrl,
      'description': description,
      'title': title, // タイトルを追加
    };
  }
}
