import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weight_provider.dart';
import '../models/weight.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final items = Provider.of<WeightProvider>(context).items;
    return Scaffold(
        appBar: AppBar(
          title: const Text('Weight Tracker'),
        ),
        body: SizedBox(
          height: MediaQuery.of(context).size.height / 2,
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) => Card(
              color: index.isEven ? Colors.blue.shade100 : Colors.blue.shade200,
              child: ListTile(
                key: ValueKey(items[index].id),
                leading: Text(
                  '${items[index].weight} kg',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                  ),
                ),
                trailing: Row(
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.edit),
                    ),
                    IconButton(
                      onPressed: () {},
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
        ));
  }
}
