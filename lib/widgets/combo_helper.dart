import 'package:kisekae/models/tryon_combo_model.dart';

class ComboItemView {
  final int productId;
  final String name;
  final String? imageUrl;

  const ComboItemView({
    required this.productId,
    required this.name,
    this.imageUrl,
  });
}

extension TryOnComboView on TryOnCombo {
  List<ComboItemView> get itemViews => items
      .map(
        (i) => ComboItemView(
          productId: i.productId,
          name: i.productName,
          imageUrl: i.thumbnail,
        ),
      )
      .toList();

  int get itemCount => itemsCount > items.length ? itemsCount : items.length;

  bool containsProduct(int productId) =>
      items.any((i) => i.productId == productId);
}
