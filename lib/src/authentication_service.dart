import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher_string.dart';

class Authentication {
  static const scopes = ['https://www.googleapis.com/auth/tasks'];
  static const authUri = 'https://accounts.google.com/o/oauth2/auth';
  static const tokenUri = 'https://oauth2.googleapis.com/token';

  static final client = Client();
  AccessCredentials? _credentials;

  final Map<String, dynamic> _secrets = {};

  Future<Map<String, String>> get headers async {
    final clientId = await _getClientId();
    final savedCredentials = await _getCredentials();

    if (_credentials == null) {
      // Assume no user
      if (savedCredentials == null) {
        // Brand new user
        _credentials = await _authenticate(clientId: clientId);
        _saveCredentials();
      } else {
        // Recover user
        _credentials = AccessCredentials.fromJson(savedCredentials);
      }
    }

    if (_credentials!.accessToken.hasExpired) {
      // Assume long time user or just recovered from saved
      debugPrint('Refreshing access token');
      _credentials = await refreshCredentials(clientId, _credentials!, client);
      _credentials ??= await _authenticate(clientId: clientId);
      _saveCredentials();
    }

    if (_credentials?.accessToken == null) throw 'Failed to authenticate';
    final token = _credentials!.accessToken;
    final authorization = '${token.type} ${token.data}';
    debugPrint(authorization);
    return {'Authorization': authorization};
  }

  Future<AccessCredentials> _authenticate({required ClientId clientId}) async {
    try {
      return await obtainAccessCredentialsViaUserConsent(
          clientId, scopes, client, launchUrlString);
    } catch (e) {
      throw 'Failed to authenticate: $e';
    }
  }

  Future<Map<String, dynamic>?> _getCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? json = prefs.getString('credentials');
    return json == null ? null : jsonDecode(json);
  }

  Future<void> _saveCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (_credentials == null) throw 'Tring to save unknown credentials';
    final json = jsonEncode(_credentials!.toJson());
    prefs.setString('credentials', json);
    debugPrint('Credentials saved');
  }

  Future<ClientId> _getClientId() async {
    if (_secrets.isEmpty) {
      // Assume first time through
      try {
        final data = await rootBundle.loadString('assets/client-secrets.json');
        final json = jsonDecode(data);
        _secrets.addAll(json['installed']);
      } catch (e) {
        _secrets['client_secret'] = Platform.environment['client_secret'];
        _secrets['client_id'] = Platform.environment['client_id'];
      }
    }

    if (_secrets['client_id'] == null) throw 'client_id missing';
    if (_secrets['client_secret'] == null) throw 'client_secret missing';

    return ClientId.fromJson({
      'identifier': _secrets['client_id'],
      'secret': _secrets['client_secret']
    });
  }
}
