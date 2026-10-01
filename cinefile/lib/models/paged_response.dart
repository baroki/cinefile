class PagedResponse<T> {
  final List<T> results;
  final int page;
  final int totalPages;

  PagedResponse({
    required this.results,
    required this.page,
    required this.totalPages,
  });
}