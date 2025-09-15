import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'add_prospect_page.dart';
import 'prospect_detail_page.dart';

class Prospect {
  final String nom;
  final String prenom;
  final String email;
  final String telephone;
  final String? linkedin;

  Prospect({
    required this.nom,
    required this.prenom,
    required this.email,
    required this.telephone,
    this.linkedin,
  });
}

class ProspectsPage extends StatefulWidget {
  const ProspectsPage({super.key, required this.title});

  final String title;

  @override
  State<ProspectsPage> createState() => _ProspectsPageState();
}

class _ProspectsPageState extends State<ProspectsPage> {
  final List<Prospect> prospects = [
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
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
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
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
                        backgroundColor: Colors.deepPurple,
                        child: Text(
                          '${prospect.prenom[0]}${prospect.nom[0]}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        '${prospect.prenom} ${prospect.nom}',
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
                                  content: Text('Appel vers ${prospect.prenom} ${prospect.nom}'),
                                ),
                              );
                              break;
                            case 'email':
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Email à ${prospect.prenom} ${prospect.nom}'),
                                ),
                              );
                              break;
                            case 'modifier':
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Modifier ${prospect.prenom} ${prospect.nom}'),
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
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddProspectPage(),
            ),
          );

          if (result != null) {
            // TODO: Ajouter le nouveau prospect à la liste
            setState(() {
              prospects.add(Prospect(
                nom: result['nom'],
                prenom: result['prenom'],
                email: result['email'],
                telephone: result['telephone'],
                linkedin: result['linkedin'].isEmpty ? null : result['linkedin'],
              ));
            });
          }
        },
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}