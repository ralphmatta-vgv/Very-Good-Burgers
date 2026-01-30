import 'package:flutter/material.dart';

import '../utils/theme.dart';

class PunchCard extends StatelessWidget {
  const PunchCard({
    super.key,
    required this.filledCount,
    this.total = 10,
    this.showNumbers = true,
    this.size = 40,
    this.useBurgerIcon = false,
  });

  final int filledCount;
  final int total;
  final bool showNumbers;
  final double size;
  final bool useBurgerIcon;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    const perRow = 5;
    for (var r = 0; r < (total / perRow).ceil(); r++) {
      final rowChildren = <Widget>[];
      for (var c = 0; c < perRow; c++) {
        final index = r * perRow + c;
        if (index >= total) break;
        final isFilled = index < filledCount;
        final isTenth = index == total - 1;
        rowChildren.add(_PunchCircle(
          index: index + 1,
          isFilled: isFilled,
          isTenth: isTenth,
          showNumber: showNumbers,
          size: size,
          useBurgerIcon: useBurgerIcon,
        ));
        if (c < perRow - 1 && index + 1 < total) {
          rowChildren.add(SizedBox(width: size * 0.3));
        }
      }
      rows.add(Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: rowChildren,
      ));
      if (r < (total / perRow).ceil() - 1) {
        rows.add(SizedBox(height: size * 0.3));
      }
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: rows,
    );
  }
}

class _PunchCircle extends StatelessWidget {
  const _PunchCircle({
    required this.index,
    required this.isFilled,
    required this.isTenth,
    required this.showNumber,
    required this.size,
    this.useBurgerIcon = false,
  });

  final int index;
  final bool isFilled;
  final bool isTenth;
  final bool showNumber;
  final double size;
  final bool useBurgerIcon;

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Widget? child;
    if (isTenth && !useBurgerIcon) {
      bgColor = isFilled ? AppColors.gold : AppColors.gray200;
      child = Text(
        isFilled ? '🎁' : (showNumber ? '$index' : ''),
        style: TextStyle(
          fontSize: size * 0.4,
          color: isFilled ? AppColors.navy : AppColors.gray500,
          fontWeight: FontWeight.bold,
        ),
      );
    } else if (useBurgerIcon) {
      bgColor = Colors.transparent;
      child = Opacity(
        opacity: isFilled ? 1.0 : 0.35,
        child: Text(
          '🍔',
          style: TextStyle(fontSize: size * 0.55),
        ),
      );
    } else {
      bgColor = isFilled ? AppColors.primary : Colors.transparent;
      child = isFilled
          ? Icon(Icons.check, color: AppColors.white, size: size * 0.5)
          : (showNumber
              ? Text(
                  '$index',
                  style: TextStyle(
                    fontSize: size * 0.35,
                    color: AppColors.gray500,
                    fontWeight: FontWeight.w500,
                  ),
                )
              : null);
    }

    final Border? border = useBurgerIcon
        ? Border.all(color: AppColors.gray300, width: 2, strokeAlign: BorderSide.strokeAlignInside)
        : (isFilled && !isTenth
            ? null
            : Border.all(
                color: isTenth ? AppColors.gold : AppColors.gray300,
                width: isFilled ? 0 : 2,
                strokeAlign: BorderSide.strokeAlignInside,
              ));

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        border: border,
        boxShadow: isFilled && !useBurgerIcon
            ? [
                BoxShadow(
                  color: (isTenth ? AppColors.gold : AppColors.primary).withValues(alpha: 0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: child != null
          ? Center(child: child)
          : null,
    );
  }
}
