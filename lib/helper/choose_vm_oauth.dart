import 'package:aad_oauth/helper/core_oauth.dart';
import 'package:aad_oauth/helper/desktop_oauth.dart';
import 'package:aad_oauth/helper/mobile_oauth.dart';
import 'package:aad_oauth/model/config.dart';
import 'dart:io' as io;

CoreOAuth getOAuthConfig(Config config) {
  if (io.Platform.isWindows) {
    return DesktopOAuth(config);
  }
  return MobileOAuth(config);
}
