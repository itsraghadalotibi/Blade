// event.dart
import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class LoadHomeData extends HomeEvent {}

class SearchProjectEvent extends HomeEvent {
  final String query;

  SearchProjectEvent(this.query);

  @override
  List<Object> get props => [query];
}
