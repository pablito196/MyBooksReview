import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _auth = FirebaseAuth.instance;
  final _nameController = TextEditingController();
  final _photoUrlController = TextEditingController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final data = doc.data();

      _nameController.text = data?['name'] ?? user.displayName ?? '';
      _photoUrlController.text = data?['photoURL'] ?? user.photoURL ?? '';

      setState(() {});
    }
  }

  Future<void> _updateProfile() async {
    setState(() => _loading = true);
    final uid = _auth.currentUser!.uid;
    final name = _nameController.text;
    final photoURL = _photoUrlController.text;

    try {
      await _auth.currentUser!.updateDisplayName(name);
      await _auth.currentUser!.updatePhotoURL(photoURL);

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'name': name,
        'photoURL': photoURL,
        'email': _auth.currentUser!.email,
      }, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil actualizado')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar perfil: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _pickAndUploadImage() async {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Elegir desde galería'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Tomar una foto'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      final file = File(pickedFile.path);
      final uid = _auth.currentUser!.uid;
      final ref = FirebaseStorage.instance.ref().child('profile_pictures/$uid.jpg');

      try {
        final uploadTask = await ref.putFile(file);
        final downloadUrl = await uploadTask.ref.getDownloadURL();

        // Actualiza Firebase Auth
        await _auth.currentUser!.updatePhotoURL(downloadUrl);

        // Actualiza Firestore
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'photoURL': downloadUrl,
        }, SetOptions(merge: true));

        setState(() {
          _photoUrlController.text = downloadUrl;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Foto actualizada')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al subir imagen: $e')),
        );
      }
    }
  }

  Future<void> _signOut() async {
    await _auth.signOut();
    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Mi Perfil')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: _photoUrlController.text.isNotEmpty
                      ? NetworkImage(_photoUrlController.text)
                      : const AssetImage('assets/default_avatar.png') as ImageProvider,
                ),
                IconButton(
                  icon: const Icon(Icons.camera_alt),
                  onPressed: _pickAndUploadImage,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(user?.email ?? '',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 24),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loading ? null : _updateProfile,
              child: _loading
                  ? const CircularProgressIndicator()
                  : const Text('Actualizar Perfil'),
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: _signOut,
              icon: const Icon(Icons.logout),
              label: const Text('Cerrar Sesión'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            ),
          ],
        ),
      ),
    );
  }
}
