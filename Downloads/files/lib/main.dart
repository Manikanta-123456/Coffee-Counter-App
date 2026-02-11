import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(CoffeeCounterApp());
}

class CoffeeCounterApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Coffee Counter',
      theme: ThemeData(
        primarySwatch: Colors.brown,
        scaffoldBackgroundColor: Color(0xFFF5E6D3),
        fontFamily: 'Roboto',
      ),
      home: CoffeeCounterHome(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class CoffeeCounterHome extends StatefulWidget {
  @override
  _CoffeeCounterHomeState createState() => _CoffeeCounterHomeState();
}

class _CoffeeCounterHomeState extends State<CoffeeCounterHome> with SingleTickerProviderStateMixin {
  int todayCount = 0;
  int weeklyTotal = 0;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _loadData();
    
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String today = DateTime.now().toString().split(' ')[0];
    String savedDate = prefs.getString('date') ?? '';
    
    if (today != savedDate) {
      await prefs.setInt('todayCount', 0);
      await prefs.setString('date', today);
      setState(() {
        todayCount = 0;
      });
    } else {
      setState(() {
        todayCount = prefs.getInt('todayCount') ?? 0;
      });
    }
    
    setState(() {
      weeklyTotal = prefs.getInt('weeklyTotal') ?? 0;
    });
  }

  Future<void> _addCoffee() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    
    setState(() {
      todayCount++;
      weeklyTotal++;
    });
    
    await prefs.setInt('todayCount', todayCount);
    await prefs.setInt('weeklyTotal', weeklyTotal);
    
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
  }

  Future<void> _resetToday() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      todayCount = 0;
    });
    await prefs.setInt('todayCount', 0);
  }

  Future<void> _resetWeek() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      weeklyTotal = 0;
    });
    await prefs.setInt('weeklyTotal', 0);
  }

  Color _getCaffeineColor() {
    if (todayCount == 0) return Colors.brown[100]!;
    if (todayCount <= 2) return Colors.brown[300]!;
    if (todayCount <= 4) return Colors.brown[500]!;
    return Colors.brown[800]!;
  }

  String _getCaffeineMessage() {
    if (todayCount == 0) return "Time for your first coffee!";
    if (todayCount == 1) return "Good start! ☕";
    if (todayCount == 2) return "Productive day ahead!";
    if (todayCount == 3) return "You're on a roll!";
    if (todayCount == 4) return "Caffeine champion! 🏆";
    return "Whoa, easy there! 😅";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Coffee Counter', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.brown[700],
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.brown[700]!, Colors.brown[400]!],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'TODAY',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white70,
                        letterSpacing: 2,
                      ),
                    ),
                    SizedBox(height: 20),
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: Icon(
                        Icons.coffee,
                        size: 120,
                        color: _getCaffeineColor(),
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      '$todayCount',
                      style: TextStyle(
                        fontSize: 80,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      todayCount == 1 ? 'Coffee' : 'Coffees',
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.white70,
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      _getCaffeineMessage(),
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.all(20),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Icon(Icons.calendar_today, size: 30, color: Colors.brown[600]),
                          SizedBox(height: 10),
                          Text(
                            'This Week',
                            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                          ),
                          SizedBox(height: 5),
                          Text(
                            '$weeklyTotal',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.brown[800],
                            ),
                          ),
                        ],
                      ),
                      Container(
                        height: 60,
                        width: 1,
                        color: Colors.grey[300],
                      ),
                      Column(
                        children: [
                          Icon(Icons.trending_up, size: 30, color: Colors.brown[600]),
                          SizedBox(height: 10),
                          Text(
                            'Daily Avg',
                            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                          ),
                          SizedBox(height: 5),
                          Text(
                            '${(weeklyTotal / 7).toStringAsFixed(1)}',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.brown[800],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: _addCoffee,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.brown[700],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 5,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add, size: 28),
                          SizedBox(width: 10),
                          Text(
                            'Add Coffee',
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text('Reset Today?'),
                                content: Text('This will reset today\'s coffee count to 0.'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      _resetToday();
                                      Navigator.pop(context);
                                    },
                                    child: Text('Reset', style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 15),
                            side: BorderSide(color: Colors.brown[300]!),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: Text('Reset Today', style: TextStyle(color: Colors.brown[700])),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text('Reset Week?'),
                                content: Text('This will reset weekly total to 0.'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      _resetWeek();
                                      Navigator.pop(context);
                                    },
                                    child: Text('Reset', style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 15),
                            side: BorderSide(color: Colors.brown[300]!),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: Text('Reset Week', style: TextStyle(color: Colors.brown[700])),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
