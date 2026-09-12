/// Remote or local adapter boundary.
///
/// Implementations throw AppFailure and must not leak vendor exception types
/// (`DioException`, `PostgrestException`, …) above this line.
abstract interface class DataSource {}
