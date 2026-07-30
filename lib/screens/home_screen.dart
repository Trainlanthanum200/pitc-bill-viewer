import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/saved_ref.dart';
import '../services/storage_service.dart';
import '../services/disco_bill_scraper_service.dart';
import '../widgets/app_drawer.dart';
import 'bill_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<SavedRef> _refs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final refs = await StorageService.loadAll();
    setState(() {
      _refs = refs;
      _loading = false;
    });
  }

  Future<void> _openAddDialog() async {
    final labelController = TextEditingController();
    final refController = TextEditingController();
    Disco? selectedDisco;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Add Reference Number"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<Disco>(
                initialValue: selectedDisco,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: "Select Company",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                items: kDiscoList
                    .map((d) => DropdownMenuItem(
                          value: d,
                          child: Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: d.themeColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  "${d.shortName} — ${d.fullName}",
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ))
                    .toList(),
                onChanged: (d) => setDialogState(() => selectedDisco = d),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: labelController,
                decoration: InputDecoration(
                  labelText: "Label (e.g. Ghar, Dukan)",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: refController,
                keyboardType: TextInputType.number,
                maxLength: 14,
                decoration: InputDecoration(
                  labelText: "14-digit Reference Number",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                final label = labelController.text.trim();
                final refNo = refController.text.trim();
                if (selectedDisco == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please select a company")),
                  );
                  return;
                }
                if (label.isEmpty || refNo.length != 14) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            "Enter a label and a valid 14-digit number")),
                  );
                  return;
                }
                Navigator.pop(context, true);
              },
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );

    if (result == true) {
      final newRef = SavedRef(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        label: labelController.text.trim(),
        refNo: refController.text.trim(),
        discoCode: selectedDisco!.code,
      );
      await StorageService.add(newRef);
      _load();
    }
  }

  Future<void> _deleteRef(SavedRef ref) async {
    await StorageService.remove(ref.id);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const AppDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _refs.isEmpty
                      ? _buildEmptyState()
                      : _buildList(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddDialog,
        backgroundColor: kPrimary,
        icon: const Icon(Icons.add_rounded),
        label: const Text("Add Number"),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [kPrimary, kPrimaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: kPrimary.withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            icon: const Icon(Icons.menu_rounded, color: Colors.white),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.bolt_rounded, color: Colors.white, size: 32),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  kAppName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  "Your saved connections",
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.receipt_long_rounded,
                size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              "No saved numbers yet",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600),
            ),
            const SizedBox(height: 6),
            Text(
              "Tap 'Add Number' below to save your first\nelectricity reference number.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
      itemCount: _refs.length,
      itemBuilder: (context, index) {
        final ref = _refs[index];
        final disco = discoByCode(ref.discoCode);
        final color = disco.themeColor;
        return Dismissible(
          key: ValueKey(ref.id),
          direction: DismissDirection.endToStart,
          background: Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            padding: const EdgeInsets.only(right: 20),
            alignment: Alignment.centerRight,
            decoration: BoxDecoration(
              color: Colors.red.shade400,
              borderRadius: BorderRadius.circular(18),
            ),
            child:
                const Icon(Icons.delete_outline_rounded, color: Colors.white),
          ),
          onDismissed: (_) => _deleteRef(ref),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18)),
              leading: Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.bolt_rounded, color: color),
              ),
              title: Text(
                ref.label,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 15),
              ),
              subtitle: Text(
                "${disco.shortName} • Ref: ${ref.refNo}",
                style: const TextStyle(fontSize: 12),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.delete_outline_rounded,
                        color: Colors.red.shade300),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18)),
                          title: const Text("Delete this number?"),
                          content: Text(
                              "\"${ref.label}\" will be removed from your saved list."),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text("Cancel"),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red.shade400),
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text("Delete"),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) _deleteRef(ref);
                    },
                  ),
                  const Icon(Icons.chevron_right_rounded),
                ],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BillScreen(
                      refNo: ref.refNo,
                      label: ref.label,
                      discoCode: ref.discoCode,
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

