import 'package:crcrme_banque_stages/common/providers/risks_provider.dart';
import 'package:crcrme_banque_stages/common/providers/students_provider.dart';
import 'package:crcrme_banque_stages/screens/ref_sst/sst_cards/sst_cards_screen.dart';
import 'package:crcrme_banque_stages/screens/ref_sst/job_list_risks_and_skills/job_list_screen.dart';
import 'package:enhanced_containers/database_list_provided.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../common/Risk.dart';
import 'widgets/search_bar.dart';
import '/common/widgets/main_drawer.dart';

class HomeSSTScreen extends StatefulWidget {
  const HomeSSTScreen({Key? key}) : super(key: key);

  static const route = "/home-sst";

  @override
  State<HomeSSTScreen> createState() => _HomeSSTScreenState();
}

class _HomeSSTScreenState extends State<HomeSSTScreen> {
  final _searchController = TextEditingController();
  final _ref = FirebaseDatabase.instance.ref();

  Future<String> json = Future<String>.value("");

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
    _activateListeners();
  }

  Future<String> fetchRisks() async {
    return await Future<String>.value(_ref.child("01").onValue.toString());
  }

  bool test = true;

  @override
  Widget build(BuildContext context) {
    Widget body = const Center(child: CircularProgressIndicator());
    var data = Provider.of<RisksProvider>(context, listen: true);
    if (test) {
      //data.isEmpty
      body = FutureBuilder<String>(
          future: fetchRisks(),
          builder: (ctx, snapshot) {
            if (snapshot.hasData) {
              //data.deserialize(snapshot.data!);
              test = false;
            }
            return const Center(child: CircularProgressIndicator());
          });
    } else {
      body = ListView(
        children: [
          //Container for the search bar
          Center(
              child: Container(
            margin: const EdgeInsets.only(top: 50.0),
            width: 300,
            height: 260,
            padding: const EdgeInsets.all(17.0),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              color: Colors.blue,
              boxShadow: [
                BoxShadow(color: Colors.grey, spreadRadius: 1, blurRadius: 15)
              ],
            ),
            child: InkWell(
                onTap: () {
                  print("Clicked on jod list risks and skills");
                },
                child: Column(
                  children: [
                    const Text("Analyse des risques par métier",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 25,
                            color: Colors.white,
                            fontFamily: "Noto Sans")),
                    Padding(
                        padding: const EdgeInsets.only(top: 25.0),
                        child: SearchBar(controller: _searchController)),
                    const Padding(
                      padding: EdgeInsets.only(top: 30.0),
                      child: Text(
                        "L'analyse des risques à la SST a été faite pour les 45 métiers les plus populaires du répertoires du Ministère de l'éducation.",
                        textAlign: TextAlign.justify,
                        style: TextStyle(
                            fontSize: 11,
                            color: Colors.white,
                            fontStyle: FontStyle.italic),
                      ),
                    )
                  ],
                )),
          )),
          Center(
              child: Container(
            margin: const EdgeInsets.only(top: 35.0),
            child: InkWell(
              onTap: () {
                print("Clicked on sst cards list");
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => SSTCardsScreen(),
                ));
              },
              child: Ink(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  color: Colors.blue,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.grey, spreadRadius: 1, blurRadius: 15)
                  ],
                ),
                width: 300,
                height: 260,
                child: const Padding(
                  padding: EdgeInsets.all(45.0),
                  child: Center(
                    child: Text(
                      "Consulter les fiches de risques",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 25,
                          color: Colors.white,
                          fontFamily: "Noto Sans"),
                    ),
                  ),
                ),
              ),
            ),
          )),
        ],
      );
    }
    return Scaffold(
        appBar: AppBar(
          title: const Text("Référentiel SST"),
        ),
        drawer: const MainDrawer(),
        body: body);
  }

  void _activateListeners() {
    _ref.child("01").onValue.listen((event) {
      final String name = event.snapshot.value.toString();
      setState(() {
        print(name);
      });
    });
  }
}
