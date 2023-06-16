import 'package:flutter/material.dart';
import 'package:nas_photo_viewer/view/root/root_bloc.dart';

class RootPage extends StatelessWidget {
  static const String routeName = '/';
  final RootPageBloc rootPageBloc;
  const RootPage({super.key, required this.rootPageBloc});

  @override
  Widget build(BuildContext context) {
    // check token
    rootPageBloc.login(context);

    return const Scaffold(
      appBar: null,
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
