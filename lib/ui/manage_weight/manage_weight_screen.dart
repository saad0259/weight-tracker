import 'package:flutter/material.dart';
import '../../providers/weight_provider.dart';
import '../../utils/custom_validator.dart';
import 'package:provider/provider.dart';

class ManageWeightScreen extends StatefulWidget {
  static const routeName = '/manage-weight-screen';

  const ManageWeightScreen({Key? key}) : super(key: key);

  @override
  State<ManageWeightScreen> createState() => _ManageWeightScreenState();
}

class _ManageWeightScreenState extends State<ManageWeightScreen> {
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  double _formData = 0.0;
  String? entryId;
  String? initData;
  final customValidator = CustomValidator();

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      // Invalid!
      return;
    }
    try {
      Focus.of(context).unfocus();
    } catch (_) {}
    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
    });

    if (entryId == null) {
      await Provider.of<WeightProvider>(context, listen: false)
          .addWeightEntry(_formData.toStringAsFixed(2));
    } else {
      Provider.of<WeightProvider>(context, listen: false)
          .updateWeight(entryId!, _formData.toStringAsFixed(2));
    }

    setState(() {
      _isLoading = false;
    });
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    entryId = ModalRoute.of(context)?.settings.arguments as String?;
    if (entryId != null) {
      initData = Provider.of<WeightProvider>(context, listen: false)
          .findById(entryId!);
    }

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Manage Weight'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  initialValue: entryId == null ? '' : initData,
                  key: const ValueKey('weight'),
                  decoration: const InputDecoration(
                      hintText: 'Add your weight (e.g 61.58)'),
                  keyboardType: TextInputType.number,
                  validator: (val) => customValidator.validateNumber(val),
                  onSaved: (val) {
                    if (val != null) {
                      val.replaceAll(' ', '');
                      _formData = double.parse(val);
                    }
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading
                      ? const CircularProgressIndicator.adaptive()
                      : const Text('Save'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
