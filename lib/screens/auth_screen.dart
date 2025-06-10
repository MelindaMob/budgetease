import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/user_profile_service.dart';
import '../models/user_profile_model.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  bool _isLogin = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    final auth = Provider.of<AuthService>(context, listen: false);
    try {
      if (_isLogin) {
        final user = await auth.signIn(_emailController.text.trim(), _passwordController.text.trim());
        if (user != null) {
          final profileService = Provider.of<UserProfileService>(context, listen: false);
          final profileData = await auth.getUserProfile(user.uid);
          if (profileData != null) {
            profileService.updateProfile(
              user.uid,
              UserProfileModel(
                id: profileData['id'],
                firstName: profileData['firstName'],
                lastName: profileData['lastName'],
                email: profileData['email'],
              ),
            );
          }
        }
      } else {
        final user = await auth.signUp(_emailController.text.trim(), _passwordController.text.trim());
        if (user != null) {
          final profileService = Provider.of<UserProfileService>(context, listen: false);
          await profileService.updateProfile(
            user.uid,
            UserProfileModel(
              id: user.uid,
              firstName: _firstNameController.text.trim(),
              lastName: _lastNameController.text.trim(),
              email: _emailController.text.trim(),
            ),
          );
        }
      }
    } on Exception catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _isLogin ? 'Connexion' : 'Créer un compte',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 24),
                    if (!_isLogin) ...[
                      TextFormField(
                        controller: _firstNameController,
                        decoration: const InputDecoration(labelText: 'Prénom'),
                        validator: (v) => v == null || v.isEmpty ? 'Entrez votre prénom' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _lastNameController,
                        decoration: const InputDecoration(labelText: 'Nom'),
                        validator: (v) => v == null || v.isEmpty ? 'Entrez votre nom' : null,
                      ),
                      const SizedBox(height: 12),
                    ],
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) => v == null || !v.contains('@') ? 'Entrez un email valide' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(labelText: 'Mot de passe'),
                      obscureText: true,
                      validator: (v) => v == null || v.length < 6 ? '6 caractères minimum' : null,
                    ),
                    const SizedBox(height: 24),
                    if (_error != null)
                      Text(
                        _error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    if (_loading)
                      const CircularProgressIndicator()
                    else
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _submit,
                          child: Text(_isLogin ? 'Se connecter' : 'Créer un compte'),
                        ),
                      ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isLogin = !_isLogin;
                        });
                      },
                      child: Text(_isLogin
                          ? "Pas de compte ? S'inscrire"
                          : "Déjà un compte ? Se connecter"),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}