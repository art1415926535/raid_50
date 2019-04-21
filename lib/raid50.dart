import 'dart:math';

String generateDataString(int length) {
  var rand = new Random();
  var codes = new List.generate(length, (index) {
    return rand.nextInt(33) + 89;
  });
  var res = new String.fromCharCodes(codes);
  return res;
}

class Disk {
  List<String> data;
  int capacity;
  int freeMemory;

  Disk(int capacity) {
    this.capacity = capacity;
    data = [];
    freeMemory = this.capacity - data.length;
  }

  int getDataVolume() {
    int size = 0;
    for (var i in data) {
      if (i != null) size += i.length;
    }
    return size;
  }

  deleteData(int index) {
    data[index] = '';
  }

  updateFreeMemory() {
    freeMemory = capacity - getDataVolume();
  }

  fillData(String data) {
    if (data.length > getDataVolume()) {
      return 'Нет свободного места на диске';
    }
    this.data.add(data);
    updateFreeMemory();
  }

  setParity() {
    this.data.add(null);
  }

  changeCapacity(int newCapacity) {
    if (newCapacity < getDataVolume()) {
      return 'Введенное значение меньше, чем занятая память';
    }
    capacity = newCapacity;
    updateFreeMemory();
  }

  addData(String data) {
    if (data.length > this.freeMemory) {
      return 'Нет свободного места на диске';
    }
    this.data.add(data);
    this.updateFreeMemory();
  }

  info() {
    return {
      'size': this.capacity,
      'data': this.data,
      'avaliable': this.freeMemory
    };
  }
}

class RAID50 {
  int num;
  List<List> raid0;

  RAID50(int num, int diskSize) {
    this.num = num;
    raid0 = new List<List>.generate(
        2, (i) => List<Disk>.generate(num ~/ 2, (j) => Disk(diskSize)));
  }

  info() {
    return raid0
        .map((listDisk) => listDisk.map((disk) => disk.info()).toList())
        .toList();
  }

  changeDiskSize(int newSize) {
    for (var i in raid0) {
      for (var j in i) {
        if(j.changeCapacity(newSize)!= null)
          return j.changeCapacity(newSize);
        j.changeCapacity(newSize);
      }
    }
  }

  addDisk(int addNum) {
    if (addNum % 2 != 0) {
      return 'Нечетное значение';
    }
    if (raid0[0][0].getDataVolume() != 0) {
      return 'Диск заполнен данными, невозможно изменить количество дисков';
    }
    num += addNum;
    var length = addNum ~/ 2;
    var capacity = raid0[0][0].capacity;
    for (var diskList in raid0) {
      diskList.addAll(new List<Disk>.generate(length, (int) => Disk(capacity)));
    }
  }

  deleteDataFromDisk(int index) {
    for (var listDisk in raid0) {
      for (Disk disk in listDisk) disk.deleteData(index);
    }
  }

  int getRaidVolume() {
    int res = 0;
    for (List listDisk in raid0) {
      for (Disk disk in listDisk) res += disk.freeMemory;
    }
    return res;
  }

  writeData(String data) {
    while (data.length % num != 0) {
      data += ' ';
    }
    if (data.length > getRaidVolume()) {
      return 'Нет свободной памяти';
    }
    int sizeBlock = data.length ~/ num;
    var rand = new Random();
    int s = 0;
    for (List listDisk in raid0) {
      int parity = rand.nextInt(num ~/ 2);
      for (int i = 0; i < listDisk.length; i++) {
        if (i != parity) {
          listDisk[i].addData(data.substring(s, s + sizeBlock));
          s += sizeBlock;
        } else {
          listDisk[i].setParity();
        }
      }
    }
  }
}