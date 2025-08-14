import 'package:flutter/material.dart';

class NoisyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final double elevation;
  final Color? backgroundColor;

  const NoisyAppBar({
    Key? key,
    this.title,
    this.actions,
    this.leading,
    this.centerTitle = false,
    this.elevation = 0,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Gradient background: transparent (top) to black (bottom)
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black,
              ],
            ),
          ),
          height: preferredSize.height,
          width: double.infinity,
        ),
        Container(
          color: backgroundColor ?? Theme.of(context).appBarTheme.backgroundColor,
          height: preferredSize.height,
          width: double.infinity,
        ),
        Image.asset(
          'assets/images/noise_texture.png',
          fit: BoxFit.cover,
          height: preferredSize.height,
          width: double.infinity,
          color: null, // No color blend, full effect
        ),
        AppBar(
          title: title,
          actions: actions,
          leading: leading,
          centerTitle: centerTitle,
          elevation: elevation,
          backgroundColor: Colors.transparent,
        ),
      ],
    );
  }
}
