import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../app_state.dart';
import '../l10n/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final l = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l.tabSettings)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          _Section(title: l.language),
          Card(
            child: Column(children: [
              RadioListTile<Locale?>(
                value: null,
                groupValue: s.locale,
                onChanged: (v) => s.setLocale(v),
                title: Text(l.system),
              ),
              RadioListTile<Locale?>(
                value: const Locale('id'),
                groupValue: s.locale,
                onChanged: (v) => s.setLocale(v),
                title: const Text('Bahasa Indonesia'),
              ),
              RadioListTile<Locale?>(
                value: const Locale('en'),
                groupValue: s.locale,
                onChanged: (v) => s.setLocale(v),
                title: const Text('English'),
              ),
            ]),
          ),
          const SizedBox(height: 16),
          _Section(title: l.theme),
          Card(
            child: Column(children: [
              RadioListTile<ThemeMode>(
                value: ThemeMode.system,
                groupValue: s.themeMode,
                onChanged: (v) => s.setThemeMode(v!),
                title: Text(l.system),
              ),
              RadioListTile<ThemeMode>(
                value: ThemeMode.light,
                groupValue: s.themeMode,
                onChanged: (v) => s.setThemeMode(v!),
                title: Text(l.light),
              ),
              RadioListTile<ThemeMode>(
                value: ThemeMode.dark,
                groupValue: s.themeMode,
                onChanged: (v) => s.setThemeMode(v!),
                title: Text(l.dark),
              ),
            ]),
          ),
          const SizedBox(height: 16),
          _Section(title: l.accentColor),
          Card(
            child: ListTile(
              leading: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                    color: s.accent, borderRadius: BorderRadius.circular(8)),
              ),
              title: Text(l.accentColor),
              subtitle: Text(
                  '#${s.accent.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}'),
              onTap: () async {
                Color picked = s.accent;
                await showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text(l.accentColor),
                    content: SingleChildScrollView(
                      child: ColorPicker(
                        pickerColor: picked,
                        onColorChanged: (c) => picked = c,
                        enableAlpha: false,
                        hexInputBar: true,
                        pickerAreaHeightPercent: 0.7,
                      ),
                    ),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(l.cancel)),
                      FilledButton(
                          onPressed: () async {
                            await s.setAccent(picked);
                            if (context.mounted) Navigator.pop(context);
                          },
                          child: Text(l.save)),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          _Section(title: l.backup),
          Card(
            child: Column(children: [
              ListTile(
                leading: const Icon(Icons.upload_file),
                title: Text(l.exportJson),
                onTap: () async {
                  final file = await s.exportJson();
                  if (!context.mounted) return;
                  await Share.shareXFiles([XFile(file.path)],
                      text: 'Daily backup');
                },
              ),
              ListTile(
                leading: const Icon(Icons.download),
                title: Text(l.importJson),
                onTap: () async {
                  final res = await FilePicker.platform.pickFiles();
                  if (res == null || res.files.single.path == null) return;
                  final content =
                      await File(res.files.single.path!).readAsString();
                  if (!context.mounted) return;
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text(l.importJson),
                      content: const Text('Replace semua data?'),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text(l.cancel)),
                        FilledButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: Text(l.save)),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    await s.importJson(content, replace: true);
                  }
                },
              ),
            ]),
          ),
          const SizedBox(height: 16),
          _Section(title: l.about),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Daily',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  const Text('Made by Abi Manyu (BlueBarry)'),
                  const SizedBox(height: 2),
                  Text('© 2026 Abi Manyu. All rights reserved.',
                      style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).hintColor)),
                  const SizedBox(height: 8),
                  Text('${l.version} 1.0.0',
                      style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).hintColor)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  const _Section({required this.title});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8, left: 4),
        child: Text(title,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).hintColor)),
      );
}
