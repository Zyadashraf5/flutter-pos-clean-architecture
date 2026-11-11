import 'package:flutter/material.dart';

import '../../core/constants/app_spacing.dart';
import '../../core/theme/app_colors.dart';

/// SaaS-style item card: elevation, soft shadow, rounded, hover, blue accent, badges.
class ItemCard extends StatefulWidget {
  const ItemCard({
    super.key,
    required this.child,
    this.onTap,
    this.elevation = 2,
    this.padding,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double elevation;
  final EdgeInsetsGeometry? padding;

  @override
  State<ItemCard> createState() => _ItemCardState();
}

class _ItemCardState extends State<ItemCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final padding = widget.padding ?? const EdgeInsets.symmetric(
      horizontal: AppSpacing.md,
      vertical: AppSpacing.sm,
    );
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color ?? AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: _hover ? 0.08 : 0.04),
              blurRadius: _hover ? 12 : 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: padding,
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}

/// Badge pill for quantity, tax, etc.
class ItemBadge extends StatelessWidget {
  const ItemBadge({
    super.key,
    required this.label,
    this.color,
    this.isAccent = false,
  });

  final String label;
  final Color? color;
  final bool isAccent;

  @override
  Widget build(BuildContext context) {
    final c = color ?? (isAccent ? AppColors.primary : AppColors.onSurfaceVariant);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: (isAccent ? AppColors.primary : AppColors.surfaceVariant).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: c.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: c,
        ),
      ),
    );
  }
}

/// Price highlight text (blue, bold).
class PriceHighlight extends StatelessWidget {
  const PriceHighlight({
    super.key,
    required this.value,
    this.fontSize = 16,
  });

  final String value;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Text(
      value,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
      ),
    );
  }
}
