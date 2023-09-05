import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

import '../addons/addons.dart';
import '../integrations/widgetbook_integration.dart';
import '../knobs/knobs.dart';
import '../navigation/navigation.dart';
import '../routing/routing.dart';
import 'default_app_builders.dart';
import 'widgetbook_scope.dart';

typedef AppBuilder = Widget Function(BuildContext context, Widget child);

class WidgetbookState extends ChangeNotifier {
  WidgetbookState({
    this.path,
    this.previewMode = false,
    this.queryParams = const {},
    this.appBuilder = widgetsAppBuilder,
    this.addons,
    this.integrations,
    required this.root,
  }) {
    this.knobs = KnobsRegistry(
      onLock: () {
        integrations?.forEach(
          (integration) => integration.onKnobsRegistered(this),
        );
      },
    );

    knobs.addListener(
      notifyListeners,
    );
  }

  String? path;
  bool previewMode;
  Map<String, String> queryParams;

  late final KnobsRegistry knobs;
  final AppBuilder appBuilder;
  final List<WidgetbookAddon>? addons;
  final List<WidgetbookIntegration>? integrations;
  final WidgetbookRoot root;

  List<WidgetbookNode> get directories => root.children!;

  WidgetbookUseCase? get useCase => path == null ? null : root.table[path!];

  /// A [Uri] representation of the current state.
  Uri get uri {
    final queryParameters = {
      if (path != null) 'path': path,
      ...queryParams,
    };

    return Uri(
      path: '/',
      queryParameters: queryParameters.isEmpty ? null : queryParameters,
    );
  }

  /// Gets the current state using [context].
  static WidgetbookState of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<WidgetbookScope>()!
        .notifier!;
  }

  @internal
  @override
  void notifyListeners() {
    super.notifyListeners();

    // Do not sync route in preview mode, since the widget state is already
    // controlled by using the URL.
    if (!previewMode) {
      _syncRouteInformation();
    }

    integrations?.forEach(
      (integration) => integration.onChange(this),
    );
  }

  /// Syncs this with the router's location using [SystemNavigator].
  void _syncRouteInformation() {
    SystemNavigator.routeInformationUpdated(
      // Not backwards compatible with Flutter < 3.13.0
      // ignore: deprecated_member_use
      location: uri.toString(),
    );
  }

  /// Update the [name] query parameter with the given [value].
  @internal
  void updateQueryParam(String name, String value) {
    if (AppRouteConfig.reservedKeys.contains(name)) {
      throw ArgumentError(
        'The query parameter $name is reserved and cannot be updated.',
      );
    }

    queryParams[name] = value;
    notifyListeners();
  }

  /// Update the [path], causing a new [useCase] to bet returned.
  /// Resets the [knobs] during the update.
  @internal
  void updatePath(String newPath) {
    path = newPath;

    // Reset Knobs
    knobs.clear();
    queryParams.remove('knobs');

    notifyListeners();
  }

  /// Updates [Knob.value] using the [label] to find the [Knob].
  @Deprecated('Use [knobs.updateValue] instead.')
  void updateKnobValue<T>(String label, T value) {
    knobs.updateValue<T>(label, value);
  }

  /// Update the current state using [AppRouteConfig] to update
  /// the [path], [previewMode] and [queryParams] fields. Since these fields
  /// can be manipulated from the router's query parameters, as opposed to the
  /// rest of fields that stay unchanged during runtime.
  @internal
  void updateFromRouteConfig(AppRouteConfig routeConfig) {
    path = routeConfig.path;
    previewMode = routeConfig.previewMode;
    queryParams = routeConfig.queryParams;

    notifyListeners();
  }
}
