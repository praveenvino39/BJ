import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet_cryptomask/core/bloc/preference-bloc/cubit/preference_cubit.dart';
import 'package:wallet_cryptomask/core/cubit_helper.dart';

class ConnectedSiteSheet extends StatefulWidget {
  const ConnectedSiteSheet({super.key});

  @override
  State<ConnectedSiteSheet> createState() => _ConnectedSiteSheetState();
}

class _ConnectedSiteSheetState extends State<ConnectedSiteSheet> {
  List<dynamic>? sites;

  @override
  void initState() {
    List<dynamic> sites =
        (context.read<PreferenceCubit>().state as PreferenceInitial)
            .userPreference
            .get("connected-sites", defaultValue: []);
    this.sites = sites;
    setState(() {});
    super.initState();
  }

  disconnectSite(String site) {
    this.sites!.remove(site);
    (context.read<PreferenceCubit>().state as PreferenceInitial)
        .userPreference
        .put("connected-sites", this.sites);
    List<dynamic> sites =
        (context.read<PreferenceCubit>().state as PreferenceInitial)
            .userPreference
            .get("connected-sites", defaultValue: []);
    this.sites = sites;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return sites != null
        ? sites!.isNotEmpty
            ? ListView.builder(
                itemCount: sites?.length ?? 0,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Row(
                      children: [
                        sites![index].toString().contains("https")
                            ? const Icon(
                                Icons.lock,
                                color: Colors.green,
                              )
                            : const Icon(
                                Icons.info,
                                color: Colors.grey,
                              ),
                        const SizedBox(
                          width: 5,
                        ),
                        Expanded(
                          child: Text(
                            sites?[index]
                                    .toString()
                                    .replaceAll("https://", "")
                                    .replaceAll("http://", "") ??
                                "",
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    trailing: TextButton(
                        onPressed: () {
                          disconnectSite(sites?[index]);
                        },
                        child: const Text("Disconnect")),
                  );
                })
            : const Center(child: Text("No sites connected"))
        : const Center(child: CircularProgressIndicator());
  }
}
