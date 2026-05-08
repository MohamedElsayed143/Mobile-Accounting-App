import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/account.dart';
import '../../domain/entities/invoice.dart';
import '../../domain/entities/customer.dart';
import '../../domain/entities/supplier.dart';
import '../../domain/entities/product.dart';
import '../../data/repositories/sql_accounting_repository.dart';
import '../../data/repositories/firestore_accounting_repository.dart';
import '../../../../core/error/failures.dart';
import 'accounting_state.dart';

enum ActiveView { dashboard, invoices, customers, suppliers, products }

class AccountingCubit extends Cubit<AccountingState> {
  final SqlAccountingRepository localRepository;
  final FirestoreAccountingRepository remoteRepository;

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
    required this.localRepository,
    required this.remoteRepository,
  }) : super(AccountingInitial());

  // ─── One-Time Migration ────────────────────────────────────────
  Future<void> migrateLocalDataToFirestore() async {
    try {
      debugPrint('Starting one-time migration to Firestore...');
      final localAccs = await localRepository.getAccounts().first;
      final localInvs = await localRepository.getInvoices().first;
      final localCusts = await localRepository.getCustomers().first;
      final localSups = await localRepository.getSuppliers().first;
      final localProds = await localRepository.getProducts().first;

      for (var acc in localAccs) await remoteRepository.addAccount(acc);
      for (var inv in localInvs) await remoteRepository.addInvoice(inv);
      for (var cust in localCusts) await remoteRepository.addCustomer(cust);
      for (var sup in localSups) await remoteRepository.addSupplier(sup);
      for (var prod in localProds) await remoteRepository.addProduct(prod);

      debugPrint('Migration complete.');
    } catch (e) {
      debugPrint('Migration failed: $e');
    }
  }

  // ─── Real-Time Listeners ───────────────────────────────────────
  void _startListening() {
    if (_isListening) return;
    _isListening = true;

    _accountsSub = remoteRepository.getAccounts().listen((data) {
      _accounts = data;
      _emitCurrentState();
    });
    _invoicesSub = remoteRepository.getInvoices().listen((data) {
      _invoices = data;
      _emitCurrentState();
    });
    _customersSub = remoteRepository.getCustomers().listen((data) {
      _customers = data;
      _emitCurrentState();
    });
    _suppliersSub = remoteRepository.getSuppliers().listen((data) {
      _suppliers = data;
      _emitCurrentState();
    });
    _productsSub = remoteRepository.getProducts().listen((data) {
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

  // ─── View Loaders (Triggers active state) ─────────────────────
  Future<void> loadAccounts() async {
    _activeView = ActiveView.dashboard;
    emit(AccountingLoading());
    try {
      // Local cache for faster startup
      _accounts = await localRepository.getAccounts().first;
      _invoices = await localRepository.getInvoices().first;
      _customers = await localRepository.getCustomers().first;
      _suppliers = await localRepository.getSuppliers().first;
      _products = await localRepository.getProducts().first;
      _emitCurrentState();
    } catch (_) {}

    _startListening();
  }

  Future<void> loadInvoices({String? type}) async {
    _activeView = ActiveView.invoices;
    emit(AccountingLoading());
    try {
      _invoices = await localRepository.getInvoices(type: type).first;
      _emitCurrentState();
    } catch (_) {}
    _startListening();
  }

  Future<void> loadCustomers() async {
    _activeView = ActiveView.customers;
    emit(AccountingLoading());
    try {
      _customers = await localRepository.getCustomers().first;
      _emitCurrentState();
    } catch (_) {}
    _startListening();
  }

  Future<void> loadSuppliers() async {
    _activeView = ActiveView.suppliers;
    emit(AccountingLoading());
    try {
      _suppliers = await localRepository.getSuppliers().first;
      _emitCurrentState();
    } catch (_) {}
    _startListening();
  }

  Future<void> loadProducts() async {
    _activeView = ActiveView.products;
    emit(AccountingLoading());
    try {
      _products = await localRepository.getProducts().first;
      _emitCurrentState();
    } catch (_) {}
    _startListening();
  }

  // ─── CRUD Operations (Firestore is Single Source of Truth) ─────

  Future<void> addNewAccount(Account newAccount) async {
    try {
      await remoteRepository.addAccount(newAccount);
      await localRepository.addAccount(newAccount); // Hybrid cache
      emit(AccountAddedSuccess());
      _emitCurrentState(); // Return back to previous state
    } catch (e) {
      emit(AccountingError(ServerFailure('فشل إضافة الحساب: $e')));
    }
  }

  Future<void> addInvoice(Invoice invoice) async {
    try {
      await remoteRepository.addInvoice(invoice);
      await localRepository.addInvoice(invoice);
    } catch (e) {
      emit(AccountingError(ServerFailure('فشل إضافة الفاتورة: $e')));
    }
  }

  Future<void> saveCustomer(Customer customer) async {
    try {
      if (customer.id == null) {
        await remoteRepository.addCustomer(customer);
        await localRepository.addCustomer(customer);
      } else {
        await remoteRepository.updateCustomer(customer);
        await localRepository.updateCustomer(customer);
      }
    } catch (e) {
      emit(AccountingError(ServerFailure('فشل حفظ العميل: $e')));
    }
  }

  Future<void> deleteCustomer(int id) async {
    try {
      await remoteRepository.deleteCustomer(id);
      await localRepository.deleteCustomer(id);
    } catch (e) {
      emit(AccountingError(ServerFailure('فشل حذف العميل: $e')));
    }
  }

  Future<void> saveSupplier(Supplier supplier) async {
    try {
      if (supplier.id == null) {
        await remoteRepository.addSupplier(supplier);
        await localRepository.addSupplier(supplier);
      } else {
        await remoteRepository.updateSupplier(supplier);
        await localRepository.updateSupplier(supplier);
      }
    } catch (e) {
      emit(AccountingError(ServerFailure('فشل حفظ المورد: $e')));
    }
  }

  Future<void> deleteSupplier(int id) async {
    try {
      await remoteRepository.deleteSupplier(id);
      await localRepository.deleteSupplier(id);
    } catch (e) {
      emit(AccountingError(ServerFailure('فشل حذف المورد: $e')));
    }
  }

  Future<void> saveProduct(Product product) async {
    try {
      if (product.id == null) {
        await remoteRepository.addProduct(product);
        await localRepository.addProduct(product);
      } else {
        await remoteRepository.updateProduct(product);
        await localRepository.updateProduct(product);
      }
    } catch (e) {
      emit(AccountingError(ServerFailure('فشل حفظ المنتج: $e')));
    }
  }

  Future<void> deleteProduct(int id) async {
    try {
      await remoteRepository.deleteProduct(id);
      await localRepository.deleteProduct(id);
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