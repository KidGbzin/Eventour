import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/utils/stream_subscriber_mixin.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _likes = 0;
  late final DatabaseReference _likesReference;
  late StreamSubscription<DatabaseEvent> _likesSubscription;

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    _likesReference = FirebaseDatabase.instance.ref("likes");
    try {
      final likeSnapshot = await _likesReference.get();
      _likes = likeSnapshot.value as int;
    } catch (error) {
      debugPrint(error.toString());
    }

    _likesSubscription = _likesReference.onValue.listen((DatabaseEvent event) {
      setState(() {
        _likes = (event.snapshot.value ?? 0) as int;
      });
    });
  }

  like() async {
    await _likesReference.set(ServerValue.increment(1));
  }

  @override
  void dispose() {
    _likesSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(onPressed: like, child: Text(_likes.toString())),
      appBar: PreferredSize(
        preferredSize: Size(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height * 0.075),
        child: AppBar(
          centerTitle: true,
          title: const Text("Eventour"),
        ),
      ),
    );
  }
}
