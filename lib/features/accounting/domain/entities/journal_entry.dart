import 'package:equatable/equatable.dart';

class JournalEntry extends Equatable {
  final int? id;
  final String date;
  final String reference;
  final String description;
  final List<TransactionLine> lines;

  const JournalEntry({
    this.id,
    required this.date,
    required this.reference,
    required this.description,
    required this.lines,
  });

  bool get isValid {
    double totalDebit = 0.0;
    double totalCredit = 0.0;
    for (var line in lines) {
      totalDebit += line.debit;
      totalCredit += line.credit;
    }
    // Handle floating point precision issues with a small epsilon
    return (totalDebit - totalCredit).abs() < 0.001 && lines.isNotEmpty;
  }

  JournalEntry copyWith({
    int? id,
    String? date,
    String? reference,
    String? description,
    List<TransactionLine>? lines,
  }) {
    return JournalEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      reference: reference ?? this.reference,
      description: description ?? this.description,
      lines: lines ?? this.lines,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'reference': reference,
      'description': description,
    };
  }

  @override
  List<Object?> get props => [id, date, reference, description, lines];
}

class TransactionLine extends Equatable {
  final int? id;
  final int? entryId;
  final int accountId;
  final double debit;
  final double credit;
  final String memo;

  const TransactionLine({
    this.id,
    this.entryId,
    required this.accountId,
    this.debit = 0.0,
    this.credit = 0.0,
    this.memo = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'entry_id': entryId,
      'account_id': accountId,
      'debit': debit,
      'credit': credit,
      'memo': memo,
    };
  }

  @override
  List<Object?> get props => [id, entryId, accountId, debit, credit, memo];
}
