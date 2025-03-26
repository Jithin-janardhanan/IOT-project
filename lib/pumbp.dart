import 'package:flutter/material.dart';

class PumpDetailView extends StatefulWidget {
  final String pumpName;
  
  const PumpDetailView({Key? key, required this.pumpName}) : super(key: key);

  @override
  _PumpDetailViewState createState() => _PumpDetailViewState();
}

class _PumpDetailViewState extends State<PumpDetailView> {
  // Mock valve data - replace with actual API data later
  List<Map<String, dynamic>> valves = [
    {'id': '1', 'name': 'Main Field', 'status': false},
    {'id': '2', 'name': 'Vegetable Garden', 'status': false},
    {'id': '3', 'name': 'Orchard', 'status': false},
    {'id': '4', 'name': 'Greenhouse', 'status': false},
  ];

  bool isPumpRunning = false;

  void _togglePump() {
    setState(() {
      isPumpRunning = !isPumpRunning;
      // TODO: Add API call to actually turn pump on/off
    });
  }

  void _toggleValve(int index) {
    setState(() {
      valves[index]['status'] = !valves[index]['status'];
      // TODO: Add API call to toggle specific valve
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.pumpName} Control'),
        backgroundColor: Colors.green[600],
      ),
      body: Column(
        children: [
          // Pump Status Card
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Pump Status',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Switch(
                      value: isPumpRunning,
                      onChanged: (value) => _togglePump(),
                      activeColor: Colors.green,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Valve Control Section
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.all(16.0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                childAspectRatio: 0.8,
              ),
              itemCount: valves.length,
              itemBuilder: (context, index) {
                final valve = valves[index];
                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.water_drop,
                        size: 50,
                        color: valve['status'] ? Colors.blue : Colors.grey,
                      ),
                      SizedBox(height: 10),
                      Text(
                        valve['name'],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Switch(
                        value: valve['status'],
                        onChanged: isPumpRunning 
                          ? (value) => _toggleValve(index) 
                          : null,
                        activeColor: Colors.blue,
                      ),
                      Text(
                        valve['status'] ? 'Open' : 'Closed',
                        style: TextStyle(
                          color: valve['status'] ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}