class ChatMessageModel {
  ChatMessageModel({
    this.date,
    this.id,
    this.isSentByMe,
    this.isSentNow,
    this.propertyTitleImage,
    this.timeAgo,
    this.receiverId,
    this.sound,
    this.userProfile,
    this.body,
    this.title,
    this.clickAction,
    this.message,
    this.senderId,
    this.propertyId,
    this.file,
    this.chatMessageType,
    this.audio,
    this.username,
  });

  ChatMessageModel.fromJson(Map<String, dynamic> json) {
    id = json['id'].toString();
    isSentByMe = json['isSentByMe'] as bool? ?? false;
    isSentNow = json['isSentNow'] as bool? ?? false;
    date = json['created_at']?.toString() ?? '';
    propertyTitleImage = json['property_title_image']?.toString() ?? '';
    timeAgo = json['time_ago']?.toString() ?? '';
    receiverId = json['receiver_id'].toString();
    sound = json['sound']?.toString() ?? '';

    userProfile = json['user_profile']?.toString() ?? '';
    body = json['body']?.toString() ?? '';
    title = json['title']?.toString() ?? '';
    clickAction = json['click_action']?.toString() ?? '';
    message = json['message']?.toString() ?? '';
    senderId = json['sender_id'].toString();

    propertyId = json['property_id'].toString();
    file = json['file']?.toString() ?? '';
    chatMessageType = json['chat_message_type']?.toString() ?? '';
    audio = json['audio']?.toString() ?? '';
    username = json['username']?.toString() ?? '';
  }
  String? id;
  bool? isSentByMe;
  bool? isSentNow;

  String? date;

  String? propertyTitleImage;
  String? timeAgo;
  String? receiverId;
  String? sound;
  String? userProfile;
  String? body;
  String? title;
  String? clickAction;
  String? message;
  String? senderId;
  String? propertyId;
  String? file;
  String? chatMessageType;
  String? audio;
  String? username;

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};

    data['created_at'] = date;

    data['id'] = id;

    data['isSentNow'] = isSentNow;
    data['isSentByMe'] = isSentByMe;
    data['property_title_image'] = propertyTitleImage;
    data['time_ago'] = timeAgo;
    data['receiver_id'] = receiverId;
    data['sound'] = sound;
    data['user_profile'] = userProfile;
    data['body'] = body;
    data['title'] = title;
    data['click_action'] = clickAction;
    data['message'] = message;
    data['sender_id'] = senderId;
    data['property_id'] = propertyId;
    data['file'] = file;
    data['chat_message_type'] = chatMessageType;
    data['audio'] = audio;
    data['username'] = username;
    return data;
  }

  Future<void> setId(String id) async => this.id = id;

  Future<void> setIsSentByMe(value) async =>
      isSentByMe = value as bool? ?? false;

  Future<void> setIsSentNow(value) async => isSentNow = value as bool? ?? false;

  @override
  String toString() {
    return 'ChatMessageModel{date: $date,sentByMe:$isSentByMe, sentNow:$isSentNow  id:$id, propertyTitleImage: $propertyTitleImage, timeAgo: $timeAgo, receiverId: $receiverId, sound: $sound, userProfile: $userProfile, body: $body,title: $title, clickAction: $clickAction, message: $message, senderId: $senderId, propertyId: $propertyId, file: $file, chatMessageType: $chatMessageType, audio: $audio, username: $username}';
  }
}
