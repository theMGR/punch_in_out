class UserDto {
  String? username;
  String? password;
  String? userType;
  String? punchIn;
  String? punchOut;
  double? punchInLat;
  double? punchInLon;
  double? punchOutLat;
  double? punchOutLon;
  int? id;
  String? punchInScanData;
  String? punchOutScanData;

  UserDto({
    this.username,
    this.password,
    this.userType,
    this.punchIn,
    this.punchOut,
    this.punchInLat,
    this.punchInLon,
    this.punchOutLat,
    this.punchOutLon,
    this.id,
    this.punchInScanData,
    this.punchOutScanData,
  });

  UserDto.fromJson(Map<String, dynamic> json) {
    username = json['username'];
    password = json['password'];
    userType = json['userType'];
    punchIn = json['punchIn'];
    punchOut = json['punchOut'];
    punchInLat = json['punchInLat'];
    punchInLon = json['punchInLon'];
    punchOutLat = json['punchOutLat'];
    punchOutLon = json['punchOutLon'];
    id = json['id'];
    punchInScanData = json['punchInScanData'];
    punchOutScanData = json['punchOutScanData'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['username'] = username;
    data['password'] = password;
    data['userType'] = userType;
    data['punchIn'] = punchIn;
    data['punchOut'] = punchOut;
    data['punchInLat'] = punchInLat;
    data['punchInLon'] = punchInLon;
    data['punchOutLat'] = punchOutLat;
    data['punchOutLon'] = punchOutLon;
    data['id'] = id;
    data['punchInScanData'] = punchInScanData;
    data['punchOutScanData'] = punchOutScanData;
    return data;
  }
}
