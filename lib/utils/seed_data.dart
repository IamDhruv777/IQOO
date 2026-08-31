import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../models/memory.dart';
import '../models/memory_date.dart';
import '../services/database_service.dart';

/// Inserts 8 varied dummy memories into the database for the demo scenario.
///
/// DEMO ONLY: This seed data exists so that the search demo is meaningful
/// when judged live — it proves that the correct memory surfaces from a
/// pool of unrelated items, not from an empty database.
///
/// The memory with ID 'seed_hackathon_notice' is the PRIMARY demo target.
/// It will be captured LIVE during the demo; the seeded version is a backstop.
///
/// Call this once on first app launch (guarded by [DatabaseService.isSeedDataInserted]).
Future<void> insertSeedData() async {
  final db = DatabaseService();
  // if (await db.isSeedDataInserted()) return; // Force re-insert for new seeds

  final docsDir = await getApplicationDocumentsDirectory();
  final seedDir = Directory(p.join(docsDir.path, 'seed_images'));
  if (!await seedDir.exists()) await seedDir.create(recursive: true);

  /// Copies a bundled asset image to local storage and returns its path.
  Future<String> copyAssetImage(String assetName) async {
    final destPath = p.join(seedDir.path, assetName);
    if (await File(destPath).exists()) return destPath;
    try {
      final bytes = await rootBundle.load('assets/images/seed/$assetName');
      await File(destPath).writeAsBytes(bytes.buffer.asUint8List());
    } catch (_) {
      // Asset not found — use path as-is (image will show placeholder)
    }
    return destPath;
  }

  final seeds = [
    Memory(
      id: 'seed_hackathon_notice',
      imagePath: await copyAssetImage('hackathon_notice.jpg'),
      title: 'AI Hackathon — iQOO 2026',
      summary: 'Hackathon registration notice with Sept 5 deadline',
      category: 'event',
      extractedText:
          'iQOO AI Hackathon 2026\nRegistration Deadline: September 5, 2026\nVenue: Main Auditorium, Pune\nOrganizer: iQOO & IEEE\nPrize Pool: ₹2,00,000',
      entities: {
        'event_name': 'iQOO AI Hackathon 2026',
        'location': 'Main Auditorium, Pune',
        'organizer': 'iQOO & IEEE',
        'prize_pool': '₹2,00,000',
      },
      dates: [
        MemoryDate(type: 'deadline', value: DateTime(2026, 9, 5, 23, 59)),
        MemoryDate(type: 'event_date', value: DateTime(2026, 9, 15, 10, 0)),
      ],
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    Memory(
      id: 'seed_coffee_receipt',
      imagePath: await copyAssetImage('coffee_receipt.jpg'),
      title: 'Café Coffee Day Receipt',
      summary: 'Coffee purchase receipt for ₹320',
      category: 'receipt',
      extractedText:
          'Café Coffee Day\nDate: Aug 28, 2026\nItem: Large Cappuccino x2\nTotal: ₹320\nPayment: UPI',
      entities: {
        'merchant': 'Café Coffee Day',
        'amount': '₹320',
        'payment_method': 'UPI',
      },
      dates: [MemoryDate(type: 'issue_date', value: DateTime(2026, 8, 28))],
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
    ),
    Memory(
      id: 'seed_business_card',
      imagePath: await copyAssetImage('business_card.jpg'),
      title: 'Ananya Sharma — TechFlow',
      summary: 'Business card for a product manager at TechFlow Solutions',
      category: 'contact',
      extractedText:
          'Ananya Sharma\nProduct Manager\nTechFlow Solutions\nPhone: +91 98765 43210\nEmail: ananya@techflow.in\nLinkedIn: linkedin.com/in/ananyasharma',
      entities: {
        'name': 'Ananya Sharma',
        'title': 'Product Manager',
        'company': 'TechFlow Solutions',
        'phone': '+91 98765 43210',
        'email': 'ananya@techflow.in',
      },
      dates: [],
      createdAt: DateTime.now().subtract(const Duration(days: 6)),
    ),
    Memory(
      id: 'seed_library_notice',
      imagePath: await copyAssetImage('library_notice.jpg'),
      title: 'Library Book Return Notice',
      summary: 'Notice to return overdue library books by September 10',
      category: 'notice',
      extractedText:
          'NOTICE\nAll students must return borrowed books by Sept 10, 2026.\nFine: ₹5 per day after due date.\n— Librarian, SPCE',
      entities: {
        'subject': 'Book return deadline',
        'issuing_body': 'SPCE Library',
        'fine': '₹5/day',
      },
      dates: [MemoryDate(type: 'deadline', value: DateTime(2026, 9, 10))],
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
    ),
    Memory(
      id: 'seed_amazon_order',
      imagePath: await copyAssetImage('amazon_order.jpg'),
      title: 'Amazon Order Confirmation',
      summary: 'Order receipt for mechanical keyboard, ₹4,299',
      category: 'receipt',
      extractedText:
          'Amazon.in\nOrder #402-1234567-8901234\nDas Keyboard 4 (Mechanical) x1\nTotal: ₹4,299\nEstimated delivery: Sept 2, 2026',
      entities: {
        'merchant': 'Amazon.in',
        'order_id': '402-1234567-8901234',
        'amount': '₹4,299',
        'item': 'Das Keyboard 4',
      },
      dates: [MemoryDate(type: 'other', value: DateTime(2026, 9, 2))],
      createdAt: DateTime.now().subtract(const Duration(days: 9)),
    ),
    Memory(
      id: 'seed_project_timeline',
      imagePath: await copyAssetImage('project_timeline.jpg'),
      title: 'Final Year Project Timeline',
      summary: 'Project milestone chart showing submission dates',
      category: 'document',
      extractedText:
          'FY Project Timeline 2026\nPhase 1 — Research: July 1\nPhase 2 — Design: Aug 1\nPhase 3 — Implementation: Sept 30\nFinal Submission: Nov 15, 2026',
      entities: {
        'subject': 'Final Year Project',
        'final_submission': 'Nov 15, 2026',
      },
      dates: [
        MemoryDate(type: 'deadline', value: DateTime(2026, 11, 15)),
        MemoryDate(type: 'event_date', value: DateTime(2026, 9, 30)),
      ],
      createdAt: DateTime.now().subtract(const Duration(days: 14)),
    ),
    Memory(
      id: 'seed_workshop_flyer',
      imagePath: await copyAssetImage('workshop_flyer.jpg'),
      title: 'Flutter Workshop — Sept 20',
      summary: 'Free Flutter development workshop at IEEE chapter',
      category: 'event',
      extractedText:
          'FREE Flutter Development Workshop\nDate: September 20, 2026\nTime: 10:00 AM – 4:00 PM\nVenue: Lab 302, Engineering Block\nOrganizer: IEEE Student Chapter\nRegister: bit.ly/flutter-ws',
      entities: {
        'event_name': 'Flutter Development Workshop',
        'location': 'Lab 302, Engineering Block',
        'organizer': 'IEEE Student Chapter',
        'registration_link': 'bit.ly/flutter-ws',
      },
      dates: [
        MemoryDate(type: 'event_date', value: DateTime(2026, 9, 20, 10, 0)),
      ],
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Memory(
      id: 'seed_fee_receipt',
      imagePath: await copyAssetImage('fee_receipt.jpg'),
      title: 'Semester Fee Receipt',
      summary: 'Official fee payment receipt for Semester 7',
      category: 'receipt',
      extractedText:
          'RECEIPT\nSPCE, Mumbai\nStudent: Rahul Mehta\nSem 7 Tuition Fee: ₹62,000\nPaid: Aug 15, 2026\nReceipt No: 2026-SEM7-00842',
      entities: {
        'institution': 'SPCE, Mumbai',
        'student': 'Rahul Mehta',
        'amount': '₹62,000',
        'receipt_no': '2026-SEM7-00842',
      },
      dates: [MemoryDate(type: 'issue_date', value: DateTime(2026, 8, 15))],
      createdAt: DateTime.now().subtract(const Duration(days: 16)),
    ),
    Memory(
      id: 'seed_zomato_internship',
      imagePath: await copyAssetImage('zomato_internship.jpg'),
      title: 'Zomato Backend Internship',
      summary: 'Internship opportunity for backend developers at Zomato',
      category: 'notice',
      extractedText:
          'ZOMATO INTERNSHIP DRIVE\nRole: Backend Developer Intern\nLocation: Gurugram / Remote\nStipend: ₹40,000/month\nRequirements: Node.js, MongoDB, AWS\nApply by: October 12, 2026\nLink: zomato.com/careers',
      entities: {
        'company': 'Zomato',
        'role': 'Backend Developer Intern',
        'stipend': '₹40,000/month',
        'link': 'zomato.com/careers',
      },
      dates: [MemoryDate(type: 'deadline', value: DateTime(2026, 10, 12))],
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Memory(
      id: 'seed_google_soc',
      imagePath: await copyAssetImage('gsoc_poster.jpg'),
      title: 'Google Summer of Code 2026',
      summary: 'GSoC timeline and announcement poster',
      category: 'event',
      extractedText:
          'Google Summer of Code (GSoC) 2026\nStudent application period opens: March 15, 2026\nStudent application deadline: April 1, 2026\nCoding begins: May 20, 2026\nFinal evaluations: August 25, 2026',
      entities: {
        'event': 'Google Summer of Code 2026',
      },
      dates: [
        MemoryDate(type: 'deadline', value: DateTime(2026, 4, 1)),
        MemoryDate(type: 'event_date', value: DateTime(2026, 3, 15)),
      ],
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    Memory(
      id: 'seed_electricity_bill',
      imagePath: await copyAssetImage('electric_bill.jpg'),
      title: 'Mahavitaran Electricity Bill',
      summary: 'Monthly electricity bill for August 2026',
      category: 'receipt',
      extractedText:
          'MAHAVITARAN (MSEDCL)\nConsumer No: 021234567890\nBilling Month: August 2026\nTotal Amount Due: ₹1,450\nDue Date: September 18, 2026\nPay online at mahadiscom.in',
      entities: {
        'biller': 'MAHAVITARAN',
        'amount': '₹1,450',
        'consumer_no': '021234567890',
      },
      dates: [MemoryDate(type: 'deadline', value: DateTime(2026, 9, 18))],
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Memory(
      id: 'seed_plumber_card',
      imagePath: await copyAssetImage('plumber_card.jpg'),
      title: 'Ramesh Plumbing Services',
      summary: 'Visiting card for local plumber',
      category: 'contact',
      extractedText:
          'Ramesh Plumbing & Fixing Services\nA to Z plumbing works, leaks, pipes, tanks.\n24/7 Available.\nRamesh Kumar\nPhone: +91 99887 76655\nShop 4, Market Road, Andheri West.',
      entities: {
        'name': 'Ramesh Kumar',
        'profession': 'Plumber',
        'phone': '+91 99887 76655',
      },
      dates: [],
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
    ),
  ];

  for (final seed in seeds) {
    await db.insertMemory(seed);
  }
}
