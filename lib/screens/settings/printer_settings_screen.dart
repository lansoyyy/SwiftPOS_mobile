import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../main_shell.dart';

class PrinterSettingsScreen extends StatefulWidget {
  final MainShellState shell;
  const PrinterSettingsScreen({super.key, required this.shell});

  @override
  State<PrinterSettingsScreen> createState() => _PrinterSettingsScreenState();
}

class _PrinterSettingsScreenState extends State<PrinterSettingsScreen> {
  bool _scanning = false;
  bool _testPrinting = false;
  List<_BtDevice> _devices = [];

  static const _mockDevices = [
    _BtDevice('EPSON TM-T82', 'Thermal Printer', '3C:A8:2A:12:BC:F1'),
    _BtDevice('Xprinter XP-58', 'Thermal Printer', 'A4:C3:F0:85:AC:22'),
    _BtDevice('BlueTooth Speaker', 'Audio Device', '1A:2B:3C:4D:5E:6F'),
    _BtDevice('Galaxy S24', 'Phone', 'FA:12:34:56:78:90'),
  ];

  Future<void> _startScan() async {
    setState(() {
      _scanning = true;
      _devices = [];
    });
    for (int i = 0; i < _mockDevices.length; i++) {
      await Future.delayed(const Duration(milliseconds: 600));
      if (!mounted) return;
      setState(() => _devices.add(_mockDevices[i]));
    }
    setState(() => _scanning = false);
  }

  Future<void> _testPrint() async {
    setState(() => _testPrinting = true);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _testPrinting = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Test print sent successfully!',
          style: TextStyle(
            fontFamily: 'Urbanist',
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isConnected = widget.shell.isPrinterConnected;
    final printerName = widget.shell.connectedPrinter;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Header
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Settings',
                  style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontWeight: FontWeight.w800,
                    fontSize: 26,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  'Printer & device configuration',
                  style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Connection status card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isConnected
                    ? AppColors.success.withOpacity(0.08)
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isConnected
                      ? AppColors.success.withOpacity(0.4)
                      : AppColors.surface,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isConnected
                          ? AppColors.success
                          : AppColors.surface,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isConnected ? Icons.print : Icons.print_disabled_outlined,
                      color: AppColors.surface,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isConnected ? printerName! : 'No Printer Connected',
                          style: TextStyle(
                            fontFamily: 'Urbanist',
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: isConnected
                                ? AppColors.success
                                : AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          isConnected
                              ? 'Connected & Ready'
                              : 'Scan to find a printer',
                          style: TextStyle(
                            fontFamily: 'Urbanist',
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isConnected)
                    TextButton(
                      onPressed: widget.shell.disconnectPrinter,
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.error,
                        padding: EdgeInsets.zero,
                      ),
                      child: const Text(
                        'Disconnect',
                        style: TextStyle(
                          fontFamily: 'Urbanist',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Scan button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _scanning ? null : _startScan,
                icon: _scanning
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          color: AppColors.surface,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.bluetooth_searching, size: 20),
                label: Text(
                  _scanning ? 'Scanning...' : 'Search for Printer',
                  style: const TextStyle(
                    fontFamily: 'Urbanist',
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.primary.withOpacity(0.5),
                  disabledForegroundColor: Colors.white70,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
              ),
            ),

            // Devices list
            if (_devices.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text(
                'Nearby Devices (${_devices.length})',
                style: const TextStyle(
                  fontFamily: 'Urbanist',
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 10),
              ...(_devices.map((d) {
                final isThermal = d.type == 'Thermal Printer';
                final isCurrentlyConnected =
                    widget.shell.connectedPrinter == d.name;
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: isCurrentlyConnected
                        ? Border.all(color: AppColors.success.withOpacity(0.3))
                        : null,
                    boxShadow: [
                      BoxShadow(color: AppColors.shadow, blurRadius: 6),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isThermal
                              ? AppColors.primaryBg
                              : AppColors.gray100,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          isThermal ? Icons.print : Icons.bluetooth,
                          size: 20,
                          color: isThermal
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              d.name,
                              style: const TextStyle(
                                fontFamily: 'Urbanist',
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              '${d.type} · ${d.mac}',
                              style: TextStyle(
                                fontFamily: 'Urbanist',
                                fontSize: 11,
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isCurrentlyConnected)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.success.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Connected',
                            style: TextStyle(
                              fontFamily: 'Urbanist',
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.success,
                            ),
                          ),
                        )
                      else
                        GestureDetector(
                          onTap: () => widget.shell.connectPrinter(d.name),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: isThermal
                                  ? AppColors.primary
                                  : AppColors.gray200,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Connect',
                              style: TextStyle(
                                fontFamily: 'Urbanist',
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: isThermal
                                    ? AppColors.textOnPrimary
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              })),
            ],

            // Test print section
            if (isConnected) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: AppColors.shadow, blurRadius: 8),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Test Printer',
                      style: TextStyle(
                        fontFamily: 'Urbanist',
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Print a test page to verify your printer is working correctly.',
                      style: TextStyle(
                        fontFamily: 'Urbanist',
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _testPrinting ? null : _testPrint,
                        icon: _testPrinting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.print_outlined, size: 18),
                        label: Text(
                          _testPrinting ? 'Printing...' : 'Test Print',
                          style: const TextStyle(
                            fontFamily: 'Urbanist',
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: BorderSide(color: AppColors.primary),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            // App info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: AppColors.shadow, blurRadius: 8)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'About SwiftPOS',
                    style: TextStyle(
                      fontFamily: 'Urbanist',
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _InfoRow(
                    icon: Icons.info_outline,
                    label: 'Version',
                    value: '1.0.0',
                  ),
                  const SizedBox(height: 8),
                  _InfoRow(
                    icon: Icons.offline_bolt_outlined,
                    label: 'Mode',
                    value: 'Offline',
                  ),
                  const SizedBox(height: 8),
                  _InfoRow(
                    icon: Icons.receipt_long_outlined,
                    label: 'Printer Support',
                    value: 'Bluetooth Thermal',
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

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textTertiary),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Urbanist',
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Urbanist',
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _BtDevice {
  final String name;
  final String type;
  final String mac;
  const _BtDevice(this.name, this.type, this.mac);
}
