import 'dart:convert';

class ApiKeys {
  static const String unAuthToken1 =
      'ODJlZjNmMTM4NTI1YzlhNTljYjQyNzk2ZDhjZGE4ZWVNeGVMa2FCb3BSajVUTGZhUkpwZGNSMWJXNTYwYjJiSXV2WEZlUWZGVmVmZU1DMGJDRHR0TEFIbWZrWFAzd0J4';

  static const String graphQLApiUrl1 =
      'ODJlZjNmMTM4NTI1YzlhNTljYjQyNzk2ZDhjZGE4ZWVodHRwczovL3RydXN0ZWQtZGFzc2llLTIxMzcuZGRuLmhhc3VyYS5hcHAvZ3JhcGhxbA==';

  static const String supabaseUrl1 =
      'ODJlZjNmMTM4NTI1YzlhNTljYjQyNzk2ZDhjZGE4ZWVodHRwczovL256ZmNqY2tmaWFoeWtycmNvZGdlLnN1cGFiYXNlLmNv';

  static const String supabaseAnonKey1 =
      'ODJlZjNmMTM4NTI1YzlhNTljYjQyNzk2ZDhjZGE4ZWVleUpoYkdjaU9pSklVekkxTmlJc0luUjVjQ0k2SWtwWFZDSjkuZXlKcGMzTWlPaUp6ZFhCaFltRnpaU0lzSW5KbFppSTZJbTU2Wm1OcVkydG1hV0ZvZVd0eWNtTnZaR2RsSWl3aWNtOXNaU0k2SW1GdWIyNGlMQ0pwWVhRaU9qRTNNamM1TXpNMk56Y3NJbVY0Y0NJNk1qQTBNelV3T1RZM04zMC5LcEhYNjMxcWZNbmFjZzNLcmNzQXFXSF9PYjBrLXZxT0FiMC1HWktMazhr';

  static const String _salt = '82ef3f138525c9a59cb42796d8cda8ee';

  static String decodeKey(String encoded) {
    final salted = utf8.decode(base64.decode(encoded));
    return salted.substring(_salt.length);
  }

  static String decodAnonKey(String encoded) {
    final saltedBytes = base64.decode(encoded);
    final salted = utf8.decode(saltedBytes);
    return salted.substring(_salt.length);
  }

  static String unAuthToken = decodAnonKey(unAuthToken1);

  static String graphQLApiUrl = decodeKey(graphQLApiUrl1);

  static String supabaseUrl = decodeKey(supabaseUrl1);

  static String supabaseAnonKey = decodAnonKey(supabaseAnonKey1);
}
