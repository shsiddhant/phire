/*
  SPDX-FileCopyrightText: 2026 Siddhant Sharma <sharmasiddhant@proton.me>

  SPDX-License-Identifier: GPL-3.0-or-later
*/

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  static const String _devGitHubUrl = 'https://github.com/shsiddhant';
  static const String _sourceCodeUrl = 'https://github.com/shsiddhant/phire';
  static const String _issuesUrl = 'https://github.com/shsiddhant/phire/issues';
  static const String _licenseUrl =
      'https://github.com/shsiddhant/phire/blob/main/LICENSE';
  static const String _donateUrl = 'https://ko-fi.com/shsiddhant';

  static const String _description =
      'A conversation reader that reimagines your chat history into a book-like structured reading experience.';

  static Future<void> _openEmail(BuildContext context) async {
    const email = 'sharmasiddhant@proton.me';
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=${Uri.encodeComponent('Phire')}',
    );

    try {
      final launched = await launchUrl(emailUri);
      if (!launched) throw Exception('Launch failed');
    } catch (_) {
      await Clipboard.setData(const ClipboardData(text: email));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No email app found. Email address copied to clipboard',
            ),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  static Future<void> _openUrl(BuildContext context, String urlString) async {
    final Uri url = Uri.parse(urlString);
    try {
      final launched = await launchUrl(url, mode: .externalApplication);
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not open $urlString')));
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No app found to open $urlString')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.inversePrimary,
        title: Text('About'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: const [
            _TitleCard(),
            SizedBox(height: 24),
            _AboutActionsGrid(),
            SizedBox(height: 24),
            _CreditsAndLicenseCard(),
          ],
        ),
      ),
    );
  }
}

class _TitleCard extends StatelessWidget {
  const _TitleCard();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: EdgeInsetsGeometry.symmetric(vertical: 8, horizontal: 12),
        child: Column(
          crossAxisAlignment: .start,
          children: [
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    'ফ',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                const Column(
                  crossAxisAlignment: .start,
                  children: [
                    Text(
                      'Phire',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text('Version 1.0.0'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              AboutPage._description,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AboutActionsGrid extends StatelessWidget {
  const _AboutActionsGrid();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.6,
          children: [
            _AboutAction(
              icon: Icons.code,
              title: 'Source Code',
              onTap: () =>
                  AboutPage._openUrl(context, AboutPage._sourceCodeUrl),
            ),
            _AboutAction(
              icon: Icons.bug_report,
              title: 'Issues',
              onTap: () => AboutPage._openUrl(context, AboutPage._issuesUrl),
            ),
            _AboutAction(
              icon: Icons.favorite_outline,
              title: 'Donate',
              onTap: () => AboutPage._openUrl(context, AboutPage._donateUrl),
            ),
            _AboutAction(
              icon: Icons.gavel,
              title: 'Third-party Licenses',
              onTap: () => showLicensePage(
                context: context,
                applicationName: 'Phire',
                applicationVersion: '1.0.0',
                applicationLegalese: '© 2026 Siddhant Sharma\nGPL-3.0-or-later',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AboutAction extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _AboutAction({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 26, color: colorScheme.primary),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreditsAndLicenseCard extends StatelessWidget {
  const _CreditsAndLicenseCard();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
            child: Text(
              'Authors & License',
              style: textTheme.labelLarge?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Siddhant Sharma'),
            subtitle: const Text('Developer'),
            trailing: IconButton(
              icon: const Icon(Icons.mail_outline),
              tooltip: 'Email Author',
              onPressed: () => AboutPage._openEmail(context),
            ),
            onTap: () => AboutPage._openUrl(context, AboutPage._devGitHubUrl),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          ListTile(
            leading: const Icon(Icons.balance),
            title: const Text('GNU General Public License v3.0+'),
            onTap: () => AboutPage._openUrl(context, AboutPage._licenseUrl),
          ),
        ],
      ),
    );
  }
}
