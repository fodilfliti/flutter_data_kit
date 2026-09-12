import 'package:flutter/foundation.dart';
import 'package:flutter_data_kit/flutter_data_kit.dart';

/// Typed local note (not a `Map`).
@immutable
class Note implements Identifiable {
  const Note({
    required this.id,
    required this.title,
    this.body,
  });

  @override
  final String id;
  final String title;
  final String? body;

  @override
  bool operator ==(Object other) =>
      other is Note &&
      other.id == id &&
      other.title == title &&
      other.body == body;

  @override
  int get hashCode => Object.hash(id, title, body);
}

/// Insert payload for NoteSource.create.
@immutable
class NoteDraft {
  const NoteDraft({
    required this.title,
    this.id,
    this.body,
  });

  final String title;
  final String? id;
  final String? body;
}
