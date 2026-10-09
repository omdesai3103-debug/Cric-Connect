import 'package:flutter/material.dart';
import '../../models/cricket_match.dart';
import 'match_detail_view.dart';

class MatchCard extends StatelessWidget {
  final CricketMatch match;
  const MatchCard({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final isLive = match.status == MatchStatus.live;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      clipBehavior: Clip.antiAlias, // keeps the tap ripple inside the card
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => MatchDetailView(match: match)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _StatusBadge(status: match.status),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      match.venue,
                      style: text.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(Icons.chevron_right, size: 20),
                ],
              ),
              const SizedBox(height: 12),
              _TeamRow(name: match.teamA, score: match.scoreA ?? ''),
              const SizedBox(height: 6),
              _TeamRow(
                name: match.teamB,
                score: match.scoreB ?? (isLive ? 'Yet to bat' : ''),
              ),
              const SizedBox(height: 12),
              Text(
                match.status == MatchStatus.upcoming
                    ? _formatStart(match.startTime)
                    : (match.summary ?? ''),
                style: text.bodyMedium?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatStart(DateTime time) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour < 12 ? 'am' : 'pm';
    return 'Starts ${days[time.weekday - 1]} ${time.day}/${time.month}, '
        '$hour:$minute $period';
  }
}

class _TeamRow extends StatelessWidget {
  final String name;
  final String score;
  const _TeamRow({required this.name, required this.score});

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.titleMedium;
    return Row(
      children: [
        Expanded(
          child: Text(name, style: style, overflow: TextOverflow.ellipsis),
        ),
        Text(score, style: style?.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final MatchStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, background, foreground) = switch (status) {
      MatchStatus.live => ('● LIVE', Colors.red.shade700, Colors.white),
      MatchStatus.upcoming =>
        ('UPCOMING', Colors.blue.shade50, Colors.blue.shade900),
      MatchStatus.completed =>
        ('RESULT', Colors.grey.shade200, Colors.grey.shade800),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: foreground,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}