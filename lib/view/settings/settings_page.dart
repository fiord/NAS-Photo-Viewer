import 'package:flutter/material.dart';
import 'package:nas_photo_viewer/model/certification.dart';
import 'package:nas_photo_viewer/view/settings/settings_bloc.dart';

class SettingsPage extends StatefulWidget {
  static const String routeName = '/settings';
  final SettingsPageBloc settingsPageBloc;

  const SettingsPage({super.key, required this.settingsPageBloc});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController _nasNameField = TextEditingController();
  final TextEditingController _userNameField = TextEditingController();
  final TextEditingController _passwordField = TextEditingController();
  final TextEditingController _pathField = TextEditingController();

  @override
  void initState() {
    super.initState();

    Future(() async {
      Certification cert = await widget.settingsPageBloc.loadSettings();
      _nasNameField.text = cert.nasName;
      _userNameField.text = cert.userName;
      _passwordField.text = cert.password;
      _pathField.text = cert.path;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: CustomScrollView(
        slivers: [
          const SliverAppBar(
            title: Text('Settings'),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nasNameField,
                      decoration: const InputDecoration(
                        labelText: 'BuffaloNAS.comネーム',
                      ),
                    ),
                    TextFormField(
                      controller: _userNameField,
                      decoration: const InputDecoration(
                        labelText: 'username',
                      ),
                    ),
                    TextFormField(
                      controller: _passwordField,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'password',
                      ),
                    ),
                    TextFormField(
                      controller: _pathField,
                      decoration: const InputDecoration(
                        labelText: 'path',
                      ),
                    ),
                    FilledButton(
                      onPressed: () async {
                        final nasName = _nasNameField.text;
                        final userName = _userNameField.text;
                        final password = _passwordField.text;
                        final path = _pathField.text;
                        final cert = Certification(
                          nasName: nasName,
                          userName: userName,
                          password: password,
                          path: path,
                        );
                        final res =
                            await widget.settingsPageBloc.saveSettings(cert);
                        if (res && context.mounted) {
                          Navigator.of(context).maybePop();
                        }
                      },
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(double.infinity, 0),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(3.0),
                        child: Text('Save'),
                      ),
                    ),
                  ],
                ),
              ),
              childCount: 1,
            ),
          ),
        ],
      ),
    );
  }
}
