library stacked_cards_carousel;

import 'package:flutter/material.dart';

class StackedCardsController {
  ///Initial index of the item to be displayed. Should be less than the length of [items].
  ///Defaults to 0. If the value is greater than the length of [items], it will be set to 0.
  ///If the value is less than 0, it will be set to 0.
  ///Would be used to determine the initial position of the card stack and ignored after that.
  int _index;
  int get index => _index;
  StackedCardsController([int initialIndex = 0]) : _index = initialIndex;
  __StackedCardsState? _state;

  void _attach(__StackedCardsState state) {
    if (_state != null) {
      throw Exception(
          'StackedCardsController: Controller is already attached to a widget');
    }
    _state = state;
  }

  void _detach() {
    _state = null;
  }

  void dispose() {
    _detach();
  }
}

class StackedCardsCarouselWidget extends StatelessWidget {
  ///Items to be displayed in the card stack.
  ///The items would be constrained with the [height] and [width] provided.
  ///There should be atleast 3 items in the list.
  final List<Widget> items;

  ///Height of a card in stack. Defaults to 300.
  final double height;

  ///Width of a card in stack. Defaults to 200.
  final double width;

  ///Number of levels to be displayed in the card stack. Defaults to 3.
  ///The levels would be displayed in a stack with the top level being the first element in the list.
  ///
  final int stackLevels;

  ///Callback function to be called when the item is changed.
  ///This function would be called after the index has been changed.
  final Function(int i)? onItemChanged;

  /// Controller for stacked cards widget.
  /// This can be used to control the index of the card stack.
  final StackedCardsController? controller;

  const StackedCardsCarouselWidget({
    super.key,
    required this.items,
    this.height = 300,
    this.width = 200,
    this.stackLevels = 3,
    this.onItemChanged,
    this.controller,
  }) : assert(items.length >= 3,
            'StackedCardsCarouselWidget: There should be atleast 3 items in the list');

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return _StackedCards(
        items: items,
        height: height,
        width: width,
        stackLevels: stackLevels,
        onItemChanged: onItemChanged,
        controller: controller,
        containerWidth: constraints.maxWidth,
      );
    });
  }
}

class _StackedCards extends StatefulWidget {
  ///Items to be displayed in the card stack.
  ///The items would be constrained with the [height] and [width] provided.
  ///There should be atleast 3 items in the list.
  final List<Widget> items;

  ///Height of a card in stack. Defaults to 300.
  final double height;

  ///Width of a card in stack. Defaults to 200.
  final double width;

  /// Widget's container width
  final double containerWidth;

  ///Number of levels to be displayed in the card stack. Defaults to 3.
  ///The levels would be displayed in a stack with the top level being the first element in the list.
  final int stackLevels;

  ///Callback function to be called when the item is changed.
  ///This function would be called after the index has been changed.
  final Function(int i)? onItemChanged;

  /// Controller for stacked cards widget.
  /// This can be used to control the index of the card stack.
  final StackedCardsController? controller;
  const _StackedCards({
    required this.items,
    required this.height,
    required this.width,
    required this.stackLevels,
    this.onItemChanged,
    this.controller,
    required this.containerWidth,
  });

  @override
  State<_StackedCards> createState() => __StackedCardsState();
}

class __StackedCardsState extends State<_StackedCards> {
  T getNextItem<T>(List<T> list, int currentIndex, int steps) {
    if (list.isEmpty) {
      throw Exception('List is empty');
    }
    int nextIndex = (currentIndex + steps) % list.length;
    return list[nextIndex];
  }

  T getPreviousItem<T>(List<T> list, int currentIndex, int steps) {
    if (list.isEmpty) {
      throw Exception('List is empty');
    }
    int previousIndex = (currentIndex - steps) % list.length;
    if (previousIndex < 0) {
      previousIndex += list.length;
    }
    return list[previousIndex];
  }

  final _panThreshold = 100;
  double _dx = 0;
  bool _isAnimating = false;
  double spaceIntervals = 0;

