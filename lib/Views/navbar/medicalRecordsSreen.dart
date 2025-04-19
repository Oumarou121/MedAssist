// import 'dart:io';

// import 'package:easy_pdf_viewer/easy_pdf_viewer.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:iconsax/iconsax.dart';
// import 'package:intl/intl.dart';
// import 'package:med_assist/Models/medicalRecord.dart';
// import 'package:url_launcher/url_launcher.dart';

// class MedicalRecordsScreen extends StatefulWidget {
//   final String uid;
//   final String name;
//   const MedicalRecordsScreen({
//     super.key,
//     required this.uid,
//     required this.name,
//   });

//   @override
//   State<MedicalRecordsScreen> createState() => _MedicalRecordsScreenState();
// }

// class _MedicalRecordsScreenState extends State<MedicalRecordsScreen> {
//   final List<MedicalRecord> _allRecords = [
//     MedicalRecord(
//       patientUid: '1',
//       title: 'Radiographie thoracique',
//       date: DateTime(2023, 11, 15),
//       type: 'Imagerie',
//       fileUrl:
//           'https://fxwpdqnowtwmckklipve.supabase.co/storage/v1/object/public/medical-records//Demande.pdf',
//       fileType: 'PDF',
//       fileSize: 2450,
//     ),
//     MedicalRecord(
//       patientUid: '2',
//       title: 'Analyse sanguine complète',
//       date: DateTime(2023, 10, 28),
//       type: 'Analyse',
//       fileUrl:
//           'https://fxwpdqnowtwmckklipve.supabase.co/storage/v1/object/public/medical-records//Demande.pdf',
//       fileType: 'PDF',
//       fileSize: 850,
//     ),
//     MedicalRecord(
//       patientUid: '3',
//       title: 'Ordonnance cardiologue',
//       date: DateTime(2023, 9, 12),
//       type: 'Prescription',
//       fileUrl:
//           'https://fxwpdqnowtwmckklipve.supabase.co/storage/v1/object/public/medical-records//WhatsApp%20Image%202025-04-13%20at%2012.03.59%20AM.jpeg',
//       fileType: 'Image',
//       fileSize: 320,
//     ),
//   ];

//   String _selectedCategory = 'Tous';
//   final double _maxStorage = 50;

//   List<MedicalRecord> get _filteredRecords {
//     if (_selectedCategory == 'Tous') return _allRecords;
//     return _allRecords.where((r) => r.type == _selectedCategory).toList();
//   }

//   double get _usedStorage {
//     return _allRecords.fold(0, (sum, r) => sum + r.fileSize) / 1024;
//   }

//   @override
//   Widget build(BuildContext context) {
//     final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
//     final size = MediaQuery.of(context).size;
//     return Padding(
//       padding: EdgeInsets.only(bottom: bottomPadding + 60),
//       child: Scaffold(
//         backgroundColor: const Color(0xFFF5F7FB),
//         body: CustomScrollView(
//           slivers: [
//             SliverAppBar(
//               expandedHeight: 80,
//               flexibleSpace: FlexibleSpaceBar(
//                 title: Text(
//                   'My Medical records',
//                   style: GoogleFonts.poppins(
//                     color: Colors.white,
//                     fontWeight: FontWeight.w600,
//                     fontSize: 16,
//                   ),
//                 ),

//                 background: Container(
//                   decoration: const BoxDecoration(
//                     gradient: LinearGradient(
//                       colors: [Color(0xFF00C853), Color(0xFFB2FF59)],
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight,
//                     ),
//                   ),
//                 ),
//               ),
//               actions: [
//                 IconButton(
//                   onPressed: () {},
//                   icon: Icon(Iconsax.search_status_1, color: Colors.white),
//                 ),
//               ],
//             ),
//             SliverToBoxAdapter(
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 20,
//                   vertical: 10,
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     _buildCategoryFilter(),
//                     SizedBox(height: size.height * 0.03),
//                     _buildStorageIndicator(),
//                     SizedBox(height: size.height * 0.03),
//                     _filteredRecords.isEmpty
//                         ? _buildEmptyState()
//                         : _buildDocumentsList(),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildCategoryFilter() {
//     final categories = ['Tous', 'Prescription', 'Analyse', 'Imagerie'];

