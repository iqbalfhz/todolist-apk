// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exchange_rates.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ExchangeRates _$ExchangeRatesFromJson(Map<String, dynamic> json) => _ExchangeRates(
  base: json['base'] as String,
  date: json['date'] as String,
  fetchedAt: DateTime.parse(json['fetched_at'] as String),
  rates: Map<String, String>.from(json['rates'] as Map),
);

Map<String, dynamic> _$ExchangeRatesToJson(_ExchangeRates instance) => <String, dynamic>{
  'base': instance.base,
  'date': instance.date,
  'fetched_at': instance.fetchedAt.toIso8601String(),
  'rates': instance.rates,
};
