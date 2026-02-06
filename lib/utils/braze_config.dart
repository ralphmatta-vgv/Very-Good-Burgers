/// Braze REST API config for server-side operations (e.g. rename external ID).
///
/// Set via dart-define when running so the key is not committed:
///   flutter run --profile --dart-define=BRAZE_REST_API_KEY=your_rest_api_key
///
/// Or set [BrazeConfig.restApiKey] in code for local dev (do not commit real keys).
abstract class BrazeConfig {
  /// REST API key with "users.external_ids.rename" permission. Empty = skip rename migration.
  static String restApiKey = String.fromEnvironment(
    'BRAZE_REST_API_KEY',
    defaultValue: '',
  );

  /// REST base URL. Must match your SDK cluster (e.g. sdk.fra-02.braze.eu → rest.fra-02.braze.eu).
  static String restEndpoint = String.fromEnvironment(
    'BRAZE_REST_ENDPOINT',
    defaultValue: 'https://rest.fra-02.braze.eu',
  );
}
