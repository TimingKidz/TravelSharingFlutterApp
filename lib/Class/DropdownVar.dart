import 'package:travel_sharing/localization.dart';

class DropdownVar{
  final List<String> genderList = [
    AppLocalizations.instance.text("male"),
    AppLocalizations.instance.text("female"),
    AppLocalizations.instance.text("lgbtq")
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
    AppLocalizations.instance.text("motorcycle"),
    AppLocalizations.instance.text("car")
  ];
  final List<String> ratingTypeList = [
    AppLocalizations.instance.text("polite"),
    AppLocalizations.instance.text("friendly"),
    AppLocalizations.instance.text("punctual")
  ];
}