import 'package:flutter/material.dart';
import 'settings.dart';

String tr(String value) {
  if (!AppSettings.instance.isEnglish) return value;
  if (_en.containsKey(value)) return _en[value]!;
  for (final entry in _dynamic.entries) {
    final match = RegExp(entry.key).firstMatch(value);
    if (match != null) {
      var result = entry.value;
      for (var i = 1; i <= match.groupCount; i++) {
        result = result.replaceAll('{$i}', match.group(i) ?? '');
      }
      return result;
    }
  }
  return value;
}

class AppText extends StatelessWidget {
  const AppText(
    this.data, {
    super.key,
    this.style,
    this.textAlign,
    this.overflow,
    this.maxLines,
    this.softWrap,
    this.textDirection,
    this.semanticsLabel,
    this.translate = true,
  });
  final String data;
  final bool translate;
  final TextStyle? style;
  final TextAlign? textAlign;
  final TextOverflow? overflow;
  final int? maxLines;
  final bool? softWrap;
  final TextDirection? textDirection;
  final String? semanticsLabel;
  @override
  Widget build(BuildContext context) => Text(
    translate ? tr(data) : data,
    style: style,
    textAlign: textAlign,
    overflow: overflow,
    maxLines: maxLines,
    softWrap: softWrap,
    textDirection: textDirection,
    semanticsLabel: semanticsLabel,
  );
}

