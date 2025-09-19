import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/prospect.dart';
import '../services/prospect_service.dart';
import '../utils/app_logger.dart';

// Provider pour le service des prospects
final prospectServiceProvider = Provider<ProspectService>((ref) {
  return ProspectService();
});

// Provider pour la liste des prospects (stream)
final prospectsStreamProvider = StreamProvider<List<Prospect>>((ref) {
  final service = ref.watch(prospectServiceProvider);
  return service.obtenirProspects();
});

// Provider pour la recherche de prospects
final searchQueryProvider = StateProvider<String>((ref) => '');

// Provider pour les prospects filtrés par recherche
final filteredProspectsProvider = StreamProvider<List<Prospect>>((ref) {
  final service = ref.watch(prospectServiceProvider);
  final searchQuery = ref.watch(searchQueryProvider);

  if (searchQuery.isEmpty) {
    return service.obtenirProspects();
  } else {
    return service.rechercherProspects(searchQuery);
  }
});

// Provider pour le nombre total de prospects
final prospectsCountProvider = FutureProvider<int>((ref) {
  final service = ref.watch(prospectServiceProvider);
  return service.compterProspects();
});

// Provider pour un prospect spécifique par ID
final prospectByIdProvider = FutureProviderFamily<Prospect?, String>((ref, id) {
  final service = ref.watch(prospectServiceProvider);
  return service.obtenirProspectParId(id);
});

// Notifier pour les actions sur les prospects
class ProspectsNotifier extends StateNotifier<AsyncValue<void>> {
  final ProspectService _service;
  final Ref _ref;

  ProspectsNotifier(this._service, this._ref) : super(const AsyncValue.data(null));

  // Ajouter un prospect
  Future<String?> ajouterProspect(Prospect prospect) async {
    state = const AsyncValue.loading();
    try {
      final id = await _service.ajouterProspect(prospect);
      AppLogger.info('Prospect ajouté via provider: ${prospect.nomComplet}');
      state = const AsyncValue.data(null);
      // Invalider les providers pour forcer le refresh
      _ref.invalidate(prospectsStreamProvider);
      _ref.invalidate(prospectsCountProvider);
      return id;
    } catch (error, stackTrace) {
      AppLogger.error('Erreur lors de l\'ajout du prospect via provider', error, stackTrace);
      state = AsyncValue.error(error, stackTrace);
      return null;
    }
  }

  // Modifier un prospect
  Future<bool> modifierProspect(Prospect prospect) async {
    state = const AsyncValue.loading();
    try {
      await _service.modifierProspect(prospect);
      AppLogger.info('Prospect modifié via provider: ${prospect.nomComplet}');
      state = const AsyncValue.data(null);
      // Invalider les providers pour forcer le refresh
      _ref.invalidate(prospectsStreamProvider);
      _ref.invalidate(prospectByIdProvider(prospect.id!));
      return true;
    } catch (error, stackTrace) {
      AppLogger.error('Erreur lors de la modification du prospect via provider', error, stackTrace);
      state = AsyncValue.error(error, stackTrace);
      return false;
    }
  }

  // Supprimer un prospect
  Future<bool> supprimerProspect(String id) async {
    state = const AsyncValue.loading();
    try {
      await _service.supprimerProspect(id);
      AppLogger.info('Prospect supprimé via provider: $id');
      state = const AsyncValue.data(null);
      // Invalider les providers pour forcer le refresh
      _ref.invalidate(prospectsStreamProvider);
      _ref.invalidate(prospectsCountProvider);
      _ref.invalidate(prospectByIdProvider(id));
      return true;
    } catch (error, stackTrace) {
      AppLogger.error('Erreur lors de la suppression du prospect via provider', error, stackTrace);
      state = AsyncValue.error(error, stackTrace);
      return false;
    }
  }

  // Initialiser les données de test
  Future<void> initialiserDonneesTest() async {
    state = const AsyncValue.loading();
    try {
      await _service.initialiserDonneesTest();
      AppLogger.info('Données de test initialisées via provider');
      state = const AsyncValue.data(null);
      // Invalider les providers pour forcer le refresh
      _ref.invalidate(prospectsStreamProvider);
      _ref.invalidate(prospectsCountProvider);
    } catch (error, stackTrace) {
      AppLogger.error('Erreur lors de l\'initialisation des données de test via provider', error, stackTrace);
      state = AsyncValue.error(error, stackTrace);
    }
  }

  // Mettre à jour la requête de recherche
  void updateSearchQuery(String query) {
    AppLogger.debug('Mise à jour de la requête de recherche: "$query"');
    _ref.read(searchQueryProvider.notifier).state = query;
  }

  // Effacer la recherche
  void clearSearch() {
    AppLogger.debug('Effacement de la recherche');
    _ref.read(searchQueryProvider.notifier).state = '';
  }
}

// Provider pour le notifier des prospects
final prospectsNotifierProvider = StateNotifierProvider<ProspectsNotifier, AsyncValue<void>>((ref) {
  final service = ref.watch(prospectServiceProvider);
  return ProspectsNotifier(service, ref);
});

// Provider pour l'état de chargement des prospects
final prospectsLoadingProvider = Provider<bool>((ref) {
  final prospectsState = ref.watch(prospectsStreamProvider);
  final notifierState = ref.watch(prospectsNotifierProvider);

  return prospectsState.isLoading || notifierState.isLoading;
});

// Provider pour les erreurs liées aux prospects
final prospectsErrorProvider = Provider<String?>((ref) {
  final prospectsState = ref.watch(prospectsStreamProvider);
  final notifierState = ref.watch(prospectsNotifierProvider);

  if (prospectsState.hasError) {
    return prospectsState.error.toString();
  }

  if (notifierState.hasError) {
    return notifierState.error.toString();
  }

  return null;
});