import 'package:flutter/material.dart';

class UpdatesScreen extends StatelessWidget {
  const UpdatesScreen({super.key});

  @override
  Widget build(BuildContext context) => DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Updates'),
            actions: [
              TextButton(
                onPressed: () {},
                child: const Text('Mark all as read'),
              )
            ],
            bottom: const TabBar(
              tabs: [
                Text('Updates'),
                Text('Comments'),
              ],
            ),
          ),
          body: const TabBarView(
            children: [
              Center(child: Text('You don’t have more updates to review')),
              Center(child: Text('Nothing here yet')),
            ],
          ),
        ),
      );
}