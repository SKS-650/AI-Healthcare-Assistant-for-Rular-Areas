String fileExtension(String filename) {
  final index = filename.lastIndexOf('.');
  if (index == -1 || index == filename.length - 1) return '';
  return filename.substring(index + 1).toLowerCase();
}
