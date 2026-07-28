import 'package:flutter/material.dart';
import 'dart:ui' as ui;

// Color Theme for Zen Mart Pro
class ZenMartColors {
  // Primary Colors
  static const Color darkBg = Color(0xFF0f1d3a);
  static const Color darkBgSecondary = Color(0xFF1a2d4a);
  static const Color tealPrimary = Color(0xFF2b8fb7);
  static const Color tealAccent = Color(0xFF5dcaa5);
  static const Color greenAccent = Color(0xFFa8d86f);
  
  // Supporting Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFb0b8c8);
  static const Color textMuted = Color(0xFF7a8394);
  
  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [tealPrimary, tealAccent],
  );
  
  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [tealAccent, greenAccent],
  );
}

// Primary Button - Solid Teal Gradient
class ZenMartPrimaryButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isLoading;
  final double height;
  final double? width;
  final TextStyle? textStyle;

  const ZenMartPrimaryButton({
    Key? key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.height = 56,
    this.width,
    this.textStyle,
  }) : super(key: key);

  @override
  State<ZenMartPrimaryButton> createState() => _ZenMartPrimaryButtonState();
}

class _ZenMartPrimaryButtonState extends State<ZenMartPrimaryButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _animationController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.isLoading ? null : _onTapDown,
      onTapUp: widget.isLoading ? null : _onTapUp,
      onTapCancel: _animationController.reverse,
      onTap: widget.isLoading ? null : widget.onPressed,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          height: widget.height,
          width: widget.width,
          decoration: BoxDecoration(
            gradient: ZenMartColors.primaryGradient,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: ZenMartColors.tealAccent.withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Center(
            child: widget.isLoading
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(ZenMartColors.white),
                    ),
                  )
                : Text(
                    widget.label,
                    style: widget.textStyle ??
                        const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: ZenMartColors.white,
                          letterSpacing: 0.5,
                        ),
                  ),
          ),
        ),
      ),
    );
  }
}

// Secondary Button - Outlined
class ZenMartSecondaryButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final double height;
  final double? width;
  final TextStyle? textStyle;

  const ZenMartSecondaryButton({
    Key? key,
    required this.label,
    required this.onPressed,
    this.height = 56,
    this.width,
    this.textStyle,
  }) : super(key: key);

  @override
  State<ZenMartSecondaryButton> createState() => _ZenMartSecondaryButtonState();
}

class _ZenMartSecondaryButtonState extends State<ZenMartSecondaryButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _animationController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _animationController.reverse,
      onTap: widget.onPressed,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          height: widget.height,
          width: widget.width,
          decoration: BoxDecoration(
            color: Colors.transparent,
            border: Border.all(
              color: ZenMartColors.tealAccent,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              widget.label,
              style: widget.textStyle ??
                  const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: ZenMartColors.tealAccent,
                    letterSpacing: 0.5,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}

// Glossy/Frosted Glass Button - Modern Look
class ZenMartGlossyButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final double height;
  final double? width;
  final TextStyle? textStyle;
  final bool isLoading;

  const ZenMartGlossyButton({
    Key? key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.height = 56,
    this.width,
    this.textStyle,
    this.isLoading = false,
  }) : super(key: key);

  @override
  State<ZenMartGlossyButton> createState() => _ZenMartGlossyButtonState();
}

