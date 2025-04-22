import 'dart:io';
import 'package:mime/mime.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageService {
  final SupabaseClient supabase = Supabase.instance.client;

  Future<String> uploadProfileImage({
    required File file,
    required String uid,
  }) async {
    try {
      final extension = file.path.split('.').last;
      final filePath = 'profile_images/$uid.$extension';

      final mimeType = lookupMimeType(file.path) ?? 'application/octet-stream';

      await supabase.storage
          .from('users')
          .upload(
            filePath,
            file,
            fileOptions: FileOptions(contentType: mimeType, upsert: true),
          );

      final publicUrl = supabase.storage.from('users').getPublicUrl(filePath);

      return publicUrl;
    } catch (e) {
      throw Exception('Upload failed: $e');
    }
  }

  Future<void> deleteProfileImage(String publicUrl) async {
    try {
      final bucketUrl = supabase.storage
          .from('users')
          .getPublicUrl('')
          .replaceAll(RegExp(r'/$'), '');

      if (!publicUrl.startsWith(bucketUrl)) {
        throw Exception('URL invalide ou ne correspond pas au bucket.');
      }

      final relativePath = publicUrl.replaceFirst('$bucketUrl/', '');

      final response = await supabase.storage.from('users').remove([
        relativePath,
      ]);

      if (response.isEmpty) {
        throw Exception('Aucun fichier supprimé.');
      }
    } catch (e) {
      throw Exception('Échec de la suppression : $e');
    }
  }

  Future<String> uploadMedicalFile({
    required File file,
    required String uid,
    required String medicalRecordTitle,
    required String fileTitle,
  }) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      final encodedFileTitle = Uri.encodeComponent(fileTitle);
      final encodedMedicalRecordTitle = Uri.encodeComponent(medicalRecordTitle);
      final extension = file.path.split('.').last;

      final fileName = '${timestamp}_$encodedFileTitle.$extension';
      final filePath = '$uid/$encodedMedicalRecordTitle/$fileName';

      final mimeType = lookupMimeType(file.path) ?? 'application/octet-stream';

      final response = await supabase.storage
          .from('medical-records')
          .upload(
            filePath,
            file,
            fileOptions: FileOptions(contentType: mimeType),
          );

      if (response.isEmpty) {
        throw Exception('File upload failed');
      }

      final publicUrl = supabase.storage
          .from('medical-records')
          .getPublicUrl(filePath);

      return publicUrl;
    } catch (e) {
      throw Exception('Upload failed: $e');
    }
  }

  Future<void> deleteMedicalRecordFolder(
    String uid,
    String medicalRecordTitle,
  ) async {
    try {
      final encodedMedicalRecordTitle = Uri.encodeComponent(medicalRecordTitle);
      final folderPath = '$uid/$encodedMedicalRecordTitle';

      final List<FileObject> files = await supabase.storage
          .from('medical-records')
          .list(path: folderPath);

      if (files.isEmpty) {
        print('Aucun fichier à supprimer dans "$folderPath".');
        return;
      }

      final List<String> filePathsToDelete =
          files.map((file) => '$folderPath/${file.name}').toList();

      final deleteResponse = await supabase.storage
          .from('medical-records')
          .remove(filePathsToDelete);

      if (deleteResponse.isEmpty) {
        throw Exception('Échec de la suppression des fichiers.');
      }

      print('Tous les fichiers dans "$folderPath" ont été supprimés.');
    } catch (e) {
      throw Exception('Erreur lors de la suppression du dossier : $e');
    }
  }

  Future<void> deleteMedicalFileFromUrl(String publicUrl) async {
    try {
      final bucketUrl = supabase.storage
          .from('medical-records')
          .getPublicUrl('')
          .replaceAll(RegExp(r'/$'), '');

      if (!publicUrl.startsWith(bucketUrl)) {
        throw Exception('URL invalide ou ne correspond pas au bucket.');
      }

      final relativePath = publicUrl.replaceFirst('$bucketUrl/', '');

      final response = await supabase.storage.from('medical-records').remove([
        relativePath,
      ]);

      if (response.isEmpty) {
        throw Exception('Aucun fichier supprimé.');
      }
    } catch (e) {
      throw Exception('Échec de la suppression : $e');
    }
  }

  Future<String> moveMedicalFileFromUrl({
    required String publicUrl,
    required String newUid,
    required String newMedicalRecordTitle,
  }) async {
    try {
      final bucket = supabase.storage.from('medical-records');
      final bucketUrl = bucket.getPublicUrl('').replaceAll(RegExp(r'/$'), '');

      if (!publicUrl.startsWith(bucketUrl)) {
        throw Exception('URL invalide ou ne correspond pas au bucket.');
      }

      final oldPath = publicUrl.replaceFirst('$bucketUrl/', '');

      final fileBytes = await bucket.download(oldPath);

      final fileName = oldPath.split('/').last;
      final encodedNewTitle = Uri.encodeComponent(newMedicalRecordTitle);
      final newPath = '$newUid/$encodedNewTitle/$fileName';

      final mimeType = lookupMimeType(fileName) ?? 'application/octet-stream';

      await bucket.uploadBinary(
        newPath,
        fileBytes,
        fileOptions: FileOptions(contentType: mimeType),
      );

      await bucket.remove([oldPath]);

      final newPublicUrl = bucket.getPublicUrl(newPath);
      return newPublicUrl;
    } catch (e) {
      throw Exception('Erreur lors du déplacement : $e');
    }
  }
}
