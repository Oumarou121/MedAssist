// import 'dart:io';
// import 'package:mime/mime.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

// class StorageService {
//   final SupabaseClient supabase = Supabase.instance.client;

//   Future<String> uploadMedicalFile({
//     required File file,
//     required String uid,
//     required String medicalRecordTitle,
//     required String fileTitle,
//   }) async {
//     try {
//       final timestamp = DateTime.now().millisecondsSinceEpoch;
//       final fileName = '${timestamp}_$fileTitle';
//       final filePath = '$uid/$medicalRecordTitle/$fileName';

//       final mimeType = lookupMimeType(file.path) ?? 'application/octet-stream';

//       final response = await supabase.storage
//           .from('medical-records')
//           .upload(
//             filePath,
//             file,
//             fileOptions: FileOptions(contentType: mimeType),
//           );

//       if (response.isEmpty) {
//         throw Exception('File upload failed');
//       }

//       final publicUrl = supabase.storage
//           .from('medical-records')
//           .getPublicUrl(filePath);

//       return publicUrl;
//     } catch (e) {
//       throw Exception('Upload failed: $e');
//     }
//   }

//   Future<void> deleteMedicalRecordFolder(
//     String uid,
//     String medicalRecordTitle,
//   ) async {
//     try {
//       final folderPath = '$uid/$medicalRecordTitle';

//       final List<FileObject> files = await supabase.storage
//           .from('medical-records')
//           .list(path: folderPath);

//       if (files.isEmpty) {
//         print('Aucun fichier à supprimer dans "$folderPath".');
//         return;
//       }

//       final List<String> filePathsToDelete =
//           files.map((file) => '$folderPath/${file.name}').toList();

//       final deleteResponse = await supabase.storage
//           .from('medical-records')
//           .remove(filePathsToDelete);

//       if (deleteResponse.isEmpty) {
//         throw Exception('Échec de la suppression des fichiers.');
//       }

//       print('Tous les fichiers dans "$folderPath" ont été supprimés.');
//     } catch (e) {
//       throw Exception('Erreur lors de la suppression du dossier : $e');
//     }
//   }

//   Future<void> deleteMedicalFileFromUrl(String publicUrl) async {
//     try {
//       final bucketUrl = supabase.storage
//           .from('medical-records')
//           .getPublicUrl('')
//           .replaceAll(RegExp(r'/$'), '');

//       if (!publicUrl.startsWith(bucketUrl)) {
//         throw Exception('URL invalide ou ne correspond pas au bucket.');
//       }

//       final relativePath = publicUrl.replaceFirst('$bucketUrl/', '');

//       final response = await supabase.storage.from('medical-records').remove([
//         relativePath,
//       ]);

//       if (response.isEmpty) {
//         throw Exception('Aucun fichier supprimé.');
//       }
//     } catch (e) {
//       throw Exception('Échec de la suppression : $e');
//     }
//   }

//   // Future<String> moveMedicalFileWithinUid({
//   //   required String publicUrl,
//   //   required String newMedicalRecordTitle,
//   // }) async {
//   //   try {
//   //     final bucket = supabase.storage.from('medical-records');
//   //     final bucketUrl = bucket.getPublicUrl('').replaceAll(RegExp(r'/$'), '');

//   //     if (!publicUrl.startsWith(bucketUrl)) {
//   //       throw Exception('URL invalide ou ne correspond pas au bucket.');
//   //     }

//   //     // 1. Extraire l'ancien chemin (ex: uid/OldTitle/filename.pdf)
//   //     final oldPath = publicUrl.replaceFirst('$bucketUrl/', '');

//   //     // 2. Extraire le uid et le nom du fichier
//   //     final pathParts = oldPath.split('/');
//   //     if (pathParts.length < 3) {
//   //       throw Exception('Chemin invalide.');
//   //     }

//   //     final uid = pathParts[0];
//   //     final fileName = pathParts.last;

//   //     // 3. Télécharger le fichier
//   //     final fileBytes = await bucket.download(oldPath);

//   //     // 4. Déterminer le nouveau chemin
//   //     final newPath = '$uid/$newMedicalRecordTitle/$fileName';

