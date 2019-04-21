import 'dart:math';

String generateDataString(int length) {
  var rand = new Random();
  var codes = new List.generate(
      length,
          (index){
        return rand.nextInt(33)+89;
      }
  );
  var res = new String.fromCharCodes(codes);
  return res;
}

class Disk{
  List<String> data;
  int capacity;
  int freeMemory;

  Disk(int capacity){
    this.capacity = capacity;
    this.data = [];
    this.freeMemory = this.capacity - data.length;
  }

  int getDataVolume(){
    int size = 0;
    for(var i in this.data){
        size += i.length;
    }
    return size;
  }

  deleteData(){
    this.data = [];
  }

  updateFreeMemory(){
    this.freeMemory = this.capacity - this.getDataVolume();
  }

  fillData(String data){
    if(data.length > this.getDataVolume()){
      return {-1: 'No free space'};
    }
    this.data.add(data);
    this.updateFreeMemory();
  }

  setParity(){
    this.data.add(null);
  }

  changeCapacity(int newCapacity){
    if(newCapacity < this.getDataVolume()){
      return {-1: 'Value entered is smaller than data size'};
    }
    this.capacity = newCapacity;
    this.updateFreeMemory();
  }

  addData(String data){
    if(data.length > this.freeMemory){
      return {-1: 'No free space'};
    }
    this.data.add(data);
    this.updateFreeMemory();
  }

  info(){
    return {'disk size': this.capacity, 'data': this.data, 'free': this.freeMemory};
  }
}

class RAID50{
  int num;
  List<Disk> listDisk0, listDisk1;

  RAID50(int num, int diskSize){
    this.num = num;
    var length = num~/2;
    this.listDisk0 = new List<Disk>.generate(length, (i) => Disk(diskSize));
    this.listDisk1 = new List<Disk>.generate(length, (i) => Disk(diskSize));
  }

  info(){
    var listInfo = [];
    for(int i = 0; i < this.listDisk0.length; i++){
      listInfo.add({'Disk $i': listDisk0[i].info()});
    }
    for(int i = 0; i < this.listDisk1.length; i++){
      int j = i + this.listDisk0.length;
      listInfo.add({'Disk $j': listDisk1[i].info()});
    }
    return listInfo;
  }

  changeDiskSize(int newSize){
    for(var i in this.listDisk0){
      i.changeCapacity(newSize);
    }
    for(var i in this.listDisk1){
      i.changeCapacity(newSize);
    }
  }

  changeNumDisk(int newNum){
    if(newNum%2 != 0){
      return {-1: 'Odd value'};
    }
    if(this.listDisk0[0].getDataVolume() != 0){
      return {-1: 'Disk have data'};
    }
    this.num = newNum;
    var length = newNum~/2;
    var capacity = this.listDisk0[0].capacity;
    this.listDisk0.addAll(new List<Disk>.generate(length, (int) => Disk(capacity)));
    this.listDisk1.addAll(new List<Disk>.generate(length, (int) => Disk(capacity)));
  }

  deleteDataFromAllDisk(){
    for(var i in this.listDisk0){
      i.deleteData();
    }
    for(var i in this.listDisk1){
      i.deleteData();
    }
  }

  int getRaidVolume(){
    int res = 0;
    for(var i in this.listDisk0){
      res += i.freeMemory;
    }
    for(var i in this.listDisk1){
      res += i.freeMemory;
    }
    return res;
  }

  fillDataToDisk(String data){
    if(data.length > this.getRaidVolume()){
      return {-1: 'No memory space'};
    }
    while(data.length%this.num != 0) {
      data += ' ';
    }
    int sizeBlock = data.length ~/ this.num;
    var rand = new Random(56);
    int parity = rand.nextInt(this.num~/2);
    print('DEBUG parity = $parity');
    int s = 0;
    for(int i = 0; i<this.listDisk0.length; i++){
      if(i != parity) {
        this.listDisk0[i].addData(data.substring(s, s + sizeBlock));
        s += sizeBlock;
      }
      else{
        print('DEBUG disk $i');
        this.listDisk0[i].setParity();
      }
    }
    parity = rand.nextInt(this.num~/2);
    print('DEBUG parity = $parity');
    for(int i = 0; i<this.listDisk1.length; i++){
      if(i != parity) {
        this.listDisk1[i].addData(data.substring(s, s + sizeBlock));
        s += sizeBlock;
      }
      else{
        print('DEBUG disk $i');
        this.listDisk1[i].setParity();
      }
    }
  }

}


void main() {
  var r = RAID50(6, 10);
  var l = generateDataString(10);
  r.fillDataToDisk(l);
  l = generateDataString(10);
  r.fillDataToDisk(l);
  l = generateDataString(10);

  r.fillDataToDisk(l);
  print(r.info());
}