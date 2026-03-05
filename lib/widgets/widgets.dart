import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

// ─── SECTION LABEL ────────────────────────────────────────────────────────────
class SectionLabel extends StatelessWidget {
  final String text;
  const SectionLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(
          text.toUpperCase(),
          style: GoogleFonts.syne(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppTheme.textSecondary,
            letterSpacing: 1.2,
          ),
        ),
      );
}

// ─── TM INPUT FIELD ───────────────────────────────────────────────────────────
class TmInput extends StatelessWidget {
  final String label;
  final String? prefix;
  final String? suffix;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final String? hint;
  final int maxLines;
  final void Function(String)? onChanged;

  const TmInput({
    super.key,
    required this.label,
    required this.controller,
    this.prefix,
    this.suffix,
    this.keyboardType = TextInputType.number,
    this.hint,
    this.maxLines = 1,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 13, color: AppTheme.textSecondary)),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            keyboardType:
                maxLines > 1 ? TextInputType.multiline : keyboardType,
            maxLines: maxLines,
            onChanged: onChanged,
            style: const TextStyle(fontSize: 16, color: AppTheme.textPrimary),
            decoration: InputDecoration(
              hintText: hint,
              prefixText: prefix != null ? '$prefix  ' : null,
              prefixStyle: const TextStyle(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 13),
              suffixText: suffix,
              suffixStyle: const TextStyle(
                  color: AppTheme.textSecondary, fontSize: 13),
            ),
          ),
          const SizedBox(height: 14),
        ],
      );
}

// ─── TM CARD ─────────────────────────────────────────────────────────────────
class TmCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final Color? borderColor;

  const TmCard(
      {super.key, required this.child, this.padding, this.borderColor});

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: padding ?? const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: borderColor ?? AppTheme.border, width: 1),
        ),
        child: child,
      );
}

// ─── RESULT ROW ───────────────────────────────────────────────────────────────
class ResultRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isTotal;
  final Color? valueColor;

  const ResultRow({
    super.key,
    required this.label,
    required this.value,
    this.isTotal = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.syne(
                fontSize: isTotal ? 15 : 13,
                fontWeight:
                    isTotal ? FontWeight.w700 : FontWeight.w400,
                color:
                    isTotal ? AppTheme.textPrimary : AppTheme.textSecondary,
              ),
            ),
            Text(
              value,
              style: GoogleFonts.syne(
                fontSize: isTotal ? 22 : 15,
                fontWeight: FontWeight.w700,
                color: valueColor ??
                    (isTotal ? AppTheme.primary : AppTheme.textPrimary),
              ),
            ),
          ],
        ),
      );
}

// ─── PRIMARY BUTTON ───────────────────────────────────────────────────────────
class TmButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool secondary;
  final bool danger;
  final IconData? icon;

  const TmButton({
    super.key,
    required this.label,
    this.onPressed,
    this.secondary = false,
    this.danger = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    Color bg = secondary
        ? AppTheme.surface2
        : danger
            ? AppTheme.danger
            : AppTheme.primary;
    Color fg = (secondary) ? AppTheme.textPrimary : Colors.black;
    if (danger) fg = Colors.white;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: icon != null ? Icon(icon, size: 20) : const SizedBox.shrink(),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          side: secondary
              ? const BorderSide(color: AppTheme.border)
              : BorderSide.none,
          textStyle:
              GoogleFonts.syne(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

// ─── INFO CHIP ────────────────────────────────────────────────────────────────
class InfoChip extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const InfoChip(
      {super.key, required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: (color ?? AppTheme.primary).withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: (color ?? AppTheme.primary).withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(
                    fontSize: 10,
                    color: color ?? AppTheme.primary,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 3),
            Text(value,
                style: GoogleFonts.syne(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: color ?? AppTheme.primary)),
          ],
        ),
      );
}
