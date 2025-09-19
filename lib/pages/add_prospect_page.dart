import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '../models/prospect.dart';
import '../providers/prospects_provider.dart';
import '../utils/validation_utils.dart';
import '../widgets/custom_text_form_field.dart';

class AddProspectPage extends HookConsumerWidget {
  const AddProspectPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Utilisation des hooks pour les contrôleurs (dispose automatique)
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final nomController = useTextEditingController();
    final prenomController = useTextEditingController();
    final emailController = useTextEditingController();
    final telephoneController = useTextEditingController();
    final linkedinController = useTextEditingController();

    // Formatter pour les numéros de téléphone français
    final phoneFormatter = useMemoized(
      () => MaskTextInputFormatter(
        mask: '## ## ## ## ##',
        filter: {'#': RegExp(r'[0-9]')},
        type: MaskAutoCompletionType.lazy,
      ),
    );

    // Fonction de sauvegarde avec gestion d'erreurs améliorée
    Future<void> saveProspect() async {
      if (!formKey.currentState!.validate()) return;

      try {
        // Utiliser le factory sécurisé avec validation et sanitisation
        final prospect = Prospect.create(
          nom: nomController.text,
          prenom: prenomController.text,
          email: emailController.text,
          telephone: telephoneController.text,
          linkedin: linkedinController.text.trim().isEmpty
              ? null
              : linkedinController.text,
        );

        // Utiliser Riverpod pour ajouter le prospect
        final success = await ref
            .read(prospectsNotifierProvider.notifier)
            .ajouterProspect(prospect);

        if (context.mounted) {
          if (success != null) {
            Navigator.pop(context, true);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${prospect.nomComplet} ajouté avec succès'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                action: SnackBarAction(
                  label: 'Voir',
                  textColor: Colors.white,
                  onPressed: () {
                    // Future: naviguer vers les détails du prospect
                  },
                ),
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
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur : ${e.toString()}'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }

    // Auto-complétion intelligente pour l'email
    void handleEmailChange(String value) {
      if (value != value.toLowerCase()) {
        emailController.value = TextEditingValue(
          text: value.toLowerCase(),
          selection: emailController.selection,
        );
      }
    }

    // Auto-complétion pour LinkedIn
    void handleLinkedInChange(String value) {
      if (value.isNotEmpty &&
          !value.startsWith('http') &&
          !value.startsWith('linkedin.com')) {
        if (value.startsWith('linkedin.com') ||
            value.startsWith('www.linkedin.com')) {
          linkedinController.value = TextEditingValue(
            text: 'https://$value',
            selection: TextSelection.collapsed(offset: 'https://$value'.length),
          );
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter un Prospect'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),

              // Nom
              CustomTextFormField.name(
                controller: nomController,
                label: 'Nom',
                validator: (value) => ValidationUtils.validateName(value, 'nom'),
              ),
              const SizedBox(height: 16),

              // Prénom
              CustomTextFormField.name(
                controller: prenomController,
                label: 'Prénom',
                validator: (value) => ValidationUtils.validateName(value, 'prénom'),
              ),
              const SizedBox(height: 16),

              // Email
              CustomTextFormField.email(
                controller: emailController,
                validator: ValidationUtils.validateEmail,
                onChanged: handleEmailChange,
              ),
              const SizedBox(height: 16),

              // Téléphone
              CustomTextFormField.phone(
                controller: telephoneController,
                phoneFormatters: [phoneFormatter],
                validator: ValidationUtils.validatePhone,
              ),
              const SizedBox(height: 16),

              // LinkedIn
              CustomTextFormField.url(
                controller: linkedinController,
                label: 'Profil LinkedIn (optionnel)',
                helperText: 'URL complète du profil LinkedIn',
                hintText: 'https://linkedin.com/in/nom-prenom',
                validator: ValidationUtils.validateLinkedIn,
                onChanged: handleLinkedInChange,
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
                          onPressed: isLoading ? null : saveProspect,
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