const _en = <String, String>{
  'محفظتي': 'Mahfazaty',
  'الرئيسية': 'Home',
  'سلف ودين': 'Debts',
  'جمعيات': 'Groups',
  'الجمعيات': 'Savings groups',
  'الإحصائيات': 'Statistics',
  'الإعدادات': 'Settings',
  'الرصيد الحالي': 'Current balance',
  'دخل الشهر': 'Monthly income',
  'مصروف الشهر': 'Monthly expenses',
  'إضافة مصروف': 'Add expense',
  'إضافة دخل': 'Add income',
  'آخر العمليات': 'Recent transactions',
  'مصاريف آخر ٧ أيام': 'Spending over 7 days',
  'مفيش مصاريف الأسبوع ده 🎉': 'No expenses this week 🎉',
  'لسه مفيش عمليات': 'No transactions yet',
  'سجل أول مصروف أو دخل وابدأ تتابع فلوسك':
      'Record your first income or expense to get started',
  'إضافة عملية': 'Add transaction',
  'مصروف': 'Expense',
  'دخل': 'Income',
  'المبلغ': 'Amount',
  'التصنيف (اكتب اللي انت عايزه)': 'Category (your own name)',
  'مثلاً: علاج برد، مواصلات، شاي المكتب…': 'Type your own category…',
  'ملاحظة (اختياري)': 'Note (optional)',
  'اكتب مبلغ صحيح': 'Enter a valid amount',
  'حفظ التعديل': 'Save changes',
  'سجل المصروف': 'Save expense',
  'سجل الدخل': 'Save income',
  'التعديل متاح في يوم إضافة العملية بس':
      'Editing is available only on the day added',
  'مينفعش تعديل عمليات يوم سابق':
      'Transactions from earlier days cannot be edited',
  'تعديل': 'Edit',
  'إلغاء': 'Cancel',
  'النهارده': 'Today',
  'إمبارح': 'Yesterday',
  'دلوقتي': 'Just now',
  'لي عند الناس': 'Owed to me',
  'عليا للناس': 'I owe',
  'الصافي': 'Net balance',
  'سلف جديد': 'New debt',
  'لي 💰': 'Owed to me 💰',
  'عليا 🧾': 'I owe 🧾',
  'محدش مدينلك بحاجة': 'Nobody owes you money',
  'معليكش دين لحد': 'You owe nobody',
  'أي سلف جديد هيتسجل هنا وتفضل عارف كل مليم':
      'New debts will appear here so you can keep track',
  'اسم الشخص': 'Person name',
  'اكتب اسم الشخص': 'Enter a name',
  'لي (هيرجعهولي)': 'They owe me',
  'عليا (لازم أرده)': 'I owe them',
  'سجل إنه ليك': 'Save money owed to me',
  'سجل إنه عليك': 'Save money I owe',
  'اتسجل السلف ✅': 'Debt saved ✅',
  'اتسدت': 'Settled',
  'اتسدت ✅': 'Settled ✅',
  'رجعها غير مسددة': 'Mark as unsettled',
  'تم التسديد ✅': 'Settled ✅',
  'امسح 🗑': 'Delete 🗑',
  'تذكير بالتسديد 🔔': 'Repayment reminder 🔔',
  'تغيير ميعاد التذكير 🔔': 'Change reminder 🔔',
  'إلغاء التذكير 🔕': 'Cancel reminder 🔕',
  'إلغاء التذكير': 'Cancel reminder',
  'فكرني بالتسديد يوم': 'Remind me about repayment',
  'تذكير تسديد 💰': 'Repayment reminder 💰',
  'تذكير قسط جمعية 📅': 'Savings payment reminder 📅',
  'جمعية جديدة': 'New savings group',
  'لسه مفيش جمعيات': 'No savings groups yet',
  'ضيف الجمعية بعدد شهورها وقسطها الشهري، وهنحسبلك هتقبض كام وإمتى':
      'Add a savings group with its duration and payment to see when you receive the pot',
  'أضف أول جمعية': 'Add your first group',
  'مفيش جمعيات شغالة': 'No active groups',
  'شغالة': 'Active',
  'خلصت 🎉': 'Completed 🎉',
  'اسم الجمعية': 'Group name',
  'مثلاً: جمعية الشغل': 'For example: Work group',
  'القسط الشهري': 'Monthly payment',
  'عدد الشهور': 'Number of months',
  'شهر البداية': 'Starting month',
  'دورك في القبض': 'Your payout turn',
  'اكتب قسط شهري صحيح': 'Enter a valid monthly payment',
  'اكتب اسم الجمعية': 'Enter a group name',
  'سجل الجمعية': 'Save group',
  'الجمعية اتسجلت ✅': 'Group saved ✅',
  'شهور الجمعية': 'Group months',
  'دوس على الشهر لما تدفع قسطه': 'Tap a month when its payment is made',
  'قبضتها 💰': 'Mark payout received 💰',
  'قبضتك 🎉': 'Your payout 🎉',
  'تراجع عن القبض': 'Undo payout',
  'تذكير القسط 🔔': 'Payment reminder 🔔',
  'تذكير بميعاد القسط': 'Payment reminder',
  'فكرني بقسط الجمعية يوم': 'Choose a payment reminder date',
  'غير الميعاد': 'Change date',
  'سيبه زي ما هو': 'Keep as is',
  'امسح الجمعية': 'Delete group',
  'اتدفع ✓': 'Paid ✓',
  'مصاريف الشهر حسب التصنيف': 'Monthly spending by category',
  'إجمالي الشهر': 'Monthly total',
  'مفيش مصاريف الشهر ده لسه': 'No expenses this month yet',
  'الدخل مقابل المصروف (آخر ٦ شهور)': 'Income vs expenses (6 months)',
  'تسجيل الخروج؟': 'Sign out?',
  'بياناتك المحفوظة على الموبايل هتفضل زي ما هي.':
      'Your data on this device will be kept.',
  'تسجيل الخروج': 'Sign out',
  'خروج': 'Sign out',
  'تسجيل الدخول': 'Sign in',
  'سجل دخولك عشان تكمل': 'Sign in to continue',
  'أهلاً بيك في محفظتي': 'Welcome to Mahfazaty',
  'الإيميل': 'Email',
  'كلمة السر': 'Password',
  'نسيت كلمة السر؟': 'Forgot password?',
  'ماعندكش حساب؟': 'No account yet?',
  'اعمل حساب جديد': 'Create account',
  'الدخول كضيف': 'Continue as guest',
  'حساب جديد': 'New account',
  'اعمل حسابك وخلي فلوسك تحت السيطرة':
      'Create an account and keep track of your money',
  'الاسم': 'Name',
  'تأكيد كلمة السر': 'Confirm password',
  'إنشاء الحساب': 'Create account',
  'أو': 'or',
  'اكتب إيميلك فوق الأول، وبعدين اضغط نسيت كلمة السر.':
      'Enter your email first, then tap Forgot password.',
  'اكتب الإيميل': 'Enter your email',
  'اكتب كلمة السر': 'Enter your password',
  'اكتب اسمك': 'Enter your name',
  'الإيميل ده مش صحيح': 'Enter a valid email',
  'كلمة السر لازم ٦ حروف على الأقل': 'Password must be at least 6 characters',
  'كلمتا السر مش زي بعض': 'Passwords do not match',
  'بعتنالك لينك إعادة تعيين كلمة السر على إيميلك.':
      'A password reset link was sent to your email.',
  'الحسابات السحابية لسه بتتجهز في النسخة دي. تقدر تكمل كضيف، وبياناتك هتفضل محفوظة على موبايلك.':
      'Account access is not configured. You can continue as a guest with data saved on this device.',
  'تخطي': 'Skip',
  'التالي': 'Next',
  'يلا نبدأ': 'Get started',
  'خلصت': 'Done',
  'فلوسك… تحت السيطرة': 'Your money, under control',
  'مصاريفك ودخلك في مكان واحد': 'Your income and expenses in one place',
  'سجل أي عملية في ثواني، وصنفها بالأسماء اللي تحبها، والتطبيق بيتعلم منك ويقترحها عليك بعد كده.':
      'Record transactions in seconds using your own category names.',
  'سلف ودين من غير ما تنسى': 'Keep track of debts',
  'اعرف مين ليه عليك ومين لك عنده، والصافي قدامك، وسدد بضغطة واحدة.':
      'See what you owe and what is owed to you, and track repayment.',
  'جمعياتك محسوبة للآخر': 'Plan your savings groups',
  'القسط الشهري وعدد الشهور ودور قبضك، والتطبيق بيحسبلك هتقبض كام وإمتى بالظبط.':
      'Set the monthly payment, duration and payout turn to see when you receive the pot.',
  'اعمل جمعية وتابع أقساطك شهر بشهر':
      'Create a savings group and track monthly payments',
  'اكتب القسط الشهري ونشوف هتقبض كام وإمتى':
      'Enter the monthly payment to calculate your payout',
  'تمت الإضافة بنجاح': 'Saved successfully',
};
const _dynamic = <String, String>{
  r'^(.+) ج\.م$': '{1} EGP',
  r'^(.+) جمعية شغالة$': '{1} active groups',
  r'^(.+) شهور$': '{1} months',
  r'^القسط: (.+)$': 'Payment: {1}',
  r'^دفعت: (.+)$': 'Paid: {1}',
  r'^فاضل: (.+)$': 'Remaining: {1}',
  r'^شهر (.+)$': 'Month {1}',
  r'^الشهر (.+)$': 'Month {1}',
  r'^دفعت (.+) من (.+) شهر$': 'Paid {1} of {2} months',
  r'^بتدفع (.+) كل شهر$': 'You pay {1} each month',
  r'^هتقبض (.+) في (.+)$': 'Receive {1} in {2}',
  r'^قبضت (.+)$': 'Received {1}',
  r'^تذكير (.+)$': 'Reminder {1}',
  r'^تذكير يوم (.+)$': 'Reminder on {1}',
  r'^هفكرك بالتسديد يوم (.+) 🔔$': 'Repayment reminder set for {1} 🔔',
  r'^هفكرك بقسط "(.+)" يوم (.+) 🔔$': 'Payment reminder for {1} on {2} 🔔',
  r'^بدأت (.+) • القسط (.+) • الإجمالي (.+)$':
      'Started {1} • Payment {2} • Total {3}',
  r'^هتدفع (.+) كل شهر لمدة (.+) شهر، وتقبض (.+) في (.+) 💰$':
      'Pay {1} monthly for {2} months, receive {3} in {4} 💰',
};
