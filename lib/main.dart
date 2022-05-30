import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Eventour',
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> with TickerProviderStateMixin{
  late TabController _tabController;
  final TextEditingController eventName = TextEditingController();
  final TextEditingController eventLocal = TextEditingController();
  final TextEditingController eventCategory = TextEditingController();
  final TextEditingController categoryName = TextEditingController();

  final CollectionReference _events = FirebaseFirestore.instance.collection('Events');
  final CollectionReference _categories = FirebaseFirestore.instance.collection('Categories');
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  Future<void> _createOrUpdate([DocumentSnapshot? documentSnapshot]) async {
    String action = 'create';
    if (documentSnapshot != null) {
      action = 'update';
      eventName.text = documentSnapshot['Name'];
      eventLocal.text = documentSnapshot['Local'];
      eventCategory.text = documentSnapshot['Category'];
    }
    await showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext ctx) {
        return Padding(
          padding: EdgeInsets.only(top: 20, left: 20, right: 20, bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: eventName,
                decoration: const InputDecoration(labelText: 'Nome'),
              ),
              TextField(
                controller: eventLocal,
                decoration: const InputDecoration(labelText: 'Local'),
              ),
              TextField(
                controller: eventCategory,
                decoration: const InputDecoration(labelText: 'Categoria'),
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                child: Text(action == 'create' ? 'Create' : 'Update'),
                onPressed: () async {
                  final String name = eventName.text;
                  final String local = eventLocal.text;
                  final String category = eventCategory.text;
                  if (action == 'create') {
                    await _events.add({"Name": name, "Local": local, "Category": category});
                  }
                  if (action == 'update') {
                    await _events.doc(documentSnapshot!.id).update({"Name": name, "Local": local, "Category": category});
                  }
                  eventCategory.text = '';
                  eventName.text = '';
                  eventLocal.text = '';
                  Navigator.of(context).pop();
                }
              )
            ],
          ),
        );
      }
    );
  }

  Future<void> _createOrUpdateCategory([DocumentSnapshot? documentSnapshot]) async {
    String action = 'create';
    if (documentSnapshot != null) {
      action = 'update';
      categoryName.text = documentSnapshot['Name'];
    }
    await showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext ctx) {
        return Padding(
          padding: EdgeInsets.only(top: 20, left: 20, right: 20, bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: categoryName,
                decoration: const InputDecoration(labelText: 'Nome'),
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                child: Text(action == 'create' ? 'Create' : 'Update'),
                onPressed: () async {
                  final String name = categoryName.text;
                  if (action == 'create') {
                    await _categories.add({"Name": name});
                  }
                  if (action == 'update') {
                    await _categories.doc(documentSnapshot!.id).update({"Name": name});
                  }
                  categoryName.text = '';
                  Navigator.of(context).pop();
                }
              )
            ],
          ),
        );
      }
    );
  }

  Future<void> _deleteProduct(String productId) async {
    await _events.doc(productId).delete();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('O evento foi excluído.')));
  }

  Future<void> _deleteCategory(String productId) async {
    await _categories.doc(productId).delete();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('O evento foi excluído.')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height * 0.15),
        child: AppBar(
          centerTitle: true,
          title: const Text('CRUD Eventour'),
          bottom: PreferredSize(
            preferredSize: Size(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height * 0.075),
            child: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(
                  text: "Eventos",
                ),
                Tab(
                  text: "Categorias",
                ),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          StreamBuilder(
            stream: _events.snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
              if (streamSnapshot.hasData) {
                return ListView.builder(
                  itemCount: streamSnapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final DocumentSnapshot documentSnapshot = streamSnapshot.data!.docs[index];
                    return Card(
                      margin: const EdgeInsets.all(10),
                      child: ListTile(
                        leading: Icon(
                          Icons.event,
                          size: MediaQuery.of(context).size.height * 0.05,
                        ),
                        title: Text(documentSnapshot['Name']),
                        subtitle: Text(documentSnapshot['Local']),
                        trailing: SizedBox(
                          width: 100,
                          child: Row(
                            children: [
                              IconButton(icon: const Icon(Icons.edit), onPressed: () => _createOrUpdate(documentSnapshot)),
                              IconButton(icon: const Icon(Icons.delete), onPressed: () => _deleteProduct(documentSnapshot.id)),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              }
              return const Center(
                child: CircularProgressIndicator(),
              );
            },
          ),
          StreamBuilder(
            stream: _categories.snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
              if (streamSnapshot.hasData) {
                return ListView.builder(
                  itemCount: streamSnapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final DocumentSnapshot documentSnapshot = streamSnapshot.data!.docs[index];
                    return Card(
                      margin: const EdgeInsets.all(10),
                      child: ListTile(
                        leading: Icon(
                          Icons.category,
                          size: MediaQuery.of(context).size.height * 0.05,
                        ),
                        title: Text(documentSnapshot['Name']),
                        trailing: SizedBox(
                          width: 100,
                          child: Row(
                            children: [
                              IconButton(icon: const Icon(Icons.edit), onPressed: () => _createOrUpdateCategory(documentSnapshot)),
                              IconButton(icon: const Icon(Icons.delete), onPressed: () => _deleteCategory(documentSnapshot.id)),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              }
              return const Center(
                child: CircularProgressIndicator(),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_tabController.index == 0) {
            _createOrUpdate();
          }
          else {
            _createOrUpdateCategory();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}