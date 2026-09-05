import 'package:flutter/material.dart';

class AppUser {
  final String name;
  final String role;
  const AppUser({required this.name, required this.role});
}

enum TxType { income, expense }

enum EvStatus { draft, active, completed }

class EventItem {
  final String name;
  final String dateLabel;
  final int budget;
  final double progress; // 0..100
  final EvStatus status;
  final IconData icon;

  const EventItem({
    required this.name,
    required this.dateLabel,
    required this.budget,
    required this.progress,
    required this.status,
    required this.icon,
  });
}

class TransactionModel {
  final String title;
  final String eventName;
  final TxType type;
  final int amount;
  final DateTime date;
  final String category;
  final String paymentMethod;
  final String note;
  final int docCount;

  const TransactionModel({
    required this.title,
    required this.eventName,
    required this.type,
    required this.amount,
    required this.date,
    required this.category,
    required this.paymentMethod,
    this.note = '',
    this.docCount = 0,
  });
}

class ActivityModel {
  final String title;
  final String eventName;
  final TxType type;
  final int amount;
  final DateTime date;

  const ActivityModel({
    required this.title,
    required this.eventName,
    required this.type,
    required this.amount,
    required this.date,
  });
}

class LogisticsItem {
  final String name;
  final int qty;
  final String unit;
  final bool received;

  const LogisticsItem({
    required this.name,
    required this.qty,
    required this.unit,
    required this.received,
  });
}

class RabCategory {
  final String name;
  final int used;
  final int budget;

  const RabCategory({
    required this.name,
    required this.used,
    required this.budget,
  });

  double get percent => budget == 0 ? 0 : used / budget * 100;
}

class RabItem {
  final String description;
  final int qty;
  final String unit;
  final int price;

  const RabItem({
    required this.description,
    required this.qty,
    required this.unit,
    required this.price,
  });

  int get total => qty * price;
}

/// Titik untuk grafik "Ringkasan Arus Kas".
class CashFlowPoint {
  final double income;
  final double expense;
  const CashFlowPoint(this.income, this.expense);
}
