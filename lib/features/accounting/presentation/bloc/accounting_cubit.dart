import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/account.dart';
import '../../domain/entities/invoice.dart';
import '../../domain/entities/customer.dart';
import '../../domain/entities/supplier.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/accounting_repository.dart';
import '../../../../core/error/failures.dart';
import 'accounting_state.dart';

enum ActiveView { dashboard, invoices, customers, suppliers, products }

class AccountingCubit extends Cubit<AccountingState> {
  final IAccountingRepository repository;

  StreamSubscription? _accountsSub;
  StreamSubscription? _invoicesSub;
  StreamSubscription? _customersSub;
  StreamSubscription? _suppliersSub;
  StreamSubscription? _productsSub;

  List<Account> _accounts = [];
  List<Invoice> _invoices = [];
  List<Customer> _customers = [];
  List<Supplier> _suppliers = [];
  List<Product> _products = [];

  ActiveView _activeView = ActiveView.dashboard;
  bool _isListening = false;

  AccountingCubit({
    required this.repository,
  }) : super(AccountingInitial());

  // ─── Real-Time Listeners ───────────────────────────────────────
  void _startListening() {
    if (_isListening) return;
    _isListening = true;

    _accountsSub = repository.getAccounts().listen((data) {
      _accounts = data;
      _emitCurrentState();
    });
    _invoicesSub = repository.getInvoices().listen((data) {
      _invoices = data;
      _emitCurrentState();
    });
    _customersSub = repository.getCustomers().listen((data) {
      _customers = data;
      _emitCurrentState();
    });
    _suppliersSub = repository.getSuppliers().listen((data) {
      _suppliers = data;
      _emitCurrentState();
    });
    _productsSub = repository.getProducts().listen((data) {
      _products = data;
      _emitCurrentState();
    });
  }

  void _emitCurrentState() {
    switch (_activeView) {
      case ActiveView.dashboard:
        double totalSales = 0;
        double totalPurchases = 0;
        for (var inv in _invoices) {
          if (inv.type == InvoiceType.sale) totalSales += inv.totalAmount;
          else totalPurchases += inv.totalAmount;
        }
        emit(AccountingLoaded(
          _accounts,
          totalSales: totalSales,
          totalPurchases: totalPurchases,
          customerCount: _customers.length,
          supplierCount: _suppliers.length,
          productCount: _products.length,
        ));
        break;
      case ActiveView.invoices:
        emit(InvoicesLoaded(_invoices));
        break;
      case ActiveView.customers:
        emit(CustomersLoaded(_customers));
        break;
      case ActiveView.suppliers:
        emit(SuppliersLoaded(_suppliers));
        break;
      case ActiveView.products:
        emit(ProductsLoaded(_products));
        break;
    }
  }

  Future<void> loadAccounts() async {
    _activeView = ActiveView.dashboard;
    emit(AccountingLoading());
    _startListening();
  }

  Future<void> loadInvoices({String? type}) async {
    _activeView = ActiveView.invoices;
    emit(AccountingLoading());
    _startListening();
  }

  Future<void> loadCustomers() async {
    _activeView = ActiveView.customers;
    emit(AccountingLoading());
    _startListening();
  }

  Future<void> loadSuppliers() async {
    _activeView = ActiveView.suppliers;
    emit(AccountingLoading());
    _startListening();
  }

  Future<void> loadProducts() async {
    _activeView = ActiveView.products;
    emit(AccountingLoading());
    _startListening();
  }

  // ─── CRUD Operations ──────────────────────────────────────────

  Future<void> addNewAccount(Account newAccount) async {
    try {
      await repository.addAccount(newAccount);
      emit(AccountAddedSuccess());
    } catch (e) {
      emit(AccountingError(ServerFailure('فشل إضافة الحساب: $e')));
    }
  }

  Future<void> addInvoice(Invoice invoice) async {
    try {
      await repository.addInvoice(invoice);
    } catch (e) {
      emit(AccountingError(ServerFailure('فشل إضافة الفاتورة: $e')));
    }
  }

  Future<void> saveCustomer(Customer customer) async {
    try {
      if (customer.id == null) {
        await repository.addCustomer(customer);
      } else {
        await repository.updateCustomer(customer);
      }
    } catch (e) {
      emit(AccountingError(ServerFailure('فشل حفظ العميل: $e')));
    }
  }

  Future<void> deleteCustomer(String id) async {
    try {
      await repository.deleteCustomer(id);
    } catch (e) {
      emit(AccountingError(ServerFailure('فشل حذف العميل: $e')));
    }
  }

  Future<void> saveSupplier(Supplier supplier) async {
    try {
      if (supplier.id == null) {
        await repository.addSupplier(supplier);
      } else {
        await repository.updateSupplier(supplier);
      }
    } catch (e) {
      emit(AccountingError(ServerFailure('فشل حفظ المورد: $e')));
    }
  }

  Future<void> deleteSupplier(String id) async {
    try {
      await repository.deleteSupplier(id);
    } catch (e) {
      emit(AccountingError(ServerFailure('فشل حذف المورد: $e')));
    }
  }

  Future<void> saveProduct(Product product) async {
    try {
      if (product.id == null) {
        await repository.addProduct(product);
      } else {
        await repository.updateProduct(product);
      }
    } catch (e) {
      emit(AccountingError(ServerFailure('فشل حفظ المنتج: $e')));
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      await repository.deleteProduct(id);
    } catch (e) {
      emit(AccountingError(ServerFailure('فشل حذف المنتج: $e')));
    }
  }

  @override
  Future<void> close() {
    _accountsSub?.cancel();
    _invoicesSub?.cancel();
    _customersSub?.cancel();
    _suppliersSub?.cancel();
    _productsSub?.cancel();
    return super.close();
  }
}