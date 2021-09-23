import 'package:meta/meta.dart';

enum BuildFlavor { production, development, alpha }

BuildEnvironment get env => _env;
BuildEnvironment _env;

class BuildEnvironment {
  final String environment;

  /// The backend server.
  final String baseUrl;
  final String baseUrl2;
  final String serverUrl;
  final String accessKey;
  final String secret;
  final String authUrl;
  final String environmentUrl;
  final BuildFlavor flavor;

  BuildEnvironment._init(
      {this.environment,
      this.flavor,
      this.baseUrl,
      this.baseUrl2,
      this.accessKey,
      this.secret,
      this.authUrl,
      this.environmentUrl,
      this.serverUrl});

  /// Sets up the top-level [env] getter on the first call only.
  static void init({
    @required environment,
    @required flavor,
    @required baseUrl,
    @required baseUrl2,
    @required accessKey,
    @required secret,
    @required authUrl,
    @required environmentUrl,
    @required serverUrl
  }) =>
      _env ??= BuildEnvironment._init(
          environment: environment,
          flavor: flavor,
          baseUrl: baseUrl,
          baseUrl2: baseUrl2,
          accessKey: accessKey,
          secret: secret,
          authUrl: authUrl,
          environmentUrl: environmentUrl,
          serverUrl: serverUrl);
}
