class Products {
  String product;
  double price;
  String image;
  String category;
  String description;
  List<ProductOptions> productOptions;
  bool available;
  String productID;
  String code;
  List searchName;
  bool vegan;
  bool showOnMenu;
  bool featured;

  Products(
      this.product,
      this.price,
      this.image,
      this.description,
      this.category,
      this.productOptions,
      this.available,
      this.productID,
      this.code,
      this.searchName,
      this.vegan,
      this.showOnMenu,
      this.featured);
}

class ProductOptions {
  String title;
  bool mandatory;
  bool multipleOptions;
  String priceStructure;
  List priceOptions;

  ProductOptions(this.title, this.mandatory, this.multipleOptions,
      this.priceStructure, this.priceOptions);
}

class PriceOptions {
  String option;
  double price;

  PriceOptions(this.option, this.price);
}
