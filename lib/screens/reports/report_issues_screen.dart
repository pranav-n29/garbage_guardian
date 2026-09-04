import 'package:flutter/material.dart';
import '../../models/bin.dart';
import '../../services/bin_store.dart';
import '../../services/report_store.dart';

class ReportIssuesScreen extends StatefulWidget {
  const ReportIssuesScreen({super.key});

  @override
  State<ReportIssuesScreen> createState() =>
      _ReportIssuesScreenState();
}

class _ReportIssuesScreenState
    extends State<ReportIssuesScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _descriptionController =
      TextEditingController();

  String? _selectedIssue;
  String? _selectedBinId;
  String _selectedLocation = 'Location unavailable';

  bool _isSubmitting = false;

  final List<String> _issueTypes = [
    'Bin is Full',
    'Bin is Damaged',
    'Garbage Around Bin',
    'Bad Odour',
    'Bin Not Working',
    'Other',
  ];

  @override
  void initState() {
    super.initState();

    BinStore.instance.addListener(_onBinsUpdated);
  }

  @override
  void dispose() {
    BinStore.instance.removeListener(_onBinsUpdated);
    _descriptionController.dispose();
    super.dispose();
  }

  void _onBinsUpdated() {
    if (!mounted) return;

    if (_selectedBinId != null) {
      final bin = BinStore.instance.bins.cast<Bin?>().firstWhere(
        (item) => item?.id == _selectedBinId,
        orElse: () => null,
      );

      if (bin != null) {
        setState(() {
          _selectedLocation = bin.location.isEmpty
              ? 'Location unavailable'
              : bin.location;
        });
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final arguments =
        ModalRoute.of(context)?.settings.arguments;

    if (arguments is Map) {
      final binId = arguments['binId']?.toString();

      if (binId != null && binId.isNotEmpty) {
        _selectedBinId = binId;

        final location =
            arguments['location']?.toString();

        if (location != null && location.isNotEmpty) {
          _selectedLocation = location;
        }

        final bin = BinStore.instance.bins
            .cast<Bin?>()
            .firstWhere(
              (item) => item?.id == binId,
              orElse: () => null,
            );

        if (bin != null) {
          _selectedLocation =
              bin.location.isEmpty
                  ? 'Location unavailable'
                  : bin.location;
        }
      }
    }
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedBinId == null ||
        _selectedBinId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please select a smart bin.',
          ),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    // Temporary local submission.
    // This will be replaced with the backend API
    // when the report endpoint is provided.

    await Future.delayed(
      const Duration(milliseconds: 600),
    );

    ReportStore.instance.addReport(
      binId: _selectedBinId!,
      location: _selectedLocation,
      issueType: _selectedIssue!,
      description:
          _descriptionController.text.trim(),
    );

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
    });

    _showSuccessDialog();
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.check_circle,
                color: Color(0xFF2E7D32),
                size: 30,
              ),
              SizedBox(width: 10),
              Text('Report Submitted'),
            ],
          ),
          content: const Text(
            'Your issue has been recorded successfully. '
            'You can view it under My Reports.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text(
                'Done',
                style: TextStyle(
                  color: Color(0xFF2E7D32),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bins = BinStore.instance.bins;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8F6),

      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Report an Issue',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Form(
        key: _formKey,

        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [

              // -------------------------------------------------------
              // HEADER
              // -------------------------------------------------------

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),

                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius:
                      BorderRadius.circular(18),
                ),

                child: const Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.report_problem_outlined,
                      color: Color(0xFF2E7D32),
                      size: 28,
                    ),

                    SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Help us keep the city clean',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),

                          SizedBox(height: 5),

                          Text(
                            'Report a problem with a smart bin '
                            'so the waste management team can '
                            'take appropriate action.',
                            style: TextStyle(
                              color:
                                  Color(0xFF4F6651),
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // -------------------------------------------------------
              // SMART BIN
              // -------------------------------------------------------

              const Text(
                'Smart Bin',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              DropdownButtonFormField<String>(
                initialValue: _selectedBinId,

                decoration: InputDecoration(
                  prefixIcon: const Icon(
                    Icons.delete_outline,
                    color: Color(0xFF2E7D32),
                  ),

                  labelText: 'Select Smart Bin',

                  filled: true,
                  fillColor: Colors.white,

                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),

                items: bins.map((bin) {
                  return DropdownMenuItem<String>(
                    value: bin.id,

                    child: Text(
                      bin.id,
                    ),
                  );
                }).toList(),

                onChanged: (value) {
                  if (value == null) return;

                  final bin = bins.cast<Bin?>().firstWhere(
                    (item) => item?.id == value,
                    orElse: () => null,
                  );

                  setState(() {
                    _selectedBinId = value;

                    _selectedLocation =
                        bin == null ||
                                bin.location.isEmpty
                            ? 'Location unavailable'
                            : bin.location;
                  });
                },

                validator: (value) {
                  if (value == null ||
                      value.isEmpty) {
                    return 'Please select a smart bin';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 12),

              // LOCATION
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(14),
                ),

                child: Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      color: Colors.grey,
                      size: 20,
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Location',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 11,
                            ),
                          ),

                          const SizedBox(height: 3),

                          Text(
                            _selectedLocation,
                            style: const TextStyle(
                              fontWeight:
                                  FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // -------------------------------------------------------
              // ISSUE TYPE
              // -------------------------------------------------------

              const Text(
                'Issue Type',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              DropdownButtonFormField<String>(
                initialValue: _selectedIssue,

                decoration: InputDecoration(
                  prefixIcon: const Icon(
                    Icons.category_outlined,
                    color: Color(0xFF2E7D32),
                  ),

                  labelText: 'Select issue type',

                  filled: true,
                  fillColor: Colors.white,

                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),

                items: _issueTypes.map((issue) {
                  return DropdownMenuItem<String>(
                    value: issue,
                    child: Text(issue),
                  );
                }).toList(),

                onChanged: (value) {
                  setState(() {
                    _selectedIssue = value;
                  });
                },

                validator: (value) {
                  if (value == null ||
                      value.isEmpty) {
                    return 'Please select an issue type';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 24),

              // -------------------------------------------------------
              // DESCRIPTION
              // -------------------------------------------------------

              const Text(
                'Description',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              TextFormField(
                controller:
                    _descriptionController,

                maxLines: 5,

                decoration: InputDecoration(
                  hintText:
                      'Describe the issue...',
                  hintStyle: const TextStyle(
                    color: Colors.grey,
                  ),

                  filled: true,
                  fillColor: Colors.white,

                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),

                  contentPadding:
                      const EdgeInsets.all(16),
                ),

                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Please describe the issue';
                  }

                  if (value.trim().length < 5) {
                    return 'Please provide a little more detail';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 20),

              // -------------------------------------------------------
              // PHOTO
              // -------------------------------------------------------

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.grey.shade200,
                  ),
                ),

                child: Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,

                      decoration: BoxDecoration(
                        color:
                            Colors.blue.withValues(
                          alpha: 0.1,
                        ),
                        borderRadius:
                            BorderRadius.circular(12),
                      ),

                      child: const Icon(
                        Icons.camera_alt_outlined,
                        color: Colors.blue,
                      ),
                    ),

                    const SizedBox(width: 12),

                    const Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Add Photo',
                            style: TextStyle(
                              fontWeight:
                                  FontWeight.w600,
                            ),
                          ),

                          SizedBox(height: 3),

                          Text(
                            'Photo attachment can be connected later.',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),

                    OutlinedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Photo upload will be connected next.',
                            ),
                          ),
                        );
                      },
                      child: const Text('Add'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // -------------------------------------------------------
              // SUBMIT
              // -------------------------------------------------------

              SizedBox(
                width: double.infinity,
                height: 54,

                child: ElevatedButton.icon(
                  onPressed: _isSubmitting
                      ? null
                      : _submitReport,

                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(
                          Icons.send_outlined,
                        ),

                  label: Text(
                    _isSubmitting
                        ? 'Submitting...'
                        : 'Submit Report',

                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xFF2E7D32),
                    foregroundColor:
                        Colors.white,

                    disabledBackgroundColor:
                        Colors.grey.shade400,

                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // -------------------------------------------------------
              // NOTE
              // -------------------------------------------------------

              Container(
                padding:
                    const EdgeInsets.all(14),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(14),
                ),

                child: const Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.grey,
                      size: 20,
                    ),

                    SizedBox(width: 10),

                    Expanded(
                      child: Text(
                        'Please provide accurate information '
                        'so the waste management team can '
                        'respond effectively.',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}