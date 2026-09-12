import 'package:flutter/foundation.dart';
import 'package:flutter_data_kit/flutter_data_kit.dart';

/// Typed row for the example `notes` table (not a `Map`).
@immutable
class Note implements Identifiable {
  const Note({
    required this.id,
    required this.title,
    this.body,
  });

  factory Note.fromRow(Map<String, dynamic> row) {
    return Note(
      id: row['id']! as String,
      title: row['title']! as String,
      body: row['body'] as String?,
    );
  }

  @override
  final String id;
  final String title;
  final String? body;

  Map<String, dynamic> toRow() => {
    'id': id,
    'title': title,
    if (body != null) 'body': body,
  };

  @override
  bool operator ==(Object other) =>
      other is Note &&
      other.id == id &&
      other.title == title &&
      other.body == body;

  @override
  int get hashCode => Object.hash(id, title, body);
}

/// Insert payload for `NoteSource.create`.
@immutable
class NoteDraft {
  const NoteDraft({
    required this.title,
    this.body,
  });

  final String title;
  final String? body;

  Map<String, dynamic> toInsert() => {
    'title': title,
    if (body != null) 'body': body,
  };
}
