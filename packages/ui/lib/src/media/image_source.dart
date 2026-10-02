/*
 * Author: Anton Ustinoff <https://github.com/ziqq> | <a.a.ustinoff@gmail.com>
 * Date: 13 August 2026
 */

import 'package:cross_file/cross_file.dart' show XFile;
import 'package:flutter/foundation.dart' show immutable;

/// Identifies an image without exposing platform-specific filesystem types.
///
/// Use [UIImageSource$Network] for HTTP(S) content,
/// [UIImageSource$Asset] for Flutter bundle assets, and
/// [UIImageSource$Local] for picker-provided [XFile] values.
@immutable
sealed class UIImageSource {
  const UIImageSource();

  /// Creates a remote image source.
  const factory UIImageSource.network(String url) = UIImageSource$Network;

  /// Creates a bundled asset image source.
  const factory UIImageSource.asset(String path) = UIImageSource$Asset;

  /// Creates a local image source selected through a platform picker.
  const factory UIImageSource.local(XFile file) = UIImageSource$Local;

  /// Resolves an HTTP(S) [location] as network content and any other non-empty
  /// location as a Flutter asset.
  factory UIImageSource.fromLocation(String location) =>
      location.startsWith('http://') || location.startsWith('https://')
      ? UIImageSource.network(location)
      : UIImageSource.asset(location);

  /// Resolves legacy locations into a platform-neutral source.
  ///
  /// A non-empty [localPath] takes precedence over [location]. Returns `null`
  /// when neither value is usable.
  static UIImageSource? fromLocations({String? localPath, String? location}) {
    if (localPath != null && localPath.isNotEmpty) return UIImageSource.local(XFile(localPath));
    if (location != null && location.isNotEmpty) return UIImageSource.fromLocation(location);
    return null;
  }
}

/// An image loaded from an HTTP or HTTPS URL.
final class UIImageSource$Network extends UIImageSource {
  /// Creates a remote image source.
  const UIImageSource$Network(this.url) : assert(url != '', 'Network image URL must not be empty.');

  /// Absolute URL supplied to the network image loader.
  final String url;

  @override
  int get hashCode => url.hashCode;

  @override
  bool operator ==(Object other) => identical(this, other) || (other is UIImageSource$Network && url == other.url);
}

/// An image bundled with the Flutter application.
final class UIImageSource$Asset extends UIImageSource {
  /// Creates an asset image source.
  const UIImageSource$Asset(this.path) : assert(path != '', 'Asset image path must not be empty.');

  /// Asset key registered in the consuming application's asset bundle.
  final String path;

  @override
  int get hashCode => path.hashCode;

  @override
  bool operator ==(Object other) => identical(this, other) || (other is UIImageSource$Asset && path == other.path);
}

/// An image represented by a picker-provided cross-platform file.
final class UIImageSource$Local extends UIImageSource {
  /// Creates a local image source.
  const UIImageSource$Local(this.file);

  /// File handle read from its path on native platforms and as bytes on Web.
  final XFile file;

  @override
  int get hashCode => file.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is UIImageSource$Local && identical(file, other.file));
}
