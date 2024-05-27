import 'package:flutter/material.dart';
import 'package:nocode_commons/core/base_state.dart';
import 'package:twinned_api/twinned_api.dart';
import 'package:twinned_widgets/core/twin_image_helper.dart';
import 'package:twinned_widgets/twinned_widgets.dart';

class TwinnedDashboardWidget extends StatefulWidget {
  final DashboardScreen? screen;
  final String? screenId;

  const TwinnedDashboardWidget({super.key, this.screen, this.screenId});

  @override
  State<TwinnedDashboardWidget> createState() => _TwinnedDashboardWidgetState();
}

class _TwinnedDashboardWidgetState extends BaseState<TwinnedDashboardWidget> {
  DashboardScreen? _screen;

  final List<Widget> _children = [];
  Color backgroundColor = Colors.white;
  MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start;
  CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center;
  MainAxisSize mainAxisSize = MainAxisSize.max;
  Axis? scrollDirection = Axis.vertical;
  Decoration? decoration;

  @override
  void initState() {
    _screen = widget.screen;
    debugPrint(
        'HOST: ${TwinnedSession.instance.host}, DomainKey: ${TwinnedSession.instance.domainKey}, ApiKey: ${TwinnedSession.instance.authToken}');

    super.initState();
  }

  Radius _getRadius(RadiusConfig? config) {
    if (null == config) return Radius.zero;

    switch (config.type) {
      case RadiusConfigType.swaggerGeneratedUnknown:
      case RadiusConfigType.zero:
        return Radius.zero;
      case RadiusConfigType.circular:
        return Radius.circular(config.radius ?? 0);
      case RadiusConfigType.elliptical:
        return Radius.elliptical(config.xRadius ?? 0, config.yRadius ?? 0);
    }
  }

  void _initDefaults() {
    DashboardScreen screen = _screen!;

    backgroundColor = Color(screen.bgColor ?? Colors.white.value);
    mainAxisAlignment = MainAxisAlignment.values
        .byName(screen.mainAxisAlignment ?? mainAxisAlignment.name);
    crossAxisAlignment = CrossAxisAlignment.values
        .byName(screen.crossAxisAlignment ?? crossAxisAlignment.name);
    mainAxisSize =
        MainAxisSize.values.byName(screen.mainAxisSize ?? mainAxisSize.name);
    if (null != screen.scrollDirection && screen.scrollDirection != 'none') {
      scrollDirection =
          Axis.values.byName(screen.scrollDirection ?? scrollDirection!.name);
    }

    BoxBorder? border;
    BorderRadiusGeometry? borderRadius;
    DecorationImage? image;

    if (null != screen.border) {
      BorderConfig config = screen.border!;
      border = Border.all(
        color: Color(config.color ?? Colors.black.value),
        width: config.width ?? 1.0,
      );

      switch (screen.border!.type) {
        case BorderConfigType.swaggerGeneratedUnknown:
        case BorderConfigType.zero:
          borderRadius = BorderRadius.zero;
          break;
        case BorderConfigType.all:
          borderRadius = BorderRadius.all(_getRadius(config.allRadius));
          break;
        case BorderConfigType.only:
          borderRadius = BorderRadius.only(
            topLeft: _getRadius(config.topLeftRadius),
            topRight: _getRadius(config.topRightRadius),
            bottomLeft: _getRadius(config.bottomLeftRadius),
            bottomRight: _getRadius(config.bottomRightRadius),
          );
          break;
        case BorderConfigType.horizontal:
          borderRadius = BorderRadius.horizontal(
              left: _getRadius(config.leftRadius),
              right: _getRadius(config.rightRadius));
          break;
        case BorderConfigType.vertical:
          borderRadius = BorderRadius.vertical(
              top: _getRadius(config.topRadius),
              bottom: _getRadius(config.bottomRadius));
          break;
        case BorderConfigType.circular:
          borderRadius = BorderRadius.circular(config.circularRadius ?? 0);
          break;
      }
    }

    if (null != screen.bgImage && screen.bgImage!.isNotEmpty) {
      BoxFit fit = BoxFit.contain;

      if (null != screen.bgImageFit) {
        switch (screen.bgImageFit!.fit) {
          case ImageFitConfigFit.swaggerGeneratedUnknown:
          case ImageFitConfigFit.none:
            fit = BoxFit.none;
            break;
          case ImageFitConfigFit.contain:
            fit = BoxFit.contain;
            break;
          case ImageFitConfigFit.cover:
            fit = BoxFit.cover;
            break;
          case ImageFitConfigFit.fill:
            fit = BoxFit.fill;
            break;
          case ImageFitConfigFit.fitheight:
            fit = BoxFit.fitHeight;
            break;
          case ImageFitConfigFit.fitwidth:
            fit = BoxFit.fitWidth;
            break;
          case ImageFitConfigFit.scaledown:
            fit = BoxFit.scaleDown;
            break;
        }
      }

      image = DecorationImage(
        image: TwinImageHelper.getDomainImage(screen.bgImage!).image,
        fit: fit,
      );
    }

    decoration = BoxDecoration(
      image: image,
      border: border,
      borderRadius: borderRadius,
    );

    for (ScreenRow row in screen.rows) {
      _children.add(_buildScreenRow(row));
    }

    setState(() {});
  }

