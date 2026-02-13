import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../shared/ui/glass_card.dart';
import '../../../shared/ui/gradient_scaffold.dart';
import '../../auth/data/auth_repository.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final ImagePicker _picker = ImagePicker();
  late TextEditingController _locationController;
  late List<String> _photoUrls;
  late List<String> _hobbies;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authStateProvider);
    _locationController = TextEditingController(text: user?.location ?? '');
    _photoUrls = List<String>.from(user?.photoUrls ?? []);
    _hobbies = List<String>.from(user?.hobbies ?? []);
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    final user = ref.read(authStateProvider);
    if (user == null) return;

    ref.read(authStateProvider.notifier).updateProfile(user.copyWith(
          photoUrls: _photoUrls,
          hobbies: _hobbies,
          location: _locationController.text.isNotEmpty
              ? _locationController.text
              : null,
        ));

    setState(() => _hasChanges = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Profil posodobljen!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 1)),
    );
  }

  Future<void> _pickPhoto(int index) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        if (index < _photoUrls.length) {
          _photoUrls[index] = image.path;
        } else {
          _photoUrls.add(image.path);
        }
        _hasChanges = true;
      });
    }
  }

  void _removePhoto(int index) {
    setState(() {
      _photoUrls.removeAt(index);
      _hasChanges = true;
    });
  }

  void _showAddHobbyDialog() {
    final nameController = TextEditingController();
    final emojiController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text("Dodaj hobi", style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Ime hobija",
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white54)),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: emojiController,
              style: const TextStyle(color: Colors.white),
              maxLength: 2,
              decoration: const InputDecoration(
                labelText: "Ikona (Emoji)",
                labelStyle: TextStyle(color: Colors.white70),
                helperText: "Uporabi sistemsko tipkovnico za emoji",
                helperStyle: TextStyle(color: Colors.white54),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white54)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child:
                const Text("Prekliči", style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.pinkAccent),
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                setState(() {
                  final newHobby =
                      "${emojiController.text.trim()} ${nameController.text.trim()}";
                  _hobbies.add(newHobby);
                  _hasChanges = true;
                });
                Navigator.pop(ctx);
              }
            },
            child: const Text("Dodaj", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      child: Column(
        children: [
          // App bar
          Padding(
            padding: const EdgeInsets.only(top: 10, left: 8, right: 8),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(LucideIcons.arrowLeft, color: Colors.white),
                  onPressed: () => context.pop(),
                ),
                Expanded(
                  child: Text('Uredi profil',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                ),
                _hasChanges
                    ? IconButton(
                        icon: const Icon(LucideIcons.check,
                            color: Colors.greenAccent),
                        onPressed: _saveChanges,
                      )
                    : const SizedBox(width: 48),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24)
                  .copyWith(bottom: 80),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Photos ---
                  Text('Slike',
                      style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  const Text('Dodaj do 4 slike. Prva slika je glavna.',
                      style: TextStyle(color: Colors.white38, fontSize: 12)),
                  const SizedBox(height: 12),

                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: 4,
                    itemBuilder: (context, index) {
                      final hasPhoto = index < _photoUrls.length;
                      return GestureDetector(
                        onTap: () => _pickPhoto(index),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: Colors.white.withValues(alpha: 0.06),
                            border: Border.all(
                              color: hasPhoto
                                  ? Colors.white24
                                  : Colors.white.withValues(alpha: 0.1),
                              width: hasPhoto ? 1 : 2,
                            ),
                            image: hasPhoto
                                ? DecorationImage(
                                    image: _photoUrls[index].startsWith('http')
                                        ? NetworkImage(_photoUrls[index])
                                        : FileImage(File(_photoUrls[index]))
                                            as ImageProvider,
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: Stack(
                            children: [
                              if (!hasPhoto)
                                Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(LucideIcons.plus,
                                          color: Colors.white30, size: 32),
                                      const SizedBox(height: 4),
                                      Text(
                                        index == 0 ? 'Glavna' : 'Dodaj',
                                        style: const TextStyle(
                                            color: Colors.white30,
                                            fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              if (hasPhoto)
                                Positioned(
                                  top: 6,
                                  right: 6,
                                  child: GestureDetector(
                                    onTap: () => _removePhoto(index),
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Colors.black54,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(LucideIcons.x,
                                          color: Colors.white, size: 16),
                                    ),
                                  ),
                                ),
                              if (hasPhoto && index == 0)
                                Positioned(
                                  bottom: 6,
                                  left: 6,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.pinkAccent,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Text('⭐ Glavna',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 28),

                  // --- Location ---
                  Text('Lokacija',
                      style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  GlassCard(
                    child: TextField(
                      controller: _locationController,
                      onChanged: (_) => setState(() => _hasChanges = true),
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      decoration: const InputDecoration(
                        hintText: 'npr. Ljubljana, Slovenija',
                        hintStyle: TextStyle(color: Colors.white30),
                        prefixIcon: Icon(LucideIcons.mapPin,
                            color: Colors.white54, size: 18),
                        border: InputBorder.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // --- Hobbies ---
                  Row(
                    children: [
                      Expanded(
                        child: Text('Hobiji',
                            style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600)),
                      ),
                      GestureDetector(
                        onTap: _showAddHobbyDialog,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.pinkAccent.withValues(alpha: 0.5),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.add,
                              color: Colors.white, size: 18),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _hobbies.asMap().entries.map((entry) {
                      final index = entry.key;
                      final hobby = entry.value;
                      return Chip(
                        label: Text(hobby,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500)),
                        backgroundColor: Colors.white.withValues(alpha: 0.1),
                        side: const BorderSide(color: Colors.white24),
                        shape: const StadiumBorder(),
                        deleteIcon: const Icon(LucideIcons.x,
                            size: 14, color: Colors.white54),
                        onDeleted: () {
                          setState(() {
                            _hobbies.removeAt(index);
                            _hasChanges = true;
                          });
                        },
                      );
                    }).toList(),
                  ),

                  if (_hobbies.isEmpty) ...[
                    const SizedBox(height: 10),
                    const Text('Še nisi dodal/-a hobijev.',
                        style: TextStyle(color: Colors.white30, fontSize: 13)),
                  ],

                  const SizedBox(height: 30),

                  // Save button
                  if (_hasChanges)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _saveChanges,
                        icon: const Icon(LucideIcons.check, size: 18),
                        label: Text('Shrani spremembe',
                            style: GoogleFonts.outfit(
                                fontWeight: FontWeight.w600)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.pinkAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
