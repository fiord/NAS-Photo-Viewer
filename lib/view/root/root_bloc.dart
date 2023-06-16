import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:nas_photo_viewer/config/config.dart';
import 'package:nas_photo_viewer/service/certification/certification_repository.dart';
import 'package:nas_photo_viewer/service/http/http_repository.dart';
import 'package:nas_photo_viewer/view/settings/settings_page.dart';
import 'package:nas_photo_viewer/view/viewer/viewer_page.dart';

class RootPageBloc {
  final HttpRepository httpRepository;
  final CertificationRepository certificationRepository;
  RootPageBloc({
    required this.httpRepository,
    required this.certificationRepository,
  });

  Future<bool> _tryLogin() async {
    // buffalonas.com
    final certification = await certificationRepository.getCertification();
    final nasName = certification.nasName;
    if (nasName.isEmpty) {
      Logger().d("certification is empty");
      return false;
    }
    final resp = await httpRepository
        .post(Uri.parse(Config.buffaloUrl), {'name': nasName});
    if (resp.statusCode != 302) {
      // throw error
      Logger().e(
          'status code not correct in ${Config.buffaloUrl}, expected 302, but actual ${resp.statusCode}');
      return false;
    }
    // get header to redirect
    final nasUrl = resp.headers.value('Location')!;
    await httpRepository.setNasUrl(nasUrl);

    final userName = certification.userName;
    final password = certification.password;
    // NAS login
    final loginUri = Uri.parse('${httpRepository.getNasUrl()}rpc/login');
    final loginResp = await httpRepository.post(loginUri, {
      'user': userName,
      'password': password,
    });
    if (loginResp.statusCode != 200) {
      Logger().e(
          'status code not correct in ${loginUri.toString()}, expected 200, but actual ${loginResp.statusCode}');
      return false;
    }
    return true;
  }

  Future<void> login(BuildContext context) async {
    // try login
    final result = await _tryLogin();
    Logger().d("result: $result");
    if (result) {
      // navigate to folders
      if (context.mounted) {
        await Navigator.of(context)
            .pushNamed(ViewerPage.routeName, arguments: '/');
      }
    } else {
      if (context.mounted) {
        await Navigator.of(context).pushNamed(SettingsPage.routeName);
      }
      if (context.mounted) login(context);
    }
  }
}
