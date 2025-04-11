// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:ebroker/utils/Extensions/lib/adaptive_type.dart';

class UserModel {
  String? address;
  String? createdAt;
  int? customertotalpost;
  String? email;
  String? fcmId;
  String? authId;
  int? id;
  int? isActive;
  bool? isProfileCompleted;
  String? logintype;
  String? mobile;
  String? name;
  int? notification;
  String? profile;
  String? token;
  String? updatedAt;
  String? instagram;
  String? facebook;
  String? youtube;
  String? twitter;

  UserModel({
    this.address,
    this.createdAt,
    this.customertotalpost,
    this.email,
    this.fcmId,
    this.authId,
    this.id,
    this.isActive,
    this.isProfileCompleted,
    this.logintype,
    this.mobile,
    this.name,
    this.notification,
    this.profile,
    this.token,
    this.updatedAt,
    this.instagram,
    this.facebook,
    this.youtube,
    this.twitter,
  });

  UserModel.fromJson(Map<String, dynamic> json) {
    address = json['address']?.toString() ?? '';
    createdAt = json['created_at']?.toString() ?? '';
    customertotalpost = Adapter.forceInt(json['customertotalpost'] as int?);
    email = json['email']?.toString() ?? '';
    fcmId = json['fcm_id']?.toString() ?? '';
    authId = json['auth_id']?.toString() ?? '';
    id = json['id'] as int?;
    isActive = Adapter.forceInt(json['isActive']);
    isProfileCompleted = json['isProfileCompleted'] as bool?;
    logintype = json['logintype']?.toString() ?? '';
    mobile = json['mobile']?.toString() ?? '';
    name = json['name']?.toString() ?? '';
    notification = (json['notification'] is int)
        ? json['notification'] as int?
        : int.parse(json['notification']?.toString() ?? '0');
    profile = json['profile']?.toString() ?? '';
    token = json['token']?.toString() ?? '';
    updatedAt = json['updated_at']?.toString() ?? '';
    instagram = json['instagram_id']?.toString() ?? '';
    facebook = json['facebook_id']?.toString() ?? '';
    youtube = json['youtube_id']?.toString() ?? '';
    twitter = json['twitter_id']?.toString() ?? '';
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['address'] = address;
    data['created_at'] = createdAt;
    data['customertotalpost'] = customertotalpost;
    data['email'] = email;
    data['fcm_id'] = fcmId;
    data['auth_id'] = authId;
    data['id'] = id;
    data['isActive'] = isActive;
    data['isProfileCompleted'] = isProfileCompleted;
    data['logintype'] = logintype;
    data['mobile'] = mobile;
    data['name'] = name;
    data['notification'] = notification;
    data['profile'] = profile;
    data['token'] = token;
    data['updated_at'] = updatedAt;
    data['instagram_id'] = instagram;
    data['facebook_id'] = facebook;
    data['youtube_id'] = youtube;
    data['twitter_id'] = twitter;
    return data;
  }

  @override
  String toString() {
    return 'UserModel(address: $address, createdAt: $createdAt, customertotalpost: $customertotalpost, email: $email, fcmId: $fcmId, authId: $authId, id: $id, isActive: $isActive, isProfileCompleted: $isProfileCompleted, logintype: $logintype, mobile: $mobile, name: $name, notification: $notification, profile: $profile, token: $token, updatedAt: $updatedAt, instagram: $instagram, facebook: $facebook, youtube: $youtube, twitter: $twitter)';
  }
}
