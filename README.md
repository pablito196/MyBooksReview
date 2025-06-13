
# 📚 BookReview App - Flutter

Este es un proyecto base para la aplicación BookReview, una app móvil para gestionar y realizar reseñas de libros desarrollada con Flutter

## 🚀 Comenzando

### Prerrequisitos

- Flutter SDK >= 3.0.0
- Dart >= 3.0.0
- Android Studio o VS Code con plugins de Flutter/Dart
- Un emulador o dispositivo físico para testing

### Instalación

1. Clona este repositorio:
```bash
git clone [url-del-repositorio]
cd book_review
```

2. Obtén las dependencias:
```bash
flutter pub get
```

3. Ejecuta el proyecto:
```bash
firebase emulators:start
flutter run
```
> 🔥 Asegúrate de iniciar los emuladores de Firebase antes de ejecutar la app. Esto levantará Firestore (8181), Auth (9099) y Storage (9199). Verifica que tu `main.dart` esté configurado con `useFirebaseEmulators = true` y la IP de tu máquina.

## 👥 Usuarios de prueba (Seed Data)

Durante la inicialización de la app se ejecuta la función `seedUsersWithAuth()` ubicada en `lib/utils/seed_data.dart`, que crea dos usuarios en el emulador de autenticación:

| Email              | Contraseña   |
|--------------------|--------------|
| user1@sistema.com  | password123  |
| user2@sistema.com  | password456  |

## 📦 Estructura del proyecto

```plaintext
/lib
│
├── /screens              # Pantallas principales (login, registro, home, detalle)
├── /providers            # Gestión de estado con Provider
├── /navigation           # Navegación por pestañas (bottom nav)
├── /utils/seed_data.dart # Registro de usuarios de prueba
├── main.dart             # Configuración principal, Firebase, emuladores, tema
```

## ⚙️ Configuración de emuladores y red

Asegúrate de que tu `main.dart` contenga la configuración correcta para usar los emuladores:

```dart
const useFirebaseEmulators = true;

if (useFirebaseEmulators) {
  final String emulatorHost = kIsWeb ? 'localhost' : '192.168.1.X'; // Tu IP local
  FirebaseFirestore.instance.useFirestoreEmulator(emulatorHost, 8181);
  FirebaseStorage.instance.useStorageEmulator(emulatorHost, 9199);
  FirebaseAuth.instance.useAuthEmulator(emulatorHost, 9099);
}
```

Además, tu archivo `AndroidManifest.xml` debe incluir:

```xml
<application
  android:usesCleartextTraffic="true"
  android:networkSecurityConfig="@xml/network_security_config">
```

Y debes tener este archivo en `android/app/src/main/res/xml/network_security_config.xml`:

```xml
<network-security-config>
  <domain-config cleartextTrafficPermitted="true">
    <domain includeSubdomains="true">192.168.1.X</domain> <!-- IP local -->
  </domain-config>
</network-security-config>
```

## 🧪 Características

- Autenticación con Firebase (emulador)
- Listado y detalle de libros
- Reseñas de libros por usuario
- Biblioteca personal por usuario
- Conexión con emuladores locales de Firebase para desarrollo

