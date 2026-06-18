# Models And Serialization Rules

This file defines how entities and transport-facing model classes must be
written in the project.


## Parsing And Serialization
- Use pattern matching for structural validation:
  `if (json case <String, Object?>{'id': int id, ...})`.
- Do not use `dynamic` in parsing logic.
- Do not hide structural problems behind silent `try/catch` blocks.
- If payload shape is invalid, throw `FormatException('<Owner> | <expectation>', json)`.
- Parsing diagnostics must identify the owner and the expected shape.
- Prefer transport-compatible typedefs for IDs, for example `typedef ProductID = int;`.
- Placeholder IDs use `-1` and serialize back as `null` when the placeholder must not leave the client.
- Nullable fields are allowed only when the value can be legitimately absent in valid payloads.
- Accept numeric transport values as `int`, `double`, or `String`, then normalize explicitly.
- Accept dates as ISO8601 strings or `DateTime`, convert to local time on parse, and serialize to UTC ISO8601.
- For nested objects, parse with explicit `switch` or pattern matching.
- For lists, use `whereType<Map<String, Object?>>()`, map to submodels, and finish with `toList(growable: false)`.
- For enums, parse through explicit `fromValue` helpers.
- For money values, use `Money2` consistently.
- In repository-level payload validation, throw `FormatException('<Repository>.<method> | Expected <shape>', response)`.


## Enum Conventions
Enums that participate in model parsing, transport mapping, or persisted values
must follow one explicit contract.

- **Signature:** `enum ExampleType implements Comparable<ExampleType> { ... }`
- **Stored value:** Each case stores a canonical backend or transport value.
- **Parsing:** Implement explicit `fromValue` with `switch`, optional `fallback`, and a descriptive `ArgumentError.value(...)`.
- **Diagnostics:** When parsing fails without fallback, error text must include the parser name and the supported values.
- **Helpers:** Implement `map`, `maybeMap`, and `maybeMapOrNull`.
- **Ordering:** Use declaration order and `index`. Do not add a second ordering field.
- **String conversion:** `toString()` returns the stored value, not `name`.
- **Reflection:** Never use `values.byName` or `name` for parsing.
- **Change discipline:** If you add or remove enum cases, update all helper methods and related tests in the same change.

### Enum Template
```dart
enum ExampleType implements Comparable<ExampleType> {
  foo('foo'),
  bar('bar');

  const ExampleType(this.value);

  static ExampleType fromValue(String? value, {ExampleType? fallback}) =>
      switch (value?.trim().toLowerCase()) {
        'foo' => foo,
        'bar' => bar,
        _ =>
          fallback ??
              (throw ArgumentError.value(
                value,
                'ExampleType.fromValue',
                'Supported values are: ${ExampleType.values.map((e) => e.value).join(', ')}',
              )),
      };

  final String value;

  T map<T>({required T Function() foo, required T Function() bar}) => switch (this) {
    ExampleType.foo => foo(),
    ExampleType.bar => bar(),
  };

  T maybeMap<T>({required T Function() orElse, T Function()? foo, T Function()? bar}) =>
      map<T>(foo: foo ?? orElse, bar: bar ?? orElse);

  T? maybeMapOrNull<T>({T Function()? foo, T Function()? bar}) =>
      maybeMap<T?>(orElse: () => null, foo: foo, bar: bar);

  @override
  int compareTo(ExampleType other) => index.compareTo(other.index);

  @override
  String toString() => value;
}
```


## Model Ordering Contract
Every entity must use one semantic order and keep that exact order everywhere.

The order is not alphabetical.

The order is semantic.

The same sequence must be preserved in:
- constructor parameters
- `fromJson`
- field declarations
- `toJson`
- `copyWith`
- `hashCode`
- `operator ==`
- `toString`

If a field is moved in one place, it must be moved in all of them in the same patch.


## Recommended Semantic Groups
Use the following grouping order unless the model has a stronger domain-specific order.

1. **Identity**
   Stable identifiers of the entity itself.
2. **Ownership / linkage**
   Parent profile IDs, foreign keys, stock IDs, relation IDs.
3. **Presentation**
   User-facing labels such as `name`, `alias`, `title`, `brand`.
4. **Classification**
   Category, type, measure, state, enum-backed grouping.
5. **Value payload**
   Price, money tuples, durations, date ranges, technical payload.
6. **Media / attachments**
   Photos, files, thumbnails, remote asset references.
7. **Collections / linked aggregates**
   Embedded children such as `stocks`, `items`, `payments`.
8. **Inventory / counters**
   Quantity, availability, counts, remaining usage.
9. **Behavior flags**
   Booleans like `showInBox`, `quantityUnlimited`, `active`, `isOnline`.

Not every model uses every group. Skip missing groups, but preserve the order of the groups that exist.


## Constructor Rules
- Prefer `const` constructors where possible.
- Nullable fields are still passed explicitly when they are part of the model contract.
- Do not hide important nullable fields behind optional constructor parameters if callers should always make the choice explicit.


