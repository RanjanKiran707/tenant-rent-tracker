import 'package:flutter/widgets.dart';
import 'package:tenant_tracker/features/app/app_view_model.dart';

/// Gives every screen the app-wide [AppViewModel] (settings).
class AppScope extends InheritedWidget {
  final AppViewModel app;

  const AppScope({super.key, required this.app, required super.child});

  static AppViewModel of(BuildContext context) =>
      context.getInheritedWidgetOfExactType<AppScope>()!.app;

  @override
  bool updateShouldNotify(AppScope oldWidget) => app != oldWidget.app;
}
