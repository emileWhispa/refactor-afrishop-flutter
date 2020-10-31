import 'model.dart';

class User extends Model {
  String id;
  String number;
  String account;
  String nickname;
  String avatar;
  int type;
  String lastLoginTime;
  String lastLoginIp;
  int loginCount;
  String email;
  int emailFlag;
  String facebook;
  String createTime;
  String birthDay;
  String defaultAddress;
  String phone;
  int phoneFlag;
  int enableFlag;
  String invitedUser;
  int captcha;
  String token;
  String code;
  String slogan;
  int invitedCount;
  int sex;

  int followers = 0;
  int following = 0;
  int posts = 0;
  int likes = 0;
  int networks = 0;
  double wallet = 0.0;
  double networkAmount = 0.0;
  int visits = 0;
  bool invited = false;

  int cartCount = 0;

  bool requestHomePage = false;

  bool requestInvitation = false;

  User(this.id, this.lastLoginTime, this.birthDay, this.phone);

  User.fromJson(Map<String, dynamic> json)
      : lastLoginTime = json['lastLoginTime'],
        lastLoginIp = json['lastLoginIp'],
        loginCount = json['loginCount'],
        account = json['account'],
        nickname = json['nick'],
        avatar = json['avatar'],
        birthDay = json['birthday'],
        email = json['email'],
        emailFlag = json['emailFlag'],
        invitedUser = json['invitedUserId'],
        slogan = json['slogan'],
        invitedCount = json['invitedCount'],
        facebook = json['facebook'],
        createTime = json['createTime'],
        defaultAddress = json['defaultAddressId'],
        enableFlag = json['enableFlag'],
        sex = json['sex'],
        phone = json['phone'],
        captcha = json['captcha'],
        token = json['token'],
        networkAmount = json['networkAmount'] ?? 0.0,
        wallet = json['wallet'] ?? 0.0,
        followers = json['followers'] ?? 0,
        following = json['following'] ?? 0,
        networks = json['networks'] ?? 0,
        invited = json['invited'] ?? false,
        code = json['code'] ?? "",
        posts = json['posts'] ?? 0,
        visits = json['visits'] ?? 0,
        likes = json['likes'] ?? 0,
        phoneFlag = json['phoneFlag'],
        number = json['userNo'],
        type = json['userType'],
        id = json['userId'];

  Map<String, dynamic> toJson() => {
        'lastLoginTime': lastLoginTime,
        'lastLoginIp': lastLoginIp,
        'loginCount': loginCount,
        'account': account,
        'nick': nickname,
        'avatar': avatar,
        'birthday': birthDay,
        'email': email,
        'emailFlag': emailFlag,
        'invitedUserId': invitedUser,
        'invitedCount': invitedCount,
        'facebook': facebook,
        'createTime': createTime,
        'slogan': slogan,
        'defaultAddressId': defaultAddress,
        'enableFlag': enableFlag,
        'sex': sex,
        'phone': phone,
        'captcha': captcha,
        'token': token,
        'phoneFlag': phoneFlag,
        'userNo': number,
        'userType': type,
        'wallet': wallet,
        'code': code,
        'invited': invited ?? false,
        'id': discoverId,
        'userId': id,
      };

  static User fromJson2(Map<String, dynamic> json)=>User.fromJson(json) ;

  Map<String, dynamic> toServerModel() => {
        'externalId': id,
        'username': username,
        'mobile': phone,
        'email': email,
        'slogan': slogan,
        'avatar': avatar,
        'id': discoverId,
        'gender': sex,
      };


  String get discoverId => id;

  String display() => username;

  String get username => nickname ?? email ?? phone ?? account ??  "--";

  String singleChar() => username.substring(0, 1).toUpperCase();

  String get walletStr => (wallet ?? 0).toStringAsFixed(3);

  String get networkAmountStr => (networkAmount ?? 0).toString();
}
