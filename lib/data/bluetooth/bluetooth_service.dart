import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';

/// Bluetooth Device Model
class BluetoothDeviceModel {
  final String name;
  final String address;
  final bool isBonded;

  BluetoothDeviceModel({
    required this.name,
    required this.address,
    required this.isBonded,
  });

  @override
  String toString() => 'BluetoothDeviceModel(name: $name, address: $address)';
}

/// Bluetooth Service - Handles scanning, connecting, and managing Bluetooth devices
class BluetoothService {
  static final BluetoothService _instance = BluetoothService._internal();
  factory BluetoothService() => _instance;
  BluetoothService._internal();

  final FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;

  // State
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;
  bool _isScanning = false;
  bool _isConnected = false;
  BluetoothConnection? _connection;
  BluetoothDeviceModel? _connectedDevice;
  final List<BluetoothDeviceModel> _discoveredDevices = [];

  // Streams
  final StreamController<BluetoothState> _stateController =
      StreamController<BluetoothState>.broadcast();
  final StreamController<List<BluetoothDeviceModel>> _devicesController =
      StreamController<List<BluetoothDeviceModel>>.broadcast();
  final StreamController<bool> _scanningController =
      StreamController<bool>.broadcast();
  final StreamController<bool> _connectionController =
      StreamController<bool>.broadcast();

  // Getters
  BluetoothState get bluetoothState => _bluetoothState;
  bool get isScanning => _isScanning;
  bool get isConnected => _isConnected;
  BluetoothDeviceModel? get connectedDevice => _connectedDevice;
  List<BluetoothDeviceModel> get discoveredDevices => _discoveredDevices;

  // Streams
  Stream<BluetoothState> get onStateChanged => _stateController.stream;
  Stream<List<BluetoothDeviceModel>> get onDevicesChanged =>
      _devicesController.stream;
  Stream<bool> get onScanningChanged => _scanningController.stream;
  Stream<bool> get onConnectionChanged => _connectionController.stream;

  /// Initialize Bluetooth service
  Future<bool> initialize() async {
    // Request permissions
    final permissions = await _requestPermissions();
    if (!permissions) return false;

    // Get current state
    _bluetoothState = (await _bluetooth.state) ?? BluetoothState.UNKNOWN;
    _stateController.add(_bluetoothState);

    // Listen to state changes
    _bluetooth.onStateChanged().listen((BluetoothState state) {
      _bluetoothState = state;
      _stateController.add(state);
      debugPrint('Bluetooth state changed: $state');
    });

    return _bluetoothState.isEnabled;
  }

  /// Request necessary permissions
  Future<bool> _requestPermissions() async {
    final statuses = await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();

    return statuses.values.every((status) => status.isGranted);
  }

  /// Check if Bluetooth is available
  Future<bool> get isAvailable async => await _bluetooth.isAvailable ?? false;

  /// Check if Bluetooth is enabled
  bool get isEnabled => _bluetoothState.isEnabled;

  /// Enable Bluetooth
  Future<bool> enableBluetooth() async {
    try {
      final result = await _bluetooth.requestEnable();
      return result ?? false;
    } catch (e) {
      debugPrint('Error enabling Bluetooth: $e');
      return false;
    }
  }

  /// Disable Bluetooth
  Future<bool> disableBluetooth() async {
    try {
      final result = await _bluetooth.requestDisable();
      return result ?? false;
    } catch (e) {
      debugPrint('Error disabling Bluetooth: $e');
      return false;
    }
  }

