import 'package:flutter/material.dart';
import '../main.dart';

class PengaturanScreen extends StatelessWidget {
  const PengaturanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
        backgroundColor: Colors.green[700],
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('Ganti Password'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const GantiPasswordScreen()),
              );
            },
          ),
          const Divider(),
          SwitchListTile(
            secondary: const Icon(Icons.brightness_6),
            title: const Text('Tema Gelap'),
            value: Theme.of(context).brightness == Brightness.dark,
            onChanged: (val) {
              themeNotifier.value = val ? ThemeMode.dark : ThemeMode.light;
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Bahasa'),
            trailing: const Text('Indonesia'),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => SimpleDialog(
                  title: const Text('Pilih Bahasa'),
                  children: [
                    SimpleDialogOption(
                      child: const Text('Indonesia'),
                      onPressed: () {
                        // TODO: Set bahasa ke Indonesia
                        Navigator.pop(context);
                      },
                    ),
                    SimpleDialogOption(
                      child: const Text('English'),
                      onPressed: () {
                        // TODO: Set bahasa ke English
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Tentang Aplikasi'),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Ternakin',
                applicationVersion: 'v1.0.0',
                applicationLegalese: '© 2025 Ternakin Inc.',
                applicationIcon: const Icon(Icons.pets, size: 48, color: Colors.green),
                children: [
                  const Text(
                    'Ternakin adalah aplikasi manajemen peternakan yang membantu Anda mengelola '
                    'kesehatan, pakan, dan data ternak dengan mudah.',
                  ),
                  const SizedBox(height: 16),
                  const Text('Dikembangkan oleh Tim Ternakin'),
                  const SizedBox(height: 8),
                  const Text('Email: TernakIn.com'),
                ],
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('Kebijakan Privasi & Syarat Ketentuan'),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Kebijakan Privasi & Syarat Ketentuan'),
                  content: const SingleChildScrollView(
                    child: Text(
                      'Ini adalah contoh kebijakan privasi dan syarat ketentuan aplikasi. '
                      'Silakan sesuaikan dengan kebutuhan aplikasi Anda.',
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Tutup'),
                    ),
                  ],
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.delete_forever),
            title: const Text('Reset Data'),
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Konfirmasi Reset Data'),
                  content: const Text('Apakah Anda yakin ingin menghapus semua data aplikasi?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Batal'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Ya, Hapus'),
                    ),
                  ],
                ),
              );
              if (context.mounted && confirm == true) {
                // TODO: Proses reset data aplikasi (misal: hapus database/local storage)
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Data aplikasi berhasil direset!')),
                );
              }
            },
          ),
          const Divider(),
        ],
      ),
    );
  }
}

// ...GantiPasswordScreen tetap seperti sebelumnya...
class GantiPasswordScreen extends StatefulWidget {
  const GantiPasswordScreen({super.key});

  @override
  State<GantiPasswordScreen> createState() => _GantiPasswordScreenState();
}

class _GantiPasswordScreenState extends State<GantiPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _oldController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _oldController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      // TODO: Proses ganti password (misal: API call)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password berhasil diganti!')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ganti Password'),
        backgroundColor: Colors.green[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _oldController,
                obscureText: _obscureOld,
                decoration: InputDecoration(
                  labelText: 'Password Lama',
                  suffixIcon: IconButton(
                    icon: Icon(_obscureOld ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _obscureOld = !_obscureOld),
                  ),
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Masukkan password lama' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _newController,
                obscureText: _obscureNew,
                decoration: InputDecoration(
                  labelText: 'Password Baru',
                  suffixIcon: IconButton(
                    icon: Icon(_obscureNew ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _obscureNew = !_obscureNew),
                  ),
                ),
                validator: (value) =>
                    value == null || value.length < 6 ? 'Minimal 6 karakter' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmController,
                obscureText: _obscureConfirm,
                decoration: InputDecoration(
                  labelText: 'Konfirmasi Password Baru',
                  suffixIcon: IconButton(
                    icon: Icon(_obscureConfirm ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                ),
                validator: (value) =>
                    value != _newController.text ? 'Password tidak sama' : null,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Simpan', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}