part of 'collectible_cubit.dart';

abstract class CollectibleState extends Equatable {
  final List<Collectible> collectibles;
  const CollectibleState({this.collectibles = const []});

  @override
  List<Object> get props => [];
}

class CollectibleInitial extends CollectibleState {}

class CollectibleLoading extends CollectibleState {}

class CollectibleLoaded extends CollectibleState {
  const CollectibleLoaded({super.collectibles});
}

class CollectibleAdded extends CollectibleState {
  const CollectibleAdded({super.collectibles});
}
class CollectibleTransfer extends CollectibleState {
  const CollectibleTransfer({super.collectibles});
}

class CollectibleDeleted extends CollectibleState {
  const CollectibleDeleted({super.collectibles});
}

class CollectibleError extends CollectibleState {
  final String error;
  const CollectibleError({required this.error});
}
