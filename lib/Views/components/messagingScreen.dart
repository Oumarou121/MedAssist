import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:med_assist/Models/message.dart';

class MedicalMessagingScreen extends StatelessWidget {
  const MedicalMessagingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('')),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white],
          ),
        ),
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: mockMessages.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder:
              (context, index) =>
                  _ModernMessageCard(message: mockMessages[index]),
        ),
      ),
    );
  }
}

class _ModernMessageCard extends StatelessWidget {
  final MedicalMessage message;

  const _ModernMessageCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(16),
      elevation: message.isRead ? 0 : 2,
      child: Container(
        decoration: BoxDecoration(
          color: message.isRead ? Colors.white : Colors.blue.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200, width: 1),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _navigateToDetail(context),
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
          backgroundImage: NetworkImage(message.senderImage),
        ),
        if (message.isUrgent)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red.shade600,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(
                Icons.error_outline,
                size: 14,
                color: Colors.white,
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
          message.senderName,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: Colors.blue.shade900,
          ),
        ),
        if (!message.isRead)
          Container(
            margin: const EdgeInsets.only(left: 8),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.blue.shade800,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Nouveau',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 11,
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
          message.senderSpecialty,
          style: GoogleFonts.poppins(color: Colors.grey.shade600, fontSize: 13),
        ),
        const SizedBox(height: 6),
        Text(
          message.message,
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
          DateFormat('dd MMM yyyy - HH:mm').format(message.timestamp),
          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600),
        ),
        if (message.hasAttachment)
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Icon(
              Icons.attach_file,
              size: 14,
              color: Colors.blue.shade800,
            ),
          ),
      ],
    );
  }

  Widget _buildStatusIndicator() {
    return Column(
      children: [
        if (message.isUrgent)
          Icon(Icons.priority_high, color: Colors.red.shade600, size: 20),
        const SizedBox(height: 8),
        if (message.isRead)
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
            (context, animation, secondaryAnimation) =>
                MessageDetailScreen(message: message),
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

class MessageDetailScreen extends StatelessWidget {
  final MedicalMessage message;

  const MessageDetailScreen({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade800,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.senderName,
              style: GoogleFonts.poppins(fontSize: 16, color: Colors.white),
            ),
            Text(
              message.senderSpecialty,
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMessageMeta(),
            const SizedBox(height: 32),
            _buildMessageContent(),
            const SizedBox(height: 40),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageMeta() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _MetaItem(
            icon: Icons.calendar_month,
            title: 'Date d\'envoi',
            value: DateFormat('dd MMMM yyyy').format(message.timestamp),
          ),
          const Divider(height: 32),
          _MetaItem(
            icon: Icons.medical_services,
            title: 'Spécialité',
            value: message.senderSpecialty,
          ),
          if (message.hasAttachment) ...[
            const Divider(height: 32),
            _MetaItem(
              icon: Icons.attach_file,
              title: 'Pièces jointes',
              value: '1 ordonnance',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Message :',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        const SizedBox(height: 16),
        Text(
          message.message,
          style: GoogleFonts.poppins(fontSize: 15, height: 1.6),
        ),
        const SizedBox(height: 24),
        Text(
          'Reçu à ${DateFormat('HH:mm').format(message.timestamp)}',
          style: GoogleFonts.poppins(color: Colors.grey.shade600, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            icon: Icon(Icons.reply, color: Colors.blue.shade800),
            label: Text(
              'Répondre',
              style: GoogleFonts.poppins(color: Colors.blue.shade800),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(color: Colors.blue.shade800),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {},
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.check, color: Colors.white),
            label: Text(
              'Marquer comme lu',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade800,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {},
          ),
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
        Icon(icon, size: 22, color: Colors.blue.shade800),
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

// // Ajoutez cette partie à la fin de votre fichier

// final List<MedicalMessage> mockMessages = [
//   MedicalMessage(
//     senderName: 'Dr. Marie Dupont',
//     senderSpecialty: 'Cardiologue',
//     senderImage: 'assets/images/doctor1.jpg',
//     message:
//         'Vos résultats de l\'ECG montrent une amélioration, continuez le traitement.',
//     timestamp: DateTime.now().subtract(const Duration(hours: 2)),
//   ),
//   MedicalMessage(
//     senderName: 'Dr. Jean Martin',
//     senderSpecialty: 'Généraliste',
//     senderImage: 'assets/images/doctor2.jpg',
//     message: 'Veuillez prendre rendez-vous pour le suivi de votre traitement.',
//     timestamp: DateTime.now().subtract(const Duration(days: 1)),
//     isRead: true,
//   ),
//   MedicalMessage(
//     senderName: 'Dr. Sophie Leroy',
//     senderSpecialty: 'Dermatologue',
//     senderImage: 'assets/images/doctor3.jpg',
//     message: 'Réaction allergique détectée dans vos derniers tests.',
//     timestamp: DateTime.now().subtract(const Duration(days: 3)),
//     isUrgent: true,
//   ),
// ];
