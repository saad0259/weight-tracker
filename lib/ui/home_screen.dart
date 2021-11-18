import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weight_provider.dart';
import 'package:intl/intl.dart';
import './manage_weight/manage_weight_screen.dart';
import '../constants/firebase_constants.dart' as fb;

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Future<void> _refreshData(BuildContext context) async {
    await Provider.of<WeightProvider>(context, listen: false).fetchAndSetData();
  }

  void initState() {
    super.initState();
    print('currrent user ==== ${fb.firebaseAuth.currentUser!.uid}');
    _refreshData(context);
  }

  @override
  Widget build(BuildContext context) {
    final items = Provider.of<WeightProvider>(context).items;
    final height = MediaQuery.of(context).size.height * 1;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weight Tracker'),
        actions: [
          IconButton(
            onPressed: () async {
              Provider.of<WeightProvider>(context, listen: false).clearList();
              await fb.firebaseAuth.signOut();
            },
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _refreshData(context),
        child: SizedBox(
          height: height,
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) => Card(
              color: index.isEven ? Colors.blue.shade100 : Colors.blue.shade200,
              child: ListTile(
                key: ValueKey(items[index].id),
                leading: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      DateFormat('yMEd')
                          .format(items[index].dateCreated.toDate()),
                      maxLines: 1,
                      softWrap: false,
                      style: const TextStyle(
                        fontSize: 8,
                      ),
                    ),
                  ],
                ),
                title: Text(
                  '${items[index].weight} kg',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pushNamed(
                          ManageWeightScreen.routeName,
                          arguments: items[index].id),
                      icon: const Icon(Icons.edit),
                    ),
                    IconButton(
                      onPressed: () =>
                          Provider.of<WeightProvider>(context, listen: false)
                              .deletWeight(items[index].id),
                      icon: Icon(
                        Icons.delete,
                        color: Theme.of(context).errorColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            Navigator.of(context).pushNamed(ManageWeightScreen.routeName),
        child: const Icon(Icons.add),
      ),
    );
  }
}
