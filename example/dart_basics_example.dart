import 'package:dart_basics/dart_basics.dart';
import 'package:dart_basics/src/functions.dart';
import 'package:equatable/equatable.dart';

class ApiError extends Equatable {
  const ApiError(this.message);

  final String message;

  @override
  bool? get stringify => true;

  @override
  List<Object?> get props => [message];
}

void main(List<String> argv) async {
  final argsCopy = [...argv];

  Future<Result<num, ApiError>> fetchNumberFromApi() async {
    if (argsCopy.isEmpty) {
      return const Failure(ApiError('not found'));
    }
    final arg = argsCopy.removeAt(0);
    final number = int.tryParse(arg);
    if (number == null) {
      return const Failure(ApiError('internal error'));
    }
    return Success(number);
  }

  final sum = await Result.asyncSequence(() async {
    final a = (await fetchNumberFromApi()).unwrap();
    final b = (await fetchNumberFromApi()).unwrap();

    return a + b;
  });

  print('a + b = $sum');

  const Result<int, String> result = Success(5);

  final isFive = result.map(
    (value) => switch (value) {
      Success(data: 5) => true,
      Success() => false,
      Failure() => false,
    },
  );
}
