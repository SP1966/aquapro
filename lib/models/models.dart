import 'package:flutter/material.dart';

// ─── Enums ───────────────────────────────────────────────────────────────────

enum JobStatus { scheduled, inProgress, completed, skipped }

enum PoolType { residential, commercial, spa }

enum ChemicalStatus { good, low, high, critical }

// ─── Customer ────────────────────────────────────────────────────────────────

class Customer {
  final String id;
  final String name;
  final String address;
  final String phone;
  final String email;
  final PoolType poolType;
  final double poolVolume; // gallons
  final String? notes;
  final List<ServiceJob> jobs;

  const Customer({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.email,
    required this.poolType,
    required this.poolVolume,
    this.notes,
    this.jobs = const [],
  });
}

// ─── Service Job ─────────────────────────────────────────────────────────────

class ServiceJob {
  final String id;
  final String customerId;
  final String customerName;
  final String address;
  final DateTime scheduledDate;
  JobStatus status;
  final String serviceType;
  ChemicalReading? chemicalReading;
  final List<String> photoPaths;
  final List<ChecklistItem> checklist;
  String? techNotes;

  ServiceJob({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.address,
    required this.scheduledDate,
    this.status = JobStatus.scheduled,
    required this.serviceType,
    this.chemicalReading,
    this.photoPaths = const [],
    required this.checklist,
    this.techNotes,
  });
}

// ─── Chemical Reading ─────────────────────────────────────────────────────────

class ChemicalReading {
  final DateTime timestamp;
  double ph;
  double chlorine;       // ppm
  double alkalinity;     // ppm
  double calciumHardness; // ppm
  double cyanuricAcid;   // ppm
  double? saltLevel;     // ppm (salt pools)
  String? notes;

  ChemicalReading({
    required this.timestamp,
    required this.ph,
    required this.chlorine,
    required this.alkalinity,
    required this.calciumHardness,
    required this.cyanuricAcid,
    this.saltLevel,
    this.notes,
  });

  ChemicalStatus get phStatus {
    if (ph >= 7.2 && ph <= 7.6) return ChemicalStatus.good;
    if (ph < 7.0 || ph > 7.8) return ChemicalStatus.critical;
    return ph < 7.2 ? ChemicalStatus.low : ChemicalStatus.high;
  }

  ChemicalStatus get chlorineStatus {
    if (chlorine >= 1.0 && chlorine <= 3.0) return ChemicalStatus.good;
    if (chlorine < 0.5 || chlorine > 5.0) return ChemicalStatus.critical;
    return chlorine < 1.0 ? ChemicalStatus.low : ChemicalStatus.high;
  }

  ChemicalStatus get alkalinityStatus {
    if (alkalinity >= 80 && alkalinity <= 120) return ChemicalStatus.good;
    if (alkalinity < 60 || alkalinity > 180) return ChemicalStatus.critical;
    return alkalinity < 80 ? ChemicalStatus.low : ChemicalStatus.high;
  }

  int get overallScore {
    int good = 0;
    if (phStatus == ChemicalStatus.good) good++;
    if (chlorineStatus == ChemicalStatus.good) good++;
    if (alkalinityStatus == ChemicalStatus.good) good++;
    return (good / 3 * 100).round();
  }
}

// ─── Checklist Item ──────────────────────────────────────────────────────────

class ChecklistItem {
  final String id;
  final String label;
  bool isChecked;
  final bool required;

  ChecklistItem({
    required this.id,
    required this.label,
    this.isChecked = false,
    this.required = false,
  });
}

// ─── Sample Data ─────────────────────────────────────────────────────────────

List<ChecklistItem> get defaultChecklist => [
      ChecklistItem(id: 'c1', label: 'Skim surface debris', required: true),
      ChecklistItem(id: 'c2', label: 'Empty skimmer baskets', required: true),
      ChecklistItem(id: 'c3', label: 'Brush walls & steps', required: true),
      ChecklistItem(id: 'c4', label: 'Vacuum pool floor'),
      ChecklistItem(id: 'c5', label: 'Check filter pressure'),
      ChecklistItem(id: 'c6', label: 'Backwash if needed'),
      ChecklistItem(id: 'c7', label: 'Test & balance chemicals', required: true),
      ChecklistItem(id: 'c8', label: 'Add chemicals as needed'),
      ChecklistItem(id: 'c9', label: 'Inspect pump & equipment'),
      ChecklistItem(id: 'c10', label: 'Check water level'),
    ];

