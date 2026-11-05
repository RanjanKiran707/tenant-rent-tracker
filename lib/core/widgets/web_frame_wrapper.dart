import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tenant_tracker/core/utils/url_launcher_helper.dart';

/// Direct download URL for the Android APK asset from GitHub releases.
const String apkDownloadUrl =
    'https://github.com/RanjanKiran707/tenant-rent-tracker/releases/download/v2.1.0/rent-book-v2.1.0.apk';

/// GitHub release page detailing release notes and assets.
const String apkReleasePageUrl =
    'https://github.com/RanjanKiran707/tenant-rent-tracker/releases/tag/v2.1.0';

/// Kept for backwards compatibility. Points to the direct APK download.
const String apkReleaseUrl = apkDownloadUrl;

Future<void> launchApkDownload({String? url}) async {
  await safeLaunchUrl(url ?? apkDownloadUrl);
}

/// Wraps the application on web in an authentic mobile phone mockup,
/// ensuring the interface always maintains mobile ergonomics.
///
/// On mobile devices or narrow viewports (< 768px):
/// Displays a dedicated landing page directing users to download the Android
/// APK release from GitHub with key features from the desktop showcase,
/// along with an option to preview the web edition.
///
/// On desktop displays:
/// - Wide (>= 1040px): A desktop showcase panel is shown alongside the phone mockup.
/// - Medium (768px - 1039px): The phone mockup is centered.
class WebFrameWrapper extends StatefulWidget {
  final Widget child;
  final bool forceWeb;

  const WebFrameWrapper({
    super.key,
    required this.child,
    this.forceWeb = kIsWeb,
  });

  @override
  State<WebFrameWrapper> createState() => _WebFrameWrapperState();
}

class _WebFrameWrapperState extends State<WebFrameWrapper> {
  bool _showWebPreviewOnMobile = false;