  Widget _buildScreenRow(ScreenRow row) {
    List<Widget> rowChildren = [];

    for (ScreenChild child in row.children) {
      rowChildren.add(_buildScreenChild(child));
    }

    Color backgroundColor = Color(row.bgColor ?? Colors.white.value);
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.values
        .byName(row.mainAxisAlignment ?? this.mainAxisAlignment.name);
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.values
        .byName(row.crossAxisAlignment ?? this.crossAxisAlignment.name);
    MainAxisSize mainAxisSize =
        MainAxisSize.values.byName(row.mainAxisSize ?? this.mainAxisSize.name);
    Axis? scrollDirection;

    if (null != row.scrollDirection && row.scrollDirection != 'none') {
      scrollDirection =
          Axis.values.byName(row.scrollDirection ?? Axis.vertical.name);
    }

    BoxBorder? border;
    BorderRadiusGeometry? borderRadius;
    DecorationImage? image;

    if (null != row.border) {
      BorderConfig config = row.border!;
      border = Border.all(
        color: Color(config.color ?? Colors.black.value),
        width: config.width ?? 1.0,
      );

      switch (row.border!.type) {
        case BorderConfigType.swaggerGeneratedUnknown:
        case BorderConfigType.zero:
          borderRadius = BorderRadius.zero;
          break;
        case BorderConfigType.all:
          borderRadius = BorderRadius.all(_getRadius(config.allRadius));
          break;
        case BorderConfigType.only:
          borderRadius = BorderRadius.only(
            topLeft: _getRadius(config.topLeftRadius),
            topRight: _getRadius(config.topRightRadius),
            bottomLeft: _getRadius(config.bottomLeftRadius),
            bottomRight: _getRadius(config.bottomRightRadius),
          );
          break;
        case BorderConfigType.horizontal:
          borderRadius = BorderRadius.horizontal(
              left: _getRadius(config.leftRadius),
              right: _getRadius(config.rightRadius));
          break;
        case BorderConfigType.vertical:
          borderRadius = BorderRadius.vertical(
              top: _getRadius(config.topRadius),
              bottom: _getRadius(config.bottomRadius));
          break;
        case BorderConfigType.circular:
          borderRadius = BorderRadius.circular(config.circularRadius ?? 0);
          break;
      }
    }

    if (null != row.bgImage && row.bgImage!.isNotEmpty) {
      BoxFit fit = BoxFit.contain;

      if (null != row.bgImageFit) {
        switch (row.bgImageFit!.fit) {
          case ImageFitConfigFit.swaggerGeneratedUnknown:
          case ImageFitConfigFit.none:
            fit = BoxFit.none;
            break;
          case ImageFitConfigFit.contain:
            fit = BoxFit.contain;
            break;
          case ImageFitConfigFit.cover:
            fit = BoxFit.cover;
            break;
          case ImageFitConfigFit.fill:
            fit = BoxFit.fill;
            break;
          case ImageFitConfigFit.fitheight:
            fit = BoxFit.fitHeight;
            break;
          case ImageFitConfigFit.fitwidth:
            fit = BoxFit.fitWidth;
            break;
          case ImageFitConfigFit.scaledown:
            fit = BoxFit.scaleDown;
            break;
        }
      }

      image = DecorationImage(
        image: TwinImageHelper.getDomainImage(row.bgImage!).image,
        fit: fit,
      );
    }

    Decoration decoration = BoxDecoration(
      color: backgroundColor,
      image: image,
      border: border,
      borderRadius: borderRadius,
    );

    EdgeInsetsGeometry? margin;
    EdgeInsetsGeometry? padding;

    if (null != row.margin) {
      margin = EdgeInsets.only(
          bottom: row.margin?.bottom ?? 0,
          top: row.margin?.top ?? 0,
          right: row.margin?.right ?? 0,
          left: row.margin?.left ?? 0);
    }

    if (null != row.padding) {
      padding = EdgeInsets.only(
          bottom: row.padding?.bottom ?? 0,
          top: row.padding?.top ?? 0,
          right: row.padding?.right ?? 0,
          left: row.padding?.left ?? 0);
    }

    return Container(
      height: row.height,
      margin: margin,
      padding: padding,
      decoration: decoration,
      child: Row(
        children: rowChildren,
      ),
    );
  }

