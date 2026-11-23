import 'package:flutter/material.dart';
import '../auth/auth_service.dart';
import '../settings.dart';
import '../store.dart';
import '../theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.store});
  final WalletStore store;
  Future<void> _editName(BuildContext context) async {
    final settings = AppSettings.instance;
    final c = TextEditingController(
      text: settings.profileName.isNotEmpty
          ? settings.profileName
          : AuthService.instance.displayName ?? '',
    );
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(settings.isEnglish ? 'Profile name' : 'اسم البروفايل'),
        content: TextField(
          controller: c,
          maxLength: 60,
          autofocus: true,
          decoration: InputDecoration(
            labelText: settings.isEnglish ? 'Name' : 'الاسم',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(settings.isEnglish ? 'Cancel' : 'إلغاء'),
          ),
          FilledButton(
            onPressed: () {
              if (c.text.trim().isNotEmpty) Navigator.pop(ctx, c.text.trim());
            },
            child: Text(settings.isEnglish ? 'Save' : 'حفظ'),
          ),
        ],
      ),
    );
    if (result != null) await settings.setProfileName(result);
    // The dialog route can still be animating after its result completes.
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: AppSettings.instance,
    builder: (context, _) => _buildSettings(context),
  );

  Widget _buildSettings(BuildContext context) {
    final s = AppSettings.instance;
    final en = s.isEnglish;
    final auth = AuthService.instance;
    final name = s.profileName.isNotEmpty
        ? s.profileName
        : auth.displayName ?? (en ? 'Guest' : 'ضيف');
    final ids = ['white', 'black', 'green', 'purple', 'blue', 'orange'];
    final names = en
        ? [
            'White',
            'Black',
            'Forest & Gold',
            'Purple & Rose',
            'Navy & Copper',
            'Terracotta & Sage',
          ]
        : [
            'أبيض',
            'أسود',
            'أخضر وذهبي',
            'بنفسجي ووردي',
            'كحلي ونحاسي',
            'طوبي ومريمي',
          ];
    return SafeArea(
      child: ListView(
        padding: EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          Text(
            en ? 'Settings' : 'الإعدادات',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
          ),
          SizedBox(height: 16),
          Card(
            child: ListTile(
              contentPadding: EdgeInsets.all(14),
              leading: CircleAvatar(
                backgroundColor: AppColors.emerald.withValues(alpha: .12),
                child: Icon(
                  Icons.person_outline,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              title: Text(name, style: TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text(
                auth.currentUser?.email ??
                    (en
                        ? 'Local profile on this device'
                        : 'بروفايل محلي على الجهاز'),
              ),
              trailing: IconButton(
                key: Key('edit-profile'),
                icon: Icon(Icons.edit_outlined),
                tooltip: en ? 'Edit name' : 'تعديل الاسم',
                onPressed: () => _editName(context),
              ),
            ),
          ),
          SizedBox(height: 20),
          Text(
            en ? 'App color' : 'لون التطبيق',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 6),
          Text(
            en
                ? 'Six coordinated palettes. Your choice is saved.'
                : '٦ توليفات متناسقة للخلفية والكروت والأزرار. اختيارك محفوظ.',
          ),
          SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: 6,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.05,
            ),
            itemBuilder: (context, i) {
              final id = ids[i];
              final palette = WalletPalette.all[id]!;
              final selected = s.themeId == id;
              return Semantics(
                selected: selected,
                button: true,
                label: names[i],
                child: InkWell(
                  key: Key('theme-$id'),
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => s.setTheme(id),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Theme.of(context).colorScheme.surface,
                      border: Border.all(
                        width: selected ? 2.5 : 1,
                        color: selected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).dividerColor,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 54,
                          height: 30,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: id == 'white'
                                  ? [Colors.white, Color(0xFFDEE3E7)]
                                  : [palette.primary, palette.accent],
                            ),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey),
                          ),
                          child: selected
                              ? Icon(
                                  Icons.check,
                                  size: 21,
                                  color: id == 'white'
                                      ? Colors.black
                                      : Colors.white,
                                )
                              : null,
                        ),
                        SizedBox(height: 7),
                        Text(
                          names[i],
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 20),
          Card(
            child: Padding(
              padding: EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    en ? 'Language' : 'اللغة',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 10),
                  SegmentedButton<String>(
                    segments: [
                      ButtonSegment(value: 'ar', label: Text('العربية')),
                      ButtonSegment(value: 'en', label: Text('English')),
                    ],
                    selected: {s.language},
                    onSelectionChanged: (v) => s.setLanguage(v.first),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: Icon(Icons.payments_outlined),
              title: Text(en ? 'Currency' : 'العملة'),
              subtitle: Text(en ? 'Egyptian pound (EGP)' : 'جنيه مصري (ج.م)'),
            ),
          ),
          SizedBox(height: 12),
          Card(
            child: Padding(
              padding: EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.shield_outlined),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      en
                          ? 'Changing appearance or language does not change your transactions, debts or savings groups. Financial records stay on this device.'
                          : 'تغيير اللون أو اللغة مش بيغيّر عملياتك أو السلف أو الجمعيات. بيانات الفلوس محفوظة على الجهاز.',
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 20),
          Center(
            child: Text(
              en ? 'Mahfazaty · 1.5.0' : 'محفظتي · 1.5.0',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
