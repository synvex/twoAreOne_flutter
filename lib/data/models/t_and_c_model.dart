
class PageContentModel {
  final String pagesContent;

  const PageContentModel({required this.pagesContent});

  factory PageContentModel.fromJson(Map<String, dynamic> json) {
    return PageContentModel(
      pagesContent: (json['pages_content'] ?? '') as String,
    );
  }
}