import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:med_assist/Models/doctor.dart';
import 'package:med_assist/Models/message.dart';
import 'package:med_assist/Models/user.dart';
import 'package:provider/provider.dart';

class MedicalMessagingScreen extends StatelessWidget {
  final Stream<AppUserData> userDataStream;
  const MedicalMessagingScreen({super.key, required this.userDataStream});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return StreamBuilder<AppUserData>(
      stream: userDataStream,
      builder: (context, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (userSnapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text('Erreur utilisateur : ${userSnapshot.error}'),
            ),
          );
        }

        if (!userSnapshot.hasData) {
          return const Scaffold(
            body: Center(child: Text("Utilisateur non trouvé.")),
          );
        }

        final userData = userSnapshot.data!;
        final ManagersMedicalMessage managersMedicalMessage =
            ManagersMedicalMessage(
              uid: userData.uid,
              name: userData.name,
              medicalMessages: userData.medicalMessages,
            );

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                expandedHeight: 80,
                backgroundColor: const Color(0xFF00C853),
                automaticallyImplyLeading: false,
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.symmetric(horizontal: 10),
                  title: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        icon: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 0),
                      Text(
                        'my_medical_messages'.tr(),
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF00C853), Color(0xFFB2FF59)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    onPressed: () {},
                    icon: Icon(Iconsax.search_status_1, color: Colors.white),
                  ),
                ],
              ),

              SliverToBoxAdapter(child: SizedBox(height: size.height * 0.02)),

              StreamBuilder<List<MedicalMessageData>>(
                stream: managersMedicalMessage.getMedicalMessagesStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return SliverToBoxAdapter(
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (snapshot.hasError) {
                    return SliverToBoxAdapter(
                      child: Center(child: Text('Erreur : ${snapshot.error}')),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _buildEmptyState(),
                      ),
                    );
                  }

                  final medicalMessageDatas =
                      snapshot.data!..sort(
                        (a, b) => b.medicalMessage.createdAt.compareTo(
                          a.medicalMessage.createdAt,
                        ),
                      );

                  return SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final messageData = medicalMessageDatas[index];
                      return _ModernMessageCard(
                        medicalMessage: messageData.medicalMessage,
                        doctor: messageData.doctor,
                        managersMedicalMessage: managersMedicalMessage,
                      );
                    }, childCount: medicalMessageDatas.length),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   final size = MediaQuery.of(context).size;

  //   final userData = Provider.of<AppUserData?>(context);
  //   if (userData == null) {
  //     return const Scaffold(body: Center(child: CircularProgressIndicator()));
  //   }

  //   final managersMedicalMessage = ManagersMedicalMessage(
  //     uid: userData.uid,
  //     name: userData.name,
  //     medicalMessages: userData.medicalMessages,
  //   );

  //   return Scaffold(
  //     body: CustomScrollView(
  //       slivers: [
  //         SliverAppBar(
  //           pinned: true,
  //           expandedHeight: 80,
  //           backgroundColor: const Color(0xFF00C853),
  //           automaticallyImplyLeading: false,
  //           flexibleSpace: FlexibleSpaceBar(
  //             titlePadding: const EdgeInsets.symmetric(horizontal: 10),
  //             title: Row(
  //               children: [
  //                 IconButton(
  //                   onPressed: () => Navigator.of(context).pop(),
  //                   icon: const Icon(
  //                     Icons.arrow_back_ios_new,
  //                     color: Colors.white,
  //                     size: 18,
  //                   ),
  //                 ),
  //                 const SizedBox(width: 0),
  //                 Text(
  //                   'my_medical_messages'.tr(),
  //                   style: GoogleFonts.poppins(
  //                     color: Colors.white,
  //                     fontWeight: FontWeight.w600,
  //                     fontSize: 18,
  //                   ),
  //                 ),
  //               ],
  //             ),
  //             background: Container(
  //               decoration: const BoxDecoration(
  //                 gradient: LinearGradient(
  //                   colors: [Color(0xFF00C853), Color(0xFFB2FF59)],
  //                   begin: Alignment.topLeft,
  //                   end: Alignment.bottomRight,
  //                 ),
  //               ),
  //             ),
  //           ),
  //           actions: [
  //             IconButton(
  //               onPressed: () {},
  //               icon: Icon(Iconsax.search_status_1, color: Colors.white),
  //             ),
  //           ],
  //         ),

  //         SliverToBoxAdapter(child: SizedBox(height: size.height * 0.02)),

  //         StreamBuilder<List<MedicalMessageData>>(
  //           stream: managersMedicalMessage.getMedicalMessagesStream(),
  //           builder: (context, snapshot) {
  //             if (snapshot.connectionState == ConnectionState.waiting) {
  //               return SliverToBoxAdapter(
  //                 child: Center(child: CircularProgressIndicator()),
  //               );
  //             }

  //             if (snapshot.hasError) {
  //               return SliverToBoxAdapter(
  //                 child: Center(child: Text('Erreur : ${snapshot.error}')),
  //               );
  //             }

  //             if (!snapshot.hasData || snapshot.data!.isEmpty) {
  //               return SliverToBoxAdapter(
  //                 child: Padding(
  //                   padding: const EdgeInsets.symmetric(horizontal: 20),
  //                   child: _buildEmptyState(),
  //                 ),
  //               );
  //             }

  //             final medicalMessageDatas =
  //                 snapshot.data!..sort(
  //                   (a, b) => b.medicalMessage.createdAt.compareTo(
  //                     a.medicalMessage.createdAt,
  //                   ),
  //                 );

  //             return SliverList(
  //               delegate: SliverChildBuilderDelegate((context, index) {
  //                 final messageData = medicalMessageDatas[index];
  //                 return _ModernMessageCard(
  //                   medicalMessage: messageData.medicalMessage,
  //                   doctor: messageData.doctor,
  //                   managersMedicalMessage: managersMedicalMessage,
  //                 );
  //               }, childCount: medicalMessageDatas.length),
  //             );
  //           },
  //         ),
  //       ],
  //     ),
  //   );
  // }

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
            Icon(Iconsax.message, size: 40, color: Colors.blueGrey[200]),
            const SizedBox(height: 8),
            Text(
              'no_medical_messages'.tr(),
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
}

