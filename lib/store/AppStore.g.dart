// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'AppStore.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic

mixin _$AppStore on _AppStore, Store {
  final _$isRingtoneAtom = Atom(name: '_AppStore.isRingtone');

  @override
  bool get isRingtone {
    _$isRingtoneAtom.context.enforceReadPolicy(_$isRingtoneAtom);
    _$isRingtoneAtom.reportObserved();
    return super.isRingtone;
  }

  @override
  set isRingtone(bool value) {
    _$isRingtoneAtom.context.conditionallyRunInAction(() {
      super.isRingtone = value;
      _$isRingtoneAtom.reportChanged();
    }, _$isRingtoneAtom, name: '${_$isRingtoneAtom.name}_set');
  }

  @override
  String toString() {
    final string = 'isRingtone: ${isRingtone.toString()}';
    return '{$string}';
  }
}
