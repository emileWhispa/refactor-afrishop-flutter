class Address {
  String addressId;
  String address;
  String delivery;
  String phone;
  String email;

  bool sending = false;

  Address(this.address, this.delivery, this.phone, this.email);

  Address.fromJson(Map<String, dynamic> json)
      : delivery = json['deliveryName'],
        address = json['addressDetail'],
        addressId = json['addressId'],
        phone = json['phone'],
        email = json['email'];
}
