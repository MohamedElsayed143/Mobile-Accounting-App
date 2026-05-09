import json
import os

translations = {
    "إضافة صنف جديد": "Add New Product",
    "المنتجات - كارت الصنف": "Products - Product Card",
    "فشل الاتصال بالإنترنت، تأكد من اتصالك بالشبكة": "No Internet Connection, please check your network",
    "كود الحساب": "Account Code",
    "يرجى تسجيل الخروج والدخول مجدداً لإجراء هذا التغيير لأسباب أمنية": "Please logout and login again to apply this change for security reasons",
    "سجل الفواتير": "Invoices History",
    "تعديل كارت الصنف": "Edit Product Card",
    "الإعدادات": "Settings",
    "فشل حفظ المورد:": "Failed to save supplier:",
    "فاتورة": "Invoice",
    "تم إنشاء الحساب بنجاح! يرجى تسجيل الدخول": "Account created successfully! Please login",
    "الفواتير": "Invoices",
    "الوضع الليلي": "Dark Mode",
    "إعادة المحاولة": "Retry",
    "الأصناف": "Items",
    "سعر الشراء": "Purchase Price",
    "اضغط + لإضافة مورد جديد": "Press + to add a new supplier",
    "تعديل الملف الشخصي": "Edit Profile",
    "يرجى إدخال الاسم": "Please enter the name",
    "بحث باسم المورد أو الهاتف...": "Search by supplier name or phone...",
    "فاتورة شراء": "Purchase Invoice",
    "رصيد": "Balance",
    "الأمان": "Security",
    "لا يوجد موردون بعد": "No suppliers yet",
    "نظام المحاسبة الاحترافي": "Professional Accounting System",
    "حدث خطأ غير متوقع": "An unexpected error occurred",
    "إلغاء": "Cancel",
    "اختر صنفاً": "Select an item",
    "التفضيلات": "Preferences",
    "لا توجد فواتير بيع بعد": "No sales invoices yet",
    "اسم الصنف *": "Item Name *",
    "حفظ": "Save",
    "حذف": "Delete",
    "الإجمالي:  ج.م": "Total: EGP",
    "عن التطبيق": "About App",
    "رقم الهاتف مسجل مسبقاً": "Phone number is already registered",
    "لديك حساب بالفعل؟ سجل دخول": "Already have an account? Login",
    "الاسم يجب أن يكون 3 أحرف على الأقل": "Name must be at least 3 characters",
    "فواتير البيع": "Sales Invoices",
    "تغيير كلمة المرور": "Change Password",
    "اسم المورد *": "Supplier Name *",
    "مبيعات": "Sales",
    "فشل حفظ المنتج:": "Failed to save product:",
    "الملف الشخصي": "Profile",
    "كود:": "Code:",
    "لا توجد فواتير شراء بعد": "No purchase invoices yet",
    "تأكيد كلمة المرور": "Confirm Password",
    "العملاء": "Customers",
    "اختر مورداً": "Select a supplier",
    "رقم الهاتف": "Phone Number",
    "العنوان": "Address",
    "حفظ الصنف": "Save Item",
    "الكمية": "Quantity",
    "كلمة المرور يجب أن تكون 6 أحرف على الأقل": "Password must be at least 6 characters",
    "إضافة سطر": "Add Row",
    "إضافة صنف": "Add Item",
    "الوصف": "Description",
    "الموردين": "Suppliers",
    "تسجيل الدخول": "Login",
    "حدث خطأ:": "An error occurred:",
    "ليس لديك حساب؟ سجل الآن": "Don't have an account? Register now",
    "صنف": "Item",
    "الاسم الكامل": "Full Name",
    "اضغط + لإضافة صنف جديد": "Press + to add a new item",
    "إضافة عميل جديد": "Add New Customer",
    "اختر عميلاً": "Select a customer",
    "إضافة مورد جديد": "Add New Supplier",
    "سعر البيع": "Selling Price",
    "تم تغيير كلمة المرور بنجاح": "Password changed successfully",
    "فشل إضافة الفاتورة:": "Failed to add invoice:",
    "فاتورة الشراء": "Purchase Invoice",
    "كلمات المرور غير متطابقة": "Passwords do not match",
    "دليل الحسابات": "Chart of Accounts",
    "العربية": "Arabic",
    "كلمة المرور يجب أن لا تقل عن 6 أحرف": "Password must not be less than 6 characters",
    "رقم:   •": "No:   •",
    "حذف العميل": "Delete Customer",
    "لا يوجد رقم هاتف": "No phone number",
    "اسم العميل *": "Customer Name *",
    "البريد الإلكتروني": "Email",
    "فواتير الشراء": "Purchase Invoices",
    "كلمة المرور الجديدة": "New Password",
    "المبيعات": "Sales",
    "تسجيل الخروج": "Logout",
    "؟": "?",
    "فشل حذف العميل:": "Failed to delete customer:",
    "لا يوجد عملاء بعد": "No customers yet",
    "حذف الصنف": "Delete Item",
    "السعر": "Price",
    "فشل حذف المنتج:": "Failed to delete product:",
    "الحركات الأخيرة": "Recent Transactions",
    "برجاء إدخال رقم الموبايل وكلمة المرور": "Please enter mobile number and password",
    "إنشاء حساب جديد": "Create New Account",
    "ج.م": "EGP",
    "كلمة المرور": "Password",
    "حذف المورد": "Delete Supplier",
    "تعديل": "Edit",
    "بيع": "Sale",
    "لوحة التحكم المالي": "Financial Dashboard",
    "تعديل بيانات المورد": "Edit Supplier Details",
    "نسبة الخصم التلقائية:": "Auto Discount Rate:",
    "كود الصنف": "Item Code",
    "خصم": "Discount",
    "فشل إضافة الحساب:": "Failed to add account:",
    "تعديل بيانات العميل": "Edit Customer Details",
    "بحث باسم الصنف أو الكود...": "Search by item name or code...",
    "أصناف الفاتورة": "Invoice Items",
    "رقم الموبايل يجب أن يكون 11 رقم": "Mobile number must be 11 digits",
    "اضغط + لإضافة فاتورة جديدة": "Press + to add a new invoice",
    "المشتريات": "Purchases",
    "اللغة": "Language",
    "مدين": "Debit",
    "دائن": "Credit",
    "فشل حفظ العميل:": "Failed to save customer:",
    "فاتورة بيع جديدة": "New Sales Invoice",
    "فاتورة شراء جديدة": "New Purchase Invoice",
    "الرصيد الحالي": "Current Balance",
    "برجاء ملء جميع الحقول": "Please fill all fields",
    "مستخدم بدون اسم": "Unnamed User",
    "الخصم": "Discount",
    "رقم الإصدار": "Version Number",
    "إضافة عميل": "Add Customer",
    "نظام المحاسبة الذكي": "Smart Accounting System",
    "شراء": "Purchase",
    "مشتريات": "Purchases",
    "الاسم": "Name",
    "الموردون": "Suppliers",
    "نظام غير مدعوم": "Unsupported System",
    "فاتورة بيع": "Sales Invoice",
    "لا بيانات": "No Data",
    "يرجى إدخال كلمة المرور": "Please enter the password",
    "اضغط + لإضافة عميل جديد": "Press + to add a new customer",
    "رقم الموبايل": "Mobile Number",
    "تسجيل": "Register",
    "حساب:": "Account:",
    "رقم الهاتف أو كلمة المرور غير صحيح": "Invalid phone number or password",
    "دخول": "Enter",
    "فشل حذف المورد:": "Failed to delete supplier:",
    "لا يوجد منتجات بعد": "No products yet",
    "إضافة قيد يومية جديد": "Add New Journal Entry",
    "إضافة مورد": "Add Supplier",
    "بحث باسم العميل أو الهاتف...": "Search by customer name or phone..."
}

