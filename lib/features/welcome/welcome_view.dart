import 'package:flutter/material.dart';
import 'package:tenant_tracker/core/di/app_dependencies.dart';
import 'package:tenant_tracker/core/widgets/big_button.dart';
import 'package:tenant_tracker/core/widgets/obx_value.dart';
import 'package:tenant_tracker/features/welcome/welcome_view_model.dart';
import 'package:tenant_tracker/l10n/app_localizations.dart';

class WelcomeView extends StatefulWidget {
  /// Runs when the user finishes or skips the guide.
  final Future<void> Function() onFinish;

  const WelcomeView({super.key, required this.onFinish});

  @override
  State<WelcomeView> createState() => _WelcomeViewState();
}

class _WelcomeViewState extends State<WelcomeView> {
  late final WelcomeViewModel ctrl;

  @override
  void initState() {
    super.initState();
    ctrl = WelcomeViewModel(onFinish: widget.onFinish);
  }

  @override
  void dispose() {
    ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: AppDependencies.instance.appViewModel.toggleLanguage,
            child: Text(
              l.langToggle,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ObxValue<int>(
            listenable: ctrl.page,
            builder: (page) {
              final title = [l.w1T, l.w2T, l.w3T][page];
              final body = [l.w1B, l.w2B, l.w3B][page];
              final last = page == WelcomeViewModel.pageCount - 1;
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('${page + 1}', style: const TextStyle(fontSize: 84)),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    body,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      height: 1.5,
                      color: Color(0xFF5B6675),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var i = 0; i < WelcomeViewModel.pageCount; i++)
                        Container(
                          width: 12,
                          height: 12,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: i == page
                                ? const Color(0xFF1D4ED8)
                                : const Color(0xFFC3CCD7),
                          ),
                        ),
                    ],
                  ),
                  BigButton(
                    label: last ? l.start : l.next,
                    onPressed: last ? ctrl.finish : ctrl.next,
                  ),
                  if (!last)
                    BigButton(
                      label: l.skip,
                      kind: BigButtonKind.secondary,
                      onPressed: ctrl.finish,
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
