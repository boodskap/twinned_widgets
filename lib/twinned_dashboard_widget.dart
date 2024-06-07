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
  final bool popupMode;
  final int? selectedRow;
  final int? selectedCol;
  final OnRowClicked? onRowClicked;
  final OnComponentClicked? onComponentClicked;

  TwinnedDashboardWidget(
      {super.key,
      this.screen,
      this.screenId,
      this.editMode = false,
      this.popupMode = false,
      this.selectedRow,
      this.selectedCol,
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
  int? selectedRow;
  int? selectedCol;

  @override
  void initState() {
    _screen = widget.screen;
    selectedRow = widget.selectedRow;
    selectedCol = widget.selectedCol;
    super.initState();
  }

  Radius _getRadius(RadiusConfig? config) {
    if (null == config) return Radius.zero;

    switch (config.radType) {
      case null:
      case RadiusConfigRadType.swaggerGeneratedUnknown:
      case RadiusConfigRadType.zero:
        return Radius.zero;
      case RadiusConfigRadType.circular:
        return Radius.circular(config.rad ?? 45.0);
      case RadiusConfigRadType.elliptical:
        return Radius.elliptical(config.xRad ?? 45, config.yRad ?? 45);
    }
  }

  BoxDecoration? _buildDecoration(String tag,
      {BorderConfig? config,
      int? bgColor,
      String? bgImage,
      ImageFitConfig? bgImageFit}) {
    BoxBorder? border;
    BorderRadiusGeometry? borderRadius;
    DecorationImage? image;

    if (null == config) return null;

    if (null != config) {
      Color borderColor = Color((config?.color ?? Colors.transparent.value));
      double borderWidth = config?.width ?? 0.0;
      border = Border.all(color: borderColor, width: borderWidth);

      debugPrint('$tag Border: Color:${borderColor.value} Width:$borderWidth');

      switch (config!.type) {
        case BorderConfigType.swaggerGeneratedUnknown:
        case BorderConfigType.zero:
          borderRadius = BorderRadius.zero;
          debugPrint('$tag BorderRadius: ZERO');
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
          debugPrint('$tag BorderRadius: ONLY');
          break;
        case BorderConfigType.horizontal:
          borderRadius = BorderRadius.horizontal(
              left: _getRadius(config.leftRadius),
              right: _getRadius(config.rightRadius));
          debugPrint('$tag BorderRadius: HORIZONTAL');
          break;
        case BorderConfigType.vertical:
          borderRadius = BorderRadius.vertical(
              top: _getRadius(config.topRadius),
              bottom: _getRadius(config.bottomRadius));
          debugPrint('$tag BorderRadius: VERTICAL');
          break;
        case BorderConfigType.circular:
          borderRadius = BorderRadius.circular(config.circularRadius ?? 0);
          debugPrint('$tag BorderRadius: CIRCULAR');
          break;
      }
    }

    if (null != bgImage && bgImage!.isNotEmpty) {
      BoxFit fit = BoxFit.contain;

      if (null != bgImageFit) {
        switch (bgImageFit!.fit) {
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
          case ImageFitConfigFit.fitHeight:
            fit = BoxFit.fitHeight;
            break;
          case ImageFitConfigFit.fitWidth:
            fit = BoxFit.fitWidth;
            break;
          case ImageFitConfigFit.scaleDown:
            fit = BoxFit.scaleDown;
            break;
        }
      }

      debugPrint('$tag BG Image: $bgImage, Fit: $fit');

      image = DecorationImage(
        image: TwinImageHelper.getDomainImage(bgImage!).image,
        fit: fit,
      );
    }

    if (null != bgColor && bgColor <= 0) {
      bgColor = Colors.transparent.value;
    }

    Color backgroundColor = Color(bgColor ?? Colors.transparent.value);

    return BoxDecoration(
      color: backgroundColor,
      image: image,
      border: border,
      borderRadius: borderRadius,
    );
  }

  void _initDefaults() {
    if (null == _screen) return;

    DashboardScreen screen = _screen!;

    _children.clear();

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
      if ((row.spacing ?? 0) > 0) {
        rowChildren.add(divider(horizontal: true, width: row.spacing!));
      }
    }

    int bgColor = row.bgColor ?? Colors.transparent.value;

    if (bgColor <= 0) {
      bgColor = Colors.transparent.value;
    }

    if (widget.editMode && selectedRow == rowIndex) {
      bgColor = Colors.black26.value;
    }

    Decoration? decoration = _buildDecoration('ROW-$rowIndex',
        config: row.rowBorderConfig,
        bgColor: bgColor,
        bgImage: row.bgImage,
        bgImageFit: row.bgImageFit);

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

    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start;
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center;
    MainAxisSize mainAxisSize = MainAxisSize.max;

    mainAxisAlignment = MainAxisAlignment.values
        .byName(row.mainAxisAlignment ?? mainAxisAlignment.name);
    crossAxisAlignment = CrossAxisAlignment.values
        .byName(row.crossAxisAlignment ?? crossAxisAlignment.name);
    mainAxisSize =
        MainAxisSize.values.byName(row.mainAxisSize ?? mainAxisSize.name);

    Color? backgroundColor;

    if (null == decoration) {
      backgroundColor = Color(bgColor);
    }

    Widget child = Row(
      mainAxisSize: mainAxisSize,
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      children: rowChildren,
    );

    if (null != row.scrollDirection && row.scrollDirection != 'none') {
      Axis scrollDirection =
          Axis.values.byName(_screen!.scrollDirection ?? Axis.vertical.name);

      Widget scrollable = SingleChildScrollView(
        scrollDirection: scrollDirection,
        child: child,
      );

      child = scrollable;
    }

    Widget container = Container(
      color: backgroundColor,
      height: row.height,
      margin: margin,
      padding: padding,
      decoration: decoration,
      child: child,
    );

    if (null != row.scrollDirection && row.scrollDirection != 'none') {
      Axis scrollDirection =
          Axis.values.byName(row.scrollDirection ?? Axis.vertical.name);
      SingleChildScrollView scrollable = SingleChildScrollView(
        scrollDirection: scrollDirection,
        child: container,
      );
      container = scrollable;
    }

    if (widget.editMode) {
      Widget clickable = InkWell(
        mouseCursor: SystemMouseCursors.contextMenu,
        onTap: () {
          setState(() {
            selectedRow = rowIndex;
          });
          widget.onRowClicked!(rowIndex, row);
        },
        child: container,
      );
      container = clickable;
    }

    return container;
  }

  Widget _buildScreenChild(
      int rowIndex, int colIndex, ScreenRow row, ScreenChild child) {
    int bgColor = child.bgColor ?? Colors.transparent.value;

    if (bgColor <= 0) {
      bgColor = Colors.transparent.value;
    }

    if (widget.editMode && selectedRow == rowIndex && selectedCol == colIndex) {
      bgColor = Colors.black45.value;
    }

    Decoration? decoration = _buildDecoration('COL-[$rowIndex, $colIndex]',
        config: child.childBorderConfig,
        bgColor: bgColor,
        bgImage: child.bgImage,
        bgImageFit: child.bgImageFit);

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

    if (null != child.alignment &&
        child.alignment!.alignment !=
            AlignmentConfigAlignment.swaggerGeneratedUnknown) {
      switch (child.alignment!.alignment) {
        case AlignmentConfigAlignment.swaggerGeneratedUnknown:
        case AlignmentConfigAlignment.center:
          alignment = Alignment.center;
          break;
        case AlignmentConfigAlignment.bottomRight:
          alignment = Alignment.bottomRight;
          break;
        case AlignmentConfigAlignment.bottomLeft:
          alignment = Alignment.bottomLeft;
          break;
        case AlignmentConfigAlignment.centerLeft:
          alignment = Alignment.centerLeft;
          break;
        case AlignmentConfigAlignment.centerRight:
          alignment = Alignment.centerRight;
          break;
        case AlignmentConfigAlignment.topRight:
          alignment = Alignment.topRight;
          break;
        case AlignmentConfigAlignment.topLeft:
          alignment = Alignment.topCenter;
          break;
        case AlignmentConfigAlignment.topCenter:
          alignment = Alignment.topCenter;
          break;
        case AlignmentConfigAlignment.bottomCenter:
          alignment = Alignment.bottomCenter;
          break;
      }
    }

    Widget component = TwinnedWidgets.build(
        child.widgetId, child.config as Map<String, dynamic>);

    if (widget.editMode) {
      Widget clickable = InkWell(
        mouseCursor: SystemMouseCursors.contextMenu,
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

    Color? backgroundColor;

    if (null == decoration) {
      backgroundColor = Color(bgColor);
    }

    Widget container = Container(
      color: backgroundColor,
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

    DashboardScreen screen = _screen!;

    int bgColor = screen.bgColor ?? Colors.transparent.value;

    if (bgColor <= 0) {
      bgColor = Colors.transparent.value;
    }

    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start;
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center;
    MainAxisSize mainAxisSize = MainAxisSize.max;

    mainAxisAlignment = MainAxisAlignment.values
        .byName(screen.mainAxisAlignment ?? mainAxisAlignment.name);
    crossAxisAlignment = CrossAxisAlignment.values
        .byName(screen.crossAxisAlignment ?? crossAxisAlignment.name);
    mainAxisSize =
        MainAxisSize.values.byName(screen.mainAxisSize ?? mainAxisSize.name);

    BoxDecoration? decoration = _buildDecoration('SCREEN',
        config: screen.screenBorderConfig,
        bgColor: screen.bgColor,
        bgImage: screen.bgImage,
        bgImageFit: screen.bgImageFit);

    EdgeInsetsGeometry? margin;
    EdgeInsetsGeometry? padding;

    if (null != screen.marginConfig) {
      margin = EdgeInsets.only(
          bottom: screen.marginConfig?.bottom ?? 0,
          top: screen.marginConfig?.top ?? 0,
          right: screen.marginConfig?.right ?? 0,
          left: screen.marginConfig?.left ?? 0);
    }

    if (null != screen.paddingConfig) {
      padding = EdgeInsets.only(
          bottom: screen.paddingConfig?.bottom ?? 0,
          top: screen.paddingConfig?.top ?? 0,
          right: screen.paddingConfig?.right ?? 0,
          left: screen.paddingConfig?.left ?? 0);
    }

    Color? backgroundColor;

    if (null == decoration) {
      backgroundColor = Color(bgColor);
    }

    Widget child = Container(
      color: backgroundColor,
      decoration: decoration,
      margin: margin,
      padding: padding,
      child: Column(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        mainAxisSize: mainAxisSize,
        children: _children,
      ),
    );

    if (null != screen.scrollDirection && screen.scrollDirection != 'none') {
      Axis scrollDirection =
          Axis.values.byName(_screen!.scrollDirection ?? Axis.vertical.name);

      Widget scrollable = SingleChildScrollView(
        scrollDirection: scrollDirection,
        child: child,
      );

      child = scrollable;
    }

    if (null != screen.bannerImage && screen.bannerImage!.isNotEmpty) {
      //TODO get height and fit from config
      BoxFit fit = BoxFit.contain;

      if (null != screen.bannerImageFit) {
        switch (screen.bannerImageFit!.fit) {
          case ImageFitConfigFit.swaggerGeneratedUnknown:
          case ImageFitConfigFit.none:
          case ImageFitConfigFit.contain:
            fit = BoxFit.contain;
            break;
          case ImageFitConfigFit.cover:
            fit = BoxFit.cover;
            break;
          case ImageFitConfigFit.fill:
            fit = BoxFit.fill;
            break;
          case ImageFitConfigFit.fitHeight:
            fit = BoxFit.fitHeight;
            break;
          case ImageFitConfigFit.fitWidth:
            fit = BoxFit.fitWidth;
            break;
          case ImageFitConfigFit.scaleDown:
            fit = BoxFit.scaleDown;
            break;
        }
      }

      Widget banner =
          TwinImageHelper.getDomainImage(screen.bannerImage!, fit: fit);

      Widget column = Column(
        children: [
          SizedBox(
              width: MediaQuery.of(context).size.width,
              height: screen.bannerHeight ?? 100,
              child: banner),
          Flexible(child: child),
        ],
      );

      child = column;
    }

    Widget? floating;

    if (widget.popupMode) {
      floating = IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_left,
            size: 48,
            color: Colors.blue,
          ));
    }

    return Scaffold(
      key: Key(const Uuid().v4()),
      backgroundColor: Color(bgColor),
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
      floatingActionButton: floating,
      body: child,
    );
  }

  void apply(DashboardScreen screen, int? selectedRow, int? selectedCol) {
    setState(() {
      this.selectedRow = selectedRow;
      this.selectedCol = selectedCol;
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
