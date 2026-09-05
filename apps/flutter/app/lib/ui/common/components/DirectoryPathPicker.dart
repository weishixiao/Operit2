import 'dart:io' show Platform;

import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

/// Whether the current platform provides a native directory picker through
/// [getDirectoryPath]. Only desktop platforms (and the web) do; on mobile
/// platforms (iOS / Android / OpenHarmony) the file_selector implementation
/// throws `UnimplementedError`.
bool get _supportsNativeDirectoryPicker =>
    kIsWeb ||
    (!kIsWeb &&
        (Platform.isMacOS || Platform.isWindows || Platform.isLinux));

/// Presents a directory path picker that works on every platform.
///
/// On desktop and the web the native directory picker is used. On mobile
/// platforms a text dialog is shown instead so the user can enter the path
/// manually (which is also the practical way for jailbroken devices that
/// need to reach arbitrary on-device directories).
///
/// Returns a trimmed non-empty path, or `null` when the user cancels.
Future<String?> showDirectoryPathPicker(
  BuildContext context, {
  required String title,
  String? initialPath,
}) async {
  if (_supportsNativeDirectoryPicker) {
    final path = await getDirectoryPath(
      initialDirectory: (initialPath == null || initialPath.isEmpty)
          ? null
          : initialPath,
    );
    if (path == null || path.trim().isEmpty) {
      return null;
    }
    return path.trim();
  }

  final controller = TextEditingController(text: initialPath ?? '');
  final entered = await showDialog<String>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: controller,
        autofocus: true,
        decoration: const InputDecoration(
          hintText: '/var/mobile/Documents/operit',
          border: OutlineInputBorder(),
        ),
        onSubmitted: (value) {
          final text = value.trim();
          if (text.isNotEmpty) {
            Navigator.of(dialogContext).pop(text);
          }
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text('取消'),
        ),
        FilledButton(
          onPressed: () {
            final text = controller.text.trim();
            if (text.isNotEmpty) {
              Navigator.of(dialogContext).pop(text);
            }
          },
          child: const Text('确定'),
        ),
      ],
    ),
  );

  if (entered == null) {
    return null;
  }
  final path = entered.trim();
  return path.isEmpty ? null : path;
}