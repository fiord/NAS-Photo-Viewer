import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nas_photo_viewer/data/secure_storage/secure_storage.dart';
import 'package:nas_photo_viewer/model/nas_file.dart';
import 'package:nas_photo_viewer/service/certification/certification_repository.dart';
import 'package:nas_photo_viewer/service/http/http_repository.dart';
import 'package:nas_photo_viewer/service/nasfiles/nasfiles_repository.dart';
import 'package:nas_photo_viewer/view/image_detail/image_detail.dart';
import 'package:nas_photo_viewer/view/root/root_bloc.dart';
import 'package:nas_photo_viewer/view/root/root_page.dart';
import 'package:nas_photo_viewer/view/settings/settings_bloc.dart';
import 'package:nas_photo_viewer/view/settings/settings_page.dart';
import 'package:nas_photo_viewer/view/viewer/viewer_bloc.dart';
import 'package:nas_photo_viewer/view/viewer/viewer_page.dart';

void main() async {
  final secureStorage = SecureStorage();
  final certificationRepository = CertificationRepository(secureStorage);
  final httpRepository = HttpRepository();
  final nasFilesRepository = NasFilesRepository();

  runApp(ProviderScope(
    child: App(
      secureStorage: secureStorage,
      certificationRepository: certificationRepository,
      httpRepository: httpRepository,
      nasFilesRepository: nasFilesRepository,
    ),
  ));
}

class App extends StatelessWidget {
  final SecureStorage secureStorage;
  final CertificationRepository certificationRepository;
  final HttpRepository httpRepository;
  final NasFilesRepository nasFilesRepository;
  const App({
    super.key,
    required this.secureStorage,
    required this.certificationRepository,
    required this.httpRepository,
    required this.nasFilesRepository,
  });

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NAS Photo Viewer',
      theme: ThemeData.light(useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),
      initialRoute: RootPage.routeName,
      routes: <String, WidgetBuilder>{
        RootPage.routeName: (BuildContext context) {
          final rootPageBloc = RootPageBloc(
              httpRepository: httpRepository,
              certificationRepository: certificationRepository);
          return RootPage(rootPageBloc: rootPageBloc);
        },
        SettingsPage.routeName: (BuildContext context) {
          final settingsPageBloc = SettingsPageBloc(certificationRepository);
          return SettingsPage(
            settingsPageBloc: settingsPageBloc,
          );
        },
        ViewerPage.routeName: (BuildContext context) {
          final arg = ModalRoute.of(context)!.settings.arguments;
          final path = (arg ?? '/') as String;
          final viewerPageBloc = ViewerPageBloc(
            httpRepository: httpRepository,
            nasFilesRepository: nasFilesRepository,
            path: path,
          );
          return ViewerPage(
            viewerPageBloc: viewerPageBloc,
          );
        },
        ImageDetailPage.routeName: (BuildContext context) {
          final arg = ModalRoute.of(context)!.settings.arguments;
          final map = (arg ?? {}) as Map<String, dynamic>;
          final index = (map['index'] ?? 0) as int;
          final nasfiles = (map['nasfiles'] ?? []) as List<NasFile>;
          final urlBase = (map['urlBase'] ?? '') as String;
          return ImageDetailPage(
            index: index,
            nasfiles: nasfiles,
            urlBase: urlBase,
          );
        },
      },
    );
  }
}
