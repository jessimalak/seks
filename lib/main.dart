import 'dart:convert';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:seks/classes/auth.dart';
import 'package:seks/classes/encounter.dart';
import 'package:seks/screens/add.dart';
import 'package:seks/screens/calendar.dart';
import 'package:seks/screens/list.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:seks/screens/profile.dart';
import 'package:seks/screens/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (_) => AuthService(),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Seks',
          localizationsDelegates: const [GlobalMaterialLocalizations.delegate],
          supportedLocales: const [Locale('es')],
          theme: ThemeData(
              useMaterial3: true,
              colorSchemeSeed: Color(0xffed3770),
              appBarTheme: const AppBarTheme(elevation: 0),
              cardTheme: const CardTheme(color: Color(0xffeeeeee), elevation: 0),
              textTheme: const TextTheme(headline2: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              inputDecorationTheme: const InputDecorationTheme(errorStyle: TextStyle(color: Colors.red))),
          darkTheme: ThemeData(
              brightness: Brightness.dark,
              useMaterial3: true,
              colorSchemeSeed: Color(0xffed3770),
              scaffoldBackgroundColor: Colors.black,
              appBarTheme: const AppBarTheme(elevation: 0, color: Color(0xff212121)),
              cardTheme: const CardTheme(color: Color(0xff292929), elevation: 0),
              textTheme: const TextTheme(headline2: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
              iconTheme: const IconThemeData(color: Colors.white),
              inputDecorationTheme: const InputDecorationTheme(errorStyle: TextStyle(color: Colors.red))),
          // themeMode: ThemeMode.dark,
          initialRoute: 'initial',
          routes: {'initial': (c) => const MyHomePage(), 'add': (c) => const AddScreen(), 'settings': (c) => const SettingsScreen(), 'profile': (c)=> ProfileScreen()},
        ));
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int view = 0;
  final PageController _pageController = PageController();
  bool isLoading = true;

  List<Encounter> data = [];
  late SharedPreferences preferences;

  @override
  initState() {
    super.initState();
    __get();
  }

  Future __get() async {
    preferences = await SharedPreferences.getInstance();
    var enc = preferences.getKeys().toList();
    enc = enc.where((key) => key.contains('encounter_')).toList();
    List<Encounter> listData = [];
    for (var key in enc) {
      String? value = preferences.getString(key);
      if (value != null) {
        Encounter encounter = Encounter.fromJson(jsonDecode(value));
        listData.add(encounter);
      }
    }
    listData.sort((a, b) => a.date < b.date ? 1 : 0);
    setState(() {
      // data = listData;
      isLoading = false;
    });
    context.read<AuthService>().setEncounters(listData);
    var user_ = FirebaseAuth.instance.currentUser;
    if (user_ != null) {
      var dbData = FirebaseFirestore.instance.collection('users').doc(user_.uid);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Sincronizando...'),
        duration: Duration(seconds: 1),
      ));
      var dbEncounters = await dbData.collection('encounters').get();
      List<String> dbEncKeys = [];
      for (var element in dbEncounters.docs) {
        dbEncKeys.add(element.id);
        var enc = listData.firstWhere((onDevice) => element.id == 'encounter_${onDevice.id}',
            orElse: () =>
                Encounter(id: '0', duration: 0, date: 0, notes: '', partner: Partner(name: '', gender: '', age: 0, details: '', id: ''), place: '', points: 0, positions: [], protection: false));
        bool finded = enc.id != '0';
        if (!finded) {
          preferences.setString(element.id, jsonEncode(element.data()));
          listData.add(Encounter.fromJson(element.data()));
        }
      }
      List<String> toRemove = [];
      for (var element in listData) {
        String id = 'encounter_${element.id}';
        if (!dbEncKeys.contains(id)) {
          toRemove.add(id);
        }
      }
      for (String id in toRemove) {
        listData.removeWhere((item) => 'encounter_${item.id}' == id);
        await preferences.remove(id);
      }
      setState(() {
        data = listData;
      });
      var dbPlaces = await dbData.collection('places').get();
      List<String> places = preferences.getStringList('place_') ?? [];
      bool placesChange = false;
      for (var element in dbPlaces.docs) {
        if (!places.contains(element.data()['name'])) {
          placesChange = true;
          places.add(element.data()['name']);
        }
      }
      if (placesChange) {}
      await preferences.setStringList('place_', places);
      var dbPartners = await dbData.collection('partners').get();
      var partnerKeys = preferences.getKeys().where((element) => element.contains('partner_'));
      for (var element in dbPartners.docs) {
        if (!partnerKeys.contains(element.id)) {
          await preferences.setString(element.id, jsonEncode(element.data()));
        }
      }
    }
  }

  Map<String, List<Encounter>> calendarData(List<Encounter> newData) {
    Map<String, List<Encounter>> dates_ = {};
    for (Encounter item in newData) {
      String date = formatDate(item.date, formatType: dateFormatType.moment);
      if (dates_[date] == null) {
        dates_[date] = [item];
      } else {
        dates_[date]?.add(item);
      }
    }
    return dates_;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Seks'),
        actions: [
          IconButton(
              onPressed: () async {
                Navigator.pushNamed(context, 'settings');
              },
              icon: const Icon(FluentIcons.settings_24_regular))
        ],
      ),
      body: PageView(
        controller: _pageController,
        children: isLoading ? [const SpinKitSpinningLines(color: Color(0xffed3770))] : [const ListScreen(), const CalendarScreen()],
        onPageChanged: (i) {
          setState(() {
            view = i;
          });
        },
      ),
      floatingActionButton: SingleChildScrollView(
          child: Column(children: [
        FloatingActionButton(
          heroTag: 'none',
          onPressed: () async {
            _pageController.animateToPage(view == 0 ? 1 : 0, duration: const Duration(milliseconds: 500), curve: Curves.ease);
          },
          mini: true,
          child: view == 0 ? const Icon(FluentIcons.calendar_ltr_24_regular) : const Icon(FluentIcons.list_24_regular),
        ),
        FloatingActionButton(
          onPressed: () async {
            Navigator.pushNamed(context, 'add');
          },
          tooltip: 'Add',
          child: const Icon(FluentIcons.add_24_regular),
        )
      ])),
    );
  }
}
