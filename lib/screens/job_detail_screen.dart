import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/widgets.dart';
import 'chemical_log_screen.dart';

class JobDetailScreen extends StatefulWidget {
  final ServiceJob job;
  final void Function(ServiceJob) onJobUpdated;

  const JobDetailScreen({
    super.key,
    required this.job,
    required this.onJobUpdated,
  });

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  late ServiceJob _job;

  @override
  void initState() {
    super.initState();
    _job = widget.job;
    _tabs = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_job.customerName),
        actions: [
          if (_job.status != JobStatus.completed)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: _job.status == JobStatus.scheduled
                  ? TextButton(
                      onPressed: _startJob,
                      child: const Text('Start Job',
                          style: TextStyle(
                              color: AppTheme.primary,
                              fontWeight: FontWeight.w700)),
                    )
                  : TextButton(
                      onPressed: _completeJob,
                      child: const Text('Complete',
                          style: TextStyle(
                              color: AppTheme.success,
                              fontWeight: FontWeight.w700)),
                    ),
            ),
        ],
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: AppTheme.primary,
          indicatorSize: TabBarIndicatorSize.label,
          labelColor: AppTheme.primary,
          unselectedLabelColor: AppTheme.textMuted,
          labelStyle: const TextStyle(
              fontWeight: FontWeight.w600, fontSize: 13),
          tabs: const [
            Tab(text: 'Checklist'),
            Tab(text: 'Chemicals'),
            Tab(text: 'Photos'),
          ],
        ),
      ),
      body: Column(
        children: [
          _JobHeader(job: _job),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [
                _ChecklistTab(job: _job, onToggle: _toggleChecklist),
                _ChemicalsTab(
                    job: _job,
                    onLog: () async {
                      final result = await Navigator.push<ChemicalReading>(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ChemicalLogScreen(existingReading: _job.chemicalReading),
                        ),
                      );
                      if (result != null) {
                        setState(() => _job.chemicalReading = result);
                        widget.onJobUpdated(_job);
                      }
                    }),
                _PhotosTab(job: _job),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _startJob() {
    setState(() => _job.status = JobStatus.inProgress);
    widget.onJobUpdated(_job);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Job started'),
        backgroundColor: AppTheme.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _completeJob() {
    final required =
        _job.checklist.where((i) => i.required && !i.isChecked).length;
    if (required > 0) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: AppTheme.surface,
          title: const Text('Required items incomplete',
              style: TextStyle(color: AppTheme.textPrimary)),
          content: Text(
            '$required required checklist item${required > 1 ? 's are' : ' is'} not checked.',
            style: const TextStyle(color: AppTheme.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Go Back'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _forceComplete();
              },
              child: const Text('Complete Anyway',
                  style: TextStyle(color: AppTheme.warning)),
            ),
          ],
        ),
      );
      return;
    }
    _forceComplete();
  }

  void _forceComplete() {
    setState(() => _job.status = JobStatus.completed);
    widget.onJobUpdated(_job);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✓ Job completed!'),
        backgroundColor: AppTheme.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _toggleChecklist(String itemId) {
    setState(() {
      final item = _job.checklist.firstWhere((i) => i.id == itemId);
      item.isChecked = !item.isChecked;
    });
    widget.onJobUpdated(_job);
  }
}

// ─── Job Header ───────────────────────────────────────────────────────────────

