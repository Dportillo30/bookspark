import 'package:bookspark/presentation/modules/app/app.dart';
import 'package:bookspark/presentation/modules/auth/login/login.dart';
import 'package:bookspark/presentation/modules/home/home.dart';
import 'package:flutter/widgets.dart';


List<Page<dynamic>> onGenerateAppViewPages(
  AppStatus state,
  List<Page<dynamic>> pages,
) {
  switch (state) {
    case AppStatus.authenticated:
      return [HomePage.page()];
    case AppStatus.unauthenticated:
      return [LoginPage.page()];
  }
}
