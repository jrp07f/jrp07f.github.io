import 'package:flutter/material.dart';
import 'package:mini_ginger_web/commons/ginger_core_palette.dart';

class CarouselControl extends StatefulWidget {
  /// [child] the scrollable child
  final Widget child;

  /// [scrollController] controller for the enclosing scrollable
  final ScrollController scrollController;

  /// [controlVerticalPosition] is the position of the carousel controls
  /// from the top of the containing widget
  final double controlVerticalPosition;

  /// [scrollPositionAdjustment] is how much we want the scrollable to move
  /// left or right.
  /// The width of the parent is used as the adjustment if the parentContext
  /// is provided and this will be disregarded because of that.
  final double scrollPositionAdjustment;

  /// [showDarkControls] controls when to use the darker version of the
  /// control widgets
  final bool showDarkControls;

  /// This is the context of the immediate parent of this carousel control
  /// It is used to get the visible runtime width of the scrollable
  final BuildContext parentContext;

  /// This is how much of the last visible part of the scrollable we want to
  /// show in the new visible part
  final double spacingOffset;

  /// This is the size of the control in height and width passed in from its parent
  /// We need this because some of the horizontal scroll views are shorter than
  /// the control
  final double controlSize;

  const CarouselControl({
    Key key,
    this.child,
    this.scrollController,
    this.controlVerticalPosition = 50.0,
    this.scrollPositionAdjustment = 50.0,
    this.showDarkControls = false,
    this.parentContext,
    this.spacingOffset = 0.0,
    this.controlSize = 30,
  }) : super(key: key);

  @override
  _CarouselControlState createState() => _CarouselControlState();
}

class _CarouselControlState extends State<CarouselControl> {
  bool showLeftControl = false;
  bool showRightControl = false;
  bool isWeb = false;
  double scrollPositionAdjustment = 0;

  /// We will only show the right control if there are more content on the right
  void maybeShowRightControl() {
    if (widget?.scrollController?.position?.extentAfter != null) {
      if (widget.scrollController.position.extentAfter == 0) {
        showRightControl = false;
      } else {
        showRightControl = true;
      }

      setState(() {});
    }
  }

  /// We will only show the left control if there are more content on the left
  void maybeShowLeftControl() {
    if (widget?.scrollController?.position?.extentBefore != null) {
      if (widget.scrollController.position.extentBefore == 0) {
        showLeftControl = false;
      } else {
        showLeftControl = true;
      }

      setState(() {});
    }
  }

  void maybeShowControls() {
    maybeShowLeftControl();
    maybeShowRightControl();
  }

  void initRightControl() {
    if (widget.scrollController == null) return;
    showRightControl = true;
    setState(() {});
  }

  void initializeCarouselControl() {
    if (isWeb) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        initRightControl();

        if (widget.parentContext != null) {
          RenderBox box = widget.parentContext.findRenderObject();
          scrollPositionAdjustment = box.size.width - widget.spacingOffset;
        }
      });

      /// Listen to scroll actions and update the controls appropriately
      widget.scrollController.addListener(maybeShowControls);
    }
  }

  void scrollLeft() async {
    if (widget.scrollController.position.extentBefore > 0) {
      await widget.scrollController.animateTo(
        widget.scrollController.offset - 400,
        duration: const Duration(milliseconds: 200),
        curve: Curves.ease,
      );

      maybeShowControls();
    }
  }

  void scrollRight() async {
    if (widget.scrollController.position.extentAfter > 0) {
      await widget.scrollController.animateTo(
        widget.scrollController.offset + 300,
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );

      maybeShowControls();
    }
  }

  @override
  void initState() {
    super.initState();
    isWeb = true;
    scrollPositionAdjustment = widget.scrollPositionAdjustment;

    initializeCarouselControl();
  }

  @override
  void dispose() {
    super.dispose();

    if (isWeb) widget.scrollController.removeListener(maybeShowControls);
  }

  @override
  Widget build(BuildContext context) {
    if (!isWeb) return widget.child;

    return Stack(
      fit: StackFit.passthrough,
      children: [
        widget.child,
        if (showLeftControl)
          Positioned(
            top: widget.controlVerticalPosition,
            left: 10,
            child: GestureDetector(
              onTap: () async {
                scrollLeft();
              },
              child: CarouselIcon(
                direction: CarouselControlDirection.backward,
                showDarkControls: widget.showDarkControls,
                size: widget.controlSize,
              ),
            ),
          ),
        if (showRightControl)
          Positioned(
            top: widget.controlVerticalPosition,
            right: 10,
            child: GestureDetector(
              onTap: () async {
                scrollRight();
              },
              child: CarouselIcon(
                direction: CarouselControlDirection.forward,
                showDarkControls: widget.showDarkControls,
                size: widget.controlSize,
              ),
            ),
          ),
      ],
    );
  }
}

class CarouselIcon extends StatelessWidget {
  final bool showDarkControls;
  final CarouselControlDirection direction;
  final double size;

  const CarouselIcon({
    Key key,
    this.showDarkControls = false,
    this.direction,
    this.size = 30,
  }) : super(key: key);

  IconData get directionIconData {
    IconData iconData = Icons.arrow_back_ios_new_rounded;
    switch (direction) {
      case CarouselControlDirection.forward:
        iconData = Icons.arrow_forward_ios_rounded;
        break;
      case CarouselControlDirection.backward:
        iconData = Icons.arrow_back_ios_new_rounded;
        break;
    }

    return iconData;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      shape: const CircleBorder(),
      elevation: 5,
      color: showDarkControls
        ? GingerCorePalette.grey85
        : GingerCorePalette.grey5,
      child: SizedBox(
        height: size,
        width: size,
        child: Center(
          child: Icon(
            directionIconData,
            size: size / 2,
            color: showDarkControls
                ? GingerCorePalette.grey5
                : GingerCorePalette.grey85,
          ),
        ),
      ),
    );
  }
}

enum CarouselControlDirection {
  forward,
  backward,
}