class _JobHeader extends StatelessWidget {
  final ServiceJob job;
  const _JobHeader({required this.job});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        border: Border(bottom: BorderSide(color: AppTheme.border)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.pool, color: AppTheme.primary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(job.serviceType,
                    style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w700)),
                Text(job.address,
                    style: const TextStyle(
                        color: AppTheme.textSecondary, fontSize: 12),
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: job.status.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(job.status.label,
                style: TextStyle(
                    color: job.status.color,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

// ─── Checklist Tab ────────────────────────────────────────────────────────────

class _ChecklistTab extends StatelessWidget {
  final ServiceJob job;
  final void Function(String) onToggle;

  const _ChecklistTab({required this.job, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final checkedCount = job.checklist.where((i) => i.isChecked).length;
    final progress = job.checklist.isEmpty
        ? 0.0
        : checkedCount / job.checklist.length;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Progress header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Progress',
                      style: TextStyle(
                          color: AppTheme.textSecondary, fontSize: 12)),
                  Text('$checkedCount / ${job.checklist.length}',
                      style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: AppTheme.border,
                  valueColor: AlwaysStoppedAnimation(
                    progress >= 1.0 ? AppTheme.success : AppTheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Checklist items
        ...job.checklist.map((item) => _ChecklistTile(
              item: item,
              onToggle: () => onToggle(item.id),
            )),
      ],
    );
  }
}

class _ChecklistTile extends StatelessWidget {
  final ChecklistItem item;
  final VoidCallback onToggle;

  const _ChecklistTile({required this.item, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: item.isChecked
              ? AppTheme.success.withOpacity(0.06)
              : AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: item.isChecked
                ? AppTheme.success.withOpacity(0.3)
                : AppTheme.border,
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: item.isChecked ? AppTheme.success : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: item.isChecked
                      ? AppTheme.success
                      : AppTheme.textMuted,
                  width: 1.5,
                ),
              ),
              child: item.isChecked
                  ? const Icon(Icons.check, color: Colors.white, size: 14)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                item.label,
                style: TextStyle(
                  color: item.isChecked
                      ? AppTheme.textMuted
                      : AppTheme.textPrimary,
                  decoration:
                      item.isChecked ? TextDecoration.lineThrough : null,
                  fontSize: 14,
                ),
              ),
            ),
            if (item.required && !item.isChecked)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text('Required',
                    style: TextStyle(
                        color: AppTheme.warning, fontSize: 9)),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Chemicals Tab ────────────────────────────────────────────────────────────

class _ChemicalsTab extends StatelessWidget {
  final ServiceJob job;
  final VoidCallback onLog;

  const _ChemicalsTab({required this.job, required this.onLog});

  @override
  Widget build(BuildContext context) {
    final reading = job.chemicalReading;

    if (reading == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.science_outlined,
                    color: AppTheme.primary, size: 40),
              ),
              const SizedBox(height: 20),
              const Text('No reading logged yet',
                  style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 17,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              const Text('Log chemical readings to track water quality',
                  style: TextStyle(
                      color: AppTheme.textSecondary, fontSize: 13),
                  textAlign: TextAlign.center),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onLog,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Log Chemicals'),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Score card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.primary.withOpacity(0.12),
                AppTheme.primaryDark.withOpacity(0.06),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(
                      value: reading.overallScore / 100,
                      strokeWidth: 5,
                      backgroundColor: AppTheme.border,
                      valueColor: AlwaysStoppedAnimation(
                        reading.overallScore >= 80
                            ? AppTheme.success
                            : reading.overallScore >= 60
                                ? AppTheme.warning
                                : AppTheme.danger,
                      ),
                    ),
                  ),
                  Text('${reading.overallScore}',
                      style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w800,
                          fontSize: 16)),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Water Quality Score',
                        style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 15)),
                    const SizedBox(height: 2),
                    Text(
                      reading.overallScore >= 80
                          ? 'Water is in great condition'
                          : reading.overallScore >= 60
                              ? 'Some values need attention'
                              : 'Multiple issues detected',
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 12),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _formatTimestamp(reading.timestamp),
                      style: const TextStyle(
                          color: AppTheme.textMuted, fontSize: 11),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: onLog,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.edit_outlined,
                      color: AppTheme.primary, size: 16),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 1.3,
          children: [
            ChemicalGauge(
              label: 'pH',
              value: reading.ph,
              min: 6.5,
              max: 8.5,
              idealMin: 7.2,
              idealMax: 7.6,
              status: reading.phStatus,
              unit: '',
            ),
            ChemicalGauge(
              label: 'Chlorine',
              value: reading.chlorine,
              min: 0,
              max: 6,
              idealMin: 1.0,
              idealMax: 3.0,
              status: reading.chlorineStatus,
              unit: 'ppm',
            ),
            ChemicalGauge(
              label: 'Alkalinity',
              value: reading.alkalinity,
              min: 40,
              max: 200,
              idealMin: 80,
              idealMax: 120,
              status: reading.alkalinityStatus,
              unit: 'ppm',
            ),
            ChemicalGauge(
              label: 'Calcium Hardness',
              value: reading.calciumHardness,
              min: 100,
              max: 600,
              idealMin: 200,
              idealMax: 400,
              status: ChemicalStatus.good,
              unit: 'ppm',
            ),
          ],
        ),

        if (reading.saltLevel != null) ...[
          const SizedBox(height: 10),
          ChemicalGauge(
            label: 'Salt Level',
            value: reading.saltLevel!,
            min: 2000,
            max: 5000,
            idealMin: 2700,
            idealMax: 3400,
            status: reading.saltLevel! >= 2700 && reading.saltLevel! <= 3400
                ? ChemicalStatus.good
                : ChemicalStatus.low,
            unit: 'ppm',
          ),
        ],
      ],
    );
  }

  String _formatTimestamp(DateTime dt) {
    final hour = dt.hour > 12 ? dt.hour - 12 : dt.hour;
    final min = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return 'Logged at $hour:$min $ampm';
  }
}