final List<Customer> sampleCustomers = [
  Customer(
    id: 'cust1',
    name: 'Marcus & Priya Chen',
    address: '2847 Saguaro Dr, Scottsdale AZ 85254',
    phone: '(480) 555-0192',
    email: 'mchen@email.com',
    poolType: PoolType.residential,
    poolVolume: 18000,
    notes: 'Dog door on gate — close it after. Salt pool.',
  ),
  Customer(
    id: 'cust2',
    name: 'Sunset Valley HOA',
    address: '400 Sunset Valley Blvd, Gilbert AZ 85296',
    phone: '(480) 555-0348',
    email: 'manager@svhoa.com',
    poolType: PoolType.commercial,
    poolVolume: 85000,
    notes: 'Commercial pool. Key code: 4821. Health dept permit on file.',
  ),
  Customer(
    id: 'cust3',
    name: 'Donna Fairbanks',
    address: '1103 Ocotillo Ln, Tempe AZ 85281',
    phone: '(480) 555-0774',
    email: 'donna.f@email.com',
    poolType: PoolType.spa,
    poolVolume: 6500,
    notes: 'Spa + small pool combo. Elderly owner — be patient.',
  ),
  Customer(
    id: 'cust4',
    name: 'Rivera Family',
    address: '5519 Desert Rose Way, Mesa AZ 85205',
    phone: '(480) 555-0231',
    email: 'jrivera@email.com',
    poolType: PoolType.residential,
    poolVolume: 22000,
  ),
];

List<ServiceJob> get sampleJobs => [
      ServiceJob(
        id: 'job1',
        customerId: 'cust1',
        customerName: 'Marcus & Priya Chen',
        address: '2847 Saguaro Dr, Scottsdale AZ 85254',
        scheduledDate: DateTime.now(),
        status: JobStatus.inProgress,
        serviceType: 'Weekly Service',
        checklist: defaultChecklist,
        chemicalReading: ChemicalReading(
          timestamp: DateTime.now().subtract(const Duration(minutes: 20)),
          ph: 7.3,
          chlorine: 2.1,
          alkalinity: 95,
          calciumHardness: 280,
          cyanuricAcid: 45,
          saltLevel: 3200,
        ),
      ),
      ServiceJob(
        id: 'job2',
        customerId: 'cust2',
        customerName: 'Sunset Valley HOA',
        address: '400 Sunset Valley Blvd, Gilbert AZ 85296',
        scheduledDate: DateTime.now(),
        status: JobStatus.scheduled,
        serviceType: 'Weekly Service',
        checklist: defaultChecklist,
      ),
      ServiceJob(
        id: 'job3',
        customerId: 'cust3',
        customerName: 'Donna Fairbanks',
        address: '1103 Ocotillo Ln, Tempe AZ 85281',
        scheduledDate: DateTime.now(),
        status: JobStatus.completed,
        serviceType: 'Spa Service',
        checklist: defaultChecklist
            .map((i) => ChecklistItem(
                  id: i.id,
                  label: i.label,
                  isChecked: true,
                  required: i.required,
                ))
            .toList(),
        chemicalReading: ChemicalReading(
          timestamp: DateTime.now().subtract(const Duration(hours: 1)),
          ph: 7.5,
          chlorine: 1.8,
          alkalinity: 110,
          calciumHardness: 300,
          cyanuricAcid: 40,
        ),
        techNotes: 'All good. Spa heater making slight noise — monitor.',
      ),
      ServiceJob(
        id: 'job4',
        customerId: 'cust4',
        customerName: 'Rivera Family',
        address: '5519 Desert Rose Way, Mesa AZ 85205',
        scheduledDate: DateTime.now().add(const Duration(hours: 3)),
        status: JobStatus.scheduled,
        serviceType: 'Filter Clean',
        checklist: defaultChecklist,
      ),
    ];

// ─── Helpers ─────────────────────────────────────────────────────────────────

extension JobStatusExt on JobStatus {
  String get label {
    switch (this) {
      case JobStatus.scheduled: return 'Scheduled';
      case JobStatus.inProgress: return 'In Progress';
      case JobStatus.completed: return 'Completed';
      case JobStatus.skipped: return 'Skipped';
    }
  }

  Color get color {
    switch (this) {
      case JobStatus.scheduled: return const Color(0xFF8899B4);
      case JobStatus.inProgress: return const Color(0xFF00C2CC);
      case JobStatus.completed: return const Color(0xFF00C97A);
      case JobStatus.skipped: return const Color(0xFFFFB020);
    }
  }
}

extension PoolTypeExt on PoolType {
  String get label {
    switch (this) {
      case PoolType.residential: return 'Residential';
      case PoolType.commercial: return 'Commercial';
      case PoolType.spa: return 'Spa';
    }
  }

  String get icon {
    switch (this) {
      case PoolType.residential: return '🏠';
      case PoolType.commercial: return '🏢';
      case PoolType.spa: return '♨️';
    }
  }
}

extension ChemicalStatusExt on ChemicalStatus {
  Color get color {
    switch (this) {
      case ChemicalStatus.good: return const Color(0xFF00C97A);
      case ChemicalStatus.low: return const Color(0xFFFFB020);
      case ChemicalStatus.high: return const Color(0xFFFFB020);
      case ChemicalStatus.critical: return const Color(0xFFFF4D6D);
    }
  }

  String get label {
    switch (this) {
      case ChemicalStatus.good: return 'OK';
      case ChemicalStatus.low: return 'Low';
      case ChemicalStatus.high: return 'High';
      case ChemicalStatus.critical: return 'Critical';
    }
  }
}
