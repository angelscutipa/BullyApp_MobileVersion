import 'package:flutter/material.dart';
import 'package:bully_app/features/nfc/data/models/nfc_response_model.dart';
import 'package:bully_app/features/animals/data/models/animal_detail_response_model.dart';
import 'widgets/details_dogs/dog_details_view.dart';
import 'widgets/details_dogs/owner_details_view.dart';
import 'widgets/details_dogs/details_bottom_nav_bar.dart';

class DetailsDogs extends StatefulWidget {
  final DogData dog;
  final AnimalData? animal;

  const DetailsDogs({
    super.key,
    required this.dog,
    this.animal,
  });

  @override
  State<DetailsDogs> createState() => _DetailsDogsState();
}

class _DetailsDogsState extends State<DetailsDogs> {
  int _selectedTabIndex = 0; // 0: Ejemplar, 1: Propietario

  @override
  Widget build(BuildContext context) {
    const Color scaffoldBgColor = Color(0xFF0F0F12);

    return Scaffold(
      backgroundColor: scaffoldBgColor,
      body: _selectedTabIndex == 0
          ? DogDetailsView(dog: widget.dog, animal: widget.animal)
          : OwnerDetailsView(dog: widget.dog, animal: widget.animal),
      bottomNavigationBar: DetailsBottomNavBar(
        selectedIndex: _selectedTabIndex,
        onTabSelected: (index) {
          setState(() {
            _selectedTabIndex = index;
          });
        },
      ),
    );
  }
}
