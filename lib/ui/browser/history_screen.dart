import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:wallet_cryptomask/constant.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet_cryptomask/core/bloc/preference-bloc/cubit/preference_cubit.dart';

class HistoryScreen extends StatefulWidget {
  static const route = "favouritee_site_screen";
  final Function(String) onUrlSubmit;
  const HistoryScreen({super.key, required this.onUrlSubmit});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  getFavouriteSites() async {
    Completer<List<dynamic>> completer = Completer();
    Hive.openBox("user_preference").then((box) {
      completer.complete(box.get("fav-sites", defaultValue: []));
    });
    return completer.future;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  onDelete(List history) {
    getHistory();
    setState(() {});
  }

  Future<List> getHistory() async {
    return ((context.read<PreferenceCubit>().state as PreferenceInitial)
            .userPreference
            .get("history", defaultValue: []) as List)
        .toSet()
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Browser history",
          style: TextStyle(fontSize: 16),
        ),
        backgroundColor: kPrimaryColor,
        elevation: 0,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: getHistory(),
        builder: (context, snapshot) {
          return snapshot.hasData
              ? snapshot.data!.isNotEmpty
                  ? ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        return Card(
                          child: ListTile(
                            onTap: () {
                              widget.onUrlSubmit(snapshot.data?[index].url);
                              Navigator.of(context).pop();
                            },
                            leading: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(
                                  Icons.public,
                                  size: 20,
                                ),
                              ],
                            ),
                            horizontalTitleGap: 0,
                            trailing: IconButton(
                                onPressed: () {
                                  snapshot.data?.remove(snapshot.data?[index]);
                                  onDelete(snapshot.data!);
                                  // onDelete(state.favSites[index]);
                                },
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.red,
                                  size: 20,
                                )),
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 10),
                            isThreeLine: false,
                            title: Text(
                              snapshot.data?[index].url.contains(
                                      "file:///android_asset/flutter_assets/")
                                  ? "home.egon.wallet"
                                  : snapshot.data?[index].url,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            // subtitle: Text(
                            //   snapshot.data?[index].url.contains(
                            //           "file:///android_asset/flutter_assets/")
                            //       ? "home.egon.wallet"
                            //       : snapshot.data?[index].url,
                            //   maxLines: 1,
                            //   overflow: TextOverflow.ellipsis,
                            // ),
                          ),
                        );
                      },
                    )
                  : const Center(child: Text("No history found"))
              : const Center(
                  child: CircularProgressIndicator(color: kPrimaryColor),
                );
        },
      ),
    );
  }
}
