import 'package:flutter/material.dart';
import 'package:bully_app/features/nfc/data/models/nfc_response_model.dart';
import 'package:bully_app/features/animals/data/models/animal_detail_response_model.dart';
import 'details_utils.dart';
import 'details_header_image.dart';
import 'details_cards.dart';

class DogDetailsView extends StatelessWidget {
  final DogData dog;
  final AnimalData? animal;

  const DogDetailsView({
    super.key,
    required this.dog,
    this.animal,
  });

  @override
  Widget build(BuildContext context) {
    const Color cardBgColor = Color(0xFF1A1A1E);
    const Color accentGold = Color(0xFFFFB800);
    const Color breedGold = Color(0xFFE5A823);
    const Color textGrey = Color(0xFF8E8E93);

    final String imageUrl = dog.photo ??
        animal?.profilePhoto ??
        'https://bullyapp.com.pe/storage/generic/files/default_dog.jpeg';

    final String dogName = dog.name ?? animal?.name ?? 'Doki';
    final String breedName = dog.breed ?? 'American Bully Classic';
    final String ownerName = dog.owner?.name ??
        (animal?.user?.owner != null
            ? '${animal!.user!.owner!.firstName ?? ''} ${animal!.user!.owner!.lastName ?? ''}'.trim()
            : null) ??
        animal?.user?.name ??
        'Angel Cutipa Samayani';
    final String ownerPhone = dog.owner?.phone ??
        animal?.user?.owner?.phone ??
        '926799125';
    final String? mapLocation = animal?.user?.owner?.addressMaps ??
        dog.owner?.city ??
        animal?.user?.owner?.city;

    final String registrationNo = dog.registrationNumber ??
        dog.chipCorrelativo ??
        animal?.chip?.correlativo ??
        'IDBR-PE-00008';
    final String rawMicrochip = dog.microchip ??
        animal?.microchip ??
        animal?.chip?.code ??
        '4241531393';
    final String kennelName = dog.kennel?.name ?? 'Particular';
    final List<TrophyInfo> trophiesList = animal?.trophies ?? [];

    final bool isMale = DetailsUtils.isMale(dog.sex ?? dog.gender);
    final String sexText = DetailsUtils.getSexText(dog.sex ?? dog.gender);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Imagen de Cabecera
          DetailsHeaderImage(
            imageUrl: imageUrl,
            badgeText: 'Ejemplar Certificado',
            onBackTap: () => Navigator.of(context).pop(),
          ),

          // Contenido de los Detalles
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 2. Nombre, Verificado, Raza y Badges (Edad / Género)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  dogName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(
                                Icons.verified,
                                color: Color(0xFF1D9BF0),
                                size: 22,
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            breedName,
                            style: const TextStyle(
                              color: breedGold,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF201B10),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFF5E4515),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            DetailsUtils.calculateAge(dog.birthDateFormatted),
                            style: const TextStyle(
                              color: accentGold,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF101B26),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFF1A3D63),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isMale ? Icons.male : Icons.female,
                                color: isMale ? const Color(0xFF3897FF) : Colors.pinkAccent,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                sexText,
                                style: TextStyle(
                                  color: isMale ? const Color(0xFF3897FF) : Colors.pinkAccent,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
/*
                const SizedBox(height: 16),

                // 3. Tarjeta de Propietario
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: cardBgColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF282832),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: const Color(0xFF2C2212),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: const Color(0xFF4D3817),
                                width: 1,
                              ),
                            ),
                            child: const Icon(
                              Icons.person_outline,
                              color: accentGold,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'PROPIETARIO',
                                style: TextStyle(
                                  color: textGrey,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                ownerName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      InkWell(
                        onTap: () => DetailsUtils.openMap(mapLocation),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: const Color(0xFF222228),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFF32323C),
                              width: 1,
                            ),
                          ),
                          child: const Icon(
                            Icons.location_on_outlined,
                            color: accentGold,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
*/
                const SizedBox(height: 14),

                // 4. Tres Tarjetas de Estado (Semental, En Venta, Seguridad)
                Row(
                  children: [
                    Expanded(
                      child: InfoStatusCard(
                        title: '● SEMENTAL',
                        value: 'Disponible',
                        titleColor: const Color(0xFF2EE686),
                        valueColor: const Color(0xFF2EE686),
                        bgColor: const Color(0xFF0E1E16),
                        borderColor: const Color(0xFF194A2F),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: InfoStatusCard(
                        title: 'EN VENTA',
                        value: dog.status ?? 'De Casa',
                        titleColor: textGrey,
                        valueColor: Colors.white,
                        bgColor: cardBgColor,
                        borderColor: const Color(0xFF2A2A32),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          final int? animalId = dog.id ?? animal?.id;
                          final String targetUrl = animalId != null
                              ? 'https://bullyapp.com.pe/management/animals/$animalId'
                              : 'https://bullyapp.com.pe/management/animals';
                          Navigator.of(context).pop(targetUrl);
                        },
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Center(
                            child: Text(
                              'Ver Perfil',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // 5. Ficha Técnica Oficial Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'FICHA TÉCNICA OFICIAL',
                      style: TextStyle(
                        color: textGrey,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      'IDBR REG.',
                      style: TextStyle(
                        color: Color(0xFF6E6E73),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Grid 2x2 Ficha Técnica
                Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: InfoTechCardWithAction(
                            title: 'TELÉFONO',
                            value: ownerPhone,
                            titleColor: const Color(0xFF2EE686),
                            bgColor: const Color(0xFF0E1E16),
                            borderColor: const Color(0xFF194A2F),
                            actionWidget: InkWell(
                              onTap: () => DetailsUtils.makePhoneCall(ownerPhone),
                              borderRadius: BorderRadius.circular(50),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF133823),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.phone_outlined,
                                  color: Color(0xFF2EE686),
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: InfoTechCard(
                            title: 'REGISTRO OFICIAL',
                            value: registrationNo,
                            titleColor: const Color(0xFF3897FF),
                            bgColor: const Color(0xFF0E1A29),
                            borderColor: const Color(0xFF17385E),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: InfoTechCard(
                            title: 'MICROCHIP NFC',
                            value: DetailsUtils.formatMicrochip(rawMicrochip),
                            titleColor: breedGold,
                            bgColor: const Color(0xFF21180D),
                            borderColor: const Color(0xFF4A3418),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: InfoTechCard(
                            title: 'CRIADERO / KENNEL',
                            value: kennelName,
                            titleColor: breedGold,
                            bgColor: const Color(0xFF21180D),
                            borderColor: const Color(0xFF4A3418),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // 6. Sección de Premios (Trophies)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'PREMIOS (${trophiesList.isEmpty ? 1 : trophiesList.length})',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF201B10),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF4A3816),
                          width: 1,
                        ),
                      ),
                      child: const Text(
                        'Títulos Oficiales',
                        style: TextStyle(
                          color: accentGold,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Lista Horizontal de Trofeos
                SizedBox(
                  height: 120,
                  child: trophiesList.isNotEmpty
                      ? ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: trophiesList.length,
                          separatorBuilder: (context, index) => const SizedBox(width: 10),
                          itemBuilder: (context, index) {
                            final trophy = trophiesList[index];
                            return TrophyCard(
                              title: trophy.category ?? trophy.championship ?? 'Best in Show',
                              subtitle: '${trophy.position ?? '1er'} Lugar • ${trophy.date ?? '2023'}',
                            );
                          },
                        )
                      : const TrophyCard(
                          title: 'Best in Show',
                          subtitle: '1er Lugar • 2023',
                        ),
                ),
/*
                const SizedBox(height: 20),

                // Botón Acción Solicitar Monta / Contacto
                SizedBox(
                  height: 52,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => DetailsUtils.makePhoneCall(ownerPhone),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentGold,
                      foregroundColor: Colors.black,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.phone_in_talk_rounded,
                          size: 18,
                          color: Colors.black,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Solicitar Monta / Contacto',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
*/
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
