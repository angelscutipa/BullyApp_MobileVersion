import 'package:flutter/material.dart';
import 'package:bully_app/features/nfc/data/models/nfc_response_model.dart';
import 'package:bully_app/features/animals/data/models/animal_detail_response_model.dart';
import 'details_utils.dart';
import 'details_header_image.dart';
import 'details_cards.dart';

class OwnerDetailsView extends StatelessWidget {
  final DogData dog;
  final AnimalData? animal;

  const OwnerDetailsView({
    super.key,
    required this.dog,
    this.animal,
  });

  @override
  Widget build(BuildContext context) {
    const Color accentGold = Color(0xFFFFB800);
    const Color textGrey = Color(0xFF8E8E93);
    const Color breedGold = Color(0xFFE5A823);

    final owner = animal?.user?.owner;
    final user = animal?.user;
    final userID = animal?.user?.owner?.id;

    final String profilePhoto = owner?.profilePhoto ??
        dog.owner?.profilePhoto ??
        user?.avatar ??
        'https://bullyapp.com.pe/storage/generic/files/9add6a21-0f1e-4c74-a3f2-9dc4c262cc75.png';

    final String firstName = owner?.firstName ?? dog.owner?.name ?? 'Angel';
    final String lastName = owner?.lastName ?? '';
    final String fullName = '$firstName $lastName'.trim();
    final String username = user?.name != null
        ? '@${user!.name!.toLowerCase().replaceAll(' ', '')}'
        : '@angelcutipa';

    final String phone = owner?.phone ?? dog.owner?.phone ?? '+51 926 799 125';
    final String email = user?.email ?? dog.owner?.email ?? 'angelcutipa@gmail.com';
    final String city = owner?.city ?? dog.owner?.city ?? 'Lima';
    final String country = owner?.country ?? 'Perú';
    final String location = '$city, $country';
    final String addressMaps = owner?.addressMaps ?? location;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Imagen de Cabecera del Propietario
          DetailsHeaderImage(
            imageUrl: profilePhoto,
            badgeText: 'Criador Verificado IDBR',
            onBackTap: () => Navigator.of(context).pop(),
            /*onShareTap: () => DetailsUtils.shareProfile(context),*/
          ),

          // Contenido del Propietario
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 2. Nombre, Verificado, Badge Propietario y Handle
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        fullName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.verified,
                      color: Color(0xFF1D9BF0),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF201B10),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF4A3816),
                          width: 1,
                        ),
                      ),
                      child: const Text(
                        'PROPIETARIO',
                        style: TextStyle(
                          color: accentGold,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  username,
                  style: const TextStyle(
                    color: breedGold,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 16),

                // 3. Tarjeta de Membresía Premium VIP
                PremiumMembershipCard(ownerId: userID.toString()),

                const SizedBox(height: 20),

                // 4. Información de Contacto Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'INFORMACIÓN DE CONTACTO',
                      style: TextStyle(
                        color: textGrey,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      'DATOS DIRECTOS',
                      style: TextStyle(
                        color: Color(0xFF5E5E63),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Tarjetas de Contacto
                Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: InfoTechCardWithAction(
                            title: 'TELÉFONO',
                            value: phone,
                            titleColor: const Color(0xFF2EE686),
                            bgColor: const Color(0xFF0E1E16),
                            borderColor: const Color(0xFF194A2F),
                            actionWidget: InkWell(
                              onTap: () => DetailsUtils.makePhoneCall(phone),
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
                            title: 'REGISTRO CRIADOR',
                            value: 'IDBR-CR-2024',
                            titleColor: const Color(0xFF3897FF),
                            bgColor: const Color(0xFF0E1A29),
                            borderColor: const Color(0xFF17385E),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    InfoTechCardWithAction(
                      title: 'CORREO ELECTRÓNICO',
                      value: email,
                      titleColor: accentGold,
                      bgColor: const Color(0xFF1E170C),
                      borderColor: const Color(0xFF4A3816),
                      actionWidget: InkWell(
                        onTap: () => DetailsUtils.sendEmail(email),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: const Color(0xFF2B1F0E),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFF4A3816),
                              width: 1,
                            ),
                          ),
                          child: const Icon(
                            Icons.email_outlined,
                            color: accentGold,
                            size: 18,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    InfoTechCardWithAction(
                      title: 'UBICACIÓN',
                      value: location,
                      titleColor: accentGold,
                      bgColor: const Color(0xFF1E170C),
                      borderColor: const Color(0xFF4A3816),
                      actionWidget: InkWell(
                        onTap: () => DetailsUtils.openMap(addressMaps),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: const Color(0xFF2B1F0E),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFF4A3816),
                              width: 1,
                            ),
                          ),
                          child: const Icon(
                            Icons.location_on_outlined,
                            color: accentGold,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
