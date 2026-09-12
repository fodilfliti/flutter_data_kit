/// App-facing facade over one or more sources.
///
/// Methods throw AppFailure. Controllers catch. Do not return
/// `Either<String, T>` or Result from repositories — Result.guard belongs
/// at the one call site that must branch.
abstract interface class Repository {}
