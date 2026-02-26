import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../core/utils/error_handler.dart';
import '../../models/receipt_settings.dart';
import '../../data/repositories/receipt_settings_repository.dart';
import '../main_shell.dart';

class ReceiptSettingsScreen extends StatefulWidget {
  final MainShellState shell;
  const ReceiptSettingsScreen({super.key, required this.shell});

  @override
  State<ReceiptSettingsScreen> createState() => _ReceiptSettingsScreenState();
}

class _ReceiptSettingsScreenState extends State<ReceiptSettingsScreen> {
  final ReceiptSettingsRepository _settingsRepo = ReceiptSettingsRepository();

  final _storeNameController = TextEditingController();
  final _storeAddressController = TextEditingController();
  final _storePhoneController = TextEditingController();
  final _storeEmailController = TextEditingController();
  final _receiptHeaderController = TextEditingController();
  final _receiptFooterController = TextEditingController();
  final _receiptMessageController = TextEditingController();

  bool _showBarcode = true;
  bool _showTaxDetails = true;
  int _fontSize = 12;
  int _paperWidth = 58;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await _settingsRepo.getReceiptSettings();
    if (settings != null && mounted) {
      setState(() {
        _storeNameController.text = settings!.storeName;
        _storeAddressController.text = settings!.storeAddress;
        _storePhoneController.text = settings!.storePhone;
        _storeEmailController.text = settings!.storeEmail;
        _receiptHeaderController.text = settings!.receiptHeader;
        _receiptFooterController.text = settings!.receiptFooter;
        _receiptMessageController.text = settings!.receiptMessage;
        _showBarcode = settings!.showBarcode;
        _showTaxDetails = settings!.showTaxDetails;
        _fontSize = settings!.fontSize;
        _paperWidth = settings!.paperWidth;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text(
          'Receipt Settings',
          style: TextStyle(
            fontFamily: 'Urbanist',
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _saveSettings,
            child: const Text(
              'Save',
              style: TextStyle(
                fontFamily: 'Urbanist',
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('Store Information'),
                  const SizedBox(height: 12),
                  _buildStoreInfoSection(),
                  const SizedBox(height: 24),
                  _buildSectionHeader('Receipt Customization'),
                  const SizedBox(height: 12),
                  _buildReceiptCustomizationSection(),
                  const SizedBox(height: 24),
                  _buildSectionHeader('Receipt Options'),
                  const SizedBox(height: 12),
                  _buildReceiptOptionsSection(),
                  const SizedBox(height: 24),
                  _buildSectionHeader('Paper & Font'),
                  const SizedBox(height: 12),
                  _buildPaperAndFontSection(),
                  const SizedBox(height: 32),
                  _buildPreviewButton(),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontFamily: 'Urbanist',
        fontWeight: FontWeight.w700,
        fontSize: 16,
      ),
    );
  }

  Widget _buildStoreInfoSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField(
            label: 'Store Name',
            controller: _storeNameController,
            icon: Icons.store,
            hintText: 'e.g., SwiftPOS Store',
          ),
          const SizedBox(height: 12),
          _buildTextField(
            label: 'Address',
            controller: _storeAddressController,
            icon: Icons.location_on,
            hintText: 'Store address',
            maxLines: 2,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            label: 'Phone',
            controller: _storePhoneController,
            icon: Icons.phone,
            hintText: 'Store phone number',
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            label: 'Email',
            controller: _storeEmailController,
            icon: Icons.email,
            hintText: 'Store email',
            keyboardType: TextInputType.emailAddress,
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptCustomizationSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField(
            label: 'Receipt Header',
            controller: _receiptHeaderController,
            icon: Icons.title,
            hintText: 'Custom header text',
            maxLines: 2,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            label: 'Receipt Footer',
            controller: _receiptFooterController,
            icon: Icons.format_size,
            hintText: 'e.g., Thank you for your purchase!',
            maxLines: 2,
          ),
          const SizedBox(height: 12),
          _buildTextField(
            label: 'Receipt Message',
            controller: _receiptMessageController,
            icon: Icons.message,
            hintText: 'Additional message to display',
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptOptionsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSwitchTile(
            icon: Icons.qr_code,
            title: 'Show Barcode',
            subtitle: 'Display QR code/barcode on receipt',
            value: _showBarcode,
            onChanged: (value) => setState(() => _showBarcode = value),
          ),
          const SizedBox(height: 8),
          _buildSwitchTile(
            icon: Icons.receipt,
            title: 'Show Tax Details',
            subtitle: 'Display tax breakdown on receipt',
            value: _showTaxDetails,
            onChanged: (value) => setState(() => _showTaxDetails = value),
          ),
        ],
      ),
    );
  }

  Widget _buildPaperAndFontSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Paper Width',
            style: const TextStyle(
              fontFamily: 'Urbanist',
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _PaperWidthOption(
                  width: PaperWidth.mm58,
                  label: '58mm',
                  isSelected: _paperWidth == 58,
                  onTap: () => setState(() => _paperWidth = 58),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _PaperWidthOption(
                  width: PaperWidth.mm80,
                  label: '80mm',
                  isSelected: _paperWidth == 80,
                  onTap: () => setState(() => _paperWidth = 80),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Font Size',
            style: const TextStyle(
              fontFamily: 'Urbanist',
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(5, (index) {
              final size = 10 + index;
              return Expanded(
                child: _FontSizeOption(
                  size: size,
                  isSelected: _fontSize == size,
                  onTap: () => setState(() => _fontSize = size),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    String? hintText,
    int? maxLines,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Urbanist',
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          style: const TextStyle(fontFamily: 'Urbanist'),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(
              fontFamily: 'Urbanist',
              color: AppColors.gray400,
            ),
            prefixIcon: Icon(icon, size: 20, color: AppColors.gray600),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.gray300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          maxLines: maxLines,
          keyboardType: keyboardType,
        ),
      ],
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.gray200)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 22, color: AppColors.gray600),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Urbanist',
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _printTestReceipt,
        icon: const Icon(Icons.preview, size: 20),
        label: const Text(
          'Print Test Receipt',
          style: TextStyle(
            fontFamily: 'Urbanist',
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
      ),
    );
  }

  Future<void> _saveSettings() async {
    setState(() => _isLoading = true);

    try {
      final nameValidation = Validators.validateProductName(
        _storeNameController.text.trim(),
      );
      final emailValidation = Validators.validateEmail(
        _storeEmailController.text.trim(),
      );

      if (nameValidation != null && emailValidation != null) {
        final settings = ReceiptSettings(
          storeName: _storeNameController.text.trim(),
          storeAddress: _storeAddressController.text.trim(),
          storePhone: _storePhoneController.text.trim(),
          storeEmail: _storeEmailController.text.trim(),
          receiptHeader: _receiptHeaderController.text.trim(),
          receiptFooter: _receiptFooterController.text.trim(),
          receiptMessage: _receiptMessageController.text.trim(),
          showBarcode: _showBarcode,
          showTaxDetails: _showTaxDetails,
          fontSize: _fontSize,
          paperWidth: _paperWidth,
        );

        await _settingsRepo.saveReceiptSettings(settings);

        if (mounted) {
          ErrorHandler.showSuccessToast('Receipt settings saved');
        }
      } else {
        if (mounted) {
          ErrorHandler.showErrorToast(
            nameValidation ?? emailValidation ?? 'Please fix the errors',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.handleErrorWithDialog(context, e);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _printTestReceipt() async {
    setState(() => _isLoading = true);

    try {
      final settings = ReceiptSettings(
        storeName: _storeNameController.text.trim(),
        storeAddress: _storeAddressController.text.trim(),
        storePhone: _storePhoneController.text.trim(),
        storeEmail: _storeEmailController.text.trim(),
        receiptHeader: _receiptHeaderController.text.trim(),
        receiptFooter: _receiptFooterController.text.trim(),
        receiptMessage: _receiptMessageController.text.trim(),
        showBarcode: _showBarcode,
        showTaxDetails: _showTaxDetails,
        fontSize: _fontSize,
        paperWidth: _paperWidth,
      );

      await widget.shell.printTestReceipt(receiptSettings: settings);
    } catch (e) {
      ErrorHandler.handleErrorWithDialog(context, e);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

class _PaperWidthOption extends StatelessWidget {
  final PaperWidth width;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaperWidthOption({
    required this.width,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.1)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.gray300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: isSelected ? AppColors.primary : AppColors.gray400,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Urbanist',
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FontSizeOption extends StatelessWidget {
  final int size;
  final bool isSelected;
  final VoidCallback onTap;

  const _FontSizeOption({
    required this.size,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.1)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.gray300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          '$size pt',
          style: TextStyle(
            fontFamily: 'Urbanist',
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: isSelected ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
