import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '../models/prospect.dart';
import '../providers/prospects_provider.dart';
import '../utils/validation_utils.dart';

class AddProspectPage extends ConsumerStatefulWidget {
  const AddProspectPage({super.key});

  @override
  ConsumerState<AddProspectPage> createState() => _AddProspectPageState();
}

class _AddProspectPageState extends ConsumerState<AddProspectPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _emailController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _linkedinController = TextEditingController();

  // Formatters pour la saisie
  late final MaskTextInputFormatter _phoneFormatter;

  @override
  void initState() {
    super.initState();
    // Formatter pour les numéros de téléphone français
    _phoneFormatter = MaskTextInputFormatter(
      mask: '## ## ## ## ##',
      filter: {'#': RegExp(r'[0-9]')},
      type: MaskAutoCompletionType.lazy,
    );
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    _telephoneController.dispose();
    _linkedinController.dispose();
    super.dispose();
  }

  Future<void> _saveProspect() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Utiliser le factory sécurisé avec validation et sanitisation
        final prospect = Prospect.create(
          nom: _nomController.text,
          prenom: _prenomController.text,
          email: _emailController.text,
          telephone: _telephoneController.text,
          linkedin: _linkedinController.text.trim().isEmpty
              ? null
              : _linkedinController.text,
        );

        // Utiliser Riverpod pour ajouter le prospect
        final success = await ref
            .read(prospectsNotifierProvider.notifier)
            .ajouterProspect(prospect);

        if (mounted) {
          if (success != null) {
            Navigator.pop(context, true);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${prospect.nomComplet} ajouté avec succès'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Erreur lors de l\'ajout du prospect'),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur lors de l\'ajout: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter un Prospect'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),

              // Nom
              TextFormField(
                controller: _nomController,
                decoration: InputDecoration(
                  labelText: 'Nom *',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                  helperText: 'Uniquement lettres, espaces, tirets et apostrophes',
                ),
                textCapitalization: TextCapitalization.words,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r"[a-zA-ZÀ-ÿ\s\-\.']")),
                  LengthLimitingTextInputFormatter(50),
                ],
                validator: (value) => ValidationUtils.validateName(value, 'nom'),
              ),
              const SizedBox(height: 16),

              // Prénom
              TextFormField(
                controller: _prenomController,
                decoration: InputDecoration(
                  labelText: 'Prénom *',
                  prefixIcon: const Icon(Icons.person_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                  helperText: 'Uniquement lettres, espaces, tirets et apostrophes',
                ),
                textCapitalization: TextCapitalization.words,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r"[a-zA-ZÀ-ÿ\s\-\.']")),
                  LengthLimitingTextInputFormatter(50),
                ],
                validator: (value) => ValidationUtils.validateName(value, 'prénom'),
              ),
              const SizedBox(height: 16),

              // Email
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email *',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                  helperText: 'Format: nom@domaine.com',
                ),
                textInputAction: TextInputAction.next,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-z0-9@._\-]')),
                  LengthLimitingTextInputFormatter(100),
                ],
                validator: ValidationUtils.validateEmail,
                onChanged: (value) {
                  // Convertir automatiquement en minuscules
                  if (value != value.toLowerCase()) {
                    _emailController.value = TextEditingValue(
                      text: value.toLowerCase(),
                      selection: _emailController.selection,
                    );
                  }
                },
              ),
              const SizedBox(height: 16),

              // Téléphone
              TextFormField(
                controller: _telephoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Téléphone *',
                  prefixIcon: const Icon(Icons.phone_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                  helperText: 'Format: 06 12 34 56 78 ou +33 6 12 34 56 78',
                ),
                textInputAction: TextInputAction.next,
                inputFormatters: [
                  _phoneFormatter,
                  LengthLimitingTextInputFormatter(20),
                ],
                validator: ValidationUtils.validatePhone,
              ),
              const SizedBox(height: 16),

              // LinkedIn
              TextFormField(
                controller: _linkedinController,
                keyboardType: TextInputType.url,
                decoration: InputDecoration(
                  labelText: 'Profil LinkedIn (optionnel)',
                  prefixIcon: const Icon(Icons.link_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                  hintText: 'https://linkedin.com/in/nom-prenom',
                  helperText: 'URL complète du profil LinkedIn',
                ),
                textInputAction: TextInputAction.done,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(200),
                ],
                validator: ValidationUtils.validateLinkedIn,
                onChanged: (value) {
                  // Auto-complétion pour LinkedIn
                  if (value.isNotEmpty && !value.startsWith('http') && !value.startsWith('linkedin.com')) {
                    if (value.startsWith('linkedin.com') || value.startsWith('www.linkedin.com')) {
                      _linkedinController.value = TextEditingValue(
                        text: 'https://$value',
                        selection: TextSelection.collapsed(offset: 'https://$value'.length),
                      );
                    }
                  }
                },
              ),
              const SizedBox(height: 32),

              // Boutons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Annuler'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Consumer(
                      builder: (context, ref, child) {
                        final isLoading = ref.watch(prospectsNotifierProvider).isLoading;
                        return ElevatedButton(
                          onPressed: isLoading ? null : _saveProspect,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Text(
                                  'Enregistrer',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Note
              Text(
                '* Champs obligatoires',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}