import 'package:dartz/dartz.dart';
import 'package:expense_app/core/error/failures.dart';

/// A generic command interface that represents a use case with input and output.
///
/// [T] - The return type of the command
/// [P] - The parameter type (use [NoParams] if no parameters are needed)
abstract class Command<T, P> {
  /// Executes the command with the given parameters.
  ///
  /// Returns either a [Failure] or a result of type [T].
  Future<Either<Failure, T>> call(P params);
}

/// A marker class to represent no parameters for a command.
class NoParams {
  const NoParams();
}
