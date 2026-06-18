import 'package:meta/meta.dart';

/// {@template option}
/// A class that represents an option value.
/// {@endtemplate}
@immutable
class Option<T> {
  /// Creates an instance of [Option] with the given value.
  /// {@macro option}
  const Option(this.value) : isAbsent = false;

  @literal
  const Option.absent() : value = null, isAbsent = true;

  /// The value of the option.
  final T? value;

  /// Checks if the option has a value.
  final bool isAbsent;
}
