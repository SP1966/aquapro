import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';
import 'job_detail_screen.dart';
import 'customers_screen.dart';
import 'schedule_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  late List<ServiceJob> _jobs;

  @override
  void initState() {
    super.initState();
    _jobs = sampleJobs;
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      _DashboardTab(jobs: _jobs, onJobUpdated: _onJobUpdated),
      ScheduleScreen(jobs: _jobs, onJobUpdated: _onJobUpdated),
      CustomersScreen(customers: sampleCustomers),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppTheme.border)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.dashboard_outlined),
                activeIcon: Icon(Icons.dashboard),
                label: 'Today'),
            BottomNavigationBarItem(
                icon: Icon(Icons.calendar_today_outlined),
                activeIcon: Icon(Icons.calendar_today),
                label: 'Schedule'),
            BottomNavigationBarItem(
                icon: Icon(Icons.people_outline),
                activeIcon: Icon(Icons.people),
                label: 'Customers'),
          ],
        ),
      ),
    );
  }

  void _onJobUpdated(ServiceJob updated) {
    setState(() {
      final idx = _jobs.indexWhere((j) => j.id == updated.id);
      if (idx != -1) _jobs[idx] = updated;
    });
  }
}

// ─── Dashboard Tab ────────────────────────────────────────────────────────────

class _DashboardTab extends StatelessWidget {
  final List<ServiceJob> jobs;
  final void Function(ServiceJob) onJobUpdated;

  const _DashboardTab({required this.jobs, required this.onJobUpdated});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final todayJobs = jobs
        .where((j) =>
            j.scheduledDate.year == now.year &&
            j.scheduledDate.month == now.month &&
            j.scheduledDate.day == now.day)
        .toList();

    final completed = todayJobs.where((j) => j.status == JobStatus.completed).length;
    final inProgress = todayJobs.where((j) => j.status == JobStatus.inProgress).length;
    final remaining = todayJobs.where((j) => j.status == JobStatus.scheduled).length;

    final greeting = _greeting();

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(greeting,
                                style: const TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 13)),
                            const SizedBox(height: 2),
                            const Text('AquaPro Dashboard',
                                style: TextStyle(
                                    color: AppTheme.textPrimary,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.5)),
                          ],
                        ),
                      ),
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppTheme.primary, AppTheme.primaryDark],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Text('JD',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Stats row
                  Row(
                    children: [
                      Expanded(
                        child: StatBadge(
                          label: 'Completed',
                          value: '$completed',
                          color: AppTheme.success,
                          icon: Icons.check_circle_outline,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: StatBadge(
                          label: 'Remaining',
                          value: '$remaining',
                          color: AppTheme.primary,
                          icon: Icons.pending_outlined,
                        ),
                      ),
                    ],
                  ),

                  if (inProgress > 0) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.primary.withOpacity(0.12),
                            AppTheme.accent.withOpacity(0.06),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppTheme.primary.withOpacity(0.25)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppTheme.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '$inProgress job${inProgress > 1 ? 's' : ''} in progress',
                            style: const TextStyle(
                                color: AppTheme.primary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),
                  SectionHeader(title: "Today's Jobs"),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final job = todayJobs[index];
                  return JobCard(
                    job: job,
                    onTap: () => _openJob(context, job),
                  );
                },
                childCount: todayJobs.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),
        ],
      ),
    );
  }

  void _openJob(BuildContext context, ServiceJob job) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => JobDetailScreen(
          job: job,
          onJobUpdated: onJobUpdated,
        ),
      ),
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning 👋';
    if (h < 17) return 'Good afternoon 👋';
    return 'Good evening 👋';
  }
}
