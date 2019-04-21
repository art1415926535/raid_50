import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'RAID 50'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  List storage = [
    [
      {
        'data': ['a11', 'b11', Null],
        'size': 100, // bytes
        'avaliable': 3, // bytes
      }, // Disk 1.
      {
        'data': ['a12', Null, 'c11'],
        'size': 100, // bytes
        'avaliable': 3, // bytes
      }, // Disk 2.
      {
        'data': [Null, 'b12', 'c12'],
        'size': 100, // bytes
        'avaliable': 3, // bytes
      }, // Disk 3.
    ], // RAID 5.
    [
      {
        'data': [Null, 'b21', 'c21'],
        'size': 100, // bytes
        'avaliable': 3, // bytes
      }, // Disk 4.
      {
        'data': ['a21', Null, 'c22'],
        'size': 100, // bytes
        'avaliable': 3, // bytes
      }, // Disk 5.
      {
        'data': ['a22', 'b22', Null],
        'size': 100, // bytes
        'avaliable': 3, // bytes
      }, // Disk 3.
    ], // RAID 5.
  ]; // RAID 0.

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Column(
        children: storage
            .map((raid5) => Container(
                child: Column(
                    children: <Widget>[
                      Text(
                        'RAID 0',
                        style: TextStyle(
                            color: Theme.of(context).accentColor,
                            fontSize: 20,
                        ),
                      )
                    ] + raid5
                        .map<Widget>(
                            (disk) => Card(
                              child: Column(
                                children: <Widget>[
                                  Text(
                                    disk['data'].toString(),
                                    style: Theme.of(context).textTheme.display1,
                                  ),
                                  Text(
                                    'Size: ${disk["Size"].toString()}',
                                  ),
                                  Text(
                                    'Avaliable: ${disk["Avaliable"].toString()}',
                                  ),
                                ],
                              ),
                            )
                        )
                        .toList()
                )
        )
        )
            .toList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
