import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movie.dart';
import '../models/paged_response.dart';
import '../models/movie_images.dart';

class TMDBService {
  static const String apiKey = "b3e2d4b73994f212764b9640f5743be5";
  static const String baseUrl = "https://api.themoviedb.org/3";

  static String getPosterUrl(String posterPath) {
    return "https://image.tmdb.org/t/p/w500$posterPath";
  }

  static Future<PagedResponse<Movie>> fetchMovies(
    String endpoint, int page) async {
    final url = Uri.parse(
    "$baseUrl$endpoint?api_key=$apiKey&language=en-US&page=$page",
  );
  

  final response = await http.get(url);

  if (response.statusCode != 200) {
    throw Exception("TMDB API Error: ${response.statusCode}");
  }

  final data = jsonDecode(response.body);

  // 🎬 Filmleri parse et
  final results = (data["results"] as List)
      .map((e) => Movie.fromJson(e))
      .toList();

  // 📄 SAYFA BİLGİSİ
  final currentPage = data["page"];
  final totalPages = data["total_pages"];

  return PagedResponse<Movie>(
    results: results,
    page: currentPage,
    totalPages: totalPages,
  );
}

  static Future<PagedResponse<Movie>> fetchPopular(int page) async {
    return fetchMovies("/movie/popular", page);
  }

  static Future<PagedResponse<Movie>> fetchTopRated(int page) async {
    return fetchMovies("/movie/top_rated", page);
  }

  static Future<PagedResponse<Movie>> fetchNowPlaying(int page) async {
    return fetchMovies("/movie/now_playing", page);
  }

  static Future<PagedResponse<Movie>> fetchUpcoming(int page) async {
    return fetchMovies("/movie/upcoming", page);
  }

  static Future<PagedResponse<Movie>> fetchAllMovies(int page) {
  return fetchMovies("/discover/movie", page);
}

  static Future<List<Movie>> searchMovies(String query) async {
  if (query.isEmpty) return [];

  final url = Uri.parse(
    "$baseUrl/search/movie?api_key=$apiKey&language=en-US&query=$query&page=1",
  );

  final response = await http.get(url);

  if (response.statusCode != 200) {
    throw Exception("TMDB Search Error: ${response.statusCode}");
  }

  final data = jsonDecode(response.body);
  final results = data["results"] as List;

  final movies = results.map((e) => Movie.fromJson(e)).toList();

  // En popüler 5 sonucu getir
  movies.sort((a, b) =>
      (b.voteAverage ?? 0).compareTo(a.voteAverage ?? 0));

  return movies.take(5).toList();
}
static Future<String?> fetchTrailerKey(int movieId) async {
  final url = Uri.parse(
    "$baseUrl/movie/$movieId/videos?api_key=$apiKey&language=en-US",
  );

  final response = await http.get(url);

  if (response.statusCode != 200) {
    return null;
  }

  final data = jsonDecode(response.body);

  final results = data["results"] as List;

  for (final video in results) {
    if (video["site"] == "YouTube" &&
        video["type"] == "Trailer") {
      return video["key"];
    }
  }

  return null;
}
static Future<MovieImages> fetchMovieImages(int movieId) async {
  final url = Uri.parse(
    "$baseUrl/movie/$movieId/images?api_key=$apiKey",
  );

  final response = await http.get(url);

  if (response.statusCode != 200) {
    throw Exception("Image API Error");
  }

  final data = jsonDecode(response.body);

  final posters = (data["posters"] as List)
      .map<String>((e) => e["file_path"] as String)
      .toList();

  final backdrops = (data["backdrops"] as List)
      .map<String>((e) => e["file_path"] as String)
      .toList();

  return MovieImages(
    posters: posters,
    backdrops: backdrops,
  );
}
}