//     return SizedBox(
//       height: 40,
//       child: ListView.separated(
//         scrollDirection: Axis.horizontal,
//         itemCount: categories.length,
//         separatorBuilder: (_, __) => const SizedBox(width: 10),
//         itemBuilder:
//             (_, index) => ChoiceChip(
//               label: Text(categories[index]),
//               selected: _selectedCategory == categories[index],
//               onSelected:
//                   (selected) => setState(() {
//                     _selectedCategory = categories[index];
//                   }),
//               selectedColor: Colors.green[100],
//               labelStyle: TextStyle(
//                 color:
//                     _selectedCategory == categories[index]
//                         ? Colors.green[800]
//                         : Colors.grey[600],
//               ),
//             ),
//       ),
//     );
//   }

//   Widget _buildStorageIndicator() {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.green[50],
//         borderRadius: BorderRadius.circular(15),
//       ),
//       child: Row(
//         children: [
//           Stack(
//             alignment: Alignment.center,
//             children: [
//               CircularProgressIndicator(
//                 value: _usedStorage / _maxStorage,
//                 strokeWidth: 8,
//                 color: Colors.green[800],
//                 backgroundColor: Colors.grey[200],
//               ),
//               Text(
//                 '${(_usedStorage / _maxStorage * 100).toStringAsFixed(0)}%',
//                 style: TextStyle(
//                   color: Colors.green[800],
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(width: 20),
//           Expanded(
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Espace utilisé',
//                       style: GoogleFonts.poppins(
//                         color: Colors.grey[600],
//                         fontSize: 14,
//                       ),
//                     ),
//                     Text(
//                       '${_usedStorage.toStringAsFixed(1)} Mo / ${_maxStorage} Mo',
//                       style: GoogleFonts.poppins(
//                         color: Colors.green[800],
//                         fontWeight: FontWeight.w600,
//                         fontSize: 16,
//                       ),
//                     ),
//                   ],
//                 ),
//                 Container(
//                   padding: const EdgeInsets.all(0),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(24),
//                   ),
//                   child: IconButton(
//                     onPressed: () {
//                       _showAddMedicalRecordModal();
//                     },
//                     icon: Icon(Iconsax.document_upload, color: Colors.black),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   File? _selectedFile;
//   String? _fileType;
//   Future<void> _pickFile() async {
//     try {
//       final FilePickerResult? result = await FilePicker.platform.pickFiles(
//         type: FileType.custom,
//         allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
//       );

//       if (result != null && result.files.isNotEmpty) {
//         final PlatformFile file = result.files.first;
//         if (file.path != null) {
//           setState(() {
//             _selectedFile = File(file.path!);
//             _fileType = file.extension;
//           });
//         }
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Erreur de sélection: $e')));
//     }
//   }

//   Widget _buildFilePreview(MedicalRecord record) {
//     return switch (record.fileType.toLowerCase()) {
//       'pdf' => PdfViewerWidget(url: record.fileUrl),
//       'image' => InteractiveViewer(
//         minScale: 0.5,
//         maxScale: 5,
//         child: Image.network(
//           record.fileUrl,
//           loadingBuilder: (context, child, progress) {
//             if (progress == null) return child;
//             return Container(
//               height: 300,
//               alignment: Alignment.center,
//               child: CircularProgressIndicator(
//                 value:
//                     progress.cumulativeBytesLoaded /
//                     (progress.expectedTotalBytes ?? 1),
//               ),
//             );
//           },
//           errorBuilder:
//               (context, error, stackTrace) => _ErrorPlaceholder(
//                 message: 'Erreur de chargement',
//                 icon: Icons.image_not_supported_rounded,
//               ),
//         ),
//       ),
//       _ => _ErrorPlaceholder(
//         message: 'Aperçu non disponible',
//         icon: Icons.visibility_off_rounded,
//       ),
//     };
//   }

