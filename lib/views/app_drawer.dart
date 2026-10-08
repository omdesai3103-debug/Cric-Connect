import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_view_model.dart';
import 'auth/login_view.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  void _comingSoon(BuildContext context, String title) {
    final messenger = ScaffoldMessenger.of(context);
    Navigator.pop(context);
    messenger.showSnackBar(SnackBar(content: Text('$title – coming soon')));
  }

  void _openLogin(BuildContext context) {
    final navigator = Navigator.of(context);
    navigator.pop(); // close the drawer
    navigator.push(MaterialPageRoute(builder: (_) => const LoginView()));
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
    Navigator.pop(context); // close the drawer
  }

  Widget _item(BuildContext context, IconData icon, String title) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () => _comingSoon(context, title),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final auth = context.watch<AuthViewModel>();

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
                    auth.isLoggedIn ? auth.userName! : 'Guest Player',
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
          _item(context, Icons.person_outline, 'My profile'),
          _item(context, Icons.sports_cricket_outlined, 'My matches'),
          _item(context, Icons.groups_outlined, 'My teams'),
          _item(context, Icons.emoji_events_outlined, 'My tournaments'),
          const Divider(),
          _item(context, Icons.settings_outlined, 'Settings'),
          _item(context, Icons.help_outline, 'Help & feedback'),
          _item(context, Icons.info_outline, 'About Cric-Connect'),
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