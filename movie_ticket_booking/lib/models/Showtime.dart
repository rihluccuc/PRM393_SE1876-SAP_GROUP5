class Showtime {
  final String id;
  final String movieId;
  final String cinemaId;
  final DateTime time;
  final List<List<int>> seatMap; // ma trận ghế (0 = trống, 1 = đã đặt)

  Showtime({
    required this.id,
    required this.movieId,
    required this.cinemaId,
    required this.time,
    required this.seatMap,
  });

  factory Showtime.fromJson(Map<String, dynamic> json) {
    return Showtime(
      id: json['id'],
      movieId: json['movieId'],
      cinemaId: json['cinemaId'],
      time: DateTime.parse(json['time']),
      seatMap: List<List<int>>.from(
        json['seatMap'].map((row) => List<int>.from(row)),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'movieId': movieId,
      'cinemaId': cinemaId,
      'time': time.toIso8601String(),
      'seatMap': seatMap,
    };
  }
}