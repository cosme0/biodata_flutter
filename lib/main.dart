import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const BiodataApp());
}

class BiodataApp extends StatelessWidget {
  const BiodataApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Biodata',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const BiodataFormScreen(),
    );
  }
}

class BiodataFormScreen extends StatefulWidget {
  const BiodataFormScreen({super.key});

  @override
  State<BiodataFormScreen> createState() => _BiodataFormScreenState();
}

class _BiodataFormScreenState extends State<BiodataFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _ageController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _zipController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _schoolController = TextEditingController();
  final _courseController = TextEditingController();
  final _hobbiesController = TextEditingController();
  final _favoritesController = TextEditingController();

  String? _gender;
  String? _yearLevel;
  DateTime? _birthdate;
  bool _saving = false;

  static const _genders = ['Male', 'Female', 'Other', 'Prefer not to say'];
  static const _yearLevels = ['1st Year', '2nd Year', '3rd Year', '4th Year'];

  @override
  void dispose() {
    _fullNameController.dispose();
    _nicknameController.dispose();
    _ageController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _zipController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _schoolController.dispose();
    _courseController.dispose();
    _hobbiesController.dispose();
    _favoritesController.dispose();
    super.dispose();
  }

  Future<void> _pickBirthdate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthdate ?? DateTime(now.year - 18),
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked != null) {
      setState(() => _birthdate = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    try {
      await FirebaseFirestore.instance.collection('biodata').add({
        'fullName': _fullNameController.text.trim(),
        'nickname': _nicknameController.text.trim(),
        'age': int.tryParse(_ageController.text.trim()) ?? 0,
        'gender': _gender,
        'birthdate': _birthdate,
        'address': _addressController.text.trim(),
        'city': _cityController.text.trim(),
        'zipCode': _zipController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'school': _schoolController.text.trim(),
        'course': _courseController.text.trim(),
        'yearLevel': _yearLevel,
        'hobbies': _hobbiesController.text.trim(),
        'favorites': _favoritesController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Biodata saved successfully!')),
      );
      _formKey.currentState!.reset();
      setState(() {
        _gender = null;
        _yearLevel = null;
        _birthdate = null;
      });
    } on FirebaseException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save: ${e.message}')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Biodata Form'),
        actions: [
          IconButton(
            icon: const Icon(Icons.list_alt),
            tooltip: 'View submissions',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const BiodataRecordsScreen()),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Center(
              child: Image.asset(
                'assets/app_icon.png',
                width: 88,
                height: 88,
              ),
            ),
            const SizedBox(height: 16),
            _sectionHeader('Basic Information'),
            _buildTextField(
              controller: _fullNameController,
              label: 'Full Name',
              icon: Icons.person,
              textCapitalization: TextCapitalization.words,
            ),
            _buildTextField(
              controller: _nicknameController,
              label: 'Nickname',
              icon: Icons.badge,
              textCapitalization: TextCapitalization.words,
            ),
            _buildTextField(
              controller: _ageController,
              label: 'Age',
              icon: Icons.cake,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            DropdownButtonFormField<String>(
              initialValue: _gender,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Gender',
                prefixIcon: Icon(Icons.wc),
                border: OutlineInputBorder(),
              ),
              items: _genders
                  .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                  .toList(),
              onChanged: (v) => setState(() => _gender = v),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: _pickBirthdate,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: _birthdate == null ? 'Birthdate' : 'Birthdate (tap to change)',
                  prefixIcon: const Icon(Icons.date_range),
                  border: const OutlineInputBorder(),
                ),
                child: Text(
                  _birthdate == null
                      ? 'Tap to select'
                      : '${_birthdate!.month}/${_birthdate!.day}/${_birthdate!.year}',
                ),
              ),
            ),
            const SizedBox(height: 24),
            _sectionHeader('Address'),
            _buildTextField(
              controller: _addressController,
              label: 'Street Address',
              icon: Icons.home,
              textCapitalization: TextCapitalization.words,
            ),
            _buildTextField(
              controller: _cityController,
              label: 'City',
              icon: Icons.location_city,
              textCapitalization: TextCapitalization.words,
            ),
            _buildTextField(
              controller: _zipController,
              label: 'Zip Code',
              icon: Icons.pin,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 24),
            _sectionHeader('Contact'),
            _buildTextField(
              controller: _emailController,
              label: 'Email Address',
              icon: Icons.email,
              keyboardType: TextInputType.emailAddress,
            ),
            _buildTextField(
              controller: _phoneController,
              label: 'Phone Number',
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 24),
            _sectionHeader('School Details'),
            _buildTextField(
              controller: _schoolController,
              label: 'School',
              icon: Icons.school,
              textCapitalization: TextCapitalization.words,
            ),
            _buildTextField(
              controller: _courseController,
              label: 'Course/Program',
              icon: Icons.menu_book,
              textCapitalization: TextCapitalization.words,
            ),
            DropdownButtonFormField<String>(
              initialValue: _yearLevel,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Year Level',
                prefixIcon: Icon(Icons.grade),
                border: OutlineInputBorder(),
              ),
              items: _yearLevels
                  .map((y) => DropdownMenuItem(value: y, child: Text(y)))
                  .toList(),
              onChanged: (v) => setState(() => _yearLevel = v),
            ),
            const SizedBox(height: 24),
            _sectionHeader('Interests'),
            _buildTextField(
              controller: _hobbiesController,
              label: 'Hobbies',
              icon: Icons.sports_esports,
              maxLines: 3,
            ),
            _buildTextField(
              controller: _favoritesController,
              label: 'Favorite Things',
              icon: Icons.favorite,
              maxLines: 3,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _saving ? null : _submit,
              icon: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
              label: Text(_saving ? 'Saving...' : 'Save Biodata'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    TextCapitalization textCapitalization = TextCapitalization.none,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
        ),
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        textCapitalization: textCapitalization,
        maxLines: maxLines,
        validator: (value) {
          if (label == 'Nickname' ||
              label == 'Hobbies' ||
              label == 'Favorite Things' ||
              label == 'Course/Program') {
            return null;
          }
          if (value == null || value.trim().isEmpty) {
            return 'Please enter $label';
          }
          if (label == 'Email Address') {
            final email = value.trim();
            final valid =
                RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
            if (!valid) return 'Enter a valid email address';
          }
          if (label == 'Age') {
            final age = int.tryParse(value.trim());
            if (age == null || age <= 0) return 'Enter a valid age';
          }
          return null;
        },
      ),
    );
  }
}

