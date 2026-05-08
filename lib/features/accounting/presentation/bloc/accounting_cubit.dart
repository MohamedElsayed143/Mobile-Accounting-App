import 'dart:async';
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

  AccountingCubit({required this.repository}) : super(AccountingInitial());

  // ─── تشغيل الـ Streams لأول مرة فقط ────────────────────────────
  void _startListening() {
    if (_isListening) return;
    _isListening = true;

    _accountsSub = repository.getAccounts().listen((data) {
      _accounts = data;
      if (_activeView == ActiveView.dashboard) _emitCurrentState();
    }, onError: (e) => emit(AccountingError(ServerFailure('$e'))));

    _invoicesSub = repository.getInvoices().listen((data) {
      _invoices = data;
      if (_activeView == ActiveView.invoices ||
          _activeView == ActiveView.dashboard) _emitCurrentState();
    }, onError: (e) => emit(AccountingError(ServerFailure('$e'))));

    _customersSub = repository.getCustomers().listen((data) {
      _customers = data;
      if (_activeView == ActiveView.customers ||
          _activeView == ActiveView.dashboard) _emitCurrentState();
    }, onError: (e) => emit(AccountingError(ServerFailure('$e'))));

    _suppliersSub = repository.getSuppliers().listen((data) {
      _suppliers = data;
      if (_activeView == ActiveView.suppliers ||
          _activeView == ActiveView.dashboard) _emitCurrentState();
    }, onError: (e) => emit(AccountingError(ServerFailure('$e'))));

    _productsSub = repository.getProducts().listen((data) {
      _products = data;
      if (_activeView == ActiveView.products) _emitCurrentState();
    }, onError: (e) => emit(AccountingError(ServerFailure('$e'))));
  }

  void _emitCurrentState() {
    switch (_activeView) {
      case ActiveView.dashboard:
        double totalSales = 0, totalPurchases = 0;
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

  // ─── Load Methods ──────────────────────────────────────────────
  void loadAccounts() {
    _activeView = ActiveView.dashboard;
    emit(AccountingLoading());
    if (!_isListening) {
      _startListening();
    } else {
      // الـ streams شغّالة، ابعت البيانات الحالية فوراً
      _emitCurrentState();
    }
  }

  void loadInvoices({String? type}) {
    _activeView = ActiveView.invoices;
    emit(AccountingLoading());
    if (!_isListening) {
      _startListening();
    } else {
      _emitCurrentState();
    }
  }

  void loadCustomers() {
    _activeView = ActiveView.customers;
    emit(AccountingLoading());
    if (!_isListening) {
      _startListening();
    } else {
      _emitCurrentState();
    }
  }

  void loadSuppliers() {
    _activeView = ActiveView.suppliers;
    emit(AccountingLoading());
    if (!_isListening) {
      _startListening();
    } else {
      _emitCurrentState();
    }
  }

  void loadProducts() {
    _activeView = ActiveView.products;
    emit(AccountingLoading());
    if (!_isListening) {
      _startListening();
    } else {
      _emitCurrentState();
    }
  }

  // ─── CRUD Operations ──────────────────────────────────────────

  Future<void> addNewAccount(Account newAccount) async {
    try {
      await repository.addAccount(newAccount);
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