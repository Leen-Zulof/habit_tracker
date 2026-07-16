// country_list.dart
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

const List<String> _fallbackCountries = [
  'United States',
  'Canada',
  'United Kingdom',
  'Australia',
  'India',
  'Germany',
  'France',
  'Japan',
  'Brazil',
  'South Africa',
  'Egypt',
  'Nigeria',
  'Singapore',
  'United Arab Emirates',
  'Saudi Arabia',
  'Mexico',
  'Argentina',
  'Italy',
  'Spain',
  'Netherlands',
  'Sweden',
  'Norway',
  'Denmark',
  'Finland',
  'New Zealand',
  'China',
  'South Korea',
  'Pakistan',
  'Turkey',
  'Indonesia',
  'Philippines',
  'Thailand',
  'Vietnam',
];

Future<List<String>> fetchCountries({http.Client? client}) async {
  final httpClient = client ?? http.Client();

  try {
    final response = await httpClient
        .get(
          Uri.parse('https://restcountries.com/v3.1/all?fields=name'),
          headers: {'Accept': 'application/json'},
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);

      if (decoded is List) {
        final countryList = decoded
            .map((country) {
              if (country is Map<String, dynamic> && country['name'] is Map) {
                final commonName = country['name']['common'];
                return commonName is String ? commonName : null;
              }
              return null;
            })
            .whereType<String>()
            .toSet()
            .toList()
          ..sort();

        if (countryList.isNotEmpty) {
          return countryList;
        }
      }
    }
  } on TimeoutException catch (_) {
    // Fall back to the built-in list if the request times out.
  } on FormatException catch (_) {
    // Fall back to the built-in list if the payload cannot be parsed.
  } on Exception catch (_) {
    // Fall back to the built-in list for any other request issue.
  } finally {
    if (client == null) {
      httpClient.close();
    }
  }

  return _fallbackCountries;
}
