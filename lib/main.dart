import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:raid_50/raid50.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: MyHomePage(title: 'RAID 50'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  RAID50 raid = RAID50(6, 4);

  List storage = [];

  int pressedRow;

  void _addDisksDialog(BuildContext context) async {
    int diskCount;
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: const Text('Выберите количество дисков'),
            children: List<Widget>.generate(5, (int i) {
              return SimpleDialogOption(
                onPressed: () {
                  diskCount = (i + 1) * 2;
                  Navigator.pop(context);
                },
                child: Text('+ ${(i + 1) * 2}'),
              );
            }),
          );
        });
    if (diskCount == null) return;

    String error = raid.addDisk(diskCount);

    if (error != null) {
      _errorDialog(context, error);
      return;
    }

    setState(() {
      storage = raid.info();
    });
  }

  void _updateDiskSize(BuildContext context) async {
    int diskSize;
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: const Text('Выберите размер дисков'),
            children: List<Widget>.generate(10, (int i) {
              return SimpleDialogOption(
                onPressed: () {
                  diskSize = pow(2, i + 1);
                  Navigator.pop(context);
                },
                child: Text('${pow(2, i + 1)} байт'),
              );
            }),
          );
        });
    if (diskSize == null) return;

    String error = raid.changeDiskSize(diskSize);

    if (error != null) {
      _errorDialog(context, error);
      return;
    }

    setState(() {
      storage = raid.info();
    });
  }

  void _addDataDialog(BuildContext context) async {
    String data;
    await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Введите данные для сохранения в RAID'),
          content: new Row(
            children: <Widget>[
              new Expanded(
                  child: new TextField(
                autofocus: true,
                decoration: new InputDecoration(
                    labelText: 'Данные', hintText: 'Строка данных'),
                onChanged: (value) {
                  data = value;
                },
              ))
            ],
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Добавить данные'),
              onPressed: () async {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
    if (data == null || data == '') return;

    String error = raid.writeData(data);

    if (error != null) {
      _errorDialog(context, error);
      return;
    }

    setState(() {
      storage = raid.info();
    });
  }

  Future<String> _errorDialog(BuildContext context, String text) async {
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(title: Text('Ошибка'), content: Text(text));
      },
    );
  }

  void selectData(int dataIndex) {
    setState(() {
      pressedRow = dataIndex;
    });
  }

  void deleteData(int dataIndex) {
    setState(() {
      String error = raid.deleteDataFromDisk(dataIndex);

      if (error != null) {
        _errorDialog(context, error);
        return;
      }

      setState(() {
        storage = raid.info();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    storage = raid.info();
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
                shrinkWrap: true,
                itemCount: storage.length,
                itemBuilder: (BuildContext ctx, int raid5Index) {
                  return Container(
                    margin: const EdgeInsets.only(top: 10),
                    child: Column(
                      children: <Widget>[
                        Text(
                          'RAID 5 №${raid5Index + 1}',
                          style: TextStyle(
                            fontSize: 30,
                            color: Theme.of(ctx).accentColor,
                          ),
                        ),
                        Container(
                            height: 250,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              shrinkWrap: true,
                              itemCount: storage[raid5Index].length,
                              itemBuilder: (BuildContext ctx, int diskIndex) {
                                return new DiskWidget(
                                  storage: storage,
                                  raid5Index: raid5Index,
                                  diskIndex: diskIndex,
                                  parent: this,
                                );
                              },
                            )),
                      ],
                    ),
                  );
                }),
          ),
        ],
      ),
      floatingActionButton: SpeedDial(
        animatedIcon: AnimatedIcons.menu_close,
        animatedIconTheme: IconThemeData(size: 22.0),
        curve: Curves.bounceIn,
        overlayColor: Colors.black,
        overlayOpacity: 0.5,
        tooltip: 'Speed Dial',
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 8.0,
        shape: CircleBorder(),
        children: [
          SpeedDialChild(
              child: Icon(Icons.add),
              backgroundColor: Colors.blueAccent,
              label: 'Добавить диски',
              onTap: () => {_addDisksDialog(context)}),
          SpeedDialChild(
            child: Icon(Icons.photo_size_select_small),
            backgroundColor: Colors.blueAccent,
            label: 'Установить размер дисков',
            onTap: () => {_updateDiskSize(context)},
          ),
          SpeedDialChild(
            child: Icon(Icons.keyboard),
            backgroundColor: Colors.blueAccent,
            label: 'Добавить данные',
            onTap: () => {_addDataDialog(context)},
          ),
        ],
      ),
    );
  }
}

