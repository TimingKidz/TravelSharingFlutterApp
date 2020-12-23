
class Status {
  bool navbarNoti ;
  bool navbarTrip ;

  Status({this.navbarNoti,this.navbarTrip});


  Status.fromJson(Map<String, dynamic> json) {
    navbarNoti = json['navbarnoti'];
    navbarTrip = json["navbartrip"];
  }


}