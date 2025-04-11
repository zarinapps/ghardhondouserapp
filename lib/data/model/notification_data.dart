import 'package:ebroker/utils/Extensions/lib/adaptive_type.dart';

class NotificationData {
  NotificationData({
    this.id,
    this.title,
    this.message,
    this.image,
    this.type,
    this.sendType,
    this.customersId,
    this.propertysId,
    this.createdAt,
    this.created,
  });

  NotificationData.fromJson(Map<String, dynamic> json) {
    id = json['id'].toString();
    title = json['title']?.toString() ?? '';
    message = json['message']?.toString() ?? '';
    image = json['notification_image']?.toString() ?? '';
    type = json['type']?.toString() ?? '';
    sendType = Adapter.forceInt(json['send_type']);
    customersId = json['customers_id']?.toString() ?? '';
    propertysId = json['propertys_id']?.toString() ?? '';
    createdAt = json['created_at']?.toString() ?? '';
    created = json['created']?.toString() ?? '';
  }
  String? id;
  String? title;
  String? message;
  String? image;
  String? type;
  int? sendType;
  String? customersId;
  String? propertysId;
  String? createdAt;
  String? created;
}
