import 'package:flutter/material.dart';

import '../models/movie.dart';
import '../services/watchlist_service.dart';
import '../services/tmdb_service.dart';
import 'movie_detail_page.dart';

class WatchlistPage extends StatefulWidget {
  const WatchlistPage({super.key});

  @override
  State<WatchlistPage> createState() => _WatchlistPageState();
}

class _WatchlistPageState extends State<WatchlistPage> {

  List<Movie> movies = [];

  @override
  void initState() {
    super.initState();
    loadMovies();
  }

  void loadMovies() {
    movies = WatchlistService.getMovies();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {

    if (movies.isEmpty) {
      return const Center(
        child: Text(
          "Watchlist boş",
          style: TextStyle(fontSize: 18),
        ),
      );
    }

    return GridView.builder(

      padding: const EdgeInsets.all(12),

      itemCount: movies.length,

      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.58,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),

      itemBuilder: (context, index) {

        final movie = movies[index];

        return GestureDetector(

          onTap: () async {

            await Navigator.push(

              context,

              MaterialPageRoute(

                builder: (_) => MovieDetailPage(movie: movie),

              ),

            );

            loadMovies();

          },

          child: Card(

            clipBehavior: Clip.antiAlias,

            child: Column(

              children: [

                Expanded(

                  child: Image.network(

                    TMDBService.getPosterUrl(
                      movie.posterPath ?? "",
                    ),

                    fit: BoxFit.cover,
                    width: double.infinity,

                  ),

                ),

                Padding(

                  padding: const EdgeInsets.all(8),

                  child: Column(

                    children: [

                      Text(

                        movie.title,

                        maxLines: 2,

                        overflow: TextOverflow.ellipsis,

                        textAlign: TextAlign.center,

                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),

                      ),

                      const SizedBox(height: 6),

                      Text(
                        "⭐ ${movie.voteAverage?.toStringAsFixed(1) ?? "-"}",
                      ),

                    ],

                  ),

                ),

              ],

            ),

          ),

        );

      },

    );

  }

}