  Widget _buildScreenChild(ScreenChild child) {
    Color backgroundColor = Color(child.bgColor ?? Colors.white.value);

    BoxBorder? border;
    BorderRadiusGeometry? borderRadius;
    DecorationImage? image;

    if (null != child.border) {
      BorderConfig config = child.border!;
      border = Border.all(
        color: Color(config.color ?? Colors.black.value),
        width: config.width ?? 1.0,
      );

      switch (child.border!.type) {
        case BorderConfigType.swaggerGeneratedUnknown:
        case BorderConfigType.zero:
          borderRadius = BorderRadius.zero;
          break;
        case BorderConfigType.all:
          borderRadius = BorderRadius.all(_getRadius(config.allRadius));
          break;
        case BorderConfigType.only:
          borderRadius = BorderRadius.only(
            topLeft: _getRadius(config.topLeftRadius),
            topRight: _getRadius(config.topRightRadius),
            bottomLeft: _getRadius(config.bottomLeftRadius),
            bottomRight: _getRadius(config.bottomRightRadius),
          );
          break;
        case BorderConfigType.horizontal:
          borderRadius = BorderRadius.horizontal(
              left: _getRadius(config.leftRadius),
              right: _getRadius(config.rightRadius));
          break;
        case BorderConfigType.vertical:
          borderRadius = BorderRadius.vertical(
              top: _getRadius(config.topRadius),
              bottom: _getRadius(config.bottomRadius));
          break;
        case BorderConfigType.circular:
          borderRadius = BorderRadius.circular(config.circularRadius ?? 0);
          break;
      }
    }

    if (null != child.bgImage && child.bgImage!.isNotEmpty) {
      BoxFit fit = BoxFit.contain;

      if (null != child.bgImageFit) {
        switch (child.bgImageFit!.fit) {
          case ImageFitConfigFit.swaggerGeneratedUnknown:
          case ImageFitConfigFit.none:
            fit = BoxFit.none;
            break;
          case ImageFitConfigFit.contain:
            fit = BoxFit.contain;
            break;
          case ImageFitConfigFit.cover:
            fit = BoxFit.cover;
            break;
          case ImageFitConfigFit.fill:
            fit = BoxFit.fill;
            break;
          case ImageFitConfigFit.fitheight:
            fit = BoxFit.fitHeight;
            break;
          case ImageFitConfigFit.fitwidth:
            fit = BoxFit.fitWidth;
            break;
          case ImageFitConfigFit.scaledown:
            fit = BoxFit.scaleDown;
            break;
        }
      }

      image = DecorationImage(
        image: TwinImageHelper.getDomainImage(child.bgImage!).image,
        fit: fit,
      );
    }

    Decoration decoration = BoxDecoration(
      color: backgroundColor,
      image: image,
      border: border,
      borderRadius: borderRadius,
    );

    EdgeInsetsGeometry? margin;
    EdgeInsetsGeometry? padding;
    AlignmentGeometry? alignment;

    if (null != child.margin) {
      margin = EdgeInsets.only(
          bottom: child.margin?.bottom ?? 0,
          top: child.margin?.top ?? 0,
          right: child.margin?.right ?? 0,
          left: child.margin?.left ?? 0);
    }

    if (null != child.padding) {
      padding = EdgeInsets.only(
          bottom: child.padding?.bottom ?? 0,
          top: child.padding?.top ?? 0,
          right: child.padding?.right ?? 0,
          left: child.padding?.left ?? 0);
    }

    Widget widget = TwinnedWidgets.build(
        child.widgetId, child.config as Map<String, dynamic>);

    Widget component = Container(
      height: child.height,
      width: child.width,
      margin: margin,
      padding: padding,
      alignment: alignment,
      decoration: decoration,
      child: widget,
    );

    if (child.expanded ?? false) {
      Widget expanded = Expanded(flex: child.flex ?? 1, child: component);
      component = expanded;
    }

    return component;
  }

  @override
  Widget build(BuildContext context) {
    if (null == _screen) {
      return const Scaffold(
        body: Center(
          child: Icon(Icons.hourglass_bottom),
        ),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Container(
        decoration: decoration,
        child: Column(
          mainAxisAlignment: mainAxisAlignment,
          crossAxisAlignment: crossAxisAlignment,
          mainAxisSize: mainAxisSize,
          children: _children,
        ),
      ),
    );
  }

  Future _load() async {
    if (null != _screen) {
      _initDefaults();
      return;
    }

    if (loading) return;
    loading = true;

    await execute(() async {
      var res = await TwinnedSession.instance.twin.getDashboardScreen(
          apikey: TwinnedSession.instance.authToken, screenId: widget.screenId);
      if (validateResponse(res)) {
        _screen = res.body!.entity;
        _initDefaults();
      }
    });

    loading = false;
    refresh();
  }

  @override
  void setup() {
    _load();
  }
}
