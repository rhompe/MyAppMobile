import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:mychatme/l10n/app_localizations.dart';

class DeviceContactsScreen extends StatefulWidget {
  const DeviceContactsScreen({super.key});

  @override
  State<DeviceContactsScreen> createState() => _DeviceContactsScreenState();
}

class _DeviceContactsScreenState extends State<DeviceContactsScreen> {
  List<Contact> contacts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadContacts();
  }

  Future<void> loadContacts() async {
    final permiso = await FlutterContacts.requestPermission();
    if (!permiso) {
      setState(() => isLoading = false);
      return;
    }

    final lista = await FlutterContacts.getContacts(withProperties: true);
    setState(() {
      contacts = lista;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      //appBar: AppBar(title: const Text("Contactos del teléfono")),
      appBar: AppBar(title: Text(t.phoneContacts)),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : contacts.isEmpty
         // ? const Center(child: Text("No se encontraron contactos"))
         ? Center(child: Text(t.noContactsFound))
          : ListView.builder(
        itemCount: contacts.length,
        itemBuilder: (context, index) {
          final contact = contacts[index];
          final nombre = contact.displayName;
          final telefono = contact.phones.isNotEmpty
              ? contact.phones.first.number
              //: "Sin número";
              : t.noNumber;
          final inicial = contact.name.first.isNotEmpty
              ? contact.name.first[0]
              : "?";

          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.primaries[
              Random().nextInt(Colors.primaries.length)],
              child: Text(inicial),
            ),
            title: Text(nombre),
            subtitle: Text(telefono),
          );
        },
      ),
    );
  }
}