## Equality And Hashing Rules
- `hashCode` and `operator ==` must cover the same semantic data.
- Do not hash fewer fields than equality compares.
- Do not compare fewer fields than `hashCode` hashes.
- For records like `ProductPrice`, hash individual members explicitly when that improves clarity.
- For nullable collections, use `Object.hashAll(collection ?? const <T>[])`.
- For non-null list equality with `listEquals(a, b)`, hash the same content with `Object.hashAll(list)` instead of hashing the list object itself.
- For map equality with `mapEquals(a, b)`, hash entries without depending on iteration order, for example with `Object.hashAllUnordered(map.entries.map((e) => Object.hash(e.key, e.value)))`.
- Use `DeepCollectionEquality` only when the semantic value really is a nested collection. Do not use it as a blanket replacement for simple scalar or flat model fields.
- Identity checks and deep equality are different semantics. If `==` uses `identical` for a field, `hashCode` must hash the same object reference, not a deep expansion of its contents.
- When a model has subtype-specific equality, always compare against the same subtype. Do not accidentally compare `Image` to `File` or other sibling variants.
- A quick contract check: if `a == b`, then `a.hashCode == b.hashCode` must also hold for any combination of null, reordered map entries, and structurally-equal collection copies.


## Copy Rules
- `copyWith` keeps the exact model order used by the constructor.
- Replace only supplied parameters.
- Never mutate collections in place.


## Product Feature Ordering
The `product` feature uses these concrete groupings.

### Product
Order:
1. `id`
2. `profileID`
3. `stockID`
4. `name`
5. `alias`
6. `brand`
7. `supplier`
8. `category`
9. `measure`
10. `price`
11. `photos`
12. `stocks`
13. `quantity`
14. `quantityUnlimited`
15. `showInBox`

Why this order:
- identity and linkage come first
- human-readable labels come next
- classification and value payload stay together
- media and embedded aggregates follow
- stock counters and boolean behavior flags finish the entity

### ProductCategory
Order:
1. `categoryID`
2. `name`
3. `productsCount`

Why this order:
- identity first
- display label second
- derived counter last

### ProductStock
Order:
1. `id`
2. `alias`
3. `name`
4. `quantity`
5. `sort`

Why this order:
- identity first
- classification alias before display name
- inventory counter before ordering metadata


## Full Product Example
```dart
@immutable
final class Product {
  const Product({
    required this.id,
    required this.profileID,
    required this.stockID,
    required this.name,
    required this.alias,
    required this.brand,
    required this.supplier,
    required this.category,
    required this.measure,
    required this.price,
    required this.photos,
    required this.stocks,
    required this.quantity,
    required this.quantityUnlimited,
    required this.showInBox,
  });

  factory Product.fromJson(JSON json, {String? currency}) {
    if (json.isEmpty) throw const FormatException('Product.fromJson | JSON is empty');
    if (json case <String, Object?>{
      'id': ProductID id,
      'profileID': int profileID,
      'name': String name,
      'alias': String alias,
      'measure': Map<String, Object?> measure,
      'price': Map<String, Object?> priceJson,
    }) {
      final resolvedCurrency = Config.currencies.firstWhereOrNull((c) => c.isoCode == currency) ?? Config.currency;
      return Product(
        id: id,
        profileID: profileID,
        stockID: CoreUtil.tryParseToInt(json['stockID'] ?? json['stock_id']),
        name: name,
        alias: alias,
        brand: CoreUtil.tryParseToStringOrNull(json['brand']),
        supplier: CoreUtil.tryParseToStringOrNull(json['supplier']),
        category: switch (json['category']) {
          Map<String, Object?> categoryJson => ProductCategory.fromJson(categoryJson),
          _ => null,
        },
        measure: Measure.fromJson(measure),
        price: (
          supply: Money.fromNumWithCurrency(CoreUtil.tryParseToDouble(priceJson['supply']), resolvedCurrency),
          retail: Money.fromNumWithCurrency(CoreUtil.tryParseToDouble(priceJson['retail']), resolvedCurrency),
          special: switch (priceJson['special']) {
            num value => Money.fromNumWithCurrency(value, resolvedCurrency),
            _ => null,
          },
        ),
        photos: switch (json['photos']) {
          List<Object?> photosJson =>
            photosJson.whereType<JSON>().map(Photo.fromJson).whereType<Photo>().toList(growable: false),
          _ => null,
        },
        stocks: switch (json['stocks']) {
          List<Object?> stocksJson =>
            stocksJson.whereType<JSON>().map(ProductStock.fromJson).toList(growable: false),
          _ => const <ProductStock>[],
        },
        quantity: CoreUtil.tryParseToInt(json['quantity']),
        quantityUnlimited: CoreUtil.tryParseToBool(json['quantityUnlimited'] ?? json['quantity_unlimited']),
        showInBox: CoreUtil.tryParseToBool(json['showInBox'] ?? json['show_in_box']),
      );
    }

    throw FormatException('Product.fromJson | Expected {id, profileID, name, alias, measure, price}', json);
  }

  final ProductID id;
  final int profileID;
  final ProductStockID stockID;
  final String name;
  final String alias;
  final String? brand;
  final String? supplier;
  final ProductCategory? category;
  final Measure measure;
  final ProductPrice price;
  final List<Photo>? photos;
  final List<ProductStock> stocks;
  final int quantity;
  final bool quantityUnlimited;
  final bool showInBox;
}
```


## Anti-Pattern
Do not do this:
- constructor grouped semantically
- fields sorted alphabetically
- `toJson` sorted by backend accident
- `copyWith` sorted by editor autocomplete

That creates a model that looks stable but is cognitively expensive to maintain.


## Review Checklist
Before merging a model change, verify:
- the semantic order is the same everywhere
- parsing errors are specific
- `hashCode` and equality match
- `copyWith` keeps the same order
- collections remain immutable
- `toString` follows the same order as the rest of the model