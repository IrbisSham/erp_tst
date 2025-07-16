import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  StreamController<bool> connectionStatusController = StreamController<bool>.broadcast();

  bool _isOnline = false;
  bool get isOnline => _isOnline;

  Stream<bool> get connectionStream => connectionStatusController.stream;

  Future<void> initialize() async {
    // Check initial connectivity
    final result = await _connectivity.checkConnectivity();
    // _updateConnectionStatus([result]);
    _updateConnectionStatus2(result);

    // Listen for connectivity changes
    _connectivity.onConnectivityChanged.listen(_updateConnectionStatus2);
  }

  void _updateConnectionStatus2(ConnectivityResult result) {
    bool isConnected = result == ConnectivityResult.mobile ||
        result == ConnectivityResult.wifi ||
        result == ConnectivityResult.ethernet;
    if (_isOnline != isConnected) {
      _isOnline = isConnected;
      connectionStatusController.add(_isOnline);
    }
  }


    void _updateConnectionStatus(List<ConnectivityResult> results) {
    final isConnected = results.any((result) => 
      result == ConnectivityResult.mobile || 
      result == ConnectivityResult.wifi ||
      result == ConnectivityResult.ethernet
    );
    
    if (_isOnline != isConnected) {
      _isOnline = isConnected;
      connectionStatusController.add(_isOnline);
    }
  }

  void dispose() {
    connectionStatusController.close();
  }
}
