import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:vaclocks/Segmented.dart';
import 'package:vaclocks/core/l10n/app_localizations.dart';
import 'package:vaclocks/core/l10n/locale_cubit.dart';
import 'package:vaclocks/features/alarms/presentation/bloc/alarm_bloc.dart';
import 'package:vaclocks/features/world_clock/presentation/bloc/world_clock_bloc.dart';

class VaxpHeader extends StatelessWidget {
  const VaxpHeader({required this.index, required this.onChanged});
  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
                      const SizedBox(width: 4),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () {
            if (index == 0) {
              context.read<WorldClockBloc>().add(
                WorldClockAddRequested(context: context),
              );
            } else if (index == 1) {
              context.read<AlarmBloc>().add(AlarmAddRequested());
            }
          },
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: const Color.fromARGB(24, 255, 255, 255), // لون الحد
                width: 1.0, // سمك الحد
              ),
              borderRadius: BorderRadius.circular(
                8,
              ), // نصف قطر الزوايا (اختياري)
            ),
            child: Segmented(
              current: index,
              onChanged: onChanged,
              items: [
                (Icons.public, AppLocalizations.of(context).world),
                (Icons.alarm, AppLocalizations.of(context).alarms),
                (Icons.timer_outlined, AppLocalizations.of(context).stopwatch),
                (Icons.hourglass_bottom, AppLocalizations.of(context).timer),
              ],
            ),
          ),
        ),
    
        const SizedBox(width: 8),
        _IconButton(icon: Icons.menu, onPressed: () async {
          final info = await PackageInfo.fromPlatform();
          // ignore: use_build_context_synchronously
          showDialog(
            context: context,
            builder: (_) {
              final l10n = AppLocalizations.of(context);
              return AlertDialog(
                title: Text('${l10n.appName} • ${info.version}'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(l10n.language),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        FilledButton(
                          onPressed: () => context.read<LocaleCubit>().setEnglish(),
                          child: Text(l10n.english),
                        ),
                        FilledButton.tonal(
                          onPressed: () => context.read<LocaleCubit>().setArabic(),
                          child: Text(l10n.arabic),
                        ),
    
                      ],
    
                    )
                  ],
                ),
              );
            },
          );
        }),

      ],
    );
  }
}



class _IconButton extends StatelessWidget {
  const _IconButton({required this.icon, required this.onPressed});
  final IconData icon;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(icon, size: 20),
        ),
      ),
    );
  }
}