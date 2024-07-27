//import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'event_editing_page.dart';
import 'event.dart';
import 'event_data_source.dart';
import 'tasks_widget.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Medicate App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 34, 211, 255)),
        ),
        home: MyHomePage(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = "";
  List medications = ["Albuterol", "Amoxicillin", "Ibuprofen", "Vitamin D", "Atorvastin", "Adderall"];
  var index = 0;
  bool buttonClicked = false;

  final List<Event> _events = [];
  List<Event> get events => _events;

  DateTime _selectedDate = DateTime.now();

  DateTime get selectedDate => _selectedDate;

  void setDate(DateTime date) => _selectedDate = date;

  List<Event> get eventsOfSelectedDate => _events;

  void addEvent(Event event) {
    _events.add(event);
    notifyListeners();
  }

  void deleteEvent(Event event) {
    _events.remove(event);
    notifyListeners();
  }

  void updateClick() {
    buttonClicked = true;
    notifyListeners();
  }

  void startingMed() {
    current = medications[index];
  }

  void getNext() {
    index += 1;
    current = medications[index];
    notifyListeners();
  }
  
  void goBack() {
    index -= 1;
    current = medications[index];
    notifyListeners();
  }

  var medsTaken = <String>[];

  void toggleCheck() {
    if (medsTaken.contains(current)) {
      medsTaken.remove(current);
    } else {
      medsTaken.add(current);
    }
    notifyListeners();
  }
  
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = MedsPage();
        //VS code told me to remove these: break;
      case 1:
        page = MedsTakenPage();
        //break;
      case 2:
        page = CalendarPage();
      case 3:
        page = SearchPage();
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    return Scaffold(
      body: Row(
        children: [
          SafeArea(
            child: NavigationRail(
              extended: false,
              destinations: [
                NavigationRailDestination(
                  icon: Icon(Icons.home),
                  label: Text('Home'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.check_circle_rounded),
                  label: Text('Medications Taken'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.calendar_month),
                  label: Text('Calendar'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.search),
                  label: Text('Search'),
                ),
              ],
              selectedIndex: selectedIndex,
              onDestinationSelected: (value) {
                setState(() {
                  selectedIndex = value;
                });
              },
            ),
          ),
          Expanded(
            child: Container(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: page,
            ),
          ),
        ],
      ),
    );
  }
}


class MedsPage extends StatelessWidget {
  
  bool buttonPressed = false;
  
  @override
  Widget build(BuildContext context) {
    
    var appState = context.watch<MyAppState>();

    if (buttonPressed == false) {
      appState.startingMed();
    }
    
    var med = appState.current;

    IconData icon;
    if (appState.medsTaken.contains(med)) {
      icon = Icons.check_circle_rounded;
    } else {
      icon = Icons.check_circle_outline_rounded;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BigCard(med: med),
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  appState.toggleCheck();
                },
                icon: Icon(icon),
                label: Text('Medication Taken'),
              ),
                
            ],
          ),
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (appState.index > 0)
                ElevatedButton(
                  onPressed: () {
                    appState.goBack();
                  },
                  child: Text('Back'),
                ),
              SizedBox(width: 10),
              if (appState.index < (appState.medications.length - 1))
                ElevatedButton(
                  onPressed: () {
                    appState.getNext();
                    buttonPressed = true;
                  },
                  child: Text('Next'),
                ),
            ],
          ),
        ],
      ),
    );
  }

}

class MedsTakenPage extends StatefulWidget {
  @override
  State<MedsTakenPage> createState() => _MedsTakenPageState();
}

class _MedsTakenPageState extends State<MedsTakenPage> {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    if (appState.medsTaken.isEmpty) {
      return Center(
        child: Text('No medications taken yet.'),
      );
    }

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          //Change for 1 medication taken?
          child: Text('You have taken '
              '${appState.medsTaken.length} medications:'),
        ),
        for (var med in appState.medsTaken)
          ListTile(
            leading: Icon(Icons.check_circle_rounded),
            title: Text(med),
          ),
      ],
    );
  }
}

class CalendarPage extends StatefulWidget {
  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  CalendarController _calendarController = CalendarController();
  _AppointmentDataSource _events = _getCalendarDataSource();
  DateTime today = DateTime.now();
  int minutes = 0;

