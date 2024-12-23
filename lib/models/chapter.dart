class Chapter {
  final int chapterId;
  final String chapterName;
  final int subjectId;
  final DateTime timestamp;

  Chapter({
    required this.chapterId,
    required this.chapterName,
    required this.subjectId,
    required this.timestamp,
  });

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      chapterId: json['ChapterID'] ?? 0,
      chapterName: json['ChapterName'] ?? '',
      subjectId: json['SubjectID'] ?? 0,
      timestamp: json['TimeStamp'] != null 
          ? DateTime.parse(json['TimeStamp']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ChapterID': chapterId,
      'ChapterName': chapterName,
      'SubjectID': subjectId,
      'TimeStamp': timestamp.toIso8601String(),
    };
  }
}