  @override
  Widget build(BuildContext context) {
    if (!widget.forceWeb) return widget.child;

    return LayoutBuilder(
      builder: (context, constraints) {
        // When viewed on a mobile device (Android/iOS browser) or mobile-sized screen,
        // show the APK download landing page instead of running the mobile web app directly.
        final bool isMobileDevice =
            defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS;
        final bool isMobileScreen = constraints.maxWidth < 768;

        if (isMobileDevice || isMobileScreen) {
          if (_showWebPreviewOnMobile) {
            return Column(
              children: [
                _WebPreviewTopBanner(
                  onBackToLanding: () {
                    setState(() {
                      _showWebPreviewOnMobile = false;
                    });
                  },
                ),
                Expanded(child: widget.child),
              ],
            );
          }

          return _MobileApkLandingView(
            onPreviewWeb: () {
              setState(() {
                _showWebPreviewOnMobile = true;
              });
            },
          );
        }

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
                                      child: widget.child,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Center(
                              child: _PhoneChassis(
                                width: phoneWidth,
                                height: phoneHeight,
                                child: widget.child,
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

/// The top banner shown on mobile web if the user switches to web preview mode.
class _WebPreviewTopBanner extends StatelessWidget {
  final VoidCallback onBackToLanding;

  const _WebPreviewTopBanner({required this.onBackToLanding});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF0F172A),
      child: SafeArea(
        bottom: false,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Color(0x1AFFFFFF), width: 1),
            ),
          ),
          child: Row(
            children: [
              InkWell(
                onTap: onBackToLanding,
                borderRadius: BorderRadius.circular(6),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.arrow_back_rounded,
                        size: 16,
                        color: Color(0xFF93C5FD),
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Download Page',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF93C5FD),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: launchApkDownload,
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFF1D4ED8),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                icon: const Icon(Icons.android_rounded, size: 14),
                label: const Text(
                  'Get APK',
                  style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Dedicated landing page displayed when the web app is accessed on mobile viewports.
class _MobileApkLandingView extends StatelessWidget {
  final VoidCallback onPreviewWeb;

  const _MobileApkLandingView({required this.onPreviewWeb});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1120),
      body: Stack(
        children: [
          // Background ambient glows
          Positioned(
            top: -120,
            right: -80,
            child: Container(
              width: 360,
              height: 360,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF1D4ED8).withValues(alpha: 0.22),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -60,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF3B82F6).withValues(alpha: 0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const _MobileTopBar(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // App Icon + Title & Subtitle Hero
                        Center(
                          child: Column(
                            children: [
                              Container(
                                width: 76,
                                height: 76,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF1D4ED8)
                                          .withValues(alpha: 0.4),
                                      blurRadius: 28,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(18.5),
                                  child: Image.asset(
                                    'assets/icon/icon.png',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Rent Tracking',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  letterSpacing: -0.6,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Track monthly rent collections, manage dues, and keep a clean record of all tenant payments.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14.5,
                                  color: Color(0xFF94A3B8),
                                  height: 1.45,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Prominent APK Download Card
                        const _ApkDownloadCard(),

                        const SizedBox(height: 28),

                        // Section Heading
                        const Text(
                          'KEY FEATURES',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                            color: Color(0xFF60A5FA),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Feature Cards
                        const _FeatureCard(
                          icon: Icons.payments_rounded,
                          title: 'Monthly Rent Dues',
                          desc:
                              'Automatically computes dues based on each tenant\'s agreed rent amount and due day.',
                        ),
                        const SizedBox(height: 10),
                        const _FeatureCard(
                          icon: Icons.receipt_long_rounded,
                          title: 'Payment Records & Receipts',
                          desc:
                              'Log full, partial, and advance payments with exact payment dates.',
                        ),
                        const SizedBox(height: 10),
                        const _FeatureCard(
                          icon: Icons.pending_actions_rounded,
                          title: 'Real-Time Due Statuses',
                          desc:
                              'Instantly see who has paid, who has pending dues, and who is overdue.',
                        ),
                        const SizedBox(height: 10),
                        const _FeatureCard(
                          icon: Icons.history_rounded,
                          title: 'Rent History & Changes',
                          desc:
                              'Track rent increases or decreases over time with full historical snapshots.',
                        ),

                        const SizedBox(height: 22),

                        // Desktop Demo note
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0x1F1D4ED8),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0x3B3B82F6),
                            ),
                          ),
                          child: const Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.computer_rounded,
                                color: Color(0xFF93C5FD),
                                size: 20,
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'For the full interactive live demo, open this link on a desktop or laptop browser.',
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

                        const SizedBox(height: 18),

                        // Option to preview web edition
                        Center(
                          child: TextButton.icon(
                            onPressed: onPreviewWeb,
                            icon: const Icon(
                              Icons.visibility_outlined,
                              size: 16,
                              color: Color(0xFF94A3B8),
                            ),
                            label: const Text(
                              'Or preview web edition in browser',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF94A3B8),
                                decoration: TextDecoration.underline,
                                decorationColor: Color(0xFF64748B),
                              ),
                            ),
                          ),
                        ),
                      ],
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
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0x263B82F6),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0x4D60A5FA)),
            ),
            child: const Text(
              'v2.1.0',
              style: TextStyle(
                color: Color(0xFF93C5FD),
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Mobile-specific top bar.
class _MobileTopBar extends StatelessWidget {
  const _MobileTopBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
              width: 28,
              height: 28,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'Rent Tracking',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0x263B82F6),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0x4D60A5FA)),
            ),
            child: const Text(
              'v2.1.0',
              style: TextStyle(
                color: Color(0xFF93C5FD),
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
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
          const SizedBox(height: 18),
          const _ApkDownloadCard(),
          const SizedBox(height: 20),
          const _FeatureCard(
            icon: Icons.payments_rounded,
            title: 'Monthly Rent Dues',
            desc:
                'Automatically computes dues based on each tenant\'s agreed rent amount and due day.',
          ),
          const SizedBox(height: 10),
          const _FeatureCard(
            icon: Icons.receipt_long_rounded,
            title: 'Payment Records & Receipts',
            desc:
                'Log full, partial, and advance payments with exact payment dates.',
          ),
          const SizedBox(height: 10),
          const _FeatureCard(
            icon: Icons.pending_actions_rounded,
            title: 'Real-Time Due Statuses',
            desc:
                'Instantly see who has paid, who has pending dues, and who is overdue.',
          ),
          const SizedBox(height: 10),
          const _FeatureCard(
            icon: Icons.history_rounded,
            title: 'Rent History & Changes',
            desc:
                'Track rent increases or decreases over time with full historical snapshots.',
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
}

/// Download button card redirecting to GitHub release APK.
class _ApkDownloadCard extends StatelessWidget {
  const _ApkDownloadCard();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          color: const Color(0xFF1D4ED8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF60A5FA).withValues(alpha: 0.4),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1D4ED8).withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: InkWell(
          onTap: launchApkDownload,
          borderRadius: BorderRadius.circular(12),
          hoverColor: Colors.white.withValues(alpha: 0.08),
          splashColor: Colors.white.withValues(alpha: 0.16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.android_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Download Android APK',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: -0.2,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Release v2.1.0 • Direct GitHub download',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFFBFDBFE),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.open_in_new_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Feature display card.
class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
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

/// The realistic mobile smartphone chassis that hosts the live Flutter app on desktop.
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
