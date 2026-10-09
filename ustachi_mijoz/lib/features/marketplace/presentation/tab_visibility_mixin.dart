import 'package:auto_route/auto_route.dart';
import 'package:flutter/widgets.dart';

mixin TabVisibilityMixin<T extends StatefulWidget> on State<T> {
  bool _tabVisible = true;

  bool get isTabVisible => _tabVisible;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final visible = _resolveVisible();
    if (visible == _tabVisible) return;
    _tabVisible = visible;
    onTabVisibilityChanged(visible);
  }

  bool _resolveVisible() {

    final scope = TabsRouterScope.of(context, watch: true);
    if (scope == null) return true;
    return RouteData.of(context).isActive;
  }

  void onTabVisibilityChanged(bool visible);
}