class _ModernMessageCard extends StatelessWidget {
  final MedicalMessage medicalMessage;
  final Doctor doctor;
  final ManagersMedicalMessage managersMedicalMessage;

  const _ModernMessageCard({
    required this.medicalMessage,
    required this.doctor,
    required this.managersMedicalMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10.0),
      child: Material(
        color: Colors.white,
        elevation: medicalMessage.isRead ? 0 : 3,
        shadowColor: Colors.green.shade100,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => _navigateToDetail(context),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSenderAvatar(),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 8),
                      _buildMessagePreview(),
                      const SizedBox(height: 12),
                      _buildMetadata(),
                    ],
                  ),
                ),
                _buildStatusIndicator(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSenderAvatar() {
    return Stack(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundImage: NetworkImage(doctor.imageUrl),
        ),
        Positioned(
          right: -4,
          top: -4,
          child: Container(
            height: 12,
            width: 12,
            decoration: BoxDecoration(
              color:
                  (medicalMessage.isUrgent && !medicalMessage.isRead)
                      ? Colors.red
                      : Colors.green,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Text(
          doctor.name,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: Colors.green.shade800,
          ),
        ),
        SizedBox(width: 10),
        if (!medicalMessage.isRead)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'no_read'.tr(),
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMessagePreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          doctor.specialty,
          style: GoogleFonts.poppins(color: Colors.grey.shade600, fontSize: 13),
        ),
        const SizedBox(height: 6),
        Text(
          medicalMessage.message,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.poppins(fontSize: 14, height: 1.4),
        ),
      ],
    );
  }

  Widget _buildMetadata() {
    return Row(
      children: [
        Icon(Icons.access_time, size: 14, color: Colors.grey.shade500),
        const SizedBox(width: 6),
        Text(
          DateFormat('dd MMM yyyy - HH:mm').format(medicalMessage.createdAt),
          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildStatusIndicator() {
    return Column(
      children: [
        const SizedBox(height: 8),
        if (medicalMessage.isRead)
          Icon(
            Icons.check_circle_outline,
            color: Colors.green.shade600,
            size: 20,
          )
        else
          Icon(Icons.circle_outlined, color: Colors.grey.shade400, size: 20),
      ],
    );
  }

  void _navigateToDetail(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder:
            (context, animation, secondaryAnimation) => MessageDetailScreen(
              medicalMessage: medicalMessage,
              doctor: doctor,
              managersMedicalMessage: managersMedicalMessage,
            ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }
}

class MessageDetailScreen extends StatefulWidget {
  final MedicalMessage medicalMessage;
  final Doctor doctor;
  final ManagersMedicalMessage managersMedicalMessage;

  const MessageDetailScreen({
    super.key,
    required this.medicalMessage,
    required this.doctor,
    required this.managersMedicalMessage,
  });
  @override
  State<MessageDetailScreen> createState() => _MessageDetailPageState();
}

class _MessageDetailPageState extends State<MessageDetailScreen> {
  late bool isRead;
  @override
  void initState() {
    super.initState();
    isRead = widget.medicalMessage.isRead;
  }

  bool showResponseForm = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF00C853)),
        ),
        title: Text(
          'message_details'.tr(),
          style: GoogleFonts.poppins(
            color: const Color(0xFF00C853),
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMessageMeta(),
            const SizedBox(height: 24),
            _SectionTitle(title: 'message'.tr()),
            const SizedBox(height: 8),
            _buildMessageContent(),
            if (widget.medicalMessage.response.message.isNotEmpty) ...[
              const SizedBox(height: 32),
              _SectionTitle(title: 'response'.tr()),
              const SizedBox(height: 8),
              _buildResponseContent(),
            ],
            const SizedBox(height: 40),

            _buildActionButtons(context),

            if (showResponseForm) ...[
              const SizedBox(height: 16),
              _buildResponse(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMessageMeta() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _MetaItem(
            icon: Icons.person,
            title: 'doctor'.tr(),
            value: widget.doctor.name,
          ),
          const Divider(height: 32),
          _MetaItem(
            icon: Icons.local_hospital,
            title: 'speciality'.tr(),
            value: widget.doctor.specialty,
          ),
        ],
      ),
    );
  }

  Widget _buildMessageContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.medicalMessage.message,
          style: GoogleFonts.poppins(fontSize: 15, height: 1.6),
        ),
        const SizedBox(height: 24),
        Text(
          '${'received_at'.tr()}  ${DateFormat('dd MMMM yyyy HH:mm').format(widget.medicalMessage.createdAt)}',
          style: GoogleFonts.poppins(color: Colors.grey.shade600, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildResponseContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.medicalMessage.response.message,
          style: GoogleFonts.poppins(fontSize: 15, height: 1.6),
          textAlign: TextAlign.right,
        ),
        const SizedBox(height: 24),
        Text(
          '${'sent_at'.tr()} ${DateFormat('dd MMMM yyyy HH:mm').format(widget.medicalMessage.response.createdAt)}',
          style: GoogleFonts.poppins(color: Colors.grey.shade600, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        if (widget.medicalMessage.response.message.isEmpty)
          Expanded(
            child: OutlinedButton.icon(
              icon: const Icon(Icons.reply, color: Color(0xFF00C853)),
              label: Text(
                'answer'.tr(),
                style: GoogleFonts.poppins(color: const Color(0xFF00C853)),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: Color(0xFF00C853)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                setState(() {
                  showResponseForm = true;
                });
              },
            ),
          ),
        const SizedBox(width: 16),
        if (!isRead)
          Expanded(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.done_all, color: Colors.white),
              label: Text(
                'mark_read'.tr(),
                style: GoogleFonts.poppins(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00C853),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () async {
                await widget.managersMedicalMessage.readMedicalMessage(
                  medicalMessageId: widget.medicalMessage.id,
                  read: true,
                );
                setState(() {
                  isRead = true;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('message_mark_read'.tr())),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildResponse(BuildContext context) {
    final TextEditingController responseController = TextEditingController();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: responseController,
          maxLines: 5,
          decoration: InputDecoration(
            hintText: "${'write_response'.tr()}...",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          icon: const Icon(Icons.send, color: Colors.white),
          label: Text(
            'send_answer'.tr(),
            style: TextStyle(color: Colors.white),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00C853),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () async {
            final messageText = responseController.text.trim();
            if (messageText.isEmpty) return;

            ResponseMedicalMessage responseMedicalMessage =
                ResponseMedicalMessage(
                  message: messageText,
                  createdAt: DateTime.now(),
                );
            await widget.managersMedicalMessage.responseMedicalMessage(
              medicalMessageId: widget.medicalMessage.id,
              response: responseMedicalMessage,
            );
            await widget.managersMedicalMessage.readMedicalMessage(
              medicalMessageId: widget.medicalMessage.id,
              read: true,
            );
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('response_sent'.tr())));

            Navigator.pop(context);

            // setState(() {
            //   showResponseForm = false;
            // });
          },
        ),
      ],
    );
  }
}

class _MetaItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _MetaItem({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 22, color: const Color(0xFF00C853)),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.chat_bubble_outline, color: Color(0xFF00C853)),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
