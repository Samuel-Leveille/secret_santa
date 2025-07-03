import 'package:flutter/material.dart';
import 'package:secret_santa/providers/pige_provider.dart';
import 'package:secret_santa/services/groups_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:secret_santa/providers/groups_firestore_provider.dart';
import 'package:provider/provider.dart';
import 'package:secret_santa/services/pige_service.dart';

class GroupSettingsPage extends StatefulWidget {
  final Map<String, dynamic>? group;
  final String groupId;
  final List<dynamic> participants;
  const GroupSettingsPage(
      {super.key,
      required this.group,
      required this.participants,
      required this.groupId});

  @override
  State<GroupSettingsPage> createState() => _GroupSettingsPageState();
}

class _GroupSettingsPageState extends State<GroupSettingsPage> {
  late final TextEditingController nameController;
  late final TextEditingController descriptionController;
  late final TextEditingController moneyController;
  late final TextEditingController datePigeController;
  GroupsFirestoreProvider? _groupProvider;
  PigeProvider? _pigeProvider;

  final GroupsService groupsService = GroupsService();
  final _auth = FirebaseAuth.instance;
  final PigeService pigeService = PigeService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _groupProvider =
          Provider.of<GroupsFirestoreProvider>(context, listen: false);
      await _groupProvider?.fetchGroupData(widget.groupId);
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
        scrolledUnderElevation: 0.0,
        backgroundColor: const Color(0xFFF7F9FB),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: 8.0, right: 8.0),
                    child: Text(
                      "Paramètres du groupe",
                      style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w700,
                          fontSize: 28),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 30.0,
            ),
            Consumer<GroupsFirestoreProvider>(
              builder: (context, provider, child) {
                Map<String, dynamic>? group = provider.groupData;
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        group!['pigeStatus'] == 'INACTIVE'
                            ? const Color.fromARGB(255, 142, 234, 255)
                            : const Color.fromARGB(255, 255, 142, 142),
                        group['pigeStatus'] == 'INACTIVE'
                            ? const Color(0xFF0083B0)
                            : const Color.fromARGB(255, 176, 0, 0)
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24.0),
                              ),
                              contentPadding:
                                  const EdgeInsets.fromLTRB(24, 20, 24, 8),
                              titlePadding: const EdgeInsets.only(top: 16),
                              title: Column(
                                children: [
                                  (group['pigeStatus'] == 'INACTIVE' &&
                                              widget.participants.length ==
                                                  2) ||
                                          (group['pigeStatus'] == 'ACTIVE')
                                      ? const Icon(
                                          Icons.warning,
                                          size: 48,
                                          color: Colors.redAccent,
                                        )
                                      : const Icon(
                                          Icons.auto_awesome,
                                          size: 48,
                                          color:
                                              Color.fromARGB(255, 3, 157, 208),
                                        ),
                                  const SizedBox(height: 12),
                                  group['pigeStatus'] == 'INACTIVE' &&
                                          widget.participants.length == 2
                                      ? const Text(
                                          "Vous n'êtes que deux",
                                          style: TextStyle(
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold),
                                        )
                                      : group['pigeStatus'] == 'INACTIVE' &&
                                              widget.participants.length > 2
                                          ? const Text(
                                              "Lancer la pige ?",
                                              style: TextStyle(
                                                  fontSize: 22,
                                                  fontWeight: FontWeight.bold),
                                            )
                                          : const Text(
                                              "Annuler la pige ?",
                                              style: TextStyle(
                                                  fontSize: 22,
                                                  fontWeight: FontWeight.bold),
                                            )
                                ],
                              ),
                              content: Padding(
                                  padding: const EdgeInsets.only(bottom: 12.0),
                                  child: group['pigeStatus'] == 'INACTIVE' &&
                                          widget.participants.length == 2
                                      ? const Text(
                                          'Vous pouvez lancer la pige, mais il n\'y aura aucune surprise quant au résultat...',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.black87,
                                          ),
                                        )
                                      : group['pigeStatus'] == 'INACTIVE' &&
                                              widget.participants.length > 2
                                          ? const Text(
                                              'Êtes-vous sûr de vouloir lancer la pige ? Vous pourrez annuler à tout moment',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.black87,
                                              ),
                                            )
                                          : Container(
                                              height: 150.0,
                                              child: const Column(
                                                children: [
                                                  Text(
                                                    'Êtes-vous sûr de vouloir annuler la pige ? Cette action est irréversible',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.black87,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 12,
                                                  ),
                                                  Text(
                                                    'Appuyez sur « Confirmer » pour annuler la pige',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      color: Colors.black87,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )),
                              actionsPadding: const EdgeInsets.only(
                                  bottom: 12, right: 16, left: 16),
                              actionsAlignment: MainAxisAlignment.spaceBetween,
                              actions: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: OutlinedButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    style: OutlinedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                      side:
                                          const BorderSide(color: Colors.grey),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 12),
                                    ),
                                    child: const Text(
                                      'Annuler',
                                      style: TextStyle(
                                          fontSize: 16, color: Colors.black87),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      Navigator.of(context).pop();
                                      if (group['pigeStatus'] == 'INACTIVE') {
                                        await pigeService.lancerPige(
                                            widget.participants,
                                            widget.groupId,
                                            context);
                                      } else if (group['pigeStatus'] ==
                                          'ACTIVE') {
                                        await pigeService
                                            .cancelPige(widget.groupId);
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                                content: Text(
                                                    'Erreur: Aucune action n\'a été exécutée, veuillez réessayer ou nous contacter pour de l\'aide')));
                                      }
                                      await _groupProvider
                                          ?.fetchGroupData(widget.groupId);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: (group['pigeStatus'] ==
                                                      'INACTIVE' &&
                                                  widget.participants.length ==
                                                      2) ||
                                              (group['pigeStatus'] == 'ACTIVE')
                                          ? Colors.redAccent
                                          : const Color.fromARGB(
                                              255, 3, 157, 208),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12)),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 22, vertical: 12),
                                    ),
                                    child: group['pigeStatus'] == 'INACTIVE'
                                        ? const Text(
                                            'Lancer',
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.white),
                                          )
                                        : const Text(
                                            'Confirmer',
                                            style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.white),
                                          ),
                                  ),
                                ),
                              ],
                            );
                          });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 65, vertical: 18),
                    ),
                    child: group['pigeStatus'] == 'INACTIVE'
                        ? const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.casino, color: Colors.white),
                              SizedBox(width: 12),
                              Text(
                                "Lancer la pige",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.1,
                                ),
                              ),
                            ],
                          )
                        : const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(width: 6),
                              Text(
                                "Annuler la pige",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.1,
                                ),
                              ),
                              SizedBox(width: 6),
                            ],
                          ),
                  ),
                );
              },
            ),
            const SizedBox(
              height: 48.0,
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 8.0),
              child: Text(
                "Modification du groupe",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
              ),
            ),
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
            Padding(
              padding: const EdgeInsets.only(bottom: 26.0),
              child: _buildEditableField(
                label: "Description",
                controllerName: 'description',
                icon: Icons.description_outlined,
                controller: descriptionController,
                maxLines: 3,
                isEditing: isEditingDescription,
                onEdit: () => setState(() => isEditingDescription = true),
                onSave: () => _save('description'),
              ),
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
                  label: const Text(
                    "Éditer",
                    style: TextStyle(color: Colors.black),
                  ),
                  icon: const Icon(
                    Icons.edit,
                    color: Colors.black,
                  ),
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
