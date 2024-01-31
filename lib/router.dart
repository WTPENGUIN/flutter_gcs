import 'package:go_router/go_router.dart';
import 'package:peachgs_flutter/screens/main_root_page.dart';
import 'package:peachgs_flutter/screens/link_page.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder:(context, state) => const MainRootWindow(),
    ),
    GoRoute(
      path: '/link',
      builder:(context, state) => const LinkSettingWindow(),
    )
  ]
);