  @override
  Widget build(BuildContext context) {
    final events = Provider.of<MyAppState>(context).events;
    return Scaffold(
    body:
      SafeArea(
        child: SfCalendar(
          view: CalendarView.schedule,
          allowedViews: [
            CalendarView.schedule,
            CalendarView.day,
            CalendarView.week,
            CalendarView.month,
          ],
          onLongPress: (details) {
            final provider = Provider.of<MyAppState>(context, listen: false);
            provider.setDate(details.date!);
            showModalBottomSheet(
              context: context,
              builder: (context) => TasksWidget(),
            );
          },
          monthViewSettings: MonthViewSettings(
              navigationDirection: MonthNavigationDirection.vertical),
          headerStyle: CalendarHeaderStyle(
            backgroundColor: Colors.transparent,
          ),
          controller: _calendarController,
          dataSource: EventDataSource(events),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => EventEditingPage())
        ),
        backgroundColor: Colors.red,
        child: Icon(Icons.add, color: Colors.white),
      ),
  );
  } 
}

class SearchPage extends StatelessWidget {
  const SearchPage({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(context: context, delegate: MySearchDelegate());
            },
          ),
        ],
      ),
      body: const Center(child: Text('Search Page')),
    );
  }
}

class Favourite extends StatelessWidget {
  const Favourite({Key? key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Favourite Page'));
  }
}

class Profile extends StatelessWidget {
  const Profile({Key? key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Profile Page'));
  }
}

class MySearchDelegate extends SearchDelegate {
  final List<Map<String, String>> _searchResults = [
    {
      'name': 'Tylenol',
      'description': 'Used for pain relief and fever reduction.',
    },
    {
      'name': 'Advil',
      'description': 'An anti-inflammatory drug for pain relief.',
    },
    {
      'name': 'Claritin',
      'description': 'An allergy medication for seasonal allergies.',
    },
    {
      'name': 'Adderall',
      'description': 'Used to treat ADHD and narcolepsy.',
    },
    {
      'name': 'Neosporin',
      'description': 'An antibiotic ointment for minor cuts and scrapes.',
    },
    {
      'name': 'Albuterol',
      'description': 'Used to treat bronchospasm in patients with asthma, bronchitis, emphysema, and other lung diseases.',
    },
    {
      'name': 'Amoxicillin',
      'description': 'An antibiotic medication for bacterial infections.',
    },
    {
      'name': 'Ibuprofen',
      'description': 'An anti-inflammatory drug that is used to relieve pain, fever, and inflammation.',
    },
    {
      'name': 'Metformin',
      'description': 'Medication for treatment of Type 2 Diabetes.',
    },
    {
      'name': 'Losartan',
      'description': 'Medication for high blood pressure.',
    },
  ];

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
          showSuggestions(context);
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final medication = _searchResults.firstWhere(
      (item) => item['name']!.toLowerCase() == query.toLowerCase(),
      orElse: () => {
        'name': 'Not Found',
        'description': 'No details available.',
      },
    );

    return MedicationDetailPage(medication: medication);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestionList = query.isEmpty
        ? []
        : _searchResults.where((item) =>
            item['name']!.toLowerCase().contains(query.toLowerCase())).toList();

    return ListView.builder(
      itemCount: suggestionList.length,
      itemBuilder: (context, index) {
        final suggestionName = suggestionList[index]['name']!;
        final String resultDescription = suggestionList[index]['description']!;

        return ListTile(
          title: Text(suggestionName),
          subtitle: Text(resultDescription),
          onTap: () {
            query = suggestionName;
            showResults(context);
          },
        );
      },
    );
  }
}

class MedicationDetailPage extends StatelessWidget {
  final Map<String, String> medication;

  const MedicationDetailPage({Key? key, required this.medication});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(medication['name']!),
        backgroundColor: Colors.indigo.shade100,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              medication['name']!,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              medication['description']!,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.med,
  });

  final String med;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );
    
    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(med, style: style),
      ),
    );
  }
}

_AppointmentDataSource _getCalendarDataSource() {
  List<Appointment> appointments = <Appointment>[];
  appointments.add(Appointment(
    startTime: DateTime.now(),
    endTime: DateTime.now().add(Duration(minutes: 5)),
    subject: 'Take 1st Medication',
    color: Colors.blue,
    startTimeZone: '',
    endTimeZone: '',
  ));

  return _AppointmentDataSource(appointments);
}

class _AppointmentDataSource extends CalendarDataSource {
  _AppointmentDataSource(List<Appointment> source){
   appointments = source; 
  }
}

class MeetingDataSource extends CalendarDataSource {
  MeetingDataSource(List<Appointment> source){
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    return appointments![index].from;
  }

  @override
  DateTime getEndTime(int index) {
    return appointments![index].to;
  }

  @override
  bool isAllDay(int index) {
    return appointments![index].isAllDay;
  }

  @override
  String getSubject(int index) {
    return appointments![index].eventName;
  }

  @override
  String getStartTimeZone(int index) {
    return appointments![index].startTimeZone;
  }

  @override
  String getEndTimeZone(int index) {
    return appointments![index].endTimeZone;
  }

  @override
  Color getColor(int index) {
    return appointments![index].background;
  }
}