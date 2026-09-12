import 'package:flutter_data_kit/flutter_data_kit.dart';
import 'package:flutter_data_kit_supabase/src/map_supabase.dart';
import 'package:flutter_data_kit_supabase/src/note.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Example typed CRUD source for a single `notes` table.
///
/// Every public method is wrapped in [mapSupabase]. Copy this shape for
/// app tables — do not return `Map<String, dynamic>` from sources.
class NoteSource implements CrudSource<Note, NoteDraft>, DataSource {
  NoteSource(
    this.client, {
    this.table = 'notes',
  });

  final SupabaseClient client;
  final String table;

  @override
  Future<Note> create(NoteDraft draft) => mapSupabase(() async {
    final row =
        await client.from(table).insert(draft.toInsert()).select().single();
    return Note.fromRow(row);
  });

  @override
  Future<Note> read(String id) => mapSupabase(() async {
    final row = await client.from(table).select().eq('id', id).single();
    return Note.fromRow(row);
  });

  @override
  Future<Note> update(Note entity) => mapSupabase(() async {
    final row =
        await client
            .from(table)
            .update(entity.toRow())
            .eq('id', entity.id)
            .select()
            .single();
    return Note.fromRow(row);
  });

  @override
  Future<void> delete(String id) => mapSupabase(() async {
    await client.from(table).delete().eq('id', id);
  });

  Future<List<Note>> list() => mapSupabase(() async {
    final rows = await client.from(table).select();
    return rows.map(Note.fromRow).toList(growable: false);
  });
}
