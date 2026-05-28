import 'package:freezed_annotation/freezed_annotation.dart';

part 'product_section.freezed.dart';
part 'product_section.g.dart';

@freezed
class ProductSection with _$ProductSection {
  const factory ProductSection({
    required String name,
    int? price,
    String? link,
  }) = _ProductSection;

  factory ProductSection.fromJson(Map<String, dynamic> json) =>
      _$ProductSectionFromJson(json);
}
