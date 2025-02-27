import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NavigationHelper {
  static void pushTo(BuildContext context, String routeName, {Object? extra}) {
    context.push(routeName, extra: extra);
  }

  static void goTo(BuildContext context, String routeName, {Object? extra}) {
    context.go(routeName, extra: extra);
  }

  static void pop(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      debugPrint('Cannot pop any further.');
    }
  }

  static Future<T?> pushForResult<T>(
    BuildContext context,
    String routeName, {
    Object? extra,
  }) {
    return context.push(routeName, extra: extra);
  }
}