def main():
    ar_dict = {}
    en_dict = {}
    
    # We will use keys like "add_new_product" or auto-generated keys. 
    # Or, the easiest is to use the English translation converted to snake_case as the key.
    for ar_str, en_str in translations.items():
        key = en_str.lower().replace(" ", "_").replace("*", "").replace(":", "").replace(".", "").replace("+", "plus").replace("-", "").replace("?", "").replace(",", "").replace("(", "").replace(")", "").replace("!", "").replace("/", "").strip()
        key = "_".join(filter(None, key.split("_"))) # clean up multiple underscores
        
        # fallback for empty
        if not key:
            key = "key_" + str(len(ar_dict))
            
        # Ensure uniqueness
        original_key = key
        counter = 1
        while key in ar_dict:
            key = f"{original_key}_{counter}"
            counter += 1
            
        ar_dict[key] = ar_str
        en_dict[key] = en_str
        
    os.makedirs(r'd:\mobile-acc\assets\translations', exist_ok=True)
    with open(r'd:\mobile-acc\assets\translations\ar.json', 'w', encoding='utf-8') as f:
        json.dump(ar_dict, f, ensure_ascii=False, indent=2)
    with open(r'd:\mobile-acc\assets\translations\en.json', 'w', encoding='utf-8') as f:
        json.dump(en_dict, f, ensure_ascii=False, indent=2)

if __name__ == '__main__':
    main()
