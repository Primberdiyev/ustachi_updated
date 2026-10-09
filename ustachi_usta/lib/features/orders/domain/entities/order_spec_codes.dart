library;

const String specSize = 'size';
const String specShape = 'shape';
const String specBrand = 'brand';
const String specColor = 'color';
const String specMaterial = 'material';
const String specGlass = 'glass';
const String specSill = 'sill';
const String specFlower = 'flower';
const String specAddress = 'address';
const String specProduct = 'product';
const String specSpecialty = 'specialty';
const String specPhone = 'phone';
const String specDiscount = 'discount';
const String specNote = 'note';

const String specArea = 'area';
const String specUnitPrice = 'unitPrice';

const String specVariant = 'variant';

const String specValuePrefix = '#';

const String specValuePlastic = '${specValuePrefix}plastic';
const String specValueAluminium = '${specValuePrefix}aluminium';
const String specValueTermo = '${specValuePrefix}termo';
const String specValueDoubleGlass = '${specValuePrefix}doubleGlass';
const String specValueSingleGlass = '${specValuePrefix}singleGlass';
const String specValueLarge = '${specValuePrefix}large';
const String specValueMedium = '${specValuePrefix}medium';
const String specValueSmall = '${specValuePrefix}small';

String specItemsValue(int kinds, int count) =>
    '${specValuePrefix}items:$kinds:$count';
