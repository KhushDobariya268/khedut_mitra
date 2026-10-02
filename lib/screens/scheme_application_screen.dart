import 'package:flutter/material.dart';
import '../data/app_state.dart';
import '../services/firestore_service.dart';

class SchemeApplicationScreen extends StatefulWidget {
  final String schemeName;

  const SchemeApplicationScreen({
    super.key,
    required this.schemeName,
  });

  @override
  State<SchemeApplicationScreen> createState() =>
      _SchemeApplicationScreenState();
}

class _SchemeApplicationScreenState extends State<SchemeApplicationScreen> {
  final _formKey = GlobalKey<FormState>();

  final _fullNameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _aadhaarController = TextEditingController();
  final _villageController = TextEditingController();
  final _districtController = TextEditingController();
  final _landAreaController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _mobileController.dispose();
    _aadhaarController.dispose();
    _villageController.dispose();
    _districtController.dispose();
    _landAreaController.dispose();
    super.dispose();
  }

  Future<void> _submitApplication(AppState app) async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(app.t('pleaseFillAll')),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await FirestoreService().submitSchemeApplication(
        schemeName: widget.schemeName,
        fullName: _fullNameController.text.trim(),
        mobileNumber: _mobileController.text.trim(),
        aadhaarNumber: _aadhaarController.text.trim(),
        village: _villageController.text.trim(),
        district: _districtController.text.trim(),
        landArea: _landAreaController.text.trim(),
      );

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            icon: const Icon(
              Icons.check_circle,
              color: Color(0xFF2E7D32),
              size: 54,
            ),
            title: Text(
              app.lang == 'gu' ? 'અરજી સફળ!' : 'Application Successful!',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Text(
              app.t('appSubmitted'),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop(); // Close dialog
                  Navigator.of(context).pop(); // Go back to schemes list
                },
                child: const Text(
                  'OK',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                ),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error storing application: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);

    return AnimatedBuilder(
      animation: app,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text(app.t('applyTitle')),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Scheme Banner ---
                  Card(
                    color: const Color(0xFF1565C0).withOpacity(0.08),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(
                        color: Color(0xFF1565C0),
                        width: 1,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            backgroundColor: Color(0xFF1565C0),
                            child: Icon(Icons.assignment, color: Colors.white),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  app.t('schemeNameLabel'),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  widget.schemeName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1565C0),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // --- Input Fields ---
                  _buildTextField(
                    label: app.t('fullName'),
                    controller: _fullNameController,
                    icon: Icons.person,
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? app.t('pleaseFillAll') : null,
                  ),
                  _buildTextField(
                    label: app.t('mobileNumber'),
                    controller: _mobileController,
                    icon: Icons.phone,
                    keyboardType: TextInputType.phone,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return app.t('pleaseFillAll');
                      if (v.trim().length < 10) {
                        return app.lang == 'gu'
                            ? '૧૦ અંકનો યોગ્ય મોબાઈલ નંબર દાખલ કરો'
                            : 'Enter valid 10-digit mobile number';
                      }
                      return null;
                    },
                  ),
                  _buildTextField(
                    label: app.t('aadhaarNumber'),
                    controller: _aadhaarController,
                    icon: Icons.badge,
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return app.t('pleaseFillAll');
                      if (v.trim().length < 12) {
                        return app.lang == 'gu'
                            ? '૧૨ અંકનો યોગ્ય આધાર નંબર દાખલ કરો'
                            : 'Enter valid 12-digit Aadhaar number';
                      }
                      return null;
                    },
                  ),
                  _buildTextField(
                    label: app.t('village'),
                    controller: _villageController,
                    icon: Icons.location_city,
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? app.t('pleaseFillAll') : null,
                  ),
                  _buildTextField(
                    label: app.t('district'),
                    controller: _districtController,
                    icon: Icons.map,
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? app.t('pleaseFillAll') : null,
                  ),
                  _buildTextField(
                    label: app.t('landArea'),
                    controller: _landAreaController,
                    icon: Icons.landscape,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? app.t('pleaseFillAll') : null,
                  ),

                  const SizedBox(height: 24),

                  // --- Submit Button ---
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1565C0),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed:
                          _isSubmitting ? null : () => _submitApplication(app),
                      child: _isSubmitting
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  app.t('submitting'),
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            )
                          : Text(
                              app.t('submitApp'),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF1565C0)),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF1565C0), width: 2),
          ),
        ),
      ),
    );
  }
}
