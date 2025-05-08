
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vizoo_frontend/apps/router/router_name.dart';
import 'package:vizoo_frontend/pages/admin/admin_activity_page.dart';
import 'package:vizoo_frontend/pages/admin/admin_page.dart';
import 'package:vizoo_frontend/pages/admin/admin_trip_page.dart';
import 'package:vizoo_frontend/pages/admin/admin_user_page.dart';
import 'package:vizoo_frontend/pages/change_password/change_password_page.dart';
import 'package:vizoo_frontend/pages/edit_timeline/edit_timeline_page.dart';
import 'package:vizoo_frontend/pages/forgot_password/forgot_password_page.dart';
import 'package:vizoo_frontend/pages/home/home_page.dart';
import 'package:vizoo_frontend/pages/login/login_page.dart';
import 'package:vizoo_frontend/pages/profile/profile.dart';
import 'package:vizoo_frontend/pages/register/register_page.dart';
import 'package:vizoo_frontend/pages/timeline/timeline_page.dart';
import 'package:vizoo_frontend/pages/welcome/welcome_page.dart';

class RouterCustum{
  static final GoRouter router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      name: RouterName.welcome,
      builder: (BuildContext context, GoRouterState state) {
        return const WelcomePage();
      },
      routes: <RouteBase>[
        GoRoute(
          path: 'login',
          name: RouterName.login,
          builder: (BuildContext context, GoRouterState state) {
            return const LoginPage();
          },
          routes: [
            GoRoute(
              path: 'register',
              name: RouterName.register,
              builder: (BuildContext context, GoRouterState state) {
                return const RegisterPage();
              },
            ),
            GoRoute(
              path: 'forgotPassword',
              name: RouterName.forgotPassword,
              builder: (BuildContext context, GoRouterState state) {
                return const ForgotPasswordPage();
              },
            ),
          ]
        ),
      ],
    ),
    GoRoute(
      path: '/home',
      name: RouterName.home,
      builder: (BuildContext context, GoRouterState state) {
        return const HomePage();
      },
      routes: [
        GoRoute(
          path: 'profile',
          name: RouterName.profile,
          builder: (BuildContext context, GoRouterState state) {
            return const ProfileScreen();
          },
          routes: [
            GoRoute(
              path: 'changePassword',
              name: RouterName.changePassword,
              builder: (BuildContext context, GoRouterState state) {
                return const ChangePasswordPage();
              },
            ),
          ]
        ),
      ]
    ),
    GoRoute(
      path: '/admin',
      name: RouterName.admin,
      builder: (BuildContext context, GoRouterState state) {
        return const AdminPage();
      },
    ),
  ],
);
}