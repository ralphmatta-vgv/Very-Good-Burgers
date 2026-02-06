import 'dart:convert';

import 'package:http/http.dart' as http;

import '../utils/braze_config.dart';

/// Braze REST API helpers (e.g. rename external ID to avoid duplicate users).
abstract class BrazeRest {
  /// Renames the user's external ID in Braze so the same profile gets the new ID (no duplicate).
  /// Requires [BrazeConfig.restApiKey] to be set. Returns true on success.
  static Future<bool> renameExternalId(String currentExternalId, String newExternalId) async {
    final key = BrazeConfig.restApiKey;
    if (key.isEmpty) return false;
    if (currentExternalId == newExternalId) return true;

    final url = Uri.parse('${BrazeConfig.restEndpoint}/users/external_ids/rename');
    final body = jsonEncode({
      'external_id_renames': [
        {'current_external_id': currentExternalId, 'new_external_id': newExternalId},
      ],
    });

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $key',
        },
        body: body,
      );
      if (response.statusCode != 200) return false;
      final data = jsonDecode(response.body) as Map<String, dynamic>?;
      final errors = data?['rename_errors'] as List<dynamic>?;
      return errors == null || errors.isEmpty;
    } catch (_) {
      return false;
    }
  }
}
