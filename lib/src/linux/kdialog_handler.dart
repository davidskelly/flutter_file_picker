import 'package:file_picker/file_picker.dart';
import 'package:file_picker/src/linux/dialog_handler.dart';
import 'package:path/path.dart' as p;

class KDialogHandler implements DialogHandler {
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
    final arguments = ['--title', dialogTitle];

    if (saveFile && !pickDirectory) {
      arguments.add('--getsavefilename');
    } else if (!saveFile && !pickDirectory) {
      arguments.add('--getopenfilename');
    } else {
      arguments.add('--getexistingdirectory');
    }

    // Start directory for the dialog
    if (fileName.isNotEmpty && initialDirectory.isNotEmpty) {
      arguments.add(p.join(initialDirectory, fileName));
    } else if (fileName.isNotEmpty) {
      arguments.add(p.absolute(fileName));
    } else if (initialDirectory.isNotEmpty) {
      arguments.add(initialDirectory);
    }

    if (!pickDirectory && fileFilter.isNotEmpty) {
      // In order to specify a filter, a start directory has to be specified
      if (fileName.isEmpty && initialDirectory.isEmpty) {
        arguments.add('.');
      }
      arguments.add(fileFilter);
    }

    if (multipleFiles) {
      arguments.addAll(['--multiple', '--separate-output']);
    }

    return arguments;
  }

  @override
  String fileTypeToFileFilter(
    FileType type,
    List<String>? allowedExtensions,
  ) {
    switch (type) {
      case FileType.any:
        return '';
      case FileType.audio:
        return 'Audio File (${DialogHandler.toCaseInsensitive(DialogHandler.toExtensions(DialogHandler.audioExts))})';
      case FileType.custom:
        return '${allowedExtensions!.map((ext) => ext.toUpperCase()).join(' File, ')} File (${DialogHandler.toCaseInsensitive("*.${allowedExtensions.join(' *.')}")})';
      case FileType.image:
        return 'Image File (' + DialogHandler.toCaseInsensitive(DialogHandler.toExtensions(DialogHandler.imageExts)) + ')';
      case FileType.media:
        return 'Media File (' + DialogHandler.toCaseInsensitive(DialogHandler.toExtensions(DialogHandler.videoExts) + ' ' + DialogHandler.toExtensions(DialogHandler.imageExts)) + ')';
      case FileType.video:
        return 'Video File (' + DialogHandler.toCaseInsensitive(DialogHandler.toExtensions(DialogHandler.videoExts)) + ')';
      default:
        throw Exception('unknown file type');
    }
  }

  @override
  List<String> resultStringToFilePaths(String fileSelectionResult) {
    if (fileSelectionResult.trim().isEmpty) {
      return [];
    }

    return fileSelectionResult
        .split('\n')
        .map((String path) => path.startsWith('/') ? path : '/$path')
        .toList();
  }
}