  final List<List<Widget>> _widgetWithLevels = [];
  final StackedCardsController _controller = StackedCardsController();
  late StackedCardsController controller;
  @override
  void initState() {
    initController();
    initWidgets();
    super.initState();
  }

  void initController() {
    controller = widget.controller ?? _controller;
    controller._attach(this);
  }

  int get selectedIndex => controller.index;
  int get numberOfLevels => widget.stackLevels;
  set selectedIndex(int index) {
    if (index < 0) {
      index = 0;
    }
    if (index >= widget.items.length) {
      index = widget.items.length - 1;
    }
    controller._index = index;

    widget.onItemChanged?.call(index);
  }

  void initWidgets() {
    _widgetWithLevels.clear();
    _widgetWithLevels.add([widget.items[selectedIndex]]);
    for (int i = 1; i <= numberOfLevels; i++) {
      List<Widget> levelItems = [];
      Widget nextItem = getNextItem(widget.items, selectedIndex, i);
      Widget previousItem = getPreviousItem(widget.items, selectedIndex, i);
      levelItems.add(previousItem);
      levelItems.add(nextItem);
      _widgetWithLevels.add(levelItems);
    }
  }

  @override
  Widget build(BuildContext context) {
    double spaceIntervals =
        (widget.containerWidth - widget.width) / (2 * (widget.stackLevels - 1));
    return Stack(
      children: [
        Positioned(
          left: 0,
          right: 0,
          height: widget.height,
          child: Opacity(
            opacity: _isAnimating ? 0 : 1,
            child: Stack(
              children: [
                for (int i = _widgetWithLevels.length - 2; i > 0; i--) ...[
                  Positioned(
                    left: (widget.containerWidth - widget.width) / 2 +
                        ((i) * spaceIntervals),
                    child: Transform.scale(
                      scale: 1 - (i * 0.1),
                      child: Container(
                        height: widget.height,
                        width: widget.width,
                        color: Colors.transparent,
                        child: _widgetWithLevels[i][1],
                      ),
                    ),
                  ),
                  Positioned(
                    right: (widget.containerWidth - widget.width) / 2 +
                        ((i) * spaceIntervals),
                    child: Transform.scale(
                      scale: 1 - (i * 0.1),
                      child: Container(
                        height: widget.height,
                        width: widget.width,
                        color: Colors.transparent,
                        child: _widgetWithLevels[i][0],
                      ),
                    ),
                  )
                ],
                Positioned(
                  right: (widget.containerWidth - widget.width) / 2,
                  child: Transform.scale(
                    scale: 1,
                    child: GestureDetector(
                      onHorizontalDragStart: onHorizontalDragStart,
                      onHorizontalDragEnd: (d) => onHorizontalDragEnd(),
                      onHorizontalDragUpdate: onHorizontalDragUpdate,
                      onHorizontalDragCancel: () => onHorizontalDragEnd(),
                      child: Container(
                        height: widget.height,
                        width: widget.width,
                        color: Colors.transparent,
                        child: _widgetWithLevels[0][0],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
        if (_isAnimating)
          Builder(builder: (context) {
            double progress = _dx.abs() / _panThreshold;
            bool isForward = _dx > 0;
            List<Widget> stack = [
              for (int i = _widgetWithLevels.length - 1; i > 0; i--)
                ...getAnimatingCardStack(
                  widget.containerWidth,
                  i,
                  spaceIntervals,
                  isForward,
                  progress,
                ),
            ];
            Widget topElement = Builder(builder: (context) {
              double cuvedProgress = Curves.linear.transform(progress);
              double currentLeft = (widget.containerWidth - widget.width) / 2;
              double targetLeft = (widget.containerWidth - widget.width) / 2 +
                  (isForward ? spaceIntervals : -spaceIntervals);
              double left =
                  currentLeft + (targetLeft - currentLeft) * cuvedProgress;

              double currentScale = 1;
              double targetScaleForward = 0.9;
              double scale = currentScale +
                  (targetScaleForward - currentScale) * cuvedProgress;

              double angle = 0;

              return Positioned(
                left: left,
                child: Opacity(
                  opacity: 1,
                  child: Transform.rotate(
                    angle: angle,
                    child: Transform.scale(
                      scale: scale,
                      child: Container(
                        height: widget.height,
                        width: widget.width,
                        color: Colors.transparent,
                        child: _widgetWithLevels[0][0],
                      ),
                    ),
                  ),
                ),
              );
            });
            if (progress >= 0.5) {
              Widget topStack = stack.last;
              stack.removeLast();
              stack.add(topElement);
              stack.add(topStack);
            } else {
              stack.add(topElement);
            }
            return Positioned(
              left: 0,
              right: 0,
              height: widget.height,
              child: Stack(
                children: stack,
              ),
            );
          }),
      ],
    );
  }

  void onHorizontalDragUpdate(DragUpdateDetails d) {
    _dx += d.primaryDelta!;
    if (_dx.abs() > _panThreshold) {
      _dx = _panThreshold * _dx.sign;
    }
    setState(() {});
  }

  void onHorizontalDragEnd() {
    _isAnimating = false;
    if (_dx.abs() > (_panThreshold / 2)) {
      if (_dx > 0) {
        selectedIndex = (selectedIndex - 1) % widget.items.length;
        if (selectedIndex < 0) {
          selectedIndex += widget.items.length;
        }
      } else {
        selectedIndex = (selectedIndex + 1) % widget.items.length;
      }
      _dx = 0;

      initWidgets();
    } else {
      _dx = 0;
    }
    setState(() {});
  }

  void onHorizontalDragStart(DragStartDetails d) {
    _isAnimating = true;
  }

  List<Widget> getAnimatingCardStack(
    double maxWidth,
    int i,
    double spaceIntervals,
    bool isForward,
    double progress,
  ) {
    double scale = 1 - (i * 0.1);
    double targetScaleForward = 1 - (i * 0.1) + (isForward ? -0.1 : 0.1);
    double cuvedProgress = Curves.linear.transform(progress);
    double scaleForward = scale + (targetScaleForward - scale) * cuvedProgress;
    double targeScaleReverse = 1 - (i * 0.1) + (isForward ? 0.1 : -0.1);
    double scaleReverse = scale + (targeScaleReverse - scale) * cuvedProgress;

    double position = (maxWidth - widget.width) / 2 + ((i) * spaceIntervals);
    double targetPositionForward = (maxWidth - widget.width) / 2 +
        ((i) * spaceIntervals) +
        (isForward ? spaceIntervals : -spaceIntervals);
    double positionForward =
        position + (targetPositionForward - position) * cuvedProgress;
    double targetPositionReverse = (maxWidth - widget.width) / 2 +
        ((i) * spaceIntervals) +
        (isForward ? -spaceIntervals : spaceIntervals);
    double positionReverse =
        position + (targetPositionReverse - position) * cuvedProgress;

    double currentOpacity = i >= numberOfLevels ? 0 : 1;
    double targetOpacityForward =
        i + (isForward ? 1 : -1) >= numberOfLevels ? 0 : 1;
    double opacityForward =
        currentOpacity + (targetOpacityForward - currentOpacity) * progress;
    double targetOpacityReverse =
        i + (isForward ? -1 : 1) >= numberOfLevels ? 0 : 1;
    double opacityReverse =
        currentOpacity + (targetOpacityReverse - currentOpacity) * progress;
    Widget forwardWidget = Positioned(
      left: positionForward,
      child: Opacity(
        opacity: opacityForward,
        child: Transform.scale(
          scale: scaleForward,
          child: Container(
            height: widget.height,
            width: widget.width,
            color: Colors.transparent,
            child: _widgetWithLevels[i][1],
          ),
        ),
      ),
    );

    Widget reverseWidget = Positioned(
      right: positionReverse,
      child: Opacity(
        opacity: opacityReverse,
        child: Transform.scale(
          scale: scaleReverse,
          child: Container(
            height: widget.height,
            width: widget.width,
            color: Colors.transparent,
            child: _widgetWithLevels[i][0],
          ),
        ),
      ),
    );
    if (isForward) {
      return [forwardWidget, reverseWidget];
    } else {
      return [reverseWidget, forwardWidget];
    }
  }
}