// ─── Photos Tab ───────────────────────────────────────────────────────────────

class _PhotosTab extends StatefulWidget {
  final ServiceJob job;
  const _PhotosTab({required this.job});

  @override
  State<_PhotosTab> createState() => _PhotosTabState();
}

class _PhotosTabState extends State<_PhotosTab> {
  final List<Map<String, String>> _mockPhotos = [
    {'label': 'Before', 'time': '9:14 AM'},
    {'label': 'After', 'time': '10:02 AM'},
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _addPhoto,
                icon: const Icon(Icons.camera_alt_outlined, size: 16),
                label: const Text('Take Photo'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _addPhoto,
                icon: const Icon(Icons.photo_library_outlined,
                    size: 16, color: AppTheme.primary),
                label: const Text('From Library',
                    style: TextStyle(color: AppTheme.primary)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTheme.primary),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        if (_mockPhotos.isNotEmpty) ...[
          const SectionHeader(title: 'Logged Photos'),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: _mockPhotos.length,
            itemBuilder: (context, index) {
              final photo = _mockPhotos[index];
              return Container(
                decoration: BoxDecoration(
                  color: AppTheme.surfaceLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(11),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.primary.withOpacity(0.2),
                              AppTheme.primaryDark.withOpacity(0.4),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: const Center(
                          child: Icon(Icons.image_outlined,
                              color: AppTheme.primary, size: 40),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withOpacity(0.7),
                              Colors.transparent,
                            ],
                          ),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(11),
                            bottomRight: Radius.circular(11),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(photo['label']!,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12)),
                            Text(photo['time']!,
                                style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 10)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ] else ...[
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Column(
                children: [
                  Icon(Icons.photo_camera_outlined,
                      color: AppTheme.textMuted, size: 48),
                  SizedBox(height: 12),
                  Text('No photos yet',
                      style: TextStyle(color: AppTheme.textSecondary)),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  void _addPhoto() {
    setState(() {
      _mockPhotos.add({
        'label': _mockPhotos.length == 0 ? 'Before' : 'Photo ${_mockPhotos.length + 1}',
        'time': _currentTime(),
      });
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Photo added'),
        backgroundColor: AppTheme.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _currentTime() {
    final now = DateTime.now();
    final h = now.hour > 12 ? now.hour - 12 : now.hour;
    final m = now.minute.toString().padLeft(2, '0');
    return '$h:$m ${now.hour >= 12 ? 'PM' : 'AM'}';
  }
}
