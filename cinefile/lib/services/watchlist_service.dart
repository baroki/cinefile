import 'package:hive/hive.dart';
import '../models/movie.dart';

class WatchlistService {
  static final Box _box = Hive.box("watchlist");

  /// Filme ekle
  static Future<void> addMovie(Movie movie) async {
    await _box.put(
      movie.id.toString(),
      movie.toJson(),
    );
  }

  /// Film sil
  static Future<void> removeMovie(int movieId) async {
    await _box.delete(movieId.toString());
  }

  /// Watchlist'te var mı?
  static bool isInWatchlist(int movieId) {
    return _box.containsKey(movieId.toString());
  }

  /// Bütün filmleri getir
  static List<Movie> getMovies() {
    return _box.values
        .map((e) => Movie.fromLocal(
              Map<String, dynamic>.from(e),
            ))
        .toList();
  }

  /// Temizle
  static Future<void> clear() async {
    await _box.clear();
  }
}