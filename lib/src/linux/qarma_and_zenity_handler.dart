import 'package:file_picker/file_picker.dart';
import 'package:file_picker/src/linux/dialog_handler.dart';
import 'package:path/path.dart' as p;

import '../utils.dart';

class QarmaAndZenityHandler implements DialogHandler {
  @override
  List<String> generateCommandLineArguments(
    String dialogTitle, {
    String fileFilter = '',
    String fileName = '',
    String initialDirectory = '',
    bool multipleFiles = false,
    bool pickDirectory = false,
    bool saveFile = false,
  }) {
    final arguments = ['--file-selection', '--title', dialogTitle];

    if (saveFile) {
      arguments.addAll(['--save', '--confirm-overwrite']);
    }

    if (fileName.isNotEmpty && initialDirectory.isNotEmpty) {
      arguments.add('--filename=${p.join(initialDirectory, fileName)}');
    } else if (fileName.isNotEmpty) {
      arguments.add('--filename=$fileName');
    } else if (initialDirectory.isNotEmpty) {
      arguments.add('--filename=$initialDirectory');
    }

    if (fileFilter.isNotEmpty) {
      arguments.add('--file-filter=$fileFilter');
    }

    if (multipleFiles) {
      arguments.add('--multiple');
    }

    if (pickDirectory) {
      arguments.add('--directory');
    }

    return arguments;
  }

  @override
  String fileTypeToFileFilter(FileType type, List<String>? allowedExtensions) {
    switch (type) {
      case FileType.any:
        return '';
      case FileType.audio:
        return toExtensions("Audio Files", audioExts);
      case FileType.custom:
        return toExtensions("Custom Files", allowedExtensions!);
      case FileType.image:
        return toExtensions("Image Files", imageExts);
      case FileType.media:
        List<String> media = List.from(videoExts);
        media.addAll(imageExts);
        return toExtensions("Media Files", media);
      case FileType.video:
        return toExtensions("Video Files", videoExts);
      default:
        throw Exception('unknown file type');
    }
  }

  String toExtensions(String title, List<String> exts) {
    return "$title | ${DialogHandler.toCaseInsensitive(DialogHandler.toExtensions(exts))}";
  }

  @override
  List<String> resultStringToFilePaths(String fileSelectionResult) {
    if (fileSelectionResult.trim().isEmpty) {
      return [];
    }
    return fileSelectionResult
        .split('|/')
        .map((String path) => path.startsWith('/') ? path : '/$path')
        .toList();
  }
}
