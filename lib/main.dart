import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nas_photo_viewer/data/secure_storage/secure_storage.dart';
import 'package:nas_photo_viewer/service/certification/certification_repository.dart';
import 'package:nas_photo_viewer/service/http/http_repository.dart';
import 'package:nas_photo_viewer/view/root/root_bloc.dart';
import 'package:nas_photo_viewer/view/root/root_page.dart';
import 'package:nas_photo_viewer/view/settings/settings_bloc.dart';
import 'package:nas_photo_viewer/view/settings/settings_page.dart';
import 'package:nas_photo_viewer/view/viewer/viewer_bloc.dart';
import 'package:nas_photo_viewer/view/viewer/viewer_page.dart';

void main() {
  runApp(const ProviderScope(child: App()));
}

class App extends StatelessWidget {
  const App({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SecureStorage secureStorage = SecureStorage();
    CertificationRepository certificationRepository =
        CertificationRepository(secureStorage);
    HttpRepository httpRepository = HttpRepository();

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
            path: path,
          );
          return ViewerPage(
            viewerPageBloc: viewerPageBloc,
          );
        }
      },
    );
  }
}
