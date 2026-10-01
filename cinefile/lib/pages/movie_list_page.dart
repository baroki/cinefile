import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../services/tmdb_service.dart';
import 'movie_detail_page.dart';
import '../models/paged_response.dart';

typedef MovieFetcher = Future<PagedResponse<Movie>> Function(int page);

class MovieListPage extends StatefulWidget {
  final MovieFetcher fetcher;

  const MovieListPage({super.key, required this.fetcher});

  @override
  State<MovieListPage> createState() => _MovieListPageState();
}

class _MovieListPageState extends State<MovieListPage> {
  List<Movie> movies = [];
  int currentPage = 1;

  bool isLoading = false;
  bool hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadMovies();
  }

  Future<void> _loadMovies() async {
  if (isLoading || !hasMore) return;

  setState(() {
    isLoading = true;
  });

  try {
    final response = await widget.fetcher(currentPage);

    setState(() {
      movies.addAll(response.results);

      // 🔥 DOĞRU KONTROL
      if (response.page >= response.totalPages) {
        hasMore = false;
      } else {
        currentPage = response.page + 1;
      }
    });
  } catch (e) {
    setState(() {
      hasMore = false;
    });
  }

  setState(() {
    isLoading = false;
  });
}

  Widget _buildMovieCard(Movie movie) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MovieDetailPage(movie: movie),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white24),
          borderRadius: BorderRadius.circular(6),
        ),
        child: movie.posterPath != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.network(
                  TMDBService.getPosterUrl(movie.posterPath!),
                  fit: BoxFit.cover,
                ),
              )
            : Center(
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Text(
                    movie.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (scrollInfo) {
        if (scrollInfo.metrics.pixels >=
                scrollInfo.metrics.maxScrollExtent - 300 &&
            !isLoading &&
            hasMore) {
          _loadMovies();
        }
        return false;
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(8),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return _buildMovieCard(movies[index]);
                },
                childCount: movies.length,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 0.65,
              ),
            ),
          ),
          if (isLoading)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
          if (!hasMore)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Center(
                  child: Text(
                    "Daha fazla film yok.",
                    style: TextStyle(color: Colors.white54),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
