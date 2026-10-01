import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../services/tmdb_service.dart';
import 'movie_detail_page.dart';

class MovieSearchDelegate extends SearchDelegate {
  @override
  String get searchFieldLabel => "Search for movies...";

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = "";
        },
      )
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    return FutureBuilder<List<Movie>>(
      future: TMDBService.searchMovies(query),
      builder: (context, snapshot) {
        if (query.isEmpty) {
          return const Center(child: Text("What are you looking for?"));
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final movies = snapshot.data!;

        if (movies.isEmpty) {
          return const Center(child: Text("No results found."));
        }

        return ListView.builder(
          itemCount: movies.length,
          itemBuilder: (context, index) {
            final movie = movies[index];

            return ListTile(
              leading: movie.posterPath != null
                  ? Image.network(
                      TMDBService.getPosterUrl(movie.posterPath!),
                      width: 50,
                      fit: BoxFit.cover,
                    )
                  : const Icon(Icons.movie),
              title: Text(movie.title),
              subtitle: Text(
                movie.voteAverage != null
                    ? "Rating: ${movie.voteAverage}"
                    : "No rating",
              ),
              onTap: () {
                close(context, null);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MovieDetailPage(movie: movie),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}