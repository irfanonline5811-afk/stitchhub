import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Modern UI Components for StitchHub
/// Reusable widgets with modern design patterns

/// Modern Card with gradient shadow and rounded corners
class ModernCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double? borderRadius;
  final List<BoxShadow>? customShadow;

  const ModernCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.onTap,
    this.onLongPress,
    this.borderRadius,
    this.customShadow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.only(bottom: AppTheme.spacing16),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppTheme.white,
        borderRadius:
            BorderRadius.circular(borderRadius ?? AppTheme.radiusLarge),
        boxShadow: customShadow ?? AppTheme.shadow2,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius:
              BorderRadius.circular(borderRadius ?? AppTheme.radiusLarge),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(AppTheme.spacing20),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Modern Button with gradient and animations
class ModernButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;
  final bool isOutlined;
  final double? width;
  final double? height;

  const ModernButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.isOutlined = false,
    this.width,
    this.height,
  });

  @override
  State<ModernButton> createState() => _ModernButtonState();
}

class _ModernButtonState extends State<ModernButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        if (widget.onPressed != null && !widget.isLoading) {
          widget.onPressed!();
        }
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: widget.width,
          height: widget.height ?? 56,
          decoration: BoxDecoration(
            gradient: widget.isOutlined
                ? null
                : LinearGradient(
                    colors: widget.backgroundColor != null
                        ? [
                            widget.backgroundColor!,
                            widget.backgroundColor!.withValues(alpha: 0.8)
                          ]
                        : [AppTheme.primaryGreen, AppTheme.primaryGreenLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            border: widget.isOutlined
                ? Border.all(
                    color: widget.backgroundColor ?? AppTheme.primaryGreen,
                    width: 2,
                  )
                : null,
            boxShadow: widget.isOutlined
                ? null
                : [
                    BoxShadow(
                      color: (widget.backgroundColor ?? AppTheme.primaryGreen)
                          .withValues(alpha: 0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                      spreadRadius: 2,
                    ),
                  ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.isLoading ? null : widget.onPressed,
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.icon != null) ...[
                      Icon(
                        widget.icon,
                        color: widget.isOutlined
                            ? (widget.backgroundColor ?? AppTheme.primaryGreen)
                            : (widget.textColor ?? AppTheme.white),
                        size: 22,
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      widget.text,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                        color: widget.isOutlined
                            ? (widget.backgroundColor ?? AppTheme.primaryGreen)
                            : (widget.textColor ?? AppTheme.white),
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

/// Modern Text Field with enhanced styling
class ModernTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final IconData? prefixIcon;
  final Widget? prefixWidget;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final int? maxLines;
  final bool enabled;
  final String? initialValue;

  const ModernTextField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.prefixIcon,
    this.prefixWidget,
    this.suffixIcon,
    this.onSuffixTap,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.onChanged,
    this.maxLines = 1,
    this.enabled = true,
    this.initialValue,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        boxShadow: AppTheme.shadow1,
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator: validator,
        onChanged: onChanged,
        maxLines: maxLines,
        enabled: enabled,
        initialValue: initialValue,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          prefixIcon: prefixWidget ?? (prefixIcon != null
              ? Container(
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(prefixIcon, color: AppTheme.gray700, size: 20),
                )
              : null),
          suffixIcon: suffixIcon != null
              ? IconButton(
                  icon: Icon(suffixIcon, color: AppTheme.gray600),
                  onPressed: onSuffixTap,
                )
              : null,
          filled: true,
          fillColor: AppTheme.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            borderSide: const BorderSide(color: AppTheme.gray200, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            borderSide:
                const BorderSide(color: AppTheme.primaryGreen, width: 2.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            borderSide: const BorderSide(color: AppTheme.error, width: 1.5),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            borderSide: const BorderSide(color: AppTheme.error, width: 2.5),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
      ),
    );
  }
}

/// Modern Filter Chip
class ModernFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onSelected;
  final IconData? icon;

  const ModernFilterChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onSelected,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSelected,
      child: AnimatedContainer(
        duration: AppTheme.durationFast,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [AppTheme.primaryGreen, AppTheme.primaryGreenLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : AppTheme.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusRound),
          border: Border.all(
            color: isSelected ? AppTheme.primaryGreen : AppTheme.gray300,
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primaryGreen.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : AppTheme.shadow1,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 18,
                color: isSelected ? AppTheme.white : AppTheme.gray700,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? AppTheme.white : AppTheme.gray700,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Modern Status Badge
class ModernStatusBadge extends StatelessWidget {
  final String status;
  final Color? backgroundColor;
  final Color? textColor;

  const ModernStatusBadge({
    super.key,
    required this.status,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppTheme.primaryGreen.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusRound),
        border: Border.all(
          color:
              (backgroundColor ?? AppTheme.primaryGreen).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: textColor ?? AppTheme.primaryGreen,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

/// Modern Empty State Widget
class ModernEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? buttonText;
  final VoidCallback? onButtonTap;

  const ModernEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.buttonText,
    this.onButtonTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacing32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppTheme.spacing24),
              decoration: const BoxDecoration(
                color: AppTheme.gray100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 64,
                color: AppTheme.gray500,
              ),
            ),
            const SizedBox(height: AppTheme.spacing24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.gray900,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: AppTheme.spacing8),
              Text(
                subtitle!,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.gray600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (buttonText != null && onButtonTap != null) ...[
              const SizedBox(height: AppTheme.spacing24),
              ModernButton(
                text: buttonText!,
                onPressed: onButtonTap,
                icon: Icons.add,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Modern Section Header
class ModernSectionHeader extends StatelessWidget {
  final String title;
  final String? actionText;
  final VoidCallback? onActionTap;
  final IconData? actionIcon;

  const ModernSectionHeader({
    super.key,
    required this.title,
    this.actionText,
    this.onActionTap,
    this.actionIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacing16, vertical: AppTheme.spacing12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
              color: AppTheme.gray900,
            ),
          ),
          if (actionText != null && onActionTap != null)
            TextButton.icon(
              onPressed: onActionTap,
              icon: Icon(
                actionIcon ?? Icons.arrow_forward_rounded,
                size: 18,
              ),
              label: Text(actionText!),
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.primaryGreen,
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Animated Fade In Widget
class AnimatedFadeIn extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final double delay;

  const AnimatedFadeIn({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 600),
    this.curve = Curves.easeOut,
    this.delay = 0,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

/// Modern Search Bar
class ModernSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String? hintText;
  final void Function(String)? onChanged;
  final VoidCallback? onClear;

  const ModernSearchBar({
    super.key,
    required this.controller,
    this.hintText,
    this.onChanged,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        boxShadow: AppTheme.shadow1,
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hintText ?? 'Search...',
          hintStyle: const TextStyle(
            color: AppTheme.gray500,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.search, color: AppTheme.gray700, size: 20),
          ),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: AppTheme.gray600),
                  onPressed: () {
                    controller.clear();
                    onClear?.call();
                  },
                )
              : null,
          filled: true,
          fillColor: AppTheme.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            borderSide: const BorderSide(color: AppTheme.gray200, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            borderSide:
                const BorderSide(color: AppTheme.primaryGreen, width: 2.5),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
      ),
    );
  }
}

