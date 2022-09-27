String appName = 'nisn';
const capitalizedAppName = "NISN";

String appCatchPhrase =
    "Welcome to $capitalizedAppName. This system is meant to easily manage the entire procurement system for Maisha Medical Supplies.";
int versionNumber = 1;

String simeonMessage = appCatchPhrase;
String allIndex = "allIndex";
String dorxPhoneNumber = "0708387637";

String algoliaAppID = "3SUWKZNUK8";
String searchApiKey = "2263d9b056d2a27fb13fd71fe91f1177";

class Configurations {
  static const _apiKey = "AIzaSyCVrkAtisr2r2Q2LsRsUOAx0ai94kXhFjk";
  static const _projectId = "maisha-medical-supplies";
  static const _senderID = "413526706214";
  static const _storageBucket = "maisha-medical-supplies.appspot.com";
  static const _appId = "1:413526706214:web:0ecaadbe7646931de53ee7";
  static const _databaseUrl =
      'https://maisha-medical-supplies-default-rtdb.firebaseio.com';

  String get apiKey => _apiKey;
  String get projectId => _projectId;
  String get databaseUrl => _databaseUrl;
  String get senderID => _senderID;
  String get storageBucket => _storageBucket;
  String get appId => _appId;
}
