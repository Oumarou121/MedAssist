import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:med_assist/Models/doctor.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

class MyDoctorsList extends StatefulWidget {
  final List<Doctor> doctors;
  final PersistentTabController persistentTabController;

  const MyDoctorsList({
    super.key,
    required List<Doctor> this.doctors,
    required PersistentTabController this.persistentTabController,
  });

  @override
  State<MyDoctorsList> createState() => _MyDoctorsListState();
}

class _MyDoctorsListState extends State<MyDoctorsList> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "My Recent Doctors",
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  widget.persistentTabController.jumpToTab(2);
                },
                child: Text(
                  "See All",
                  style: GoogleFonts.poppins(color: Colors.blue, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
        buildDoctorsList(
          doctors: widget.doctors,
          persistentTabController: widget.persistentTabController,
        ),
      ],
    );
  }
}

Widget buildDoctorsList({
  required List<Doctor> doctors,
  required PersistentTabController persistentTabController,
}) {
  if (doctors.isEmpty) {
    return _buildEmptyState();
  }

  final _doctors =
      doctors.length >= 3 ? doctors.sublist(doctors.length - 3) : doctors;

  return SizedBox(
    height: 200,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: _doctors.length,
      separatorBuilder: (_, __) => const SizedBox(width: 16),
      itemBuilder:
          (context, index) =>
              _buildDoctorCard(_doctors[index], persistentTabController),
    ),
  );
}

Widget _buildEmptyState() {
  return Container(
    height: 120,
    margin: const EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(
      color: Colors.blueGrey[50],
      borderRadius: BorderRadius.circular(16),
    ),
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.user_cirlce_add, size: 40, color: Colors.blueGrey[200]),
          const SizedBox(height: 8),
          Text(
            'No doctor is following you.',
            style: GoogleFonts.poppins(
              color: Colors.blueGrey[300],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildDoctorCard(
  Doctor doctor,
  PersistentTabController persistentTabController,
) {
  return GestureDetector(
    onTap: () {
      persistentTabController.jumpToTab(2);
    },
    child: Container(
      width: 160,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                child: Image.network(
                  doctor.imageUrl,
                  height: 100,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              if (doctor.isAvailable())
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Disponible',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doctor.name,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  doctor.specialty,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Iconsax.star1, color: Colors.amber.shade700, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${doctor.rating}',
                      style: GoogleFonts.poppins(fontSize: 12),
                    ),
                    const Spacer(),
                    Icon(Iconsax.video, color: Colors.blue.shade400, size: 18),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
