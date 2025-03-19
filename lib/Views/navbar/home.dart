import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:med_assist/Models/user.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.userData});
  final AppUserData userData;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            "Hello,\n${widget.userData.name}!",
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ),
        actions: [
          Container(
            padding: const EdgeInsets.all(0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Iconsax.notification, color: Colors.black),
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 5),
                  child: CircleAvatar(
                    backgroundImage: NetworkImage(
                      'https://via.placeholder.com/50',
                    ),
                    radius: 22,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Text(""),
    );
  }

  // Widget _categoryItem(IconData icon, String title) {
  //   return Column(
  //     children: [
  //       Container(
  //         padding: const EdgeInsets.all(10),
  //         decoration: BoxDecoration(
  //           color: Colors.white,
  //           borderRadius: BorderRadius.circular(12),
  //           boxShadow: [
  //             BoxShadow(
  //               color: Colors.grey.shade300,
  //               blurRadius: 5,
  //               spreadRadius: 1,
  //             ),
  //           ],
  //         ),
  //         child: Icon(icon, size: 30, color: Colors.blue),
  //       ),
  //       const SizedBox(height: 5),
  //       Text(title, style: GoogleFonts.poppins(fontSize: 14)),
  //     ],
  //   );
  // }

  // Widget _appointmentCard() {
  //   return Container(
  //     padding: const EdgeInsets.all(15),
  //     decoration: BoxDecoration(
  //       color: Colors.purple.shade700,
  //       borderRadius: BorderRadius.circular(15),
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Row(
  //           children: [
  //             const CircleAvatar(
  //               backgroundImage: NetworkImage(
  //                 'https://via.placeholder.com/50', // Remplace par une image réelle
  //               ),
  //             ),
  //             const SizedBox(width: 10),
  //             Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 Text(
  //                   "Dr. Jennifer Smith",
  //                   style: GoogleFonts.poppins(
  //                     fontSize: 16,
  //                     fontWeight: FontWeight.w600,
  //                     color: Colors.white,
  //                   ),
  //                 ),
  //                 Text(
  //                   "Orthopedic Consultation (Foot & Ankle)",
  //                   style: GoogleFonts.poppins(
  //                     fontSize: 12,
  //                     color: Colors.white,
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ],
  //         ),
  //         const SizedBox(height: 10),
  //         Row(
  //           children: [
  //             const Icon(Iconsax.calendar, color: Colors.white, size: 20),
  //             const SizedBox(width: 5),
  //             Text(
  //               "Wed, 7 Sep 2024",
  //               style: GoogleFonts.poppins(color: Colors.white),
  //             ),
  //             const SizedBox(width: 15),
  //             const Icon(Iconsax.clock, color: Colors.white, size: 20),
  //             const SizedBox(width: 5),
  //             Text(
  //               "10:30 - 11:30 AM",
  //               style: GoogleFonts.poppins(color: Colors.white),
  //             ),
  //           ],
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget _recentVisitCard() {
  //   return Container(
  //     padding: const EdgeInsets.all(15),
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(15),
  //       boxShadow: [
  //         BoxShadow(
  //           color: Colors.grey.shade300,
  //           blurRadius: 5,
  //           spreadRadius: 1,
  //         ),
  //       ],
  //     ),
  //     child: Row(
  //       children: [
  //         const CircleAvatar(
  //           backgroundImage: NetworkImage(
  //             'https://via.placeholder.com/50', // Remplace par une image réelle
  //           ),
  //           radius: 30,
  //         ),
  //         const SizedBox(width: 10),
  //         Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Text(
  //               "Dr. Warner",
  //               style: GoogleFonts.poppins(
  //                 fontSize: 16,
  //                 fontWeight: FontWeight.w600,
  //               ),
  //             ),
  //             Text(
  //               "Neurology",
  //               style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
  //             ),
  //             Text(
  //               "5 years experience",
  //               style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
  //             ),
  //           ],
  //         ),
  //         const Spacer(),
  //         ElevatedButton(
  //           onPressed: () {},
  //           style: ElevatedButton.styleFrom(
  //             backgroundColor: Colors.blue,
  //             shape: RoundedRectangleBorder(
  //               borderRadius: BorderRadius.circular(8),
  //             ),
  //           ),
  //           child: Text(
  //             "Book Now",
  //             style: GoogleFonts.poppins(color: Colors.white),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}
