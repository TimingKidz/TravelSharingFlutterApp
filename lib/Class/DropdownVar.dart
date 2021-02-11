import 'package:travel_sharing/localization.dart';

class DropdownVar{
  final List<String> genderList = [
    "Male",
    "Female",
    "LGBTQ"
  ];
  final List<String> facultyList = [
    "Agriculture",
    "Agro-Industry",
    "Architecture",
    "Associated Medical Science",
    "Business Administration",
    "College of Art, Media and Technology",
    "Dentistry",
    "Economics",
    "Education",
    "Engineering",
    "Fine Arts",
    "Humanities",
    "Law",
    "Medicine",
    "Nursing",
    "Pharmacy",
    "Political Science and Public Administration",
    "Public Health",
    "Science",
    "Social Sciences",
    "Veterinary Medicine",
    "Mass Communication",
  ];
  final List<String> tagList = [
    "Travel",
    "Travel & Activity"
  ];
  final List<String> vehicleType = [
    "Motorcycle",
    "Car"
  ];
  final List<String> ratingTypeList = [
    "Polite",
    "Friendly",
    "Punctual"
  ];

  String genderLangMap(String type){
    switch(type){
      case "Male": {
        return AppLocalizations.instance.text("male");
      }
      break;
      case "Female": {
        return AppLocalizations.instance.text("female");
      }
      break;
      case "LGBTQ": {
        return AppLocalizations.instance.text("lgbtq");
      }
      break;
      default: {
        return "";
      }
      break;
    }
  }

  String vehicleLangMap(String type){
    switch(type){
      case "Motorcycle": {
        return AppLocalizations.instance.text("motorcycle");
      }
      break;
      case "Car": {
        return AppLocalizations.instance.text("car");
      }
      break;
      default: {
        return "";
      }
      break;
    }
  }

  String ratingLangMap(String type){
    switch(type){
      case "Polite": {
        return AppLocalizations.instance.text("polite");
      }
      break;
      case "Friendly": {
        return AppLocalizations.instance.text("friendly");
      }
      break;
      case "Punctual": {
        return AppLocalizations.instance.text("punctual");
      }
      break;
      default: {
        return "";
      }
      break;
    }
  }
}