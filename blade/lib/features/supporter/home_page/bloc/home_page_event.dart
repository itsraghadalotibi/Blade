// home_page_event.dart
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

class ClearSearchEvent extends HomeEvent {}
class SearchEvent extends HomeEvent {
  final String query;

  SearchEvent(this.query);

  @override
  List<Object> get props => [query];
}

class FilterTabChangedEvent extends HomeEvent {
  final String selectedTab;

  FilterTabChangedEvent(this.selectedTab);

  @override
  List<Object> get props => [selectedTab];
}