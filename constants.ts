import { ProductCategory, ProductUnit, Product, InventoryItem } from './types';

export const GEMINI_PRO_MODEL = 'gemini-2.5-pro';
export const GEMINI_FLASH_TTS_MODEL = 'gemini-2.5-flash-preview-tts';
export const IN_MEMORY_DB_KEY = 'coffeeShopData';

export const INITIAL_PRODUCTS: Product[] = [
  { id: 'coffee_raw_brazil', name: 'Raw Brazil Beans', category: ProductCategory.COFFEE_RAW, unit: ProductUnit.KG, costPerUnit: 15, pricePerUnit: 0 },
  { id: 'coffee_raw_colombia', name: 'Raw Colombia Beans', category: ProductCategory.COFFEE_RAW, unit: ProductUnit.KG, costPerUnit: 18, pricePerUnit: 0 },
  { id: 'coffee_roasted_brazil_250g', name: 'Roasted Brazil Beans (250g)', category: ProductCategory.COFFEE_ROASTED, unit: ProductUnit.G, costPerUnit: 0, pricePerUnit: 12 },
  { id: 'coffee_roasted_colombia_250g', name: 'Roasted Colombia Beans (250g)', category: ProductCategory.COFFEE_ROASTED, unit: ProductUnit.G, costPerUnit: 0, pricePerUnit: 14 },
  { id: 'drink_latte', name: 'Latte', category: ProductCategory.DRINK, unit: ProductUnit.UNIT, costPerUnit: 1.5, pricePerUnit: 5 },
  { id: 'drink_americano', name: 'Americano', category: ProductCategory.DRINK, unit: ProductUnit.UNIT, costPerUnit: 1.0, pricePerUnit: 4 },
  { id: 'packed_tea_green', name: 'Green Tea Pack', category: ProductCategory.PACKED_PRODUCT, unit: ProductUnit.UNIT, costPerUnit: 3, pricePerUnit: 7 },
  { id: 'packed_chocolate_bar', name: 'Chocolate Bar', category: ProductCategory.PACKED_PRODUCT, unit: ProductUnit.UNIT, costPerUnit: 2, pricePerUnit: 6 },
];

export const INITIAL_INVENTORY: InventoryItem[] = [
  { productId: 'coffee_raw_brazil', currentStock: 10000 }, // 10 kg in grams
  { productId: 'coffee_raw_colombia', currentStock: 5000 }, // 5 kg in grams
  { productId: 'coffee_roasted_brazil_250g', currentStock: 0 }, // 0 g
  { productId: 'coffee_roasted_colombia_250g', currentStock: 0 }, // 0 g
  { productId: 'drink_latte', currentStock: 50 },
  { productId: 'drink_americano', currentStock: 50 },
  { productId: 'packed_tea_green', currentStock: 20 },
  { productId: 'packed_chocolate_bar', currentStock: 30 },
];

export const EXPENSE_CATEGORIES = [
  'Rent', 'Utilities', 'Payroll', 'Supplies', 'Maintenance', 'Marketing', 'Raw Materials', 'Other'
];

export const ROASTING_YIELD_RATE = 0.8; // 80% yield from raw to roasted weight
export const ROASTED_COFFEE_SALES_WEIGHT_INCREMENT = 250; // default sales unit in grams