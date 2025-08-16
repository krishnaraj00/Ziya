import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as badges;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:shimmer/shimmer.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ziya Academy Dashboard',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String userName = 'User';
  String currentLocation = 'Malappuram';
  int completedTasks = 5;
  String validationStatus = 'Pending';
  int balance = 1200;
  int creditsEarned = 150;
  int unreadNotifications = 3;

  List<Map<String, String>> taskHistory = [
    {'date': '12 July', 'title': 'Task A', 'status': 'Completed'},
    {'date': '13 July', 'title': 'Task B', 'status': 'Completed'},
    {'date': '14 July', 'title': 'Task C', 'status': 'Completed'},
  ];

  List<String> carouselImages = [
    'https://static.vecteezy.com/system/resources/previews/003/226/128/non_2x/social-media-marketing-web-banner-digital-marketing-cover-banner-vector.jpg',
    'https://static.vecteezy.com/system/resources/thumbnails/007/802/493/small/business-conference-banner-template-design-for-webinar-marketing-online-class-program-etc-vector.jpg',
    'https://img.freepik.com/free-vector/gradient-business-template-design_23-2149751526.jpg?semt=ais_hybrid&w=740',
  ];

  String greeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return 'Good Morning';
    if (hour >= 12 && hour < 17) return 'Good Afternoon';
    if (hour >= 17 && hour < 21) return 'Good Evening';
    return 'Hello';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigoAccent,
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: AssetImage('assets/image/logo.jpeg'),
              radius: 18,
            ),
            SizedBox(width: 8),
            Text('Ziya Academy'),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {},
          ),
          badges.Badge(
            badgeContent: Text('$unreadNotifications',
                style: TextStyle(color: Colors.white, fontSize: 10)),
            child: IconButton(
              icon: Icon(Icons.notifications),
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopBanner(),
            SizedBox(height: 16),
            _buildImageCarousel(),
            SizedBox(height: 20),
            Text('${greeting()}, $userName 👋',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            _buildStatsCard(),
            SizedBox(height: 20),
            Text('🗓️ Task History',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ...taskHistory.map((task) => Card(
              child: ListTile(
                title: Text(task['title']!),
                subtitle: Text(task['date']!),
                trailing: Chip(
                  label: Text(task['status']!, style: TextStyle(color: Colors.white)),
                  backgroundColor: Colors.green,
                ),
              ),
            )),
            SizedBox(height: 20),
            Center(child: Text('Sponsored Content Here', style: TextStyle(color: Colors.grey))),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBanner() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.blue.shade50,
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.location_on, color: Colors.indigo),
                onPressed: () async {
                  final selectedLocation = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          LocationSelectorPage(initial: currentLocation.toUpperCase()),
                    ),
                  );
                  if (selectedLocation != null) {
                    setState(() {
                      currentLocation = selectedLocation;
                    });
                  }
                },
              ),
              SizedBox(width: 8),
              Expanded(child: Text(currentLocation)),
            ],
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Internship Program',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              TextButton(onPressed: () {}, child: Text('See Details')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImageCarousel() {
    return SizedBox(
      height: 180,
      child: PageView.builder(
        itemCount: carouselImages.length,
        controller: PageController(viewportFraction: 0.85),
        itemBuilder: (context, index) {
          return Container(
            margin: EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              image: DecorationImage(
                image: NetworkImage(carouselImages[index]),
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatsCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('📈 Your Stats', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Wrap(
              spacing: 16,
              runSpacing: 12,
              children: [
                _buildStatCard('Tasks', '$completedTasks'),
                _buildStatCard('Validation', validationStatus),
                _buildStatCard('Balance', '₹$balance'),
                _buildStatCard('Credits', '$creditsEarned'),
              ],
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(onPressed: () {}, child: Text('Wallet')),
                SizedBox(width: 10),
                ElevatedButton(onPressed: () {}, child: Text('Earnings')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Container(
      width: 150,
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.indigo.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 14, color: Colors.black54)),
          SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class LocationSelectorPage extends StatefulWidget {
  final String initial;
  const LocationSelectorPage({Key? key, this.initial = 'KOTTAYAM'}) : super(key: key);

  @override
  _LocationSelectorPageState createState() => _LocationSelectorPageState();
}

class _LocationSelectorPageState extends State<LocationSelectorPage> {
  String _selected = '';
  bool _loading = true;

  final Map<String, LatLng> _coords = {
    'KOTTAYAM': LatLng(9.5916, 76.5222),
    'ERNAKULAM': LatLng(9.9816, 76.2999),
    'THIRUVANANTHAPURAM': LatLng(8.5241, 76.9366),
    'MALAPPURAM': LatLng(11.0488, 76.0782), // Added MALAPPURAM
  };

  @override
  void initState() {
    super.initState();
    _selected = widget.initial;
    _simulateLoad();
  }

  Future<void> _simulateLoad() async {
    await Future.delayed(Duration(milliseconds: 800));
    setState(() => _loading = false);
  }

  void _pickCity(String city) {
    setState(() {
      _selected = city;
      _loading = true;
    });
    _simulateLoad();
  }

  @override
  Widget build(BuildContext context) {
    final center = _coords[_selected] ?? LatLng(9.5916, 76.5222); // fallback to KOTTAYAM

    return Scaffold(
      appBar: AppBar(title: Text('Select Location')),
      body: Column(
        children: [
          Expanded(
            child: FlutterMap(
              options: MapOptions(
                center: center,
                zoom: 10,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.app',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      width: 40,
                      height: 40,
                      point: center,
                      child: Icon(Icons.location_pin, color: Colors.red, size: 40),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 8),
          Text('Select location manually:'),
          Wrap(
            spacing: 8,
            children: _coords.keys.map((city) {
              return ChoiceChip(
                label: Text(city),
                selected: city == _selected,
                onSelected: (_) => _pickCity(city),
                selectedColor: Colors.blue,
                backgroundColor: Colors.grey[200],
                labelStyle: TextStyle(
                  color: city == _selected ? Colors.white : Colors.black,
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 12),
          Container(
            height: 150,
            margin: EdgeInsets.symmetric(horizontal: 16),
            child: _loading
                ? Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: Container(color: Colors.white, width: double.infinity),
            )
                : ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/banners/${_selected.toLowerCase()}.jpg',
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context, _selected),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: Text('Proceed', style: TextStyle(fontSize: 16)),
              ),
            ),
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }
}
