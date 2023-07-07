import 'package:dart_basics/src/newtype.dart';

final class UserId extends Newtype<String> {
  const UserId(super.value);
}

final class ProductId extends Newtype<String> {
  const ProductId(super.value);
}

final class Email extends Newtype<String> {
  Email(super.value)
      : assert(value.contains('@'), 'An email must contain a `@`');
}

final class PositiveInt extends Newtype<int> {
  const PositiveInt(super.value) : assert(value > 0, 'Value is not positive');
}

void main(List<String> args) {
  print('''
    A newtype can be used to give identity to equal but 
    semantically distinct primitive values, like strings 
    or numbers used as identifiers.

    Two user IDs with the same value are equal.
    ${const UserId('a')} == ${const UserId('b')}: ${const UserId('a') == const UserId('b')}

    But a user ID can never be a product ID, even when 
    they are represented by the same string.
    ${const UserId('a')} == ${const ProductId('a')}: ${const UserId('a') == const ProductId('a')}

    Newtypes can also be used to impose additional 
    constraints on underlying values.

    Is this a valid email: `hello@example.com`?
    ${Email('hello@example.com')} -- yes!

    Is this a valid email: `hello.there`?
    ${(() {
    try {
      return '${Email('hello.there')} -- yes!';
    } catch (e) {
      return 'Uh oh! This threw an error: $e';
    }
  })()}

    Similarily, is this a valid positive integer: 5?
    ${const PositiveInt(5)} -- yes!

    Is this a valid positive integer: -3?
    ${(() {
    try {
      return '${PositiveInt(-3)} -- yes!';
    } catch (e) {
      return 'Uh oh! This threw an error: $e';
    }
  })()}
''');
}
