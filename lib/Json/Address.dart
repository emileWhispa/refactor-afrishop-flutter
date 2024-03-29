class Address {
  String addressId;
  String address;
  String delivery;
  String phone;
  String isoCode;
  String email;

  bool sending = false;

  Address(this.address, this.delivery, this.phone, this.email);

  Address.fromJson(Map<String, dynamic> json)
      : delivery = json['deliveryName'],
        address = json['addressDetail'],
        addressId = json['addressId'],
        phone = json['phone'],
        isoCode = json['isoCode'],
        email = json['email'];


  Map<String,dynamic> toJson()=>{
    "deliveryName":delivery,
    "addressDetail":address,
    "addressId":addressId,
    "phone":phone,
    "isoCode":isoCode,
    "email":email,
  };
}
