List<dynamic> apiList(Object? data) {
  if (data is List) return data;
  if (data is Map) {
    final results = data['results'];
    if (results is List) return results;
  }
  return const [];
}
