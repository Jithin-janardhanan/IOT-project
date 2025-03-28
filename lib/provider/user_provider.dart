// import 'package:flutter/material.dart';
// import '../../model/user_model.dart';

// class UserProvider extends ChangeNotifier {
//   UserModel? _user;
  
//   UserModel? get user => _user;
  
//   void setUser(UserModel user) {
//     _user = user;
//     notifyListeners();
//   }
  
//   void clearUser() {
//     _user = null;
//     notifyListeners();
//   }
  
// }
import 'package:flutter/material.dart';
import '../../model/user_model.dart';

class UserProvider extends ChangeNotifier {
  UserModel? _user;
  List<Map<String, dynamic>>? _farms;
  
  UserModel? get user => _user;
  List<Map<String, dynamic>>? get farms => _farms;
  
  void setUser(UserModel user) {
    _user = user;
    notifyListeners();
  }
  
  void clearUser() {
    _user = null;
    _farms = null;
    notifyListeners();
  }
  
  void setFarms(List<Map<String, dynamic>> farms) {
    _farms = farms;
    notifyListeners();
  }
  
  void addFarm(Map<String, dynamic> farm) {
    _farms ??= [];
    _farms!.add(farm);
    notifyListeners();
  }
  
  void updateFarmPumps(int farmId, List<Map<String, dynamic>> pumps) {
    if (_farms == null) return;
    
    int farmIndex = _farms!.indexWhere((farm) => farm['id'] == farmId);
    if (farmIndex != -1) {
      _farms![farmIndex]['pumps'] = pumps;
      notifyListeners();
    }
  }
}