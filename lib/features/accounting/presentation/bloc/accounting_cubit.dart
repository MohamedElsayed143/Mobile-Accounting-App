import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/account.dart';
import '../../domain/entities/invoice.dart';
import '../../domain/entities/customer.dart';
import '../../domain/entities/supplier.dart';
import '../../domain/entities/product.dart';
import '../../data/repositories/sql_accounting_repository.dart';
import 'accounting_state.dart';

class AccountingCubit extends Cubit<AccountingState> {
  final SqlAccountingRepository repository;

  AccountingCubit(this.repository) : super(AccountingInitial());

  // ─── Accounts ────────────────────────────────────────────────
  Future<void> loadAccounts() async {
    emit(AccountingLoading());
    try {
      final accounts = await repository.getAccounts();
      final invoices = await repository.getInvoices();
      final customers = await repository.getCustomers();
      final suppliers = await repository.getSuppliers();
      final products = await repository.getProducts();

      double totalSales = 0;
      double totalPurchases = 0;

      for (var inv in invoices) {
        if (inv.type == InvoiceType.sale) {
          totalSales += inv.totalAmount;
        } else {
          totalPurchases += inv.totalAmount;
        }
      }

      emit(AccountingLoaded(
        accounts,
        totalSales: totalSales,
        totalPurchases: totalPurchases,
        customerCount: customers.length,
        supplierCount: suppliers.length,
        productCount: products.length,
      ));
    } catch (e) {
      emit(AccountingError('فشل تحميل الحسابات: $e'));
    }
  }

  Future<void> addNewAccount(Account newAccount) async {
    try {
      await repository.addAccount(newAccount);
      emit(AccountAddedSuccess());
      await loadAccounts();
    } catch (e) {
      emit(AccountingError('فشل إضافة الحساب: $e'));
    }
  }

  // ─── Invoices ────────────────────────────────────────────────
  Future<void> addInvoice(Invoice invoice) async {
    try {
      await repository.addInvoice(invoice);
      debugPrint('✅ تم حفظ الفاتورة بنجاح');
    } catch (e) {
      debugPrint('❌ Error adding invoice: $e');
      emit(AccountingError('فشل إضافة الفاتورة: $e'));
    }
  }

  Future<void> loadInvoices({String? type}) async {
    emit(AccountingLoading());
    try {
      final invoices = await repository.getInvoices(type: type);
      emit(InvoicesLoaded(invoices));
    } catch (e) {
      emit(AccountingError('فشل تحميل الفواتير: $e'));
    }
  }

  // ─── Customers ────────────────────────────────────────────────
  Future<void> loadCustomers() async {
    emit(AccountingLoading());
    try {
      final customers = await repository.getCustomers();
      emit(CustomersLoaded(customers));
    } catch (e) {
      emit(AccountingError('فشل تحميل العملاء: $e'));
    }
  }

  Future<void> saveCustomer(Customer customer) async {
    try {
      if (customer.id == null) {
        await repository.addCustomer(customer);
      } else {
        await repository.updateCustomer(customer);
      }
      await loadCustomers();
    } catch (e) {
      emit(AccountingError('فشل حفظ العميل: $e'));
    }
  }

  Future<void> deleteCustomer(int id) async {
    try {
      await repository.deleteCustomer(id);
      await loadCustomers();
    } catch (e) {
      emit(AccountingError('فشل حذف العميل: $e'));
    }
  }

  // ─── Suppliers ────────────────────────────────────────────────
  Future<void> loadSuppliers() async {
    emit(AccountingLoading());
    try {
      final suppliers = await repository.getSuppliers();
      emit(SuppliersLoaded(suppliers));
    } catch (e) {
      emit(AccountingError('فشل تحميل الموردين: $e'));
    }
  }

  Future<void> saveSupplier(Supplier supplier) async {
    try {
      if (supplier.id == null) {
        await repository.addSupplier(supplier);
      } else {
        await repository.updateSupplier(supplier);
      }
      await loadSuppliers();
    } catch (e) {
      emit(AccountingError('فشل حفظ المورد: $e'));
    }
  }

  Future<void> deleteSupplier(int id) async {
    try {
      await repository.deleteSupplier(id);
      await loadSuppliers();
    } catch (e) {
      emit(AccountingError('فشل حذف المورد: $e'));
    }
  }

  // ─── Products ────────────────────────────────────────────────
  Future<void> loadProducts() async {
    emit(AccountingLoading());
    try {
      final products = await repository.getProducts();
      emit(ProductsLoaded(products));
    } catch (e) {
      emit(AccountingError('فشل تحميل المنتجات: $e'));
    }
  }

  Future<void> saveProduct(Product product) async {
    try {
      if (product.id == null) {
        await repository.addProduct(product);
      } else {
        await repository.updateProduct(product);
      }
      await loadProducts();
    } catch (e) {
      emit(AccountingError('فشل حفظ المنتج: $e'));
    }
  }

  Future<void> deleteProduct(int id) async {
    try {
      await repository.deleteProduct(id);
      await loadProducts();
    } catch (e) {
      emit(AccountingError('فشل حذف المنتج: $e'));
    }
  }
}