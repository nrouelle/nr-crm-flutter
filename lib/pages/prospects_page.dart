import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/prospect.dart';
import '../services/prospect_service.dart';
import 'add_prospect_page.dart';
import 'prospect_detail_page.dart';

class ProspectsPage extends StatefulWidget {
  const ProspectsPage({super.key, required this.title});

  final String title;

  @override
  State<ProspectsPage> createState() => _ProspectsPageState();
}

class _ProspectsPageState extends State<ProspectsPage> {
  final ProspectService _prospectService = ProspectService();

  @override
  void initState() {
    super.initState();
    // Initialiser les données de test si nécessaire
    _prospectService.initialiserDonneesTest();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
            tooltip: 'Se déconnecter',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Liste des Prospects',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF023047),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<List<Prospect>>(
                stream: _prospectService.obtenirProspects(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error, size: 64, color: Colors.red),
                          const SizedBox(height: 16),
                          Text(
                            'Erreur lors du chargement',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            snapshot.error.toString(),
                            style: TextStyle(color: Colors.grey[600]),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  final prospects = snapshot.data ?? [];

                  if (prospects.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.person_add_outlined,
                            size: 64,
                            color: Color(0xFF023047),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Aucun prospect',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: const Color(0xFF023047),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Ajoutez votre premier prospect en touchant le bouton +',
                            style: TextStyle(color: Colors.grey[600]),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: prospects.length,
                    itemBuilder: (context, index) {
                      final prospect = prospects[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProspectDetailPage(prospect: prospect),
                              ),
                            );
                          },
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: const Color(0xFF023047),
                              child: Text(
                                prospect.initiales,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              prospect.nomComplet,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.email_outlined,
                                      size: 16,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        prospect.email,
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.phone_outlined,
                                      size: 16,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      prospect.telephone,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            trailing: PopupMenuButton<String>(
                              onSelected: (value) {
                                switch (value) {
                                  case 'appeler':
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Appel vers ${prospect.nomComplet}'),
                                      ),
                                    );
                                    break;
                                  case 'email':
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Email à ${prospect.nomComplet}'),
                                      ),
                                    );
                                    break;
                                  case 'modifier':
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Modifier ${prospect.nomComplet}'),
                                      ),
                                    );
                                    break;
                                }
                              },
                              itemBuilder: (BuildContext context) => [
                                const PopupMenuItem<String>(
                                  value: 'appeler',
                                  child: Row(
                                    children: [
                                      Icon(Icons.phone, size: 20),
                                      SizedBox(width: 8),
                                      Text('Appeler'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem<String>(
                                  value: 'email',
                                  child: Row(
                                    children: [
                                      Icon(Icons.email, size: 20),
                                      SizedBox(width: 8),
                                      Text('Envoyer un email'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem<String>(
                                  value: 'modifier',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit, size: 20),
                                      SizedBox(width: 8),
                                      Text('Modifier'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddProspectPage(),
            ),
          );
          // Le résultat est maintenant géré directement dans AddProspectPage
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}