import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_view_model.dart';
import '../viewmodels/tab_navigation.dart';
import 'auth/login_view.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  void _goToTab(BuildContext context, int index) {
    final tabs = context.read<TabNavigation>();
    Navigator.pop(context); // close the drawer
    tabs.go(index);
  }

  void _openLogin(BuildContext context) {
    final navigator = Navigator.of(context);
    navigator.pop();
    navigator.push(MaterialPageRoute(builder: (_) => const LoginView()));
  }

  void _showHelp(BuildContext context) {
    final navigator = Navigator.of(context);
    navigator.pop();
    showDialog(
      context: navigator.context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('How to use Cric-Connect'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _HelpItem(
                icon: Icons.sports_cricket,
                title: 'Score a match',
                text: 'Score tab → Start new match. Set teams, players and '
                    'the toss in 4 quick steps.',
              ),
              _HelpItem(
                icon: Icons.touch_app,
                title: 'Record each ball',
                text: 'Tap one button per ball. Grey = runs, green = 4 or 6, '
                    'orange = wide or no-ball, red = wicket.',
              ),
              _HelpItem(
                icon: Icons.undo,
                title: 'Made a mistake?',
                text: 'Tap UNDO to remove the last ball. You can undo as '
                    'many balls as you need.',
              ),
              _HelpItem(
                icon: Icons.emoji_events,
                title: 'Run a tournament',
                text: 'Tournaments tab → Create. Tap Start on any fixture '
                    'and the points table updates itself.',
              ),
              _HelpItem(
                icon: Icons.insights,
                title: 'My Career',
                text: 'See your tournaments and every match you have scored.',
              ),
            ],
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  void _showAbout(BuildContext context) {
    final navigator = Navigator.of(context);
    navigator.pop();
    showAboutDialog(
      context: navigator.context,
      applicationName: 'Cric-Connect',
      applicationVersion: '0.2.0 (prototype)',
      applicationIcon: const Icon(Icons.sports_cricket, size: 40),
      children: const [
        Text(
          'Simple, free scoring and tournaments for grassroots cricket. '
          'No club or registration needed.',
        ),
        SizedBox(height: 12),
        Text(
          'COMP826 Mobile Systems Development, Milestone 2 prototype. '
          'Auckland University of Technology.',
        ),
      ],
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('Your matches stay saved on this phone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Log out'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    context.read<AuthViewModel>().logout();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final auth = context.watch<AuthViewModel>();
    final current = context.watch<TabNavigation>().index;

    Widget tabItem(IconData icon, String title, int index) {
      return ListTile(
        leading: Icon(icon),
        title: Text(title),
        selected: current == index,
        onTap: () => _goToTab(context, index),
      );
    }

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: colors.primary),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: colors.onPrimary,
                  child: Icon(Icons.person, size: 32, color: colors.primary),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    auth.displayName,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colors.onPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          tabItem(Icons.home_outlined, 'Home', TabNavigation.home),
          tabItem(Icons.sports_cricket_outlined, 'Score a match',
              TabNavigation.score),
          tabItem(Icons.emoji_events_outlined, 'My tournaments',
              TabNavigation.tournaments),
          tabItem(Icons.insights_outlined, 'My Career', TabNavigation.career),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('How to use Cric-Connect'),
            onTap: () => _showHelp(context),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About'),
            onTap: () => _showAbout(context),
          ),
          const Divider(),
          if (auth.isLoggedIn)
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Log out'),
              onTap: () => _confirmLogout(context),
            )
          else
            ListTile(
              leading: const Icon(Icons.login),
              title: const Text('Log in / Sign up'),
              onTap: () => _openLogin(context),
            ),
        ],
      ),
    );
  }
}

class _HelpItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;
  const _HelpItem({
    required this.icon,
    required this.title,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(text),
              ],
            ),
          ),
        ],
      ),
    );
  }
}