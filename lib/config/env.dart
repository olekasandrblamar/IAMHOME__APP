import 'package:meta/meta.dart';

enum BuildFlavor { production, development, alpha }

BuildEnvironment get env => _env;
BuildEnvironment _env;

class BuildEnvironment {
  /// The backend server.
  final String baseUrl;
  final String baseUrl2;
  final String authUrl;
  final BuildFlavor flavor;

  BuildEnvironment._init({
    this.flavor,
    this.baseUrl,
    this.baseUrl2,
    this.authUrl,
  });

  /// Sets up the top-level [env] getter on the first call only.
  static void init({
    @required flavor,
    @required baseUrl,
    @required baseUrl2,
    @required authUrl,
  }) =>
      _env ??= BuildEnvironment._init(
        flavor: flavor,
        baseUrl: baseUrl,
        baseUrl2: baseUrl2,
        authUrl: authUrl,
      );
}