class DiskWidget extends StatelessWidget {
  const DiskWidget({
    Key key,
    @required this.storage,
    @required this.raid5Index,
    @required this.diskIndex,
    @required this.parent,
  }) : super(key: key);

  final List storage;
  final int raid5Index;
  final int diskIndex;
  final _MyHomePageState parent;

  final Color parityColor = Colors.green;
  final Color selectedRowColor = const Color.fromRGBO(0, 150, 255, .3);
  final Color selectedRowParityColor = const Color.fromRGBO(0, 255, 150, .3);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        padding: EdgeInsets.all(10.0),
        child: Column(
          children: <Widget>[
            Text(
              'Диск ${raid5Index * storage[0].length + diskIndex + 1}',
              style: Theme.of(context).textTheme.headline,
            ),
            Row(
              children: <Widget>[
                Text('Размер диска: '),
                Text(
                  '${storage[raid5Index][diskIndex]['size']} Б',
                  style: Theme.of(context).textTheme.body2,
                ),
              ],
            ),
            Row(
              children: <Widget>[
                Text('Доступно: '),
                Text(
                  '${storage[raid5Index][diskIndex]['avaliable']} Б',
                  style: Theme.of(context).textTheme.body2,
                ),
              ],
            ),
            Divider(),
            Text(
              'Данные',
              style: Theme.of(context).textTheme.subhead,
            ),
            Expanded(
              child: Container(
                width: 150,
                child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: storage[raid5Index][diskIndex]['data'].length,
                    itemBuilder: (BuildContext ctx, int dataIndex) {
                      var data =
                          storage[raid5Index][diskIndex]['data'][dataIndex];
                      Text info;
                      Icon icon;
                      if (data == null) {
                        icon = Icon(
                          Icons.local_parking,
                          color: parityColor,
                        );
                        List<String> parityInfo = [];
                        for (Map disk in storage[raid5Index]) {
                          List<String> data = disk['data'];
                          if (dataIndex < data.length) {
                            String row = data[dataIndex];
                            if (row != null && row.codeUnitAt(0) != 0) {
                              parityInfo.add(row);
                            }
                          }
                        }
                        info = Text(
                          parityInfo.join(', '),
                          style: TextStyle(color: parityColor),
                        );
                      } else if (data.codeUnitAt(0) != 0) {
                        icon = Icon(
                          Icons.insert_drive_file,
                          color: Colors.grey,
                        );
                        info = Text(data);
                      } else {
                        icon = Icon(
                          Icons.space_bar,
                          color: Colors.grey,
                        );
                        info = Text('пусто',
                            style: Theme.of(context).textTheme.caption);
                      }

                      return InkWell(
                        child: Padding(
                          padding: const EdgeInsets.only(
                              top: 3.0, bottom: 3.0, right: 3.0),
                          child: Container(
                            child: Row(
                              children: <Widget>[
                                Padding(
                                    padding: const EdgeInsets.only(right: 6.0),
                                    child: icon),
                                Flexible(
                                  child: info,
                                ),
                              ],
                            ),
                            decoration: BoxDecoration(
                              color: parent.pressedRow == dataIndex
                                  ? (data != null
                                      ? selectedRowColor
                                      : selectedRowParityColor)
                                  : Colors.white,
                            ),
                          ),
                        ),
                        onTap: () => {parent.selectData(dataIndex)},
                        onDoubleTap: () => {parent.deleteData(dataIndex)},
                      );
                    }),
              ),
            ),
          ],
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
        ),
      ),
    );
  }
}
