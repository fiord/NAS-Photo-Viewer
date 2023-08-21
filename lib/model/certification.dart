import 'package:flutter/material.dart';

@immutable
class Certification {
  final String nasName;
  final String userName;
  final String password;
  final String path;

  const Certification({
    this.nasName = '',
    this.userName = '',
    this.password = '',
    this.path = '/',
  });
}
