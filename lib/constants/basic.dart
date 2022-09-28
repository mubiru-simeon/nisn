String appName = 'nisn';
const capitalizedAppName = "NISN";

String appCatchPhrase =
    "Welcome to $capitalizedAppName. This app is meant to visualize data submited by our community of Amateur Radios from all over the world.";
int versionNumber = 1;

String simeonMessage = appCatchPhrase;
String simeonWebsite = "bio.link/dorx";
String allIndex = "allIndex";
String dorxPhoneNumber = "0708387637";

String algoliaAppID = "3SUWKZNUK8";
String searchApiKey = "2263d9b056d2a27fb13fd71fe91f1177";

class Configurations {
  static const _apiKey = "AIzaSyAL7gB01-997q8jnT_JlBjMHRWXDjhjEPw";
  static const _projectId = "nisn-2b222";
  static const _senderID = "1097279434073";
  static const _storageBucket = "nisn-2b222.appspot.com";
  static const _appId = "1:1097279434073:web:fcd688e3ccf307e620f048";
  static const _databaseUrl = 'https://nisn-2b222-default-rtdb.firebaseio.com';

  String get apiKey => _apiKey;
  String get projectId => _projectId;
  String get databaseUrl => _databaseUrl;
  String get senderID => _senderID;
  String get storageBucket => _storageBucket;
  String get appId => _appId;
}
