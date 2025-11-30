import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Upload une image et retourner l'URL
  Future<String?> uploadImage({
    required Uint8List imageBytes,
    required String fileName,
    required String folder, // 'movies', 'users', etc.
  }) async {
    try {
      // Créer une référence unique
      final String path =
          '$folder/${DateTime.now().millisecondsSinceEpoch}_$fileName';
      final Reference ref = _storage.ref().child(path);

      // Uploader le fichier
      final UploadTask uploadTask = ref.putData(
        imageBytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      // Attendre la fin de l'upload
      final TaskSnapshot snapshot = await uploadTask;

      // Récupérer l'URL de téléchargement
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Erreur lors de l\'upload de l\'image: $e');
      return null;
    }
  }

  // Upload une image de film
  Future<String?> uploadMovieImage(
    Uint8List imageBytes,
    String fileName,
  ) async {
    return uploadImage(
      imageBytes: imageBytes,
      fileName: fileName,
      folder: 'movies',
    );
  }

  // Upload une photo de profil
  Future<String?> uploadProfileImage(
    Uint8List imageBytes,
    String userId,
  ) async {
    return uploadImage(
      imageBytes: imageBytes,
      fileName: 'profile_$userId.jpg',
      folder: 'users',
    );
  }

  // Supprimer une image
  Future<bool> deleteImage(String imageUrl) async {
    try {
      final Reference ref = _storage.refFromURL(imageUrl);
      await ref.delete();
      return true;
    } catch (e) {
      print('Erreur lors de la suppression de l\'image: $e');
      return false;
    }
  }

  // Récupérer les métadonnées d'une image
  Future<FullMetadata?> getImageMetadata(String imageUrl) async {
    try {
      final Reference ref = _storage.refFromURL(imageUrl);
      return await ref.getMetadata();
    } catch (e) {
      print('Erreur lors de la récupération des métadonnées: $e');
      return null;
    }
  }

  // Lister toutes les images d'un dossier
  Future<List<String>> listImagesInFolder(String folder) async {
    try {
      final ListResult result = await _storage.ref().child(folder).listAll();
      final List<String> urls = [];

      for (Reference ref in result.items) {
        final String url = await ref.getDownloadURL();
        urls.add(url);
      }

      return urls;
    } catch (e) {
      print('Erreur lors du listage des images: $e');
      return [];
    }
  }
}
