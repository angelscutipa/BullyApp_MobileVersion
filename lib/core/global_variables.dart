library;

// Una lista global accesible desde cualquier pantalla para añadir los números de serie
String nfcSerialNumbers = "";

// Opcional: Una variable estática para mantener el último escaneado
String lastScannedSerial = "";

String apiBaseUrl = "https://bullyapp.com.pe/api"; // URL base de la API

bool showGlobalAppBar = false; // Variable global para controlar la visibilidad del AppBar

bool isLoggedIn = false; // Variable global para controlar el estado de inicio de sesión

int AnimalID = -1;