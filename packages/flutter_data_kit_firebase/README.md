# flutter_data_kit_firebase

Firestore / Auth / Storage / FCM adapter. **Later** — not in T13.

Will own one mapper (`FirebaseException` → `AppFailure`) and typed sources.
Apps that only use Dio or Supabase must never resolve this package.

See the family kit design: `flutter_data_kit` adapters live in this workspace.
