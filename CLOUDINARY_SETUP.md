# Configuration Cloudinary pour Cinema FST Hub

## 📸 Pourquoi Cloudinary ?

### Avantages vs Firebase Storage :

- ⚡ **10x plus rapide** grâce au CDN global
- 💰 **Plan gratuit généreux** : 25 GB stockage + 25 GB bande passante/mois
- 🎨 **Transformations d'images à la volée** (resize, crop, quality, format)
- 🌐 **Optimisation automatique** (WebP, compression intelligente)
- 📊 **Pas de timeout** - uploads ultra-rapides
- 🔧 **URLs avec paramètres** pour différentes tailles sans re-upload

### Comparaison performances :

| Opération        | Firebase Storage       | Cloudinary       |
| ---------------- | ---------------------- | ---------------- |
| Upload 500KB     | 10-30s                 | 2-5s             |
| Upload 100KB     | 5-10s                  | 1-2s             |
| Chargement image | 3-5s                   | <1s (CDN)        |
| Transformation   | ❌ Nécessite re-upload | ✅ URL paramètre |

---

## 🚀 Configuration (5 minutes)

### Étape 1 : Créer un compte Cloudinary

1. Allez sur https://cloudinary.com/users/register_free
2. Inscrivez-vous (email ou Google)
3. Confirmez votre email

### Étape 2 : Récupérer vos identifiants

1. Connectez-vous au Dashboard : https://console.cloudinary.com/
2. Notez votre **Cloud Name** (en haut, ex: `dxxxxxxx`)
3. Allez dans **Settings** → **Upload** (ou https://console.cloudinary.com/settings/upload)

### Étape 3 : Créer un Upload Preset (IMPORTANT)

1. Dans **Settings** → **Upload**, scrollez vers **Upload presets**
2. Cliquez **Add upload preset**
3. Configurez :
   - **Preset name** : `cinema_preset` (ou autre nom)
   - **Signing Mode** : **Unsigned** ⚠️ TRÈS IMPORTANT
   - **Folder** : `cinema_fst_hub` (optionnel mais recommandé)
   - **Use filename** : ✅ Coché
   - **Unique filename** : ✅ Coché
   - **Overwrite** : ❌ Non coché
4. Cliquez **Save**

### Étape 4 : Configurer l'application

1. Ouvrez `lib/services/cloudinary_service.dart`
2. Remplacez ligne 14-15 :

```dart
// AVANT
static const String cloudName = 'YOUR_CLOUD_NAME';
static const String uploadPreset = 'YOUR_UPLOAD_PRESET';

// APRÈS
static const String cloudName = 'dxxxxxxx'; // Votre Cloud Name
static const String uploadPreset = 'cinema_preset'; // Votre preset name
```

### Étape 5 : Installer le package

```bash
flutter pub get
```

---

## 🎯 Utilisation

### Upload d'image de film

```dart
final cloudinary = CloudinaryService();
final url = await cloudinary.uploadMovieImage(
  imageBytes: imageBytes,
  fileName: 'inception.jpg',
);
// Résultat : https://res.cloudinary.com/dxxxxxxx/image/upload/w_600,q_auto,f_auto/cinema_fst_hub/movies/inception.jpg
```

### Upload d'image de profil

```dart
final url = await cloudinary.uploadProfileImage(
  imageBytes: imageBytes,
  userId: 'user123',
);
// Résultat : https://res.cloudinary.com/dxxxxxxx/image/upload/w_300,q_auto,f_auto,g_face/cinema_fst_hub/profiles/profile_user123.jpg
```

### Transformation à la volée (sans re-upload)

```dart
// Image originale
final originalUrl = 'https://res.cloudinary.com/.../movie.jpg';

// Petite vignette 150x150
final thumbUrl = cloudinary.getTransformedUrl(
  originalUrl,
  width: 150,
  height: 150,
  crop: 'fill',
);

// Grande taille 1200px
final largeUrl = cloudinary.getTransformedUrl(
  originalUrl,
  width: 1200,
);
```

---

## 🔧 Transformations Cloudinary

### Paramètres URL disponibles :

- `w_600` : largeur 600px
- `h_400` : hauteur 400px
- `c_fill` : crop pour remplir (sans déformation)
- `c_fit` : fit dans les dimensions (avec déformation possible)
- `g_face` : centrer sur les visages détectés
- `q_auto` : qualité automatique optimisée
- `f_auto` : format automatique (WebP si supporté)
- `e_blur:300` : effet de flou
- `e_grayscale` : noir et blanc

### Exemples d'URLs :

```
Original :
https://res.cloudinary.com/demo/image/upload/sample.jpg

Thumbnail 150x150 :
https://res.cloudinary.com/demo/image/upload/w_150,h_150,c_fill/sample.jpg

Format WebP optimisé :
https://res.cloudinary.com/demo/image/upload/f_webp,q_auto/sample.jpg

Centré sur visage 300x300 :
https://res.cloudinary.com/demo/image/upload/w_300,h_300,c_fill,g_face/sample.jpg
```

---

## 📊 Limites du plan gratuit

- **Stockage** : 25 GB
- **Bande passante** : 25 GB/mois
- **Transformations** : 25 000/mois
- **Taille max fichier** : 10 MB

**C'est largement suffisant pour votre projet !** Exemple :

- 25 GB = ~50 000 images de 500 KB
- 25 GB bandwidth = ~500 000 chargements d'images/mois

---

## 🐛 Dépannage

### Erreur : "Upload preset not found"

→ Vérifiez que le preset est bien **Unsigned**

### Erreur : "Invalid cloud name"

→ Vérifiez l'orthographe de votre Cloud Name

### Images ne se chargent pas

→ Vérifiez que les URLs contiennent bien `https://res.cloudinary.com/`

### Upload lent

→ Vérifiez votre connexion internet (Cloudinary devrait être <5s)

---

## 📚 Ressources

- Dashboard Cloudinary : https://console.cloudinary.com/
- Documentation officielle : https://cloudinary.com/documentation
- Package Flutter : https://pub.dev/packages/cloudinary_public
- Exemples transformations : https://cloudinary.com/documentation/image_transformations

---

## ✅ Checklist avant de lancer

- [ ] Compte Cloudinary créé
- [ ] Cloud Name récupéré
- [ ] Upload Preset créé en mode **Unsigned**
- [ ] `cloudinary_service.dart` configuré avec vos identifiants
- [ ] `flutter pub get` exécuté
- [ ] Application testée avec upload d'image

---

**🎉 Profitez d'uploads ultra-rapides avec Cloudinary !**
