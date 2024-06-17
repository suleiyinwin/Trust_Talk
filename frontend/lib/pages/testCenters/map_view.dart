import 'package:flutter/material.dart';
import 'package:frontend/components/colors.dart';
import 'package:frontend/components/textstyles.dart';
import 'package:frontend/pages/testCenters/component/map_view_card.dart';

class mapView extends StatefulWidget {
  const mapView({super.key});

  @override
  State<mapView> createState() => _mapViewState();
}

class _mapViewState extends State<mapView> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(appBar: CustomAppBar(), body: MapViewBody());
  }
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        "STI Test Centers Locator",
        style: TTtextStyles.bodylargeRegular.copyWith(fontSize: 18),
      ),
      backgroundColor: AppColors.white,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class MapViewBody extends StatelessWidget {
  const MapViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const SearchBar(),
          const SizedBox(height: 18),
          Align(
            alignment: Alignment.centerLeft,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width - 110),
              child: const ButtonRow(),
            ),
          ),
          const SizedBox(height: 20),
          const MapViewCard(
            title: 'Chakphong 2 Medical Clinic',
            reviews: 'No reviews',
            description: 'Walk-in clinic • 286/2 Moo 8, Prachauthit Road',
            status: 'Closed',
            hours: 'Opens 9AM',
          ),
        ],
      ),
    );
  }
}

class SearchBar extends StatelessWidget {
  const SearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController _searchController = TextEditingController();

    return Row(
      children: [
        Expanded(
          child: Container(
            height: 50,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                  hintText: 'Search Location',
                  hintStyle: TTtextStyles.bodymediumRegular,
                  fillColor: AppColors.secondaryColor,
                  filled: true,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      borderSide:
                          const BorderSide(color: AppColors.secondaryColor)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      borderSide:
                          const BorderSide(color: AppColors.secondaryColor)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                      borderSide:
                          const BorderSide(color: AppColors.secondaryColor))),
            ),
          ),
        ),
        const SizedBox(width: 9),
        Container(
          height: 50,
          width: 50,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primaryColor),
              color: AppColors.primaryColor),
          child: IconButton(
            icon: const Icon(Icons.search_rounded, color: AppColors.white),
            onPressed: () {},
          ),
        )
      ],
    );
  }
}

class ButtonRow extends StatefulWidget {
  const ButtonRow({super.key});

  @override
  State<ButtonRow> createState() => _ButtonRowState();
}

class _ButtonRowState extends State<ButtonRow> {
  bool isClinicsSelected = true;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        CustomButton(
          text: 'Clinics',
          icon: Icons.local_hospital,
          isSelected: isClinicsSelected,
          onTap: () {
            setState(() {
              isClinicsSelected = true;
            });
          },
        ),
        CustomButton(
          text: 'Testing Centers',
          icon: Icons.health_and_safety,
          isSelected: !isClinicsSelected,
          onTap: () {
            setState(() {
              isClinicsSelected = false;
            });
          },
        ),
      ],
    );
  }
}

class CustomButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const CustomButton({
    Key? key,
    required this.text,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryColor : AppColors.secondaryColor,
          borderRadius: BorderRadius.circular(30.0),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? AppColors.secondaryColor
                  : AppColors.primaryColor,
            ),
            const SizedBox(width: 8),
            Text(
              text,
              style: TTtextStyles.bodymediumRegular.copyWith(
                color: isSelected
                    ? AppColors.secondaryColor
                    : AppColors.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
