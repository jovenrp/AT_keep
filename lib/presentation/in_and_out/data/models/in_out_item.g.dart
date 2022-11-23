// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'in_out_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InOutItem _$InOutItemFromJson(Map<String, dynamic> json) => InOutItem(
      id: json['id'] as String?,
      containerId: json['containerId'] as String?,
      itemId: json['itemId'] as String?,
      itemNum: json['itemNum'] as String?,
      sku: json['sku'] as String?,
      uom: json['uom'] as String?,
      name: json['name'] as String?,
      qty: json['qty'] as String?,
      stockType: json['stockType'] as String?,
    );

Map<String, dynamic> _$InOutItemToJson(InOutItem instance) => <String, dynamic>{
      'id': instance.id,
      'containerId': instance.containerId,
      'itemId': instance.itemId,
      'itemNum': instance.itemNum,
      'sku': instance.sku,
      'uom': instance.uom,
      'qty': instance.qty,
      'name': instance.name,
      'stockType': instance.stockType,
    };
