import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

class RemoteConfigService {
  static RemoteConfigService? _instance;
  FirebaseRemoteConfig? _remoteConfig;

  RemoteConfigService._();

  static RemoteConfigService get instance {
    _instance ??= RemoteConfigService._();
    return _instance!;
  }

  Future<void> initialize({
    Map<String, dynamic>? defaultValues,
    Duration fetchTimeout = const Duration(minutes: 1),
    Duration minimumFetchInterval = Duration.zero,
  }) async {
    try {
      _remoteConfig = FirebaseRemoteConfig.instance;

      if (defaultValues != null) {
        await _remoteConfig!.setConfigSettings(
          RemoteConfigSettings(
            fetchTimeout: fetchTimeout,
            minimumFetchInterval: minimumFetchInterval,
          ),
        );
        await _remoteConfig!.setDefaults(defaultValues);
      } else {
        await _remoteConfig!.setConfigSettings(
          RemoteConfigSettings(
            fetchTimeout: fetchTimeout,
            minimumFetchInterval: minimumFetchInterval,
          ),
        );
      }

      await fetchAndActivate();
    } catch (e) {}
  }

  Future<bool> fetchAndActivate() async {
    try {
      if (_remoteConfig == null) {
        return false;
      }
      final result = await _remoteConfig!.fetchAndActivate();

      return result;
    } catch (e) {
      return false;
    }
  }

  Future<bool> forceFetch() async {
    try {
      if (_remoteConfig == null) {
        return false;
      }
      await _remoteConfig!.fetch();
      final activated = await _remoteConfig!.activate();

      return activated;
    } catch (e) {
      return false;
    }
  }

  String getString(String key, {String defaultValue = ''}) {
    try {
      return _remoteConfig?.getString(key) ?? defaultValue;
    } catch (e) {
      return defaultValue;
    }
  }

  bool getBool(String key, {bool defaultValue = false}) {
    try {
      return _remoteConfig?.getBool(key) ?? defaultValue;
    } catch (e) {
      return defaultValue;
    }
  }

  int getInt(String key, {int defaultValue = 0}) {
    try {
      return _remoteConfig?.getInt(key) ?? defaultValue;
    } catch (e) {
      return defaultValue;
    }
  }

  double getDouble(String key, {double defaultValue = 0.0}) {
    try {
      return _remoteConfig?.getDouble(key) ?? defaultValue;
    } catch (e) {
      return defaultValue;
    }
  }

  Map<String, dynamic> getAll() {
    try {
      final all = _remoteConfig?.getAll() ?? {};
      final Map<String, dynamic> result = {};
      all.forEach((key, value) {
        result[key] = value.asString();
      });
      return result;
    } catch (e) {
      return {};
    }
  }

  bool get isInitialized => _remoteConfig != null;

  Future<void> checkAndShowUpdatePopup(BuildContext context) async {
    try {
      if (_remoteConfig == null) {
        return;
      }

      final remoteVersion = getInt('version', defaultValue: 0);

      final prefs = await SharedPreferences.getInstance();
      final localVersion = prefs.getInt('app_version') ?? 1;

      // If local version is less than remote version, show update popup
      if (localVersion < remoteVersion) {
        _showUpdateDialog(context);
      }
    } catch (e) {}
  }

  void _showUpdateDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            title: const Text('Update Required'),
            content: const Text(
              'A new version of the app is available. Please update to continue using the app.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Later'),
              ),
              ElevatedButton(
                onPressed: () async {
                  await _openPlayStore();
                },
                child: const Text('Update'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _openPlayStore() async {
    try {
      final String packageName = 'com.junto.app';
      final Uri url =
          Platform.isAndroid
              ? Uri.parse('market://details?id=$packageName')
              : Uri.parse('https://apps.apple.com/app/id$packageName');

      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        final Uri webUrl =
            Platform.isAndroid
                ? Uri.parse(
                  'https://play.google.com/store/apps/details?id=$packageName',
                )
                : Uri.parse('https://apps.apple.com/app/id$packageName');
        await launchUrl(webUrl, mode: LaunchMode.externalApplication);
      }
    } catch (e) {}
  }
}
