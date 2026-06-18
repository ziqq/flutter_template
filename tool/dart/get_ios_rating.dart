import 'dart:convert';
import 'dart:io' as io;

import 'package:http/http.dart' as http;

final $log = io.stdout.writeln; // Log to stdout
final $err = io.stderr.writeln; // Log to stderr

/// Collect AppStore rating
/// Run: `dart tool/dart/get_ios_rating.dart`
void main() => Future<void>(() async {
  const appId = '1529842812'; // AppOrOrgName app ID on the App Store, without the 'id' prefix
  const countries = {'ru'};

  final futures = countries.map((c) async {
    try {
      final url = Uri.parse('https://itunes.apple.com/lookup?id=$appId&country=$c');

      final response = await http.get(url);
      final json = jsonDecode(response.body);

      if (json case {'results': List<Object?> results} when results.isNotEmpty) {
        for (final result in results) {
          if (result case <String, Object?>{'averageUserRating': num rating, 'userRatingCount': int reviews}) {
            return (country: c, rating: rating, reviews: reviews);
          }
        }
      }
      return null;
    } on Object catch (e) {
      $err('Error fetching rating for country $c: $e');
      return null;
    }
  });

  final results = await Future.wait(futures).then(
    (list) =>
        list
            .whereType<({String country, num rating, int reviews})>()
            .where((result) => result.rating > 0 && result.reviews > 0)
            .toList(growable: false)
          ..sort((a, b) => b.rating.compareTo(a.rating)),
  );

  var totalRating = 0.0;
  var totalReviews = 0;
  for (final result in results) {
    $log('Country: ${result.country}, Rating: ${result.rating}, Reviews: ${result.reviews}');
    totalRating += result.rating * result.reviews;
    totalReviews += result.reviews;
  }
  if (totalReviews > 0) {
    final averageRating = totalRating / totalReviews;
    $log('Average Rating: ${averageRating.toStringAsFixed(2)} based on $totalReviews reviews');
  } else {
    $log('No ratings found.');
  }
});
