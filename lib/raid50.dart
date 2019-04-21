import 'package:random_string/random_string.dart';

class Disk{
  var data;
  var capacity;
  var freeMemory;
  var _parity;

  Disk(int capacity){
    this.capacity = capacity;
    this._parity = false;
    this.data = '';

  }

  fillData(String data){
    this.data = data;
    this.freeMemory = this.capacity - data.length;
  }

  setParity(){
    this._parity = true;
    this.data = null;
    this.capacity = this.capacity * 0.01;
    this.freeMemory = this.capacity;
  }

  isParity(){
    return this._parity;
  }

}

class RAID50{
  var num;
  var listDisk;

  RAID50(int num, int capacity){
    this.num = num;
    this.listDisk = new List<Disk>.generate(num, (i) => Disk(capacity));
  }
}

void main(){
  var d = Disk(50);

  var a =5;
  print(5);
  a = a*2;
  print(a);

  print('DIsk $d');
}