import 'package:meta/meta.dart';

enum BuildFlavor { production, development, alpha }

BuildEnvironment get env => _env;
BuildEnvironment _env;

class BuildEnvironment {
  /// The backend server.
  final String baseUrl;
  final String baseUrl2;
  final String accessKey;
  final String secret;
  final String authUrl;
  final BuildFlavor flavor;

  BuildEnvironment._init({
    this.flavor,
    this.baseUrl,
    this.baseUrl2,
    this.accessKey,
    this.secret,
    this.authUrl,
  });

  /// Sets up the top-level [env] getter on the first call only.
  static void init({
    @required flavor,
    @required baseUrl,
    @required baseUrl2,
    @required accessKey,
    @required secret,
    @required authUrl,
  }) =>
      _env ??= BuildEnvironment._init(
        flavor: flavor,
        baseUrl: baseUrl,
        baseUrl2: baseUrl2,
        accessKey: accessKey,
        secret: secret,
        authUrl: authUrl,
      );
}