class _ZenMartGlossyButtonState extends State<ZenMartGlossyButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _opacityAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _animationController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.isLoading ? null : _onTapDown,
      onTapUp: widget.isLoading ? null : _onTapUp,
      onTapCancel: _animationController.reverse,
      onTap: widget.isLoading ? null : widget.onPressed,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              height: widget.height,
              width: widget.width,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    ZenMartColors.tealAccent.withOpacity(0.25),
                    ZenMartColors.greenAccent.withOpacity(0.15),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: ZenMartColors.white.withOpacity(0.2),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: ZenMartColors.tealAccent.withOpacity(0.2),
                    blurRadius: 16,
                    spreadRadius: 2,
                    offset: const Offset(0, 8),
                  ),
                  // Inner highlight for glossy effect
                  BoxShadow(
                    color: ZenMartColors.white.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Center(
                child: widget.isLoading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            ZenMartColors.white,
                          ),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.icon != null) ...[
                            Icon(
                              widget.icon,
                              color: ZenMartColors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            widget.label,
                            style: widget.textStyle ??
                                const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: ZenMartColors.white,
                                  letterSpacing: 0.3,
                                ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Text Button - Minimal
class ZenMartTextButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final TextStyle? textStyle;

  const ZenMartTextButton({
    Key? key,
    required this.label,
    required this.onPressed,
    this.textStyle,
  }) : super(key: key);

  @override
  State<ZenMartTextButton> createState() => _ZenMartTextButtonState();
}

class _ZenMartTextButtonState extends State<ZenMartTextButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _colorAnimation = ColorTween(
      begin: ZenMartColors.tealAccent,
      end: ZenMartColors.greenAccent,
    ).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _animationController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _animationController.reverse,
      onTap: widget.onPressed,
      child: AnimatedBuilder(
        animation: _colorAnimation,
        builder: (context, child) {
          return Text(
            widget.label,
            style: widget.textStyle ??
                TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _colorAnimation.value,
                  letterSpacing: 0.3,
                ),
          );
        },
      ),
    );
  }
}

// Icon Button - Circular
class ZenMartIconButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final double size;
  final Color? backgroundColor;
  final Color? iconColor;

  const ZenMartIconButton({
    Key? key,
    required this.icon,
    required this.onPressed,
    this.size = 56,
    this.backgroundColor,
    this.iconColor,
  }) : super(key: key);

  @override
  State<ZenMartIconButton> createState() => _ZenMartIconButtonState();
}

class _ZenMartIconButtonState extends State<ZenMartIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _animationController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _animationController.reverse,
      onTap: widget.onPressed,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            gradient: ZenMartColors.primaryGradient,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: ZenMartColors.tealAccent.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Icon(
              widget.icon,
              color: widget.iconColor ?? ZenMartColors.white,
              size: widget.size * 0.4,
            ),
          ),
        ),
      ),
    );
  }
}

// Accent Button - Green Gradient
class ZenMartAccentButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final double height;
  final double? width;
  final TextStyle? textStyle;
  final bool isLoading;

  const ZenMartAccentButton({
    Key? key,
    required this.label,
    required this.onPressed,
    this.height = 56,
    this.width,
    this.textStyle,
    this.isLoading = false,
  }) : super(key: key);

  @override
  State<ZenMartAccentButton> createState() => _ZenMartAccentButtonState();
}

class _ZenMartAccentButtonState extends State<ZenMartAccentButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _animationController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.isLoading ? null : _onTapDown,
      onTapUp: widget.isLoading ? null : _onTapUp,
      onTapCancel: _animationController.reverse,
      onTap: widget.isLoading ? null : widget.onPressed,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          height: widget.height,
          width: widget.width,
          decoration: BoxDecoration(
            gradient: ZenMartColors.accentGradient,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: ZenMartColors.greenAccent.withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Center(
            child: widget.isLoading
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(ZenMartColors.white),
                    ),
                  )
                : Text(
                    widget.label,
                    style: widget.textStyle ??
                        const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: ZenMartColors.white,
                          letterSpacing: 0.5,
                        ),
                  ),
          ),
        ),
      ),
    );
  }
}

// ============================================
// 🎯 ZEN MART APP BAR - Use this everywhere!
// ============================================
class ZenMartAppBar extends AppBar {
  ZenMartAppBar({
    required String title,
    Key? key,
    List<Widget>? actions,
    bool centerTitle = true,
    double elevation = 0,
    PreferredSizeWidget? bottom,
    VoidCallback? onBackPressed,
    bool showBackButton = true,
  }) : super(
    key: key,
    title: Text(title),
    backgroundColor: ZenMartColors.tealPrimary,
    foregroundColor: ZenMartColors.white,
    elevation: elevation,
    centerTitle: centerTitle,
    actions: actions,
    bottom: bottom,
    automaticallyImplyLeading: showBackButton,
    leading: showBackButton ? null : const SizedBox.shrink(),
    titleTextStyle: const TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: ZenMartColors.white,
      letterSpacing: 0.5,
    ),
  );
}