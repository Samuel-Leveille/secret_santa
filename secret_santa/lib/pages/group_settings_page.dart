import 'package:flutter/material.dart';
import 'package:secret_santa/services/groups_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:secret_santa/providers/groups_firestore_provider.dart';
import 'package:provider/provider.dart';

class GroupSettingsPage extends StatefulWidget {
  final Map<String, dynamic>? group;
  final String groupId;
  const GroupSettingsPage(
      {super.key, required this.group, required this.groupId});

  @override
  State<GroupSettingsPage> createState() => _GroupSettingsPageState();
}

class _GroupSettingsPageState extends State<GroupSettingsPage> {
  late final TextEditingController nameController;
  late final TextEditingController descriptionController;
  late final TextEditingController moneyController;
  late final TextEditingController datePigeController;
  GroupsFirestoreProvider? _groupProvider;

  final GroupsService groupsService = GroupsService();
  final _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _groupProvider =
          Provider.of<GroupsFirestoreProvider>(context, listen: false);
    });

    nameController = TextEditingController(
      text: widget.group?['name'] ?? "Nom original",
    );
    descriptionController = TextEditingController(
      text: widget.group?['description'] ?? " ",
    );
    moneyController = TextEditingController(
      text: widget.group?['moneyMax']?.toString() ?? "25",
    );
    datePigeController = TextEditingController(
      text: widget.group?['pigeDate'] ??
          DateTime.now().toIso8601String().split('T').first,
    );
  }

  bool isEditingName = false;
  bool isEditingMoney = false;
  bool isEditingDate = false;
  bool isEditingDescription = false;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      setState(() {
        datePigeController.text = "${picked.toLocal()}".split(' ')[0];
      });
    }
  }

  void _save(String fieldName) {
    setState(() {
      switch (fieldName) {
        case 'name':
          isEditingName = false;
          break;
        case 'money':
          isEditingMoney = false;
          break;
        case 'date':
          isEditingDate = false;
          break;
        case 'description':
          isEditingDescription = false;
          break;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      fieldName == 'name'
          ? const SnackBar(content: Text('Nom du groupe mis à jour !'))
          : fieldName == 'moneyMax'
              ? const SnackBar(content: Text('Montant max mis à jour !'))
              : fieldName == 'date'
                  ? const SnackBar(
                      content: Text('Date de la pige mise à jour !'))
                  : const SnackBar(
                      content: Text('Description du groupe mis à jour !')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          "Paramètres du groupe",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildEditableField(
              label: "Nom du groupe",
              controllerName: 'name',
              icon: Icons.group,
              controller: nameController,
              isEditing: isEditingName,
              onEdit: () => setState(() => isEditingName = true),
              onSave: () => _save('name'),
            ),
            const SizedBox(height: 20),
            _buildEditableField(
              label: "Montant max / personne",
              controllerName: 'moneyMax',
              icon: Icons.attach_money_outlined,
              controller: moneyController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              isEditing: isEditingMoney,
              onEdit: () => setState(() => isEditingMoney = true),
              onSave: () => _save('money'),
            ),
            const SizedBox(height: 20),
            _buildEditableDateField(
              label: "Date de la pige",
              controllerName: 'pigeDate',
              icon: Icons.date_range,
              controller: datePigeController,
              isEditing: isEditingDate,
              onEdit: () => setState(() => isEditingDate = true),
              onSave: () => _save('date'),
              onPickDate: () => _selectDate(context),
            ),
            const SizedBox(height: 20),
            _buildEditableField(
              label: "Description",
              controllerName: 'description',
              icon: Icons.description_outlined,
              controller: descriptionController,
              maxLines: 3,
              isEditing: isEditingDescription,
              onEdit: () => setState(() => isEditingDescription = true),
              onSave: () => _save('description'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableField({
    required String label,
    required String controllerName,
    required IconData icon,
    required TextEditingController controller,
    required bool isEditing,
    required VoidCallback onEdit,
    required VoidCallback onSave,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: controller,
            enabled: isEditing,
            maxLines: maxLines,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              labelText: label,
              prefixIcon: Icon(icon, color: Colors.teal),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: const Color(0xFFF1F5F9),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              if (!isEditing)
                TextButton.icon(
                  onPressed: () {
                    onEdit();
                  },
                  label: const Text("Éditer"),
                  icon: const Icon(Icons.edit),
                ),
              if (isEditing)
                ElevatedButton(
                  onPressed: () async {
                    onSave();
                    await groupsService.updateGroupForm(
                        controller.text.trim(),
                        controllerName,
                        _auth.currentUser,
                        widget.groupId,
                        context);
                    await _groupProvider?.fetchGroupData(widget.groupId);
                    await _groupProvider?.fetchGroupsData();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 169, 225, 219),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text("Enregistrer"),
                ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildEditableDateField({
    required String label,
    required String controllerName,
    required IconData icon,
    required TextEditingController controller,
    required bool isEditing,
    required VoidCallback onEdit,
    required VoidCallback onSave,
    required VoidCallback onPickDate,
  }) {
    return _buildEditableField(
      label: label,
      controllerName: controllerName,
      icon: icon,
      controller: controller,
      isEditing: isEditing,
      onEdit: () {
        onEdit();
        onPickDate();
      },
      onSave: onSave,
    );
  }
}
