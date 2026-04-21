import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';
import 'job_detail_screen.dart';

class ScheduleScreen extends StatefulWidget {
  final List<ServiceJob> jobs;
  final void Function(ServiceJob) onJobUpdated;

  const ScheduleScreen(
      {super.key, required this.jobs, required this.onJobUpdated});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  DateTime _selectedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final dayJobs = widget.jobs
        .where((j) =>
            j.scheduledDate.year == _selectedDay.year &&
            j.scheduledDate.month == _selectedDay.month &&
            j.scheduledDate.day == _selectedDay.day)
        .toList();

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Schedule',
                      style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5)),
                  const SizedBox(height: 16),
                  _WeekStrip(
                    selectedDay: _selectedDay,
                    onDaySelected: (d) => setState(() => _selectedDay = d),
                    jobs: widget.jobs,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Text(
                        _formatDate(_selectedDay),
                        style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 16),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text('${dayJobs.length} jobs',
                            style: const TextStyle(
                                color: AppTheme.primary,
                                fontSize: 11,
                                fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
          if (dayJobs.isEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 60),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.event_available_outlined,
                          color: AppTheme.textMuted, size: 48),
                      SizedBox(height: 12),
                      Text('No jobs scheduled',
                          style: TextStyle(
                              color: AppTheme.textSecondary, fontSize: 15)),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final job = dayJobs[index];
                    return JobCard(
                      job: job,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => JobDetailScreen(
                            job: job,
                            onJobUpdated: widget.onJobUpdated,
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: dayJobs.length,
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    if (dt.year == now.year &&
        dt.month == now.month &&
        dt.day == now.day) return 'Today';
    final tomorrow = now.add(const Duration(days: 1));
    if (dt.year == tomorrow.year &&
        dt.month == tomorrow.month &&
        dt.day == tomorrow.day) return 'Tomorrow';

    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return '${days[dt.weekday % 7]}, ${months[dt.month]} ${dt.day}';
  }
}

class _WeekStrip extends StatelessWidget {
  final DateTime selectedDay;
  final void Function(DateTime) onDaySelected;
  final List<ServiceJob> jobs;

  const _WeekStrip({
    required this.selectedDay,
    required this.onDaySelected,
    required this.jobs,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final startOfWeek =
        now.subtract(Duration(days: now.weekday % 7));
    final days = List.generate(
        7, (i) => startOfWeek.add(Duration(days: i)));

    const dayLabels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

    return Row(
      children: List.generate(7, (i) {
        final day = days[i];
        final isSelected = day.year == selectedDay.year &&
            day.month == selectedDay.month &&
            day.day == selectedDay.day;
        final isToday = day.year == now.year &&
            day.month == now.month &&
            day.day == now.day;

        final hasJobs = jobs.any((j) =>
            j.scheduledDate.year == day.year &&
            j.scheduledDate.month == day.month &&
            j.scheduledDate.day == day.day);

        return Expanded(
          child: GestureDetector(
            onTap: () => onDaySelected(day),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.primary
                    : AppTheme.surfaceLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isToday && !isSelected
                      ? AppTheme.primary.withOpacity(0.4)
                      : Colors.transparent,
                ),
              ),
              child: Column(
                children: [
                  Text(dayLabels[i],
                      style: TextStyle(
                          color: isSelected
                              ? Colors.white.withOpacity(0.7)
                              : AppTheme.textMuted,
                          fontSize: 10)),
                  const SizedBox(height: 4),
                  Text('${day.day}',
                      style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : AppTheme.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 15)),
                  const SizedBox(height: 4),
                  if (hasJobs)
                    Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white
                            : AppTheme.primary,
                        shape: BoxShape.circle,
                      ),
                    )
                  else
                    const SizedBox(height: 4),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
