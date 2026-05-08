import 'package:equatable/equatable.dart';

class JournalEntry extends Equatable {
  final String? id;
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
    return (totalDebit - totalCredit).abs() < 0.001 && lines.isNotEmpty;
  }

  JournalEntry copyWith({
    String? id,
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

  factory JournalEntry.fromMap(Map<String, dynamic> map, {String? documentId}) {
    return JournalEntry(
      id: documentId ?? map['id']?.toString(),
      date: map['date'] ?? '',
      reference: map['reference'] ?? '',
      description: map['description'] ?? '',
      lines: (map['lines'] as List? ?? [])
          .map((l) => TransactionLine.fromMap(l as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [id, date, reference, description, lines];
}

class TransactionLine extends Equatable {
  final String? id;
  final String? entryId;
  final String accountId;
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
      'entryId': entryId,
      'accountId': accountId,
      'debit': debit,
      'credit': credit,
      'memo': memo,
    };
  }

  factory TransactionLine.fromMap(Map<String, dynamic> map) {
    return TransactionLine(
      id: map['id']?.toString(),
      entryId: map['entryId']?.toString(),
      accountId: map['accountId']?.toString() ?? '',
      debit: (map['debit'] as num?)?.toDouble() ?? 0.0,
      credit: (map['credit'] as num?)?.toDouble() ?? 0.0,
      memo: map['memo'] ?? '',
    );
  }

  @override
  List<Object?> get props => [id, entryId, accountId, debit, credit, memo];
}
