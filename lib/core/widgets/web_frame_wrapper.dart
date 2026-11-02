import 'package:flutter/material.dart';

/// Wraps the application on web in an authentic mobile phone mockup,
/// ensuring the interface always maintains mobile ergonomics.
///
/// On wide displays (>= 1040px), a desktop showcase panel is shown alongside
/// the phone mockup. On smaller displays, the phone mockup is centered.
class WebFrameWrapper extends StatelessWidget {
  final Widget child;

  const WebFrameWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate responsive phone frame dimensions to fit comfortably.
        final double phoneHeight =
            (constraints.maxHeight - 76).clamp(560.0, 860.0);
        final double maxAllowedWidth =
            (constraints.maxWidth - 32).clamp(280.0, 420.0);
        final double phoneWidth =
            (phoneHeight * 9 / 19.5).clamp(280.0, maxAllowedWidth);

        return Scaffold(
          backgroundColor: const Color(0xFF0B1120),
          body: Stack(
            children: [
              // Subtle background ambient glows
              Positioned(
                top: -120,
                right: -80,
                child: Container(
                  width: 500,
                  height: 500,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF1D4ED8).withValues(alpha: 0.18),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -100,
                left: -60,
                child: Container(
                  width: 450,
                  height: 450,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF3B82F6).withValues(alpha: 0.12),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // Main layout
              Column(
                children: [
                  const _TopBar(),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      child: constraints.maxWidth >= 1040
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Flexible(
                                  flex: 5,
                                  child: ConstrainedBox(
                                    constraints:
                                        const BoxConstraints(maxWidth: 480),
                                    child: const _ShowcaseInfoPanel(),
                                  ),
                                ),
                                const SizedBox(width: 48),
                                Flexible(
                                  flex: 5,
                                  child: Center(
                                    child: _PhoneChassis(
                                      width: phoneWidth,
                                      height: phoneHeight,
                                      child: child,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Center(
                              child: _PhoneChassis(
                                width: phoneWidth,
                                height: phoneHeight,
                                child: child,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

/// The top header showing the official app icon and "Rent Tracking" only.
class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0x1AFFFFFF), width: 1),
        ),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              'assets/icon/icon.png',
              width: 32,
              height: 32,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Rent Tracking',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }
}

/// The left showcase panel explaining Rent Tracking on desktop viewports.
class _ShowcaseInfoPanel extends StatelessWidget {
  const _ShowcaseInfoPanel();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Rent Tracking',
            style: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w800,
              height: 1.18,
              letterSpacing: -0.7,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Track monthly rent collections, manage dues, and keep a clean record of all tenant payments.',
            style: TextStyle(
              fontSize: 14.5,
              color: Color(0xFF94A3B8),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          _featureCard(
            icon: Icons.payments_rounded,
            title: 'Monthly Rent Dues',
            desc: 'Automatically computes dues based on each tenant\'s agreed rent amount and due day.',
          ),
          const SizedBox(height: 10),
          _featureCard(
            icon: Icons.receipt_long_rounded,
            title: 'Payment Records & Receipts',
            desc: 'Log full, partial, and advance payments with exact payment dates.',
          ),
          const SizedBox(height: 10),
          _featureCard(
            icon: Icons.pending_actions_rounded,
            title: 'Real-Time Due Statuses',
            desc: 'Instantly see who has paid, who has pending dues, and who is overdue.',
          ),
          const SizedBox(height: 10),
          _featureCard(
            icon: Icons.history_rounded,
            title: 'Rent History & Changes',
            desc: 'Track rent increases or decreases over time with full historical snapshots.',
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0x1F1D4ED8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0x3B3B82F6)),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.lightbulb_outline_rounded,
                  color: Color(0xFF93C5FD),
                  size: 20,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Try interacting with the phone on the right — record a payment, view dues, or test settings!',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: Color(0xFFBFDBFE),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _featureCard({
    required IconData icon,
    required String title,
    required String desc,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0x991E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x1AFFFFFF)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: const Color(0x331D4ED8),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFF60A5FA), size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF94A3B8),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The realistic mobile smartphone chassis that hosts the live Flutter app.
class _PhoneChassis extends StatelessWidget {
  final double width;
  final double height;
  final Widget child;

  const _PhoneChassis({
    required this.width,
    required this.height,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(46),
        border: Border.all(color: const Color(0xFF1E293B), width: 10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 40,
            offset: const Offset(0, 16),
          ),
          BoxShadow(
            color: const Color(0xFF1D4ED8).withValues(alpha: 0.15),
            blurRadius: 60,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(34),
        child: Stack(
          children: [
            // The Live Flutter App with customized MediaQuery
            Positioned.fill(
              child: MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  size: Size(width, height),
                  padding: const EdgeInsets.only(top: 44, bottom: 20),
                  viewPadding: const EdgeInsets.only(top: 44, bottom: 20),
                  textScaler: const TextScaler.linear(1.15),
                ),
                child: child,
              ),
            ),

            // Top Status Bar & Camera Pill (Dynamic Island)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 44,
              child: IgnorePointer(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '9:41',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      Container(
                        width: 82,
                        height: 22,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.signal_cellular_4_bar,
                            size: 13,
                            color: Color(0xFF0F172A),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            Icons.wifi,
                            size: 13,
                            color: Color(0xFF0F172A),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            Icons.battery_full,
                            size: 15,
                            color: Color(0xFF0F172A),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom Home Indicator Bar
            Positioned(
              bottom: 6,
              left: 0,
              right: 0,
              child: IgnorePointer(
                child: Center(
                  child: Container(
                    width: 128,
                    height: 4.5,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
