import 'package:drift/isolate.dart';
import 'package:drift/native.dart';

extension DriftRemoteExceptionX on DriftRemoteException {
  static const _sqliteConstraintUnique = 2067;

  bool get isUniqueConstraint {
    final cause = remoteCause;
    return cause is SqliteException &&
        cause.extendedResultCode == _sqliteConstraintUnique;
  }
}
