import 'package:flutter/material.dart';
import '../services/tmdb_service.dart';
import 'movie_list_page.dart';
import 'movie_search_delegate.dart';
import 'watchlist_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 6,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Cinefile"),
          actions: [
            IconButton(
           icon: const Icon(Icons.search),
           onPressed: () {
        showSearch(
          context: context,
          delegate: MovieSearchDelegate(),
        );
      },
    )
  ],
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
               Tab(text: "Popular"),
               Tab(text: "Top 250"),
               Tab(text: "Now Playing"),
               Tab(text: "Upcoming"),
               Tab(text: "All Movies"),
               Tab(
                     icon: Icon(Icons.favorite),
                    text: "Watchlist",
  ),
],
          ),
        ),
        body: TabBarView(
          children: [
                MovieListPage(fetcher: TMDBService.fetchPopular),
                MovieListPage(fetcher: TMDBService.fetchTopRated),
                MovieListPage(fetcher: TMDBService.fetchNowPlaying),
                MovieListPage(fetcher: TMDBService.fetchUpcoming),
                MovieListPage(fetcher: TMDBService.fetchAllMovies),
                const WatchlistPage(),
],
        ),
      ),
    );
  }
}