  /// Start scanning for Bluetooth devices
  Future<void> startScan() async {
    if (!isEnabled) {
      debugPrint('Bluetooth is not enabled');
      return;
    }

    if (_isScanning) return;

    _isScanning = true;
    _discoveredDevices.clear();
    _scanningController.add(true);
    _devicesController.add([]);

    try {
      // Get bonded devices first
      final bondedDevices = await _bluetooth.getBondedDevices();
      for (var device in bondedDevices) {
        _discoveredDevices.add(
          BluetoothDeviceModel(
            name: device.name ?? 'Unknown Device',
            address: device.address,
            isBonded: true,
          ),
        );
      }
      _devicesController.add(List.from(_discoveredDevices));

      // Start discovery
      _bluetooth.startDiscovery().listen(
        (BluetoothDiscoveryResult result) {
          final device = result.device;
          final existingIndex = _discoveredDevices.indexWhere(
            (d) => d.address == device.address,
          );

          if (existingIndex == -1) {
            _discoveredDevices.add(
              BluetoothDeviceModel(
                name: device.name ?? 'Unknown Device',
                address: device.address,
                isBonded: device.isBonded,
              ),
            );
            _devicesController.add(List.from(_discoveredDevices));
          }
        },
        onError: (error) {
          debugPrint('Discovery error: $error');
        },
        onDone: () {
          _isScanning = false;
          _scanningController.add(false);
        },
      );
    } catch (e) {
      debugPrint('Error starting scan: $e');
      _isScanning = false;
      _scanningController.add(false);
    }
  }

  /// Stop scanning for Bluetooth devices
  Future<void> stopScan() async {
    try {
      await _bluetooth.cancelDiscovery();
      _isScanning = false;
      _scanningController.add(false);
    } catch (e) {
      debugPrint('Error stopping scan: $e');
    }
  }

  /// Connect to a Bluetooth device
  Future<bool> connect(String address) async {
    if (_isConnected && _connectedDevice?.address == address) {
      return true;
    }

    try {
      // Disconnect if already connected to another device
      if (_isConnected) {
        await disconnect();
      }

      _connection = await BluetoothConnection.toAddress(address);
      _connection?.input?.listen(
        (data) {
          debugPrint('Received data: $data');
        },
        onError: (error) {
          debugPrint('Connection error: $error');
        },
      );

      _isConnected = true;
      _connectionController.add(true);

      // Find the device in discovered list
      final device = _discoveredDevices.firstWhere(
        (d) => d.address == address,
        orElse: () => BluetoothDeviceModel(
          name: 'Connected Device',
          address: address,
          isBonded: true,
        ),
      );
      _connectedDevice = device;

      debugPrint('Connected to ${device.name}');
      return true;
    } catch (e) {
      debugPrint('Error connecting to device: $e');
      _isConnected = false;
      _connectionController.add(false);
      return false;
    }
  }

  /// Disconnect from the current Bluetooth device
  Future<void> disconnect() async {
    try {
      await _connection?.close();
      _connection = null;
      _isConnected = false;
      _connectedDevice = null;
      _connectionController.add(false);
      debugPrint('Disconnected');
    } catch (e) {
      debugPrint('Error disconnecting: $e');
    }
  }

  /// Send data to the connected device
  Future<bool> sendData(String data) async {
    if (!_isConnected || _connection == null) {
      debugPrint('No device connected');
      return false;
    }

    try {
      _connection?.output.add(Uint8List.fromList(data.codeUnits));
      return true;
    } catch (e) {
      debugPrint('Error sending data: $e');
      return false;
    }
  }

  /// Send bytes to the connected device
  Future<bool> sendBytes(List<int> data) async {
    if (!_isConnected || _connection == null) {
      debugPrint('No device connected');
      return false;
    }

    try {
      _connection?.output.add(Uint8List.fromList(data));
      return true;
    } catch (e) {
      debugPrint('Error sending data: $e');
      return false;
    }
  }

  /// Get bonded devices
  Future<List<BluetoothDeviceModel>> getBondedDevices() async {
    try {
      final devices = await _bluetooth.getBondedDevices();
      return devices
          .map(
            (d) => BluetoothDeviceModel(
              name: d.name ?? 'Unknown Device',
              address: d.address,
              isBonded: true,
            ),
          )
          .toList();
    } catch (e) {
      debugPrint('Error getting bonded devices: $e');
      return [];
    }
  }

  /// Dispose resources
  void dispose() {
    _connection?.close();
    _connection = null;
    _stateController.close();
    _devicesController.close();
    _scanningController.close();
    _connectionController.close();
  }
}
