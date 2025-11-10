// Extend the Window interface to include aistudio
declare global {
  interface AIStudio {
    hasSelectedApiKey: () => Promise<boolean>;
    openSelectKey: () => Promise<void>;
  }

  interface Window {
    aistudio?: AIStudio;
    AudioContext: typeof AudioContext;
    webkitAudioContext: typeof AudioContext;
  }
}

export enum ProductCategory {
  COFFEE_RAW = 'coffee_raw',
  COFFEE_ROASTED = 'coffee_roasted',
  DRINK = 'drink',
  PACKED_PRODUCT = 'packed_product',
}

export enum ProductUnit {
  KG = 'kg',
  G = 'g',
  UNIT = 'unit',
}

export interface Product {
  id: string;
  name: string;
  category: ProductCategory;
  unit: ProductUnit;
  costPerUnit: number; // Cost to acquire/produce
  pricePerUnit: number; // Selling price
}

export interface InventoryItem {
  productId: string;
  currentStock: number; // In base units (grams for coffee, units for drinks/packed)
}

export interface SaleDetail {
  productId: string;
  quantity: number; // In base units
  salePrice: number; // Price per unit at time of sale
  total: number; // quantity * salePrice
}

export interface Transaction {
  id: string;
  type: 'income' | 'expense';
  date: string; // YYYY-MM-DD
  description: string;
  amount: number; // Total amount
  details?: SaleDetail[]; // For income transactions
  category?: string; // For expense transactions (e.g., 'rent', 'supplies', 'payroll')
}

export interface ShopData {
  products: Product[];
  inventory: InventoryItem[];
  transactions: Transaction[];
}

export interface ToastMessage {
  message: string;
  type: 'success' | 'error' | 'info';
}