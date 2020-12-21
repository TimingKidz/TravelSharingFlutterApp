
class Status {
  bool navbarNoti ;

  Status({this.navbarNoti});


  Status.fromJson(Map<String, dynamic> json) {
    navbarNoti = json['navbarnoti'];
  }


}