class BiodataRecordsScreen extends StatelessWidget {
  const BiodataRecordsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Submissions')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('biodata')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text('No biodata submitted yet.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(data['fullName']?.toString().characters.first.toUpperCase() ?? '?'),
                  ),
                  title: Text(data['fullName']?.toString() ?? 'Unknown'),
                  subtitle: Text(
                    '${data['age'] ?? '?'} years old | ${data['city'] ?? 'No city'}'
                    '\n${data['school'] ?? 'No school'} | ${data['course'] ?? ''}',
                  ),
                  isThreeLine: true,
                  onTap: () => showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(data['fullName']?.toString() ?? 'Biodata'),
                      content: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _detailRow('Nickname', data['nickname']),
                            _detailRow('Age', data['age']),
                            _detailRow('Gender', data['gender']),
                            _detailRow('Birthdate', data['birthdate']),
                            _detailRow('Address', data['address']),
                            _detailRow('City', data['city']),
                            _detailRow('Zip Code', data['zipCode']),
                            _detailRow('Email', data['email']),
                            _detailRow('Phone', data['phone']),
                            _detailRow('School', data['school']),
                            _detailRow('Course', data['course']),
                            _detailRow('Year Level', data['yearLevel']),
                            _detailRow('Hobbies', data['hobbies']),
                            _detailRow('Favorites', data['favorites']),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _detailRow(String label, Object? value) {
    final text = value?.toString() ?? 'Not provided';
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          Text(text),
        ],
      ),
    );
  }
}