final class ObjectEntity {
  final String objectKey;
  final String bucket;
  final int size;
  final IconSourceType type;
  final int nesting;
  final int idObject;
  final String? lastModified;
  final String? remotePath;
  final String? localPath;

  const ObjectEntity({
    required this.objectKey,
    required this.bucket,
    required this.size,
    required this.type,
    this.nesting = 0,
    this.idObject = 0,
    this.lastModified,
    this.remotePath,
    this.localPath,
  });
}

enum IconSourceType {
  bucket,
  image,
  doc,
  folder,
  archive,
  program,
  music,
  video,
  other;

  bool get isFolder => this == folder;
}
