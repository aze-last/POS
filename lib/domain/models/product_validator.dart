/// Unified business validation rules for product data.
///
/// Shared between domain, data repository, and presentation form dialog.
class ProductValidator {
  /// Validates product variety name.
  static String? validateName(String? name) {
    if (name == null || name.trim().isEmpty) {
      return 'Product name cannot be empty';
    }
    return null;
  }

  /// Validates selling price per kg in centavos.
  static String? validatePriceCentavos(int? priceCentavos) {
    if (priceCentavos == null || priceCentavos <= 0) {
      return 'Price must be greater than P0.00';
    }
    return null;
  }

  /// Validates capital cost per kg in centavos.
  static String? validateCapitalCentavos(int? capitalCentavos) {
    if (capitalCentavos == null || capitalCentavos <= 0) {
      return 'Capital must be greater than P0.00';
    }
    return null;
  }
}