//   //     // 5. Déterminer le type MIME
//   //     final mimeType = lookupMimeType(fileName) ?? 'application/octet-stream';

//   //     // 6. Uploader le fichier à la nouvelle destination
//   //     await bucket.uploadBinary(
//   //       newPath,
//   //       fileBytes,
//   //       fileOptions: FileOptions(contentType: mimeType),
//   //     );

//   //     // 7. Supprimer l'ancien fichier
//   //     await bucket.remove([oldPath]);

//   //     // 8. Retourner le nouveau public URL
//   //     final newPublicUrl = bucket.getPublicUrl(newPath);
//   //     return newPublicUrl;
//   //   } catch (e) {
//   //     throw Exception('Erreur lors du déplacement du fichier : $e');
//   //   }
//   // }

//   Future<String> moveMedicalFileFromUrl({
//     required String publicUrl,
//     required String newUid,
//     required String newMedicalRecordTitle,
//   }) async {
//     try {
//       final bucket = supabase.storage.from('medical-records');
//       final bucketUrl = bucket.getPublicUrl('').replaceAll(RegExp(r'/$'), '');

//       if (!publicUrl.startsWith(bucketUrl)) {
//         throw Exception('URL invalide ou ne correspond pas au bucket.');
//       }

//       final oldPath = publicUrl.replaceFirst('$bucketUrl/', '');

//       // Télécharger le fichier
//       final fileBytes = await bucket.download(oldPath);

//       // Construire le nouveau chemin
//       final fileName = oldPath.split('/').last;
//       final newPath = '$newUid/$newMedicalRecordTitle/$fileName';

//       // Déterminer le type MIME
//       final mimeType = lookupMimeType(fileName) ?? 'application/octet-stream';

//       // Uploader à la nouvelle destination
//       await bucket.uploadBinary(
//         newPath,
//         fileBytes,
//         fileOptions: FileOptions(contentType: mimeType),
//       );

//       // Supprimer l'ancien fichier
//       await bucket.remove([oldPath]);

//       // Retourner le nouveau public URL
//       final newPublicUrl = bucket.getPublicUrl(newPath);
//       return newPublicUrl;
//     } catch (e) {
//       throw Exception('Erreur lors du déplacement : $e');
//     }
//   }
// }

import 'dart:io';
import 'package:mime/mime.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageService {
  final SupabaseClient supabase = Supabase.instance.client;

  Future<String> uploadMedicalFile({
    required File file,
    required String uid,
    required String medicalRecordTitle,
    required String fileTitle,
  }) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      // Encoder les titres pour les espaces et autres caractères spéciaux
      final encodedFileTitle = Uri.encodeComponent(fileTitle);
      final encodedMedicalRecordTitle = Uri.encodeComponent(medicalRecordTitle);

      // Construire le nom de fichier et le chemin d'upload
      final fileName = '${timestamp}_$encodedFileTitle';
      final filePath = '$uid/$encodedMedicalRecordTitle/$fileName';

      final mimeType = lookupMimeType(file.path) ?? 'application/octet-stream';

      // Upload du fichier
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

      // Obtenir l'URL publique du fichier téléchargé
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

      // Télécharger le fichier
      final fileBytes = await bucket.download(oldPath);

      // Construire le nouveau chemin
      final fileName = oldPath.split('/').last;
      final encodedNewTitle = Uri.encodeComponent(newMedicalRecordTitle);
      final newPath = '$newUid/$encodedNewTitle/$fileName';

      // Déterminer le type MIME
      final mimeType = lookupMimeType(fileName) ?? 'application/octet-stream';

      // Uploader à la nouvelle destination
      await bucket.uploadBinary(
        newPath,
        fileBytes,
        fileOptions: FileOptions(contentType: mimeType),
      );

      // Supprimer l'ancien fichier
      await bucket.remove([oldPath]);

      // Retourner le nouveau public URL
      final newPublicUrl = bucket.getPublicUrl(newPath);
      return newPublicUrl;
    } catch (e) {
      throw Exception('Erreur lors du déplacement : $e');
    }
  }
}
