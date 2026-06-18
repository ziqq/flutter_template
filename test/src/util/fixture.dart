import 'dart:convert';
import 'dart:io';

import 'package:flutter_template_name/src/common/api_client/api_client.dart';
import 'package:flutter_template_name/src/common/constant/config.dart';
import 'package:flutter_template_name/src/common/constant/typedefs.dart';
import 'package:http/http.dart' as http_package;

/// A utility class for loading and parsing JSON fixtures from the file system.
class Fixture {
  /// Creates a new instance of [Fixture] with the given file path and optional data.
  Fixture(this.path, [this.data]);

  /// Creates a new instance of [Fixture] from a given JSON object.
  factory Fixture.fromJSON(JSON data) => Fixture(null, data);

  /// The file path to the JSON fixture.
  final String? path;

  final JSON? data;

  /// Parses the JSON fixture file and returns the resulting object.
  dynamic parse() {
    final $path = path;
    if ($path == null) return <String, Object?>{};
    final rawContents = File($path).readAsStringSync();
    return json.decode(rawContents);
  }

  /// Parses the JSON fixture file and returns the resulting object as a JSON map.
  JSON parseToJSON() {
    final parsed = parse();
    if (parsed case JSON json) return json;
    throw FormatException('Fixture.parseToJSON | Format is not JSON', parsed);
  }

  /// A helper function to create an `ApiClient$HTTP$Response` from a JSON body.
  ApiClient$HTTP$Response toHTTPResponse({String method = 'GET'}) => ApiClient$HTTP$Response.json(
    data ?? parseToJSON(),
    statusCode: 200,
    persistentConnection: false,
    headers: const <String, String>{},
    contentLength: (data ?? parseToJSON()).length,
    request: ApiClient$HTTP$Request(http_package.Request(method, Uri.parse(Config.apiBaseUrl))),
  );
}
