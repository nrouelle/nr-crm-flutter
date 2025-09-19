import 'package:flutter/material.dart';
import '../models/interaction.dart';
import '../services/interaction_service.dart';

class AddInteractionPage extends StatefulWidget {
  final String prospectId;
  final String prospectNom;

  const AddInteractionPage({
    super.key,
    required this.prospectId,
    required this.prospectNom,
  });

  @override
  State<AddInteractionPage> createState() => _AddInteractionPageState();
}

class _AddInteractionPageState extends State<AddInteractionPage> {
  final _formKey = GlobalKey<FormState>();
  final _commentaireController = TextEditingController();
  final _interactionService = InteractionService();

  DateTime _dateSelectionnee = DateTime.now();
  bool _isLoading = false;

  @override
  void dispose() {
    _commentaireController.dispose();
    super.dispose();
  }

  Future<void> _selectionnerDate() async {
    final DateTime? datePicker = await showDatePicker(
      context: context,
      initialDate: _dateSelectionnee,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('fr', 'FR'),
    );

    if (datePicker != null) {
      final TimeOfDay? heurePicker = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_dateSelectionnee),
      );

      if (heurePicker != null) {
        setState(() {
          _dateSelectionnee = DateTime(
            datePicker.year,
            datePicker.month,
            datePicker.day,
            heurePicker.hour,
            heurePicker.minute,
          );
        });
      }
    }
  }

  Future<void> _ajouterInteraction() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final interaction = Interaction(
        prospectId: widget.prospectId,
        commentaire: _commentaireController.text.trim(),
        date: _dateSelectionnee,
      );

      await _interactionService.ajouterInteraction(interaction);

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Interaction ajoutée avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouvelle interaction'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
              ),
            )
          else
            TextButton.icon(
              onPressed: _ajouterInteraction,
              icon: const Icon(Icons.save, color: Colors.white),
              label: const Text('Sauvegarder', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Informations du prospect
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.person,
                        color: Theme.of(context).colorScheme.primary,
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Prospect',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              widget.prospectNom,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Sélection de la date
              const Text(
                'Date de l\'interaction',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _selectionnerDate,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '${_dateSelectionnee.day.toString().padLeft(2, '0')}/${_dateSelectionnee.month.toString().padLeft(2, '0')}/${_dateSelectionnee.year} à ${_dateSelectionnee.hour.toString().padLeft(2, '0')}:${_dateSelectionnee.minute.toString().padLeft(2, '0')}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Commentaire
              const Text(
                'Commentaire',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: TextFormField(
                  controller: _commentaireController,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: InputDecoration(
                    hintText: 'Décrivez votre interaction avec le prospect...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                        width: 2,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Veuillez saisir un commentaire';
                    }
                    if (value.trim().length < 10) {
                      return 'Le commentaire doit contenir au moins 10 caractères';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Bouton d'ajout (version mobile)
              if (MediaQuery.of(context).size.width < 600)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _ajouterInteraction,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save),
                    label: Text(_isLoading ? 'Ajout en cours...' : 'Ajouter l\'interaction'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}