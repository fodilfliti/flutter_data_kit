import 'package:flutter/foundation.dart';
import 'package:flutter_data_kit/flutter_data_kit.dart';

/// Typed document for the example `notes` collection (not a `Map`).
@immutable
class Note implements Identifiable {
  const Note({
    required this.id,
    required this.title,
    this.body,
  });

  factory Note.fromDoc(String id, Map<String, dynamic> data) {
    return Note(
      id: id,
      title: data['title']! as String,
      body: data['body'] as String?,
    );
  }

  @override
  final String id;
  final String title;
  final String? body;

  Map<String, dynamic> toDoc() => {
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

  Map<String, dynamic> toDoc() => {
    'title': title,
    if (body != null) 'body': body,
  };
}
