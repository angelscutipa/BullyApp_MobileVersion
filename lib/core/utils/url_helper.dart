import '../global_variables.dart';

class UrlHelper {
  static int? getIdFromUrl(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return null;
    final segments = uri.pathSegments;
    if (segments.isEmpty) return null;
    return int.tryParse(segments.last);
  }

  static bool esUrlDeAnimalEspecifico(String url) {
    final animalId = getIdFromUrl(url);
    if (animalId != null) {
      AnimalID = animalId;
      print("EL ID DE ANIMAL ES: $AnimalID");
    }

    final regex = RegExp(r'/management/animals/\d+');
    return regex.hasMatch(url);
  }

  static bool isDashboard(String url) => url.contains('/dashboard');
  
  static bool isLoginOrLogout(String url) => 
      url.contains('/login') || url.contains('/logout');

  static bool isAnimalsManagement(String url) => 
      url.contains('/management/animals');
}
