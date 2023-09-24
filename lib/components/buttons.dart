import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:weighty/utils/constants.dart';
import 'package:weighty/utils/utils.dart';

class WeiButton extends StatelessWidget {
  final VoidCallback? onTap;
  final String? svgUrl;
  final String title;
  final double? borderRadius;
  final Color? color;
  final IconData? icon;
  final double? height;
  final double? width;
  const WeiButton(
      {super.key,
      this.onTap,
      required this.title,
      this.svgUrl,
      this.borderRadius,
      this.height,
      this.width,
      this.color,
      this.icon});

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () {
          if (onTap != null) {
            onTap!();
          }
        },
        splashColor: color ?? Theme.of(context).primaryColor.withOpacity(0.1),
        overlayColor: MaterialStateColor.resolveWith((states) {
          if (states.contains(MaterialState.pressed)) {
            return color?.withOpacity(0.2) ??
                Theme.of(context).primaryColor.withOpacity(0.2);
          }
          return Colors.transparent;
        }),
        child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                  borderRadius ?? SizeConstrains.DEFAULT_BORDER_RADIUS),
              border:
                  Border.all(color: color ?? Theme.of(context).primaryColor)),
          constraints: BoxConstraints(
              minHeight:
                  height ?? calculateHeight(factor: 0.05, context: context),
              minWidth: width ?? calculateWidth(factor: 0.1, context: context)),
          padding:
              EdgeInsets.symmetric(horizontal: SizeConstrains.DEFAULT_PADDING),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: svgUrl != null
                ? MainAxisAlignment.spaceBetween
                : MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (svgUrl != null)
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: SizeConstrains.DEFAULT_PADDING - 12),
                  child: SvgPicture.asset(svgUrl!,
                      width: calculateWidth(factor: 0.04, context: context),
                      height: calculateHeight(factor: 0.04, context: context)),
                ),
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: SizeConstrains.DEFAULT_PADDING),
                child: Text(
                  title,
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: calculateFontSize(factor: 20, context: context),
                      color: color ?? Theme.of(context).primaryColor),
                ),
              ),
              if (icon != null)
                Icon(
                  icon,
                  size: calculateFontSize(factor: 20, context: context),
                  color: color ?? Theme.of(context).primaryColor,
                )
            ],
          ),
        ));
  }
}

class FilterButton extends StatelessWidget {
  final String title;
  final bool isSelected;
  final int index;
  final Function(int) onTap;
  const FilterButton(
      {super.key,
      required this.title,
      required this.onTap,
      required this.isSelected,
      required this.index});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(index),
      borderRadius:
          BorderRadius.circular(SizeConstrains.DEFAULT_BORDER_RADIUS * 5),
      splashColor: Theme.of(context).primaryColor.withOpacity(0.1),
      overlayColor: MaterialStateColor.resolveWith((states) {
        if (states.contains(MaterialState.pressed)) {
          return Theme.of(context).primaryColor.withOpacity(0.2);
        }
        return Colors.transparent;
      }),
      child: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                  SizeConstrains.DEFAULT_BORDER_RADIUS * 5),
              border: isSelected
                  ? null
                  : Border.all(width: 1, color: Theme.of(context).primaryColor),
              color: isSelected
                  ? Theme.of(context).primaryColor
                  : Colors.transparent),
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: SizeConstrains.DEFAULT_PADDING,
                vertical: SizeConstrains.DEFAULT_PADDING),
            child: Text(title,
                style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : Theme.of(context).primaryColor,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal)),
          )),
    );
  }
}

class ReportFilterButtons extends StatefulWidget {
  final int count;
  final List<String> title;
  final int selectedIndex;
  final Function(String) onSelect;
  const ReportFilterButtons(
      {super.key,
      required this.count,
      required this.title,
      this.selectedIndex = 0,
      required this.onSelect});

  @override
  State<ReportFilterButtons> createState() => _ReportFilterButtonsState();
}

class _ReportFilterButtonsState extends State<ReportFilterButtons> {
  late RxInt _selectedIndex;
  @override
  void initState() {
    _selectedIndex = widget.selectedIndex.obs;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: calculateHeight(factor: 0.2, context: context),
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          for (int i = 0; i < widget.count; i++)
            Obx(() => FilterButton(
                title: widget.title[i],
                onTap: (index) {
                  _selectedIndex.value = index;
                  widget.onSelect(widget.title[index]);
                },
                isSelected: _selectedIndex.value == i,
                index: i))
        ],
      ),
    );
  }
}
