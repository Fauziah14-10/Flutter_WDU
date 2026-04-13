import 'package:flutter/material.dart';
import 'storage.dart';

class AppRouteObserver extends NavigatorObserver {
  // Stack manual untuk simpan nama + args
  final List<({String name, Object? args})> _stack = [];

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    final name = route.settings.name;
    final args = route.settings.arguments;
    if (name != null) {
      _stack.add((name: name, args: args));
    }
    _persistCurrent();
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (_stack.isNotEmpty) _stack.removeLast();
    final name = newRoute?.settings.name;
    final args = newRoute?.settings.arguments;
    if (name != null) {
      _stack.add((name: name, args: args));
    }
    _persistCurrent();
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (_stack.isNotEmpty) _stack.removeLast();
    _persistCurrent(); // simpan route yang sekarang aktif (top of stack)
  }

  void _persistCurrent() {
    for (final entry in _stack.reversed) {
      if (entry.name != '/' &&
          entry.name != '/login' &&
          entry.name != '/dashboard' &&
          entry.name != '/submission') {
        StorageHelper.saveLastRoute(entry.name, entry.args);
        return;
      }
    }
    // Kalau tidak ada route yang layak, hapus
    StorageHelper.saveLastRoute(null, null);
  }
}