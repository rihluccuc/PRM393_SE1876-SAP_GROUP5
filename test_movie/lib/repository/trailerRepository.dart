import '../database/databaseHelper.dart';
import '../model/trailer.dart';

class TrailerRepository {
  final DatabaseHelper _db;

  TrailerRepository({DatabaseHelper? db})
      : _db = db ?? DatabaseHelper.instance;

  Future<List<TrailerModel>> getByMovieId(int movieId) =>
      _db.getTrailersByMovieId(movieId);

  Future<void> cacheTrailers(List<TrailerModel> trailers) =>
      _db.upsertTrailers(trailers);
}
