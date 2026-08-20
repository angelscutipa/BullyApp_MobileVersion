import 'package:flutter/material.dart';
import 'package:bully_app/features/nfc/data/models/nfc_response_model.dart';

class DetailsDogs extends StatelessWidget {
  // CORRECCIÓN: Las variables de instancia en un StatelessWidget deben ser 'final', no 'const'
  final DogData dog;
  
  const DetailsDogs({super.key, required this.dog});

  @override
  Widget build(BuildContext context) {
    // Colores de la paleta premium de tu app
    const Color scaffoldBgColor = Color(0xFF111112);
    const Color cardBgColor = Color(0xFF1C1C1E);
    const Color accentColor = Color(0xFFFFD700); // Dorado/Amarillo activo
    const Color secondaryTextColor = Colors.grey;

    // Evitamos problemas si la URL de la foto viene nula usando una imagen por defecto
    final String imageUrl = dog.photo ?? 'https://bullyapp.com.pe/storage/generic/files/default_dog.jpeg';

    return Scaffold(
      backgroundColor: scaffoldBgColor,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Imagen de Cabecera con Botón de Regresar
            Stack(
              children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.45,
                  // CORRECCIÓN: Se eliminó el 'const' de aquí porque contiene un NetworkImage dinámico
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(32),
                      bottomRight: Radius.circular(32),
                    ),
                    image: DecorationImage(
                      image: NetworkImage(imageUrl), 
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // Botón de Regresar Flotante
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: CircleAvatar(
                      backgroundColor: Colors.black.withOpacity(0.5),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Contenido de los Detalles
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 2. Fila de Nombre, Edad y Género dinámicos
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dog.name ?? 'Sin Nombre', // Mapeo dinámico del JSON
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            dog.breed ?? 'Raza no especificada', // Mapeo dinámico del JSON
                            style: TextStyle(
                              color: const Color.fromARGB(255, 255, 115, 0).withOpacity(0.8),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            '2 Años', // Aquí podrías calcularlo dinámicamente usando dog.birthDateFormatted si lo requieres
                            style: TextStyle(
                              color: accentColor,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                dog.gender == 'male' ? Icons.male : Icons.female, 
                                color: dog.gender == 'male' ? Colors.blue : Colors.pink, 
                                size: 18,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                dog.gender == 'male' ? 'Macho' : 'Hembra',
                                style: const TextStyle(color: Colors.white70, fontSize: 14),
                              ),
                            ],
                          )
                        ],
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 18),

                  // 3. Bloque de Propietario e Íconos de Acción
                  SizedBox(
                    width: double.infinity,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.person_outline,
                              color: Colors.white,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              dog.owner?.name ?? "Propietario no registrado", // Mapeo dinámico del propietario
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const SizedBox(width: 12),
                            _buildActionButton(Icons.location_on_outlined, "Mapa", () {
                              // Opcional: Aquí tienes las coordenadas listas en tu JSON: dog.owner?.addressMaps
                            }),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // 4. Grid de Atributos Clave (2x2) dinámicos
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 2.3,
                    children: [
                      _buildAttributeCard(
                        const Color.fromARGB(255, 11, 39, 25), 
                        const Color.fromARGB(255, 0, 255, 136), 
                        'Teléfono propietario', 
                        dog.owner?.phone ?? 'No asignado',
                      ),
                      _buildAttributeCard(
                        const Color.fromARGB(255, 13, 28, 41), 
                        const Color.fromARGB(255, 0, 225, 255), 
                        'Registro', 
                        dog.chipCorrelativo ?? 'Sin registro',
                      ),
                      _buildAttributeCard(
                        const Color.fromARGB(255, 36, 16, 5), 
                        const Color.fromARGB(255, 255, 166, 0), 
                        'Microchip', 
                        dog.microchip != null && dog.microchip!.length > 7 
                            ? '${dog.microchip!.substring(0, 7)}...' 
                            : dog.microchip ?? 'Sin microchip',
                      ),
                      _buildAttributeCard(
                        const Color.fromARGB(255, 39, 28, 5), 
                        accentColor, 
                        'Criadero', 
                        dog.kennel?.name ?? 'Particular',
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String tooltip, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1E),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white10),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 22,
        ),
      ),
    );
  }

  Widget _buildAttributeCard(Color bgColor, Color accent, String title, String value) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: accent.withOpacity(0.4),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis, // Previene desbordamiento de texto largo
          ),
        ],
      ),
    );
  }
}