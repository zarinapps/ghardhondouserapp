class ChatMessageModal {
  ChatMessageModal({
    this.id,
    this.senderId,
    this.receiverId,
    this.propertyId,
    this.message,
    this.file,
    this.audio,
    this.createdAt,
    this.updatedAt,
  });

  ChatMessageModal.fromJson(Map<String, dynamic> json) {
    id = json['id'] as int?;
    senderId = json['sender_ id'] as int?;
    receiverId = json['receiver_id'] as int?;
    propertyId = json['property_id'] as int?;
    message = json['message']?.toString() ?? '';
    file = json['file']?.toString() ?? '';
    audio = json['audio']?.toString() ?? '';
    createdAt = json['created_at']?.toString() ?? '';
    updatedAt = json['updated_at']?.toString() ?? '';
  }
  int? id;
  int? senderId;
  int? receiverId;
  int? propertyId;
  String? message;
  String? file;
  String? audio;
  String? createdAt;
  String? updatedAt;

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['sender_id'] = senderId;
    data['receiver_id'] = receiverId;
    data['property_id'] = propertyId;
    data['message'] = message;
    data['file'] = file;
    data['audio'] = audio;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}
