import 'package:equatable/equatable.dart';

/// Base class for all use cases
/// 
/// [Type] is the return type of the use case
/// [Params] is the parameter type for the use case
abstract class UseCase<Type, Params> {
  /// Executes the use case with the given parameters
  Future<Type> call(Params params);
}

/// Use case that doesn't require any parameters
abstract class NoParamsUseCase<Type> {
  /// Executes the use case without parameters
  Future<Type> call();
}

/// Base class for use case parameters
abstract class UseCaseParams extends Equatable {
  const UseCaseParams();
}

/// Empty parameters for use cases that don't need parameters
class NoParams extends UseCaseParams {
  const NoParams();
  
  @override
  List<Object?> get props => [];
}
