import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/interaction.dart';

class InteractionService {
  static const String _collection = 'interactions';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Référence à la collection des interactions de l'utilisateur connecté
  CollectionReference<Map<String, dynamic>> get _interactionsCollection {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw Exception('Utilisateur non connecté');
    }
    return _firestore
        .collection('users')
        .doc(userId)
        .collection(_collection);
  }

  // Ajouter une nouvelle interaction
  Future<String> ajouterInteraction(Interaction interaction) async {
    try {
      final docRef = await _interactionsCollection.add(interaction.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Erreur lors de l\'ajout de l\'interaction: $e');
    }
  }

  // Récupérer toutes les interactions d'un prospect
  Stream<List<Interaction>> obtenirInteractionsProspect(String prospectId) {
    return _interactionsCollection
        .where('prospectId', isEqualTo: prospectId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Interaction.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Récupérer toutes les interactions
  Stream<List<Interaction>> obtenirToutesInteractions() {
    return _interactionsCollection
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Interaction.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Récupérer une interaction par ID
  Future<Interaction?> obtenirInteractionParId(String id) async {
    try {
      final doc = await _interactionsCollection.doc(id).get();
      if (doc.exists) {
        return Interaction.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Erreur lors de la récupération de l\'interaction: $e');
    }
  }

  // Modifier une interaction
  Future<void> modifierInteraction(Interaction interaction) async {
    if (interaction.id == null) {
      throw Exception('ID de l\'interaction requis pour la modification');
    }

    try {
      await _interactionsCollection
          .doc(interaction.id)
          .update(interaction.toFirestore());
    } catch (e) {
      throw Exception('Erreur lors de la modification de l\'interaction: $e');
    }
  }

  // Supprimer une interaction
  Future<void> supprimerInteraction(String id) async {
    try {
      await _interactionsCollection.doc(id).delete();
    } catch (e) {
      throw Exception('Erreur lors de la suppression de l\'interaction: $e');
    }
  }

  // Supprimer toutes les interactions d'un prospect
  Future<void> supprimerInteractionsProspect(String prospectId) async {
    try {
      final snapshot = await _interactionsCollection
          .where('prospectId', isEqualTo: prospectId)
          .get();

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Erreur lors de la suppression des interactions: $e');
    }
  }

  // Compter le nombre d'interactions d'un prospect
  Future<int> compterInteractionsProspect(String prospectId) async {
    try {
      final snapshot = await _interactionsCollection
          .where('prospectId', isEqualTo: prospectId)
          .count()
          .get();
      return snapshot.count ?? 0;
    } catch (e) {
      throw Exception('Erreur lors du comptage des interactions: $e');
    }
  }
}