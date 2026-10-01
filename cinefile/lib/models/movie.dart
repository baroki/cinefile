class Movie {
  final int id;
  final String title;
  final String? posterPath;
  final String? overview;
  final DateTime? releaseDate;
  final double? voteAverage;

  Movie({
    required this.id,
    required this.title,
    required this.posterPath,
    required this.overview,
    required this.releaseDate,
    required this.voteAverage,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    DateTime? date;
    final dateStr = json["release_date"];

    if (dateStr != null && dateStr.toString().isNotEmpty) {
      try {
        date = DateTime.parse(dateStr);
      } catch (_) {}
    }

    return Movie(
      id: json["id"],
      title: json["title"] ?? "Unknown",
      posterPath: json["poster_path"],
      overview: json["overview"],
      releaseDate: date,
      voteAverage: (json["vote_average"] != null)
          ? (json["vote_average"] as num).toDouble()
          : null,
    );
  }
  Map<String, dynamic> toJson() {
  return {
    "id": id,
    "title": title,
    "poster_path": posterPath,
    "overview": overview,
    "release_date": releaseDate?.toIso8601String(),
    "vote_average": voteAverage,
  };
}

factory Movie.fromLocal(Map<dynamic, dynamic> json) {
  DateTime? date;

  if (json["release_date"] != null &&
      json["release_date"].toString().isNotEmpty) {
    try {
      date = DateTime.parse(json["release_date"]);
    } catch (_) {}
  }

  return Movie(
    id: json["id"],
    title: json["title"],
    posterPath: json["poster_path"],
    overview: json["overview"],
    releaseDate: date,
    voteAverage: json["vote_average"] != null
        ? (json["vote_average"] as num).toDouble()
        : null,
  );
}
}
