import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/prospect.dart';

class ProspectService {
  static const String _collection = 'prospects';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Référence à la collection des prospects de l'utilisateur connecté
  CollectionReference<Map<String, dynamic>> get _prospectsCollection {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw Exception('Utilisateur non connecté');
    }
    return _firestore
        .collection('users')
        .doc(userId)
        .collection(_collection);
  }

  // Ajouter un nouveau prospect
  Future<String> ajouterProspect(Prospect prospect) async {
    try {
      final docRef = await _prospectsCollection.add(prospect.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Erreur lors de l\'ajout du prospect: $e');
    }
  }

  // Récupérer tous les prospects
  Stream<List<Prospect>> obtenirProspects() {
    return _prospectsCollection
        .orderBy('dateModification', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Prospect.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Récupérer un prospect par ID
  Future<Prospect?> obtenirProspectParId(String id) async {
    try {
      final doc = await _prospectsCollection.doc(id).get();
      if (doc.exists) {
        return Prospect.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Erreur lors de la récupération du prospect: $e');
    }
  }

  // Modifier un prospect
  Future<void> modifierProspect(Prospect prospect) async {
    if (prospect.id == null) {
      throw Exception('ID du prospect requis pour la modification');
    }

    try {
      final prospectModifie = prospect.copyWith(
        dateModification: DateTime.now(),
      );

      await _prospectsCollection
          .doc(prospect.id)
          .update(prospectModifie.toFirestore());
    } catch (e) {
      throw Exception('Erreur lors de la modification du prospect: $e');
    }
  }

  // Supprimer un prospect
  Future<void> supprimerProspect(String id) async {
    try {
      await _prospectsCollection.doc(id).delete();
    } catch (e) {
      throw Exception('Erreur lors de la suppression du prospect: $e');
    }
  }

  // Rechercher des prospects
  Stream<List<Prospect>> rechercherProspects(String terme) {
    final termeMinuscule = terme.toLowerCase();

    return _prospectsCollection
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Prospect.fromMap(doc.data(), doc.id))
            .where((prospect) =>
                prospect.nom.toLowerCase().contains(termeMinuscule) ||
                prospect.prenom.toLowerCase().contains(termeMinuscule) ||
                prospect.email.toLowerCase().contains(termeMinuscule))
            .toList());
  }

  // Compter le nombre de prospects
  Future<int> compterProspects() async {
    try {
      final snapshot = await _prospectsCollection.count().get();
      return snapshot.count ?? 0;
    } catch (e) {
      throw Exception('Erreur lors du comptage des prospects: $e');
    }
  }

  // Initialiser avec des données de test (optionnel)
  Future<void> initialiserDonneesTest() async {
    try {
      final snapshot = await _prospectsCollection.limit(1).get();
      if (snapshot.docs.isEmpty) {
        // Ajouter des prospects de test si la collection est vide
        final prospectsTest = [
          Prospect(
            nom: 'Dupont',
            prenom: 'Jean',
            email: 'jean.dupont@email.com',
            telephone: '+33 6 12 34 56 78',
            linkedin: 'https://linkedin.com/in/jean-dupont',
          ),
          Prospect(
            nom: 'Martin',
            prenom: 'Sophie',
            email: 'sophie.martin@entreprise.fr',
            telephone: '+33 6 23 45 67 89',
            linkedin: 'https://linkedin.com/in/sophie-martin',
          ),
          Prospect(
            nom: 'Leroy',
            prenom: 'Pierre',
            email: 'p.leroy@company.com',
            telephone: '+33 6 34 56 78 90',
            linkedin: 'https://linkedin.com/in/pierre-leroy',
          ),
          Prospect(
            nom: 'Dubois',
            prenom: 'Marie',
            email: 'marie.dubois@business.fr',
            telephone: '+33 6 45 67 89 01',
            linkedin: 'https://linkedin.com/in/marie-dubois',
          ),
          Prospect(
            nom: 'Moreau',
            prenom: 'Antoine',
            email: 'antoine.moreau@startup.io',
            telephone: '+33 6 56 78 90 12',
            linkedin: 'https://linkedin.com/in/antoine-moreau',
          ),
        ];

        for (final prospect in prospectsTest) {
          await ajouterProspect(prospect);
        }
      }
    } catch (e) {
      // Ignorer les erreurs d'initialisation
      print('Erreur lors de l\'initialisation des données de test: $e');
    }
  }
}