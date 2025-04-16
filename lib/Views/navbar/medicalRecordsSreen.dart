import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class MedicalRecordsScreen extends StatefulWidget {
  const MedicalRecordsScreen({super.key});

  @override
  State<MedicalRecordsScreen> createState() => _MedicalRecordsScreenState();
}

class _MedicalRecordsScreenState extends State<MedicalRecordsScreen> {
  final List<MedicalRecord> _allRecords = [
    MedicalRecord(
      id: '1',
      title: 'Radiographie thoracique',
      date: DateTime(2023, 11, 15),
      type: 'Imagerie',
      fileType: 'PDF',
      fileSize: 2450,
    ),
    MedicalRecord(
      id: '2',
      title: 'Analyse sanguine complète',
      date: DateTime(2023, 10, 28),
      type: 'Analyse',
      fileType: 'PDF',
      fileSize: 850,
    ),
    MedicalRecord(
      id: '3',
      title: 'Ordonnance cardiologue',
      date: DateTime(2023, 9, 12),
      type: 'Prescription',
      fileType: 'Image',
      fileSize: 320,
    ),
  ];

  String _selectedCategory = 'Tous';
  final double _maxStorage = 2048; // 2 Go en Mo

  List<MedicalRecord> get _filteredRecords {
    if (_selectedCategory == 'Tous') return _allRecords;
    return _allRecords.where((r) => r.type == _selectedCategory).toList();
  }

  double get _usedStorage {
    return _allRecords.fold(0, (sum, r) => sum + r.fileSize) / 1024;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Dossier Médical',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearch(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _uploadFile,
        child: const Icon(Icons.upload_file),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCategoryFilter(),
            const SizedBox(height: 20),
            _buildStorageIndicator(),
            const SizedBox(height: 20),
            Expanded(
              child:
                  _filteredRecords.isEmpty
                      ? _buildEmptyState()
                      : _buildDocumentsList(),
            ),
          ],
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
              selectedColor: Colors.blue[100],
              labelStyle: TextStyle(
                color:
                    _selectedCategory == categories[index]
                        ? Colors.blue[800]
                        : Colors.grey[600],
              ),
            ),
      ),
    );
  }

  Widget _buildStorageIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
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
                color: Colors.blue[800],
                backgroundColor: Colors.grey[200],
              ),
              Text(
                '${(_usedStorage / _maxStorage * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  color: Colors.blue[800],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(width: 20),
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
                  color: Colors.blue[800],
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentsList() {
    return ListView.separated(
      itemCount: _filteredRecords.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, index) => _buildDocumentCard(_filteredRecords[index]),
    );
  }

  Widget _buildDocumentCard(MedicalRecord record) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: _getFileTypeColor(record.fileType),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(_getFileTypeIcon(record.fileType), color: Colors.white),
        ),
        title: Text(
          record.title,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${record.type} • ${record.formattedDate}',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            Text(
              record.formattedSize,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder:
              (context) => [
                PopupMenuItem(
                  child: ListTile(
                    leading: const Icon(Icons.remove_red_eye),
                    title: Text('Prévisualiser'),
                    onTap: () => _previewDocument(record),
                  ),
                ),
                PopupMenuItem(
                  child: ListTile(
                    leading: const Icon(Icons.share),
                    title: Text('Partager'),
                    onTap: () => _shareDocument(record),
                  ),
                ),
                PopupMenuItem(
                  child: ListTile(
                    leading: const Icon(Icons.delete, color: Colors.red),
                    title: Text(
                      'Supprimer',
                      style: TextStyle(color: Colors.red),
                    ),
                    onTap: () => _deleteDocument(record),
                  ),
                ),
              ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open, size: 60, color: Colors.grey[400]),
          const SizedBox(height: 20),
          Text(
            'Aucun document trouvé',
            style: GoogleFonts.poppins(color: Colors.grey[500], fontSize: 16),
          ),
        ],
      ),
    );
  }

  void _showSearch(BuildContext context) {
    showSearch(
      context: context,
      delegate: MedicalRecordSearch(allRecords: _allRecords),
    );
  }

  void _uploadFile() async {
    // Implémentation de la sélection de fichier
  }

  void _previewDocument(MedicalRecord record) {
    // Navigation vers la prévisualisation
  }

  void _shareDocument(MedicalRecord record) {
    // Logique de partage
  }

  void _deleteDocument(MedicalRecord record) {
    setState(() {
      _allRecords.removeWhere((r) => r.id == record.id);
    });
  }

  Color _getFileTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'pdf':
        return Colors.red[400]!;
      case 'image':
        return Colors.green[400]!;
      default:
        return Colors.blue[400]!;
    }
  }

  IconData _getFileTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'image':
        return Icons.image;
      default:
        return Icons.insert_drive_file;
    }
  }
}

class MedicalRecordSearch extends SearchDelegate<MedicalRecord?> {
  final List<MedicalRecord> allRecords;

  MedicalRecordSearch({required this.allRecords});

  @override
  List<Widget> buildActions(BuildContext context) => [
    IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
  ];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
    icon: const Icon(Icons.arrow_back),
    onPressed: () => close(context, null),
  );

  @override
  Widget buildResults(BuildContext context) => _buildSearchResults(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildSearchResults(context);

  Widget _buildSearchResults(BuildContext context) {
    final results =
        query.isEmpty
            ? allRecords
            : allRecords
                .where(
                  (r) => r.title.toLowerCase().contains(query.toLowerCase()),
                )
                .toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder:
          (_, index) => ListTile(
            title: Text(results[index].title),
            subtitle: Text(results[index].type),
            onTap: () => close(context, results[index]),
          ),
    );
  }
}

class MedicalRecord {
  final String id;
  final String title;
  final DateTime date;
  final String type;
  final String fileType;
  final String? downloadUrl; // Lien de téléchargement optionnel
  final int fileSize; // Taille en Ko

  const MedicalRecord({
    required this.id,
    required this.title,
    required this.date,
    required this.type,
    required this.fileType,
    this.downloadUrl,
    this.fileSize = 0,
  });

  // Formatage de la date
  String get formattedDate => DateFormat('dd/MM/yyyy - HH:mm').format(date);

  // Formatage de la taille du fichier
  String get formattedSize {
    if (fileSize > 1024) {
      return '${(fileSize / 1024).toStringAsFixed(1)} Mo';
    }
    return '$fileSize Ko';
  }

  // Conversion depuis JSON
  factory MedicalRecord.fromJson(Map<String, dynamic> json) {
    return MedicalRecord(
      id: json['id'],
      title: json['title'],
      date: DateTime.parse(json['date']),
      type: json['type'],
      fileType: json['fileType'],
      downloadUrl: json['downloadUrl'],
      fileSize: json['fileSize'] ?? 0,
    );
  }

  // Conversion vers JSON
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'date': date.toIso8601String(),
    'type': type,
    'fileType': fileType,
    'downloadUrl': downloadUrl,
    'fileSize': fileSize,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicalRecord &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'MedicalRecord{id: $id, title: $title, date: $date, type: $type}';
  }
}
