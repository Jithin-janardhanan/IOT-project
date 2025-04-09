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
  
  void updatePumpValves(int pumpId, List<Map<String, dynamic>> valves) {
    if (_farms == null) return;
    
    // Loop through all farms to find the pump
    for (var farm in _farms!) {
      if (farm['pumps'] != null) {
        List<Map<String, dynamic>> pumps = List<Map<String, dynamic>>.from(farm['pumps']);
        int pumpIndex = pumps.indexWhere((pump) => pump['id'] == pumpId);
        
        if (pumpIndex != -1) {
          // Found the pump, update its valves
          pumps[pumpIndex]['valves'] = valves;
          farm['pumps'] = pumps;
          notifyListeners();
          break;
        }
      }
    }
  }
}
// import 'package:flutter/material.dart';
// import '../../model/user_model.dart';

// class UserProvider extends ChangeNotifier {
//   UserModel? _user;
//   List<Map<String, dynamic>>? _farms;
  
//   UserModel? get user => _user;
//   List<Map<String, dynamic>>? get farms => _farms;
  
//   void setUser(UserModel user) {
//     _user = user;
//     notifyListeners();
//   }
  
//   void clearUser() {
//     _user = null;
//     _farms = null;
//     notifyListeners();
//   }
  
//   void setFarms(List<Map<String, dynamic>> farms) {
//     _farms = farms;
//     notifyListeners();
//   }
  
//   void addFarm(Map<String, dynamic> farm) {
//     _farms ??= [];
//     _farms!.add(farm);
//     notifyListeners();
//   }
  
//   void updateFarmPumps(int farmId, List<Map<String, dynamic>> pumps) {
//     if (_farms == null) return;
    
//     int farmIndex = _farms!.indexWhere((farm) => farm['id'] == farmId);
//     if (farmIndex != -1) {
//       _farms![farmIndex]['pumps'] = pumps;
//       notifyListeners();
//     }
//   }
// }