//   Widget _buildFileUploadSection() {
//     final record = MedicalRecord(
//       patientUid: '1',
//       title: 'Radiographie thoracique',
//       date: DateTime(2023, 11, 15),
//       type: 'Imagerie',
//       fileUrl:
//           'https://fxwpdqnowtwmckklipve.supabase.co/storage/v1/object/public/medical-records//Demande.pdf',
//       fileType: 'PDF',
//       fileSize: 2450,
//     );
//     return Column(
//       children: [
//         if (_selectedFile != null) ...[
//           _buildFilePreview(record),
//           const SizedBox(height: 15),
//         ],
//         ElevatedButton.icon(
//           icon: const Icon(Icons.upload_rounded),
//           label: const Text('Importer un document'),
//           style: ElevatedButton.styleFrom(
//             padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//           ),
//           onPressed: _pickFile,
//         ),
//         if (_selectedFile != null)
//           Text(
//             'Fichier sélectionné: ${_selectedFile!.path.split('/').last}',
//             style: TextStyle(color: Colors.grey[600], fontSize: 14),
//           ),
//       ],
//     );
//   }

//   void _showAddMedicalRecordModal() {
//     final _titleController = TextEditingController();
//     final formKey = GlobalKey<FormState>();

//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
//       ),
//       builder: (BuildContext context) {
//         final screenHeight = MediaQuery.of(context).size.height;
//         final maxModalHeight = screenHeight * 0.95;
//         return Container(
//           constraints: BoxConstraints(maxHeight: maxModalHeight),
//           decoration: const BoxDecoration(
//             gradient: LinearGradient(
//               begin: Alignment.topCenter,
//               end: Alignment.bottomCenter,
//               colors: [Color(0xFFF5F7FB), Colors.white],
//             ),
//           ),
//           padding: EdgeInsets.only(
//             bottom: MediaQuery.of(context).viewInsets.bottom + 75,
//             left: 24,
//             right: 24,
//             top: 24,
//           ),
//           child: StatefulBuilder(
//             builder: (BuildContext context, StateSetter setModalState) {
//               return SingleChildScrollView(
//                 child: Form(
//                   key: formKey,
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Center(
//                         child: Container(
//                           width: 60,
//                           height: 4,
//                           decoration: BoxDecoration(
//                             color: Colors.grey.shade300,
//                             borderRadius: BorderRadius.circular(2),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 20),
//                       Row(
//                         children: [
//                           Icon(
//                             // Iconsax.health,
//                             Icons.description_rounded,
//                             color: Color(0xFF00C853),
//                             size: 28,
//                           ),
//                           const SizedBox(width: 12),
//                           Text(
//                             'Informations générales',
//                             style: GoogleFonts.poppins(
//                               fontSize: 22,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 20),
//                       Form(
//                         // key: formKey,
//                         child: Column(
//                           children: <Widget>[
//                             _buildModernFormField(
//                               controller: _titleController,
//                               label: 'Titre du fichier',
//                               icon: Iconsax.document,
//                               validator:
//                                   (value) =>
//                                       value!.isEmpty
//                                           ? 'Champ obligatoire'
//                                           : null,
//                             ),
//                             const SizedBox(height: 16),
//                             _buildModernFormField(
//                               controller: _titleController,
//                               label: 'Type de document',
//                               icon: Iconsax.tag,
//                               validator:
//                                   (value) =>
//                                       value!.isEmpty
//                                           ? 'Champ obligatoire'
//                                           : null,
//                             ),
//                             const SizedBox(height: 16),
//                             _buildFileUploadSection(),
//                           ],
//                         ),
//                       ),
//                       const SizedBox(height: 20),
//                       SizedBox(
//                         width: double.infinity,
//                         child: ElevatedButton.icon(
//                           icon: const Icon(
//                             Iconsax.add,
//                             size: 20,
//                             color: Colors.white,
//                           ),
//                           label: Text(
//                             'Enregistrer le dossier médical',
//                             style: GoogleFonts.poppins(
//                               fontWeight: FontWeight.w500,
//                               color: Colors.white,
//                             ),
//                           ),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: const Color(0xFF00C853),
//                             padding: const EdgeInsets.symmetric(vertical: 20),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(15),
//                             ),
//                           ),
//                           onPressed: () {},
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildModernFormField({
//     required TextEditingController controller,
//     required String label,
//     required IconData icon,
//     TextInputType? keyboardType,
//     String? Function(String?)? validator,
//   }) {
//     return TextFormField(
//       controller: controller,
//       keyboardType: keyboardType,
//       validator: validator,
//       decoration: InputDecoration(
//         labelText: label,
//         prefixIcon: Icon(icon, color: Colors.grey.shade600),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(15),
//           borderSide: BorderSide.none,
//         ),
//         filled: true,
//         fillColor: Colors.grey.shade100,
//         contentPadding: const EdgeInsets.symmetric(
//           vertical: 16,
//           horizontal: 20,
//         ),
//       ),
//       style: GoogleFonts.poppins(),
//     );
//   }

//   Widget _buildEmptyState() {
//     return Container(
//       height: 120,
//       margin: const EdgeInsets.symmetric(horizontal: 0),
//       decoration: BoxDecoration(
//         color: Colors.green[50],
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.folder_open, size: 40, color: Colors.blueGrey[200]),
//             const SizedBox(height: 8),
//             Text(
//               'No medical records',
//               style: GoogleFonts.poppins(
//                 color: Colors.blueGrey[300],
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildDocumentsList() {
//     return ListView.separated(
//       shrinkWrap: true,
//       physics: NeverScrollableScrollPhysics(),
//       itemCount: _filteredRecords.length,
//       separatorBuilder: (_, __) => const SizedBox(height: 10),
//       itemBuilder: (_, index) => _buildDocumentCard(_filteredRecords[index]),
//     );
//   }

//   Widget _buildDocumentCard(MedicalRecord record) {
//     return Card(
//       elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//       child: ListTile(
//         leading: Container(
//           width: 50,
//           height: 50,
//           decoration: BoxDecoration(
//             color: _getFileTypeColor(record.fileType),
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: Icon(_getFileTypeIcon(record.fileType), color: Colors.white),
//         ),
//         title: Text(
//           record.title,
//           style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
//         ),
//         subtitle: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               '${record.type} • ${record.formattedDate}',
//               style: TextStyle(color: Colors.grey[600], fontSize: 12),
//             ),
//             Text(
//               record.formattedSize,
//               style: TextStyle(color: Colors.grey[600], fontSize: 12),
//             ),
//           ],
//         ),
//         trailing: PopupMenuButton(
//           itemBuilder:
//               (context) => [
//                 PopupMenuItem(
//                   child: ListTile(
//                     leading: const Icon(Icons.remove_red_eye),
//                     title: Text('Prévisualiser'),
//                     onTap: () => _previewDocument(record),
//                   ),
//                 ),
//                 PopupMenuItem(
//                   child: ListTile(
//                     leading: const Icon(Icons.share),
//                     title: Text('Partager'),
//                     onTap: () => _shareDocument(record),
//                   ),
//                 ),
//                 PopupMenuItem(
//                   child: ListTile(
//                     leading: const Icon(Icons.delete, color: Colors.red),
//                     title: Text(
//                       'Supprimer',
//                       style: TextStyle(color: Colors.red),
//                     ),
//                     onTap: () => _deleteDocument(record),
//                   ),
//                 ),
//               ],
//         ),
//       ),
//     );
//   }

//   void _showSearch(BuildContext context) {
//     showSearch(
//       context: context,
//       delegate: MedicalRecordSearch(allRecords: _allRecords),
//     );
//   }

//   void _uploadFile() async {
//     // Implémentation de la sélection de fichier
//   }

//   void _previewDocument(MedicalRecord record) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => PreviewScreen(record: record)),
//     );
//   }

//   void _shareDocument(MedicalRecord record) {
//     // Logique de partage
//   }

//   void _deleteDocument(MedicalRecord record) {}

//   Color _getFileTypeColor(String type) {
//     switch (type.toLowerCase()) {
//       case 'pdf':
//         return Colors.red[400]!;
//       case 'image':
//         return Colors.green[400]!;
//       default:
//         return Colors.blue[400]!;
//     }
//   }

//   IconData _getFileTypeIcon(String type) {
//     switch (type.toLowerCase()) {
//       case 'pdf':
//         return Icons.picture_as_pdf;
//       case 'image':
//         return Icons.image;
//       default:
//         return Icons.insert_drive_file;
//     }
//   }
// }

// class MedicalRecordSearch extends SearchDelegate<MedicalRecord?> {
//   final List<MedicalRecord> allRecords;

//   MedicalRecordSearch({required this.allRecords});

//   @override
//   List<Widget> buildActions(BuildContext context) => [
//     IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
//   ];

//   @override
//   Widget buildLeading(BuildContext context) => IconButton(
//     icon: const Icon(Icons.arrow_back),
//     onPressed: () => close(context, null),
//   );

//   @override
//   Widget buildResults(BuildContext context) => _buildSearchResults(context);

//   @override
//   Widget buildSuggestions(BuildContext context) => _buildSearchResults(context);

//   Widget _buildSearchResults(BuildContext context) {
//     final results =
//         query.isEmpty
//             ? allRecords
//             : allRecords
//                 .where(
//                   (r) => r.title.toLowerCase().contains(query.toLowerCase()),
//                 )
//                 .toList();

//     return ListView.builder(
//       itemCount: results.length,
//       itemBuilder:
//           (_, index) => ListTile(
//             title: Text(results[index].title),
//             subtitle: Text(results[index].type),
//             onTap: () => close(context, results[index]),
//           ),
//     );
//   }
// }

// class PreviewScreen extends StatelessWidget {
//   final MedicalRecord record;

//   const PreviewScreen({super.key, required this.record});

//   @override
//   Widget build(BuildContext context) {
//     final colors = Theme.of(context).colorScheme;
//     final textTheme = Theme.of(context).textTheme;

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(record.title),
//         backgroundColor: colors.primaryContainer,
//         actions: [
//           IconButton.filledTonal(
//             style: IconButton.styleFrom(
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//             ),
//             icon: const Icon(Icons.open_in_new_rounded),
//             onPressed: () => _launchUrl(record.fileUrl, context),
//           ),
//           const SizedBox(width: 12),
//         ],
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _buildDetailsCard(context),
//             const SizedBox(height: 28),
//             _buildPreviewSection(context),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildDetailsCard(BuildContext context) {
//     final colors = Theme.of(context).colorScheme;
//     final textTheme = Theme.of(context).textTheme;

//     return Container(
//       decoration: BoxDecoration(
//         color: colors.surfaceVariant,
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             _buildDetailRow(
//               Icons.title_rounded,
//               'Titre',
//               record.title,
//               context,
//             ),
//             _buildDetailRow(
//               Icons.calendar_month_rounded,
//               'Date',
//               record.formattedDate,
//               context,
//             ),
//             _buildDetailRow(
//               Icons.medical_services_rounded,
//               'Type',
//               record.type,
//               context,
//             ),
//             _buildDetailRow(
//               Icons.insert_drive_file_rounded,
//               'Format',
//               record.fileType.toUpperCase(),
//               context,
//             ),
//             _buildDetailRow(
//               Icons.data_thresholding_rounded,
//               'Taille',
//               record.formattedSize,
//               context,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildDetailRow(
//     IconData icon,
//     String label,
//     String value,
//     BuildContext context,
//   ) {
//     final textTheme = Theme.of(context).textTheme;

//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 12),
//       child: Row(
//         children: [
//           Icon(icon, size: 20, color: Colors.grey[600]),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Text(
//               label,
//               style: textTheme.bodyMedium?.copyWith(
//                 color: Colors.grey[600],
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//           Text(
//             value,
//             style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildPreviewSection(BuildContext context) {
//     final textTheme = Theme.of(context).textTheme;

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             Text(
//               'Aperçu',
//               style: textTheme.titleLarge?.copyWith(
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//             const SizedBox(width: 12),
//             Expanded(child: Divider(thickness: 2, color: Colors.grey[300])),
//           ],
//         ),
//         const SizedBox(height: 20),
//         Container(
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(16),
//             border: Border.all(color: Colors.grey[200]!),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.05),
//                 blurRadius: 12,
//                 offset: const Offset(0, 4),
//               ),
//             ],
//           ),
//           clipBehavior: Clip.antiAlias,
//           child: _buildFilePreview(),
//         ),
//       ],
//     );
//   }

//   Widget _buildFilePreview() {
//     return switch (record.fileType.toLowerCase()) {
//       'pdf' => PdfViewerWidget(url: record.fileUrl),
//       'image' => InteractiveViewer(
//         minScale: 0.5,
//         maxScale: 5,
//         child: Image.network(
//           record.fileUrl,
//           loadingBuilder: (context, child, progress) {
//             if (progress == null) return child;
//             return Container(
//               height: 300,
//               alignment: Alignment.center,
//               child: CircularProgressIndicator(
//                 value:
//                     progress.cumulativeBytesLoaded /
//                     (progress.expectedTotalBytes ?? 1),
//               ),
//             );
//           },
//           errorBuilder:
//               (context, error, stackTrace) => _ErrorPlaceholder(
//                 message: 'Erreur de chargement',
//                 icon: Icons.image_not_supported_rounded,
//               ),
//         ),
//       ),
//       _ => _ErrorPlaceholder(
//         message: 'Aperçu non disponible',
//         icon: Icons.visibility_off_rounded,
//       ),
//     };
//   }

//   // ... _launchUrl reste inchangé
//   Future<void> _launchUrl(String url, BuildContext context) async {
//     try {
//       if (await canLaunchUrl(Uri.parse(url))) {
//         await launchUrl(Uri.parse(url));
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Impossible d\'ouvrir le fichier: $e')),
//       );
//     }
//   }
// }

// class _ErrorPlaceholder extends StatelessWidget {
//   final String message;
//   final IconData icon;

//   const _ErrorPlaceholder({required this.message, required this.icon});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 200,
//       color: Colors.grey[50],
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(icon, size: 40, color: Colors.grey[400]),
//           const SizedBox(height: 12),
//           Text(
//             message,
//             style: TextStyle(color: Colors.grey[500], fontSize: 16),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class PdfViewerWidget extends StatefulWidget {
//   final String url;

//   const PdfViewerWidget({super.key, required this.url});

//   @override
//   State<PdfViewerWidget> createState() => _PdfViewerWidgetState();
// }

// class _PdfViewerWidgetState extends State<PdfViewerWidget> {
//   late PDFDocument document;
//   bool isLoading = true;
//   bool hasError = false;

//   @override
//   void initState() {
//     super.initState();
//     _loadDocument();
//   }

//   Future<void> _loadDocument() async {
//     try {
//       document = await PDFDocument.fromURL(widget.url);
//       setState(() {
//         isLoading = false;
//         hasError = false;
//       });
//     } catch (e) {
//       setState(() {
//         isLoading = false;
//         hasError = true;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (hasError) {
//       //picture_as_pdf_off_rounded
//       return _ErrorPlaceholder(
//         message: 'Erreur de chargement',
//         icon: Icons.picture_as_pdf,
//       );
//     }

//     return SizedBox(
//       height: 500,
//       child:
//           isLoading
//               ? const Center(child: CircularProgressIndicator())
//               : PDFViewer(
//                 document: document,
//                 scrollDirection: Axis.vertical,
//                 lazyLoad: false,
//                 indicatorBackground:
//                     Theme.of(context).colorScheme.primaryContainer,
//                 indicatorText: Theme.of(context).colorScheme.onPrimaryContainer,
//                 progressIndicator: const CircularProgressIndicator(),
//                 backgroundColor: Colors.grey[50],
//               ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:med_assist/Models/medicalRecord.dart';
import 'package:med_assist/Models/user.dart';

class MedicalRecordsScreen extends StatefulWidget {
  final AppUserData userData;
  const MedicalRecordsScreen({super.key, required this.userData});

  @override
  State<MedicalRecordsScreen> createState() => _MedicalRecordsScreenState();
}

class _MedicalRecordsScreenState extends State<MedicalRecordsScreen> {
  late ManagersMedicalRecord _manager;
  List<MedicalRecord> _medicalRecords = [];
  List<MedicalRecord> _filteredRecords = [];
  String _selectedCategory = 'Tous';
  double _usedStorage = 0;
  final double _maxStorage = 50;

  @override
  void initState() {
    super.initState();
    _manager = ManagersMedicalRecord(
      uid: widget.userData.uid,
      name: widget.userData.name,
      medicalRecords: widget.userData.medicalRecords,
    );
    _loadMedicalRecords();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    final size = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding + 60),
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FB),
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 80,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  'My Medical records',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
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

            // SliverToBoxAdapter(
            //   child: Padding(
            //     padding: const EdgeInsets.symmetric(
            //       horizontal: 20,
            //       vertical: 10,
            //     ),
            //     child: Column(
            //       crossAxisAlignment: CrossAxisAlignment.start,
            //       children: [
            //         _buildCategoryFilter(),
            //         SizedBox(height: size.height * 0.03),
            //         _buildStorageIndicator(),
            //         SizedBox(height: size.height * 0.03),
            //         SliverPadding(
            //           padding: EdgeInsets.symmetric(horizontal: 20),
            //           sliver: SliverGrid(
            //             gridDelegate:
            //             SliverGridDelegateWithFixedCrossAxisCount(
            //               crossAxisCount: 2, // 2 colonnes
            //               crossAxisSpacing: 15,
            //               mainAxisSpacing: 15,
            //               childAspectRatio: 1.2, // Format des cartes
            //             ),
            //             delegate: SliverChildBuilderDelegate(
            //               (context, index) =>
            //                   _buildFolderItem(_filteredRecords[index]),
            //               childCount: _filteredRecords.length,
            //             ),
            //           ),
            //         ),
            //       ],
            //     ),
            //   ),
            // ),
            // SliverToBoxAdapter(child: _buildCategoryFilter()),
            SliverToBoxAdapter(child: SizedBox(height: size.height * 0.03)),
            SliverToBoxAdapter(child: _buildStorageIndicator()),
            SliverToBoxAdapter(child: SizedBox(height: size.height * 0.03)),

            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: 1,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) =>
                      _buildMedicalRecordCard(_filteredRecords[index]),
                  childCount: _filteredRecords.length,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Nouvelle méthode pour créer les items de dossier
  Widget _buildFolderItem(MedicalRecord record) {
    final fileCount = record.medicalFiles.length;

    return GestureDetector(
      onTap: () => _openFolderDetails(record),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: () => _openFolderDetails(record),
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Iconsax.folder, size: 40, color: Colors.green[700]),
                SizedBox(height: 10),
                Text(
                  record.title,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 5),
                Text(
                  '$fileCount fichier${fileCount > 1 ? 's' : ''}',
                  style: GoogleFonts.poppins(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Méthode pour ouvrir le détail d'un dossier
  void _openFolderDetails(MedicalRecord record) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder:
          (context) => Container(
            padding: EdgeInsets.all(20),
            height: MediaQuery.of(context).size.height * 0.8,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      record.title,
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: record.medicalFiles.length,
                    itemBuilder:
                        (context, index) =>
                            _buildFileItem(record.medicalFiles[index]),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildMedicalRecordCard(MedicalRecord record) {
    final totalSizeMB = record.totalSizeInKo / 1024;
    final progressValue = totalSizeMB / _maxStorage;
    final fileCount = record.medicalFiles.length;

    return GestureDetector(
      onTap: () => _openFolderDetails(record),
      child: Container(
        width: 280,
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFF00C853).withOpacity(0.1),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          record.title,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: const Color(0xFF00C853),
                          ),
                        ),
                      ),
                      _buildRecordStatus(record),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: progressValue,
                    backgroundColor: Colors.grey[200],
                    color:
                        progressValue > 0.9
                            ? Colors.red
                            : const Color(0xFF00C853),
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${totalSizeMB.toStringAsFixed(1)} Mo / ${_maxStorage} Mo',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Fichiers récents :',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...record.medicalFiles
                          .take(2)
                          .map(
                            (file) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Row(
                                children: [
                                  Icon(
                                    _getFileTypeIcon(file.type),
                                    color: Colors.green.shade400,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      '${file.title} (${(file.fileSize / 1024).toStringAsFixed(1)} Ko)',
                                      style: GoogleFonts.poppins(fontSize: 12),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    DateFormat('dd/MM').format(file.createdAt),
                                    style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      if (fileCount > 2)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            '+ ${fileCount - 2} autres...',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordStatus(MedicalRecord record) {
    final isUpdated = record.createdAt.isAfter(
      DateTime.now().subtract(Duration(days: 7)),
    );

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isUpdated ? Colors.green[50] : Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isUpdated ? 'Récent' : 'Archive',
        style: GoogleFonts.poppins(
          fontSize: 10,
          color: isUpdated ? Colors.green[800] : Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    final categories = ['Tous', 'Prescription', 'Analyse', 'Imagerie'];

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder:
            (_, index) => ChoiceChip(
              label: Text(categories[index]),
              selected: _selectedCategory == categories[index],
              onSelected:
                  (selected) => setState(() {
                    _selectedCategory = categories[index];
                  }),
              selectedColor: Colors.green[100],
              labelStyle: TextStyle(
                color:
                    _selectedCategory == categories[index]
                        ? Colors.green[800]
                        : Colors.grey[600],
              ),
            ),
      ),
    );
  }

  Widget _buildStorageIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.green[50],
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: _usedStorage / _maxStorage,
                  strokeWidth: 8,
                  color: Colors.green[800],
                  backgroundColor: Colors.grey[200],
                ),
                Text(
                  '${(_usedStorage / _maxStorage * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    color: Colors.green[800],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Espace utilisé',
                        style: GoogleFonts.poppins(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '${_usedStorage.toStringAsFixed(1)} Mo / ${_maxStorage} Mo',
                        style: GoogleFonts.poppins(
                          color: Colors.green[800],
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: IconButton(
                      onPressed: () {
                        _showAddMedicalRecordModal();
                      },
                      icon: Icon(Iconsax.folder_add, color: Colors.green),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _loadMedicalRecords() async {
    List<MedicalRecord> records = await _manager.getMedicalRecords();
    int totalKB = _manager.totalUsedMemory(records);
    double totalMB = totalKB / 1024;
    setState(() {
      _medicalRecords = records;
      _filteredRecords = _filterRecords(records, _selectedCategory);
      _usedStorage = totalMB;
    });
  }

  List<MedicalRecord> _filterRecords(
    List<MedicalRecord> records,
    String category,
  ) {
    if (category == 'Tous') return records;
    return records
        .where((record) => record.medicalFiles.any((f) => f.type == category))
        .toList();
  }

  Widget _buildFileItem(MedicalFile file) {
    return ListTile(
      leading: Icon(_getFileTypeIcon(file.type), color: Colors.green[700]),
      title: Text(file.title, style: GoogleFonts.poppins()),
      subtitle: Text(
        '${(file.fileSize / 1024).toStringAsFixed(1)} KB - ${DateFormat('dd/MM/yyyy').format(file.createdAt)}',
        style: GoogleFonts.poppins(color: Colors.grey[600]),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Iconsax.document_download, color: Colors.green[700]),
            onPressed: () => _downloadFile(file),
          ),
          IconButton(
            icon: Icon(Iconsax.trash, color: Colors.red[400]),
            onPressed: () => _confirmDeleteFile(file),
          ),
        ],
      ),
    );
  }

  IconData _getFileTypeIcon(String type) {
    switch (type) {
      case 'Prescription':
        return Iconsax.note_text;
      case 'Analyse':
        return Iconsax.health;
      case 'Imagerie':
        return Iconsax.gallery;
      default:
        return Iconsax.document;
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          Image.asset('assets/empty_folder.png', height: 150),
          const SizedBox(height: 20),
          Text(
            'Aucun dossier médical trouvé',
            style: GoogleFonts.poppins(color: Colors.grey[600]),
          ),
          const SizedBox(height: 10),
          ElevatedButton.icon(
            icon: Icon(Iconsax.document_upload),
            label: Text('Ajouter un premier document'),
            onPressed: _showAddMedicalRecordModal,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[50],
              foregroundColor: Colors.green[800],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _downloadFile(MedicalFile file) async {
    // Implémentez la logique de téléchargement
  }

  void _confirmDeleteFile(MedicalFile file) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Supprimer le fichier ?'),
            content: Text('Êtes-vous sûr de vouloir supprimer ${file.title} ?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Annuler'),
              ),
              TextButton(
                onPressed: () async {
                  await _manager.removeMedicalFile("", file);
                  _loadMedicalRecords();
                  Navigator.pop(context);
                },
                child: Text('Supprimer', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }

  void _showAddMedicalRecordModal() {
    // Implémentez la modale d'ajout
  }

  // ... Le reste du code existant (build, appbar, etc.) ...
}
