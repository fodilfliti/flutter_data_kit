import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_data_kit_firebase/flutter_data_kit_firebase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lemsa_core_kit/lemsa_core_kit.dart';

void main() {
  group('NoteSource', () {
    test('read success path', () async {
      final source = NoteSource(_FakeNotesCollection());
      final note = await source.read('n1');
      expect(note, const Note(id: 'n1', title: 'Hello', body: 'world'));
    });

    test('read maps not-found → NotFoundFailure', () async {
      final source = NoteSource(_FakeNotesCollection(failGet: true));
      await expectLater(
        source.read('missing'),
        throwsA(isA<NotFoundFailure>()),
      );
    });

    test('create success path', () async {
      final source = NoteSource(_FakeNotesCollection());
      final note = await source.create(const NoteDraft(title: 'New'));
      expect(note.title, 'New');
      expect(note.id, isNotEmpty);
    });
  });
}

class _FakeNotesCollection implements NotesCollection {
  _FakeNotesCollection({this.failGet = false});

  final bool failGet;
  final Map<String, Map<String, dynamic>> _docs = {
    'n1': {'title': 'Hello', 'body': 'world'},
  };

  @override
  Future<Map<String, dynamic>> insert(Map<String, dynamic> data) async {
    final id = 'gen_${_docs.length}';
    _docs[id] = Map<String, dynamic>.from(data);
    return {'id': id, ...data};
  }

  @override
  Future<Map<String, dynamic>> get(String id) async {
    if (failGet) {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        code: 'not-found',
      );
    }
    final doc = _docs[id];
    if (doc == null) {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        code: 'not-found',
      );
    }
    return {'id': id, ...doc};
  }

  @override
  Future<Map<String, dynamic>> update(
    String id,
    Map<String, dynamic> data,
  ) async {
    _docs[id] = Map<String, dynamic>.from(data);
    return {'id': id, ...data};
  }

  @override
  Future<void> delete(String id) async {
    _docs.remove(id);
  }

  @override
  Future<List<({String id, Map<String, dynamic> data})>> list() async {
    return [
      for (final e in _docs.entries) (id: e.key, data: e.value),
    ];
  }
}
