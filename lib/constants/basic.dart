String appName = 'nisn';
const capitalizedAppName = "NISN";

String appCatchPhrase =
    "Welcome to $capitalizedAppName. This app is meant to visualize data submited by our community of Amateur Radio Operators from all over the world.\n\nIt was inspired by the NASA Challenge 2022 and was pioneered by a dedicated team of 5 engineering students.\n1. Namugwanya Mary Patience\n2.Inebe Millycent\n3. Sebakoni Akram\n4. Simeon Mubiru\n5. Nakiwala Leticia";
int versionNumber = 1;

String googleMapsAPI = "AIzaSyBZz3QZXs9uoA4goPNRn9GIQeRpes3hwF8";
String simeonMessage = appCatchPhrase;
String simeonWebsite = "bio.link/dorx";
String dorxPhoneNumber = "0708387637";

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
