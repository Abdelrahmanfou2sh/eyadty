# عيادتي - تطبيق إدارة العيادات الطبية

تطبيق Flutter لإدارة العيادات الطبية يوفر واجهة سهلة الاستخدام للأطباء لإدارة المواعيد والمرضى.

## المميزات الرئيسية

### 📅 إدارة المواعيد
- جدولة وتتبع المواعيد
- عرض المواعيد في تقويم تفاعلي
- تصدير المواعيد إلى ملفات Excel
- البحث وتصفية المواعيد

### 👥 إدارة المرضى
- قاعدة بيانات شاملة للمرضى
- سجل المواعيد لكل مريض
- معلومات التواصل والملاحظات

### 📊 الإحصائيات والتقارير
- إحصائيات يومية وشهرية
- تحليل أداء العيادة
- رسوم بيانية تفاعلية

### 🎨 الواجهة
- تصميم عربي سهل الاستخدام
- دعم الوضع المظلم
- واجهة سريعة الاستجابة

## التقنيات المستخدمة

- **Flutter**: إطار العمل الرئيسي
- **Firebase**: قاعدة البيانات وخدمات الباكند
- **Bloc/Cubit**: إدارة حالة التطبيق
- **Excel**: تصدير البيانات
- **Charts**: عرض الإحصائيات

## هيكل المشروع

```
lib/
├── core/              # المكونات الأساسية المشتركة
├── features/          # ميزات التطبيق
│   └── home/
│       ├── cubit/     # إدارة الحالة
│       ├── data/      # نماذج البيانات
│       └── presentation/  # واجهة المستخدم
└── main.dart          # نقطة البداية
```

## المتطلبات

- Flutter SDK
- Firebase CLI
- Android Studio / VS Code

## التثبيت

1. استنساخ المشروع:
```bash
git clone https://github.com/Abdelrahmanfou2sh/eyadty.git
```

2. تثبيت التبعيات:
```bash
flutter pub get
```

3. تشغيل التطبيق:
```bash
flutter run
```

## الإصدارات

- **1.1.0**
  - تحسين الأداء وتطبيق Lazy Loading
  - تحسين واجهة المستخدم
  - إصلاح الأخطاء

- **1.0.0**
  - إطلاق النسخة الأولى
  - الميزات الأساسية

## المساهمة

نرحب بمساهماتكم! يرجى اتباع الخطوات التالية:
1. Fork المشروع
2. إنشاء فرع للميزة الجديدة
3. تقديم pull request

## الترخيص

هذا المشروع مرخص تحت رخصة MIT.
