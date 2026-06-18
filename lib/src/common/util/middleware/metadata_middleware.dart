/*
 * Date: 02 February 2026
 */

import 'package:flutter_template_name/src/common/api_client/api_client.dart';
import 'package:flutter_template_name/src/common/model/app_metadata.dart';
import 'package:meta/meta.dart';
import 'package:platform_info/platform_info.dart';

@immutable
class MetadataMiddleware {
  /// Private constructor.
  MetadataMiddleware({required this.metadata}) : _predefined = metadata.toHeaders();

  /// Metadata to be added to each request.
  @protected
  final AppMetadata metadata;

  /// Predefined headers based on the metadata.
  final Map<String, String> _predefined;

  /// The operating system of the device.
  static final String xOperatingSystem = switch (platform.operatingSystem) {
    OperatingSystem$Android() => 'android',
    OperatingSystem$Fuchsia() => 'fuchsia',
    OperatingSystem$iOS() => 'ios',
    OperatingSystem$Linux() => 'linux',
    OperatingSystem$MacOS() => 'macos',
    OperatingSystem$Windows() => 'windows',
    OperatingSystem$Unknown() => 'linux',
  };

  /// The handler transformer that injects the metadata headers.
  ApiClientHandler call(ApiClientHandler innerHandler) => (request, context) {
    request.headers.addAll(_predefined);
    return innerHandler(request, context);
  };
}
