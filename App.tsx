
import React, { useState, useEffect, useCallback } from 'react';
import { HashRouter, Routes, Route, NavLink } from 'react-router-dom';
import Dashboard from './pages/Dashboard';
import InventoryManagement from './pages/InventoryManagement';
import SalesEntry from './pages/SalesEntry';
import ExpenseEntry from './pages/ExpenseEntry';
import Reporting from './pages/Reporting';
import { ShopProvider } from './contexts/ShopContext';
import Toast from './components/Toast';
import { useToast } from './hooks/useToast';

function App() {
  const { toastMessage } = useToast();

  return (
    <HashRouter>
      <ShopProvider>
        <div className="min-h-screen flex flex-col bg-gray-100 text-gray-800">
          <header className="bg-gradient-to-r from-yellow-700 to-amber-600 text-white shadow-md p-4 sticky top-0 z-10">
            <h1 className="text-xl md:text-2xl font-bold text-center">Coffee Shop Manager</h1>
          </header>

          <main className="flex-grow p-4 pb-20 md:p-6 max-w-4xl mx-auto w-full">
            <Routes>
              <Route path="/" element={<Dashboard />} />
              <Route path="/inventory" element={<InventoryManagement />} />
              <Route path="/sales" element={<SalesEntry />} />
              <Route path="/expenses" element={<ExpenseEntry />} />
              <Route path="/reporting" element={<Reporting />} />
            </Routes>
          </main>

          <nav className="fixed bottom-0 left-0 right-0 bg-white shadow-lg border-t border-gray-200 z-10">
            <ul className="flex justify-around items-center h-16 text-sm">
              <li>
                <NavLink
                  to="/"
                  className={({ isActive }) =>
                    `flex flex-col items-center p-2 text-gray-600 hover:text-yellow-700 transition-colors ${
                      isActive ? 'text-yellow-700 font-semibold' : ''
                    }`
                  }
                >
                  <span className="text-xl">📊</span>
                  <span className="text-xs">Dashboard</span>
                </NavLink>
              </li>
              <li>
                <NavLink
                  to="/inventory"
                  className={({ isActive }) =>
                    `flex flex-col items-center p-2 text-gray-600 hover:text-yellow-700 transition-colors ${
                      isActive ? 'text-yellow-700 font-semibold' : ''
                    }`
                  }
                >
                  <span className="text-xl">📦</span>
                  <span className="text-xs">Inventory</span>
                </NavLink>
              </li>
              <li>
                <NavLink
                  to="/sales"
                  className={({ isActive }) =>
                    `flex flex-col items-center p-2 text-gray-600 hover:text-yellow-700 transition-colors ${
                      isActive ? 'text-yellow-700 font-semibold' : ''
                    }`
                  }
                >
                  <span className="text-xl">💰</span>
                  <span className="text-xs">Sales</span>
                </NavLink>
              </li>
              <li>
                <NavLink
                  to="/expenses"
                  className={({ isActive }) =>
                    `flex flex-col items-center p-2 text-gray-600 hover:text-yellow-700 transition-colors ${
                      isActive ? 'text-yellow-700 font-semibold' : ''
                    }`
                  }
                >
                  <span className="text-xl">💸</span>
                  <span className="text-xs">Expenses</span>
                </NavLink>
              </li>
              <li>
                <NavLink
                  to="/reporting"
                  className={({ isActive }) =>
                    `flex flex-col items-center p-2 text-gray-600 hover:text-yellow-700 transition-colors ${
                      isActive ? 'text-yellow-700 font-semibold' : ''
                    }`
                  }
                >
                  <span className="text-xl">📈</span>
                  <span className="text-xs">Reports</span>
                </NavLink>
              </li>
            </ul>
          </nav>
          {toastMessage && (
            <Toast message={toastMessage.message} type={toastMessage.type} />
          )}
        </div>
      </ShopProvider>
    </HashRouter>
  );
}

export default App;