import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/match_record.dart';
import '../../viewmodels/auth_view_model.dart';
import '../../viewmodels/match_history_view_model.dart';
import '../../viewmodels/tournament_view_model.dart';
import '../app_drawer.dart';
import '../tournaments/tournament_detail_view.dart';

class MyCareerView extends StatelessWidget {
  const MyCareerView({super.key});

  Future<void> _editName(BuildContext context) async {
    final auth = context.read<AuthViewModel>();
    final controller =
        TextEditingController(text: auth.hasName ? auth.displayName : '');
    final formKey = GlobalKey<FormState>();

    final newName = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit name'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            autofocus: true,
            maxLength: 30,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Display name',
              border: OutlineInputBorder(),
            ),
            validator: (value) => (value == null || value.trim().isEmpty)
                ? 'Enter a name'
                : null,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(dialogContext, controller.text.trim());
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (newName == null || !context.mounted) return;
    auth.updateName(newName);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Name updated')),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 24, 4, 8),
      child: Text(title, style: Theme.of(context).textTheme.titleLarge),
    );
  }

  Widget _emptyNote(String message) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();
    final tournamentVm = context.watch<TournamentViewModel>();
    final history = context.watch<MatchHistoryViewModel>();

    final tournaments = tournamentVm.tournaments;
    final matches = history.records;
    final completed = tournaments.where((t) => t.isComplete).length;

    return Scaffold(
      appBar: AppBar(title: const Text('My Career')),
      drawer: const AppDrawer(),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _HeaderCard(
            name: auth.displayName,
            onEditName: () => _editName(context),
            matches: matches.length,
            tournaments: tournaments.length,
            completed: completed,
          ),
          _sectionTitle(context, 'My tournaments'),
          if (tournaments.isEmpty)
            _emptyNote('Create a tournament from the Tournaments tab.')
          else
            for (final t in tournaments)
              Card(
                child: ListTile(
                  leading: CircleAvatar(
                    child: Icon(t.isComplete
                        ? Icons.emoji_events
                        : Icons.sports_cricket),
                  ),
                  title: Text(
                    t.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(t.isComplete
                      ? 'Champion: ${tournamentVm.standings(t).first.team}'
                      : '${t.playedCount}/${t.fixtures.length} matches played'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TournamentDetailView(tournamentId: t.id),
                    ),
                  ),
                ),
              ),
          _sectionTitle(context, 'Matches played'),
          if (matches.isEmpty)
            _emptyNote('Matches you score will appear here.')
          else
            for (final m in matches) _MatchRecordCard(record: m),
        ],
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final String name;
  final VoidCallback onEditName;
  final int matches;
  final int tournaments;
  final int completed;

  const _HeaderCard({
    required this.name,
    required this.onEditName,
    required this.matches,
    required this.tournaments,
    required this.completed,
  });

  Widget _stat(String value, String label, TextStyle base) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: base.copyWith(fontSize: 28, fontWeight: FontWeight.bold)),
          Text(label, style: base.copyWith(fontSize: 13)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final base = TextStyle(color: colors.onPrimary);
    final initial = name.isEmpty ? '?' : name[0].toUpperCase();

    return Card(
      color: colors.primary,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: colors.onPrimary,
              child: Text(
                initial,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: colors.primary,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(width: 40), // balances the edit button
                Flexible(
                  child: Text(
                    name,
                    overflow: TextOverflow.ellipsis,
                    style: base.copyWith(
                        fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  tooltip: 'Edit name',
                  onPressed: onEditName,
                  icon: Icon(Icons.edit, size: 20, color: colors.onPrimary),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _stat('$matches', 'Matches', base),
                _stat('$tournaments', 'Tournaments', base),
                _stat('$completed', 'Completed', base),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MatchRecordCard extends StatelessWidget {
  final MatchRecord record;
  const _MatchRecordCard({required this.record});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final colors = Theme.of(context).colorScheme;
    final d = record.playedOn;
    final isFriendly = record.tournamentName == null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Flexible(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isFriendly
                          ? Colors.blue.shade50
                          : Colors.amber.shade100,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      record.tournamentName ?? 'Friendly',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text('${d.day}/${d.month}/${d.year}', style: text.bodySmall),
              ],
            ),
            const SizedBox(height: 10),
            Text(record.firstSummary, style: text.titleMedium),
            Text(record.secondSummary, style: text.titleMedium),
            const SizedBox(height: 8),
            Text(
              record.outcome.result,
              style: text.bodyMedium?.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}