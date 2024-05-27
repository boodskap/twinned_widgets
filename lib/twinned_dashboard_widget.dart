import 'package:flutter/material.dart';
import 'package:nocode_commons/core/base_state.dart';
import 'package:twinned_api/twinned_api.dart';
import 'package:twinned_widgets/core/twin_image_helper.dart';
import 'package:twinned_widgets/twinned_widgets.dart';
import 'package:uuid/uuid.dart';

typedef OnRowClicked = void Function(int selectedRow, ScreenRow row);
typedef OnComponentClicked = void Function(
    int selectedRow, int selectedCol, ScreenRow row, ScreenChild component);

class TwinnedDashboardWidget extends StatefulWidget {
  final DashboardScreen? screen;
  final String? screenId;
  final bool editMode;
  final OnRowClicked? onRowClicked;
  final OnComponentClicked? onComponentClicked;

  TwinnedDashboardWidget(
      {super.key,
      this.screen,
      this.screenId,
      this.editMode = false,
      this.onRowClicked,
      this.onComponentClicked}) {
    if (editMode && (null == onComponentClicked || null == onRowClicked)) {
      throw Error();
    }
  }

  @override
  State<TwinnedDashboardWidget> createState() => TwinnedDashboardWidgetState();
}

class TwinnedDashboardWidgetState extends BaseState<TwinnedDashboardWidget> {
  DashboardScreen? _screen;

  final List<Widget> _children = [];
  Color backgroundColor = Colors.white;
  MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start;
  CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center;
  MainAxisSize mainAxisSize = MainAxisSize.max;
  Axis? scrollDirection = Axis.vertical;
  Decoration? decoration;
  int? selectedRow;
  int? selectedCol;

  @override
  void initState() {
    _screen = widget.screen;
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
    if (null == _screen) return;

    DashboardScreen screen = _screen!;

    _children.clear();

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

    if (null != screen.borderConfig) {
      BorderConfig config = screen.borderConfig!;
      border = Border.all(
        color: Color(config.color ?? Colors.black.value),
        width: config.width ?? 1.0,
      );

      switch (screen.borderConfig!.type) {
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

    int index = 0;
    for (ScreenRow row in screen.rows) {
      _children.add(_buildScreenRow(index, row));
      ++index;
      if ((screen.spacing ?? 0) > 0) {
        _children.add(divider(height: screen.spacing!));
      }
    }

    refresh();
  }

  Widget _buildScreenRow(int rowIndex, ScreenRow row) {
    List<Widget> rowChildren = [];

    int colIndex = 0;
    for (ScreenChild child in row.children) {
      rowChildren.add(_buildScreenChild(rowIndex, colIndex, row, child));
      ++colIndex;
    }

    int bgColor = row.bgColor ?? Colors.transparent.value;

    if (bgColor <= 0) {
      bgColor = Colors.transparent.value;
    }

    Color backgroundColor = Color(bgColor);
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

    row = row.copyWith(
        borderConfig: BorderConfig(
            type: BorderConfigType.all,
            allRadius:
                RadiusConfig(type: RadiusConfigType.circular, radius: 45)));

    border = Border.all(color: Colors.black, width: 2);

    if (null != row.borderConfig) {
      BorderConfig config = row.borderConfig!;

      border = Border.all(color: Colors.black, width: config.width ?? 1.0);

      switch (row.borderConfig!.type) {
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

    if (null != row.marginConfig) {
      margin = EdgeInsets.only(
          bottom: row.marginConfig?.bottom ?? 0,
          top: row.marginConfig?.top ?? 0,
          right: row.marginConfig?.right ?? 0,
          left: row.marginConfig?.left ?? 0);
    }

    if (null != row.paddingConfig) {
      padding = EdgeInsets.only(
          bottom: row.paddingConfig?.bottom ?? 0,
          top: row.paddingConfig?.top ?? 0,
          right: row.paddingConfig?.right ?? 0,
          left: row.paddingConfig?.left ?? 0);
    }

    Container container = Container(
      //color: backgroundColor,
      height: row.height,
      margin: margin,
      padding: padding,
      decoration: decoration,
      child: Row(
        children: rowChildren,
      ),
    );

    if (widget.editMode) {
      return InkWell(
        onTap: () {
          setState(() {
            selectedRow = rowIndex;
          });
          widget.onRowClicked!(rowIndex, row);
        },
        child: container,
      );
    } else {
      return container;
    }
  }

  Widget _buildScreenChild(
      int rowIndex, int colIndex, ScreenRow row, ScreenChild child) {
    Color backgroundColor = Color(child.bgColor ?? Colors.white.value);

    BoxBorder? border;
    BorderRadiusGeometry? borderRadius;
    DecorationImage? image;

    Color bgColor = Color(
        null != child.bgColor ? child.bgColor! : Colors.transparent.value);

    if (widget.editMode) {
      bgColor = Colors.lime;
    }

    border = Border.all(
      color: bgColor,
    );

    if (null != child.borderConfig) {
      BorderConfig config = child.borderConfig!;
      switch (child.borderConfig!.type) {
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

    if (null != child.marginConfig) {
      margin = EdgeInsets.only(
          bottom: child.marginConfig?.bottom ?? 0,
          top: child.marginConfig?.top ?? 0,
          right: child.marginConfig?.right ?? 0,
          left: child.marginConfig?.left ?? 0);
    }

    if (null != child.paddingConfig) {
      padding = EdgeInsets.only(
          bottom: child.paddingConfig?.bottom ?? 0,
          top: child.paddingConfig?.top ?? 0,
          right: child.paddingConfig?.right ?? 0,
          left: child.paddingConfig?.left ?? 0);
    }

    Widget component = TwinnedWidgets.build(
        child.widgetId, child.config as Map<String, dynamic>);

    if (widget.editMode) {
      Widget clickable = InkWell(
        onTap: () {
          setState(() {
            selectedRow = rowIndex;
            selectedCol = colIndex;
          });
          widget.onComponentClicked!(rowIndex, colIndex, row, child);
        },
        child: component,
      );
      component = clickable;
    }

    Widget container = Container(
      height: child.height,
      width: child.width,
      margin: margin,
      padding: padding,
      alignment: alignment,
      decoration: decoration,
      child: component,
    );

    if (child.expanded ?? false) {
      Widget expanded = Expanded(flex: child.flex ?? 1, child: container);
      container = expanded;
    }

    return container;
  }

  @override
  Widget build(BuildContext context) {
    _initDefaults();

    if (null == _screen) {
      return const Scaffold(
        body: Center(
          child: Icon(Icons.hourglass_bottom),
        ),
      );
    }

    Container child = Container(
      decoration: decoration,
      child: Column(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        mainAxisSize: mainAxisSize,
        children: _children,
      ),
    );

    Widget scrollable;

    switch (
        Axis.values.byName(_screen!.scrollDirection ?? Axis.vertical.name)) {
      case Axis.horizontal:
        scrollable = SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: child,
        );
        break;
      case Axis.vertical:
        scrollable = SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: child,
        );
    }

    return Scaffold(
      key: Key(const Uuid().v4()),
      backgroundColor: backgroundColor,
      body: scrollable,
    );
  }

  void apply(DashboardScreen screen) {
    setState(() {
      _screen = screen;
    });
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
  }

  @override
  void setup() {
    _load();
  }
}
