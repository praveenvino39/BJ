part of 'token_cubit.dart';

@immutable
abstract class TokenState {
  final List<Token> tokens;
  const TokenState({this.tokens = const []});
}

class TokenInitial extends TokenState {}

class TokenLoading extends TokenState{}

class TokenLoaded extends TokenState {
  const TokenLoaded({super.tokens});
}
class TokenAdded extends TokenState {
  const TokenAdded({super.tokens});
}

class TokenDeleted extends TokenState {
  const TokenDeleted({super.tokens});
}


class TokenTransfered extends TokenState {
  const TokenTransfered({super.tokens});
}

class TokenError extends TokenState{
  final String error;
  const TokenError({required this.error});
}
