class Movie {
  final String id;
  final String title;
  final String description;
  final String poster;
  final int duration;
  final double rating;

  Movie({
    required this.id,
    required this.title,
    required this.description,
    required this.poster,
    required this.duration,
    required this.rating,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      poster: json['poster'],
      duration: json['duration'],
      rating: (json['rating'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'poster': poster,
      'duration': duration,
      'rating': rating,
    };
  }
}