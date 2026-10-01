import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/movie.dart';
import '../models/movie_images.dart';
import '../services/tmdb_service.dart';
import '../services/watchlist_service.dart';

class MovieDetailPage extends StatefulWidget {
  final Movie movie;

  const MovieDetailPage({
    super.key,
    required this.movie,
  });

  @override
  State<MovieDetailPage> createState() => _MovieDetailPageState();
}

class _MovieDetailPageState extends State<MovieDetailPage> {

  late String? selectedPoster;

  late Future<MovieImages> imagesFuture;

  late Future<String?> trailerFuture;

  bool inWatchlist = false;

  @override
  void initState() {
    super.initState();

    selectedPoster = widget.movie.posterPath;

    imagesFuture =
        TMDBService.fetchMovieImages(widget.movie.id);

    trailerFuture =
        TMDBService.fetchTrailerKey(widget.movie.id);

    inWatchlist =
    WatchlistService.isInWatchlist(widget.movie.id);
  }

  @override
  Widget build(BuildContext context) {

    final releaseText =
        widget.movie.releaseDate != null
            ? widget.movie.releaseDate!
                .toIso8601String()
                .split("T")
                .first
            : "Unknown";

    final ratingText =
        widget.movie.voteAverage != null
            ? widget.movie.voteAverage.toString()
            : "N/A";

    return Scaffold(

      appBar: AppBar(
        title: Text(widget.movie.title),
      ),

      body: FutureBuilder<MovieImages>(

        future: imagesFuture,

        builder: (context, snapshot) {

          if (snapshot.connectionState ==
              ConnectionState.waiting) {

            return const Center(
              child: CircularProgressIndicator(),
            );

          }

          if (snapshot.hasError) {

            return Center(
              child: Text(
                snapshot.error.toString(),
              ),
            );

          }

          final movieImages = snapshot.data!;

          final posters = movieImages.posters.take(5).toList();

          final backdrops =
              movieImages.backdrops.take(5).toList();

          if (selectedPoster == null &&
              posters.isNotEmpty) {

            selectedPoster = posters.first;

          }

          return SingleChildScrollView(

            padding: const EdgeInsets.all(16),

            child: Column(

              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                Center(

                  child: AnimatedSwitcher(

                    duration:
                        const Duration(milliseconds: 300),

                    child: ClipRRect(

                      key: ValueKey(selectedPoster),

                      borderRadius:
                          BorderRadius.circular(12),

                      child: selectedPoster != null

                          ? Image.network(

                              TMDBService.getPosterUrl(
                                  selectedPoster!),

                              height: 420,

                              fit: BoxFit.cover,

                            )

                          : Container(

                              height: 420,

                              width: 280,

                              alignment:
                                  Alignment.center,

                              child: Text(
                                widget.movie.title,
                                textAlign:
                                    TextAlign.center,
                              ),
                            ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                Text(
                  widget.movie.title,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  "Release Date : $releaseText",
                  style:
                      const TextStyle(fontSize: 18),
                ),

                SizedBox(

  width: double.infinity,

  child: ElevatedButton.icon(

    icon: Icon(

      inWatchlist
          ? Icons.favorite
          : Icons.favorite_border,

    ),

    label: Text(

      inWatchlist
          ? "Remove from watchlist"
          : "Add to watchlist",

    ),

    onPressed: () async {

      if (inWatchlist) {

        await WatchlistService.removeMovie(
            widget.movie.id);

      } else {

        await WatchlistService.addMovie(
                  widget.movie);

      }

      setState(() {

        inWatchlist = !inWatchlist;

      });

    },

  ),

),

                const SizedBox(height: 6),

                Text(
                  "Rating : $ratingText",
                  style:
                      const TextStyle(fontSize: 18),
                ),

                const SizedBox(height: 20),

                Text(
                  widget.movie.overview ??
                      "No overview available.",
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 24),
                // ======================
// 🎬 Fragmanı İzle
// ======================

FutureBuilder<String?>(
  future: trailerFuture,
  builder: (context, trailerSnapshot) {
    if (!trailerSnapshot.hasData ||
        trailerSnapshot.data == null) {
      return const SizedBox();
    }

    final trailerKey = trailerSnapshot.data!;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.play_arrow),
        label: const Text(
          "Watch Trailer",
          style: TextStyle(fontSize: 16),
        ),
        onPressed: () async {
          final uri = Uri.parse(
            "https://www.youtube.com/watch?v=$trailerKey",
          );

          await launchUrl(
            uri,
            mode: LaunchMode.externalApplication,
          );
        },
      ),
    );
  },
),

const SizedBox(height: 30),

// ======================
// 🖼️ Alternatif Posterler
// ======================

if (posters.isNotEmpty) ...[

  const Text(
    "Alternative Posters",
    style: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  ),

  const SizedBox(height: 12),

  SizedBox(
    height: 220,

    child: ListView.builder(
      scrollDirection: Axis.horizontal,

      itemCount: posters.length,

      itemBuilder: (context, index) {

        final poster = posters[index];

        final bool isSelected =
            poster == selectedPoster;

        return GestureDetector(

          onTap: () {

            setState(() {

              selectedPoster = poster;

            });

          },

          child: AnimatedContainer(

            duration:
                const Duration(milliseconds: 250),

            margin:
                const EdgeInsets.only(right: 12),

            decoration: BoxDecoration(

              borderRadius:
                  BorderRadius.circular(10),

              border: Border.all(

                color: isSelected
                    ? Colors.blue
                    : Colors.transparent,

                width: 3,

              ),
            ),

            child: ClipRRect(

              borderRadius:
                  BorderRadius.circular(8),

              child: Image.network(

                "https://image.tmdb.org/t/p/w185$poster",

                width: 140,

                fit: BoxFit.cover,

              ),

            ),

          ),

        );

      },

    ),

  ),

],

const SizedBox(height: 30),
// ======================
// 📸 Film Görselleri
// ======================

if (backdrops.isNotEmpty) ...[

  const Text(
    "Movie Images",
    style: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  ),

  const SizedBox(height: 12),

  SizedBox(
    height: 140,

    child: ListView.builder(

      scrollDirection: Axis.horizontal,

      itemCount: backdrops.length,

      itemBuilder: (context, index) {

        final image = backdrops[index];

        return GestureDetector(

          onTap: () {

            showDialog(

              context: context,

              builder: (_) {

                return Dialog(

                  backgroundColor: Colors.black,

                  insetPadding:
                      const EdgeInsets.all(16),

                  child: InteractiveViewer(

                    minScale: 1,

                    maxScale: 5,

                    child: Image.network(
                      "https://image.tmdb.org/t/p/original$image",
                      fit: BoxFit.contain,
                    ),

                  ),

                );

              },

            );

          },

          child: Container(

            margin:
                const EdgeInsets.only(right: 10),

            child: ClipRRect(

              borderRadius:
                  BorderRadius.circular(10),

              child: Image.network(

                "https://image.tmdb.org/t/p/w500$image",

                width: 230,

                fit: BoxFit.cover,

              ),

            ),

          ),

        );

      },

    ),

  ),

],

const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }

  
}