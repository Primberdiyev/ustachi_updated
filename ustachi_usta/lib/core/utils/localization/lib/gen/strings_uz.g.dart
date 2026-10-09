///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import
// dart format off

part of 'strings.g.dart';

// Path: <root>
typedef TranslationsUz = Translations; // ignore: unused_element
class Translations with BaseTranslations<AppLocale, Translations> {
	/// Returns the current translations of the given [context].
	///
	/// Usage:
	/// final t = Translations.of(context);
	static Translations of(BuildContext context) => InheritedLocaleData.of<AppLocale, Translations>(context).translations;

	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	Translations({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.uz,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <uz>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	dynamic operator[](String key) => $meta.getTranslation(key);

	late final Translations _root = this; // ignore: unused_field

	Translations $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => Translations(meta: meta ?? this.$meta);

	// Translations

	/// uz: 'Ustachi'
	String get applicationName => 'Ustachi';

	late final TranslationsCommonUz common = TranslationsCommonUz.internal(_root);
	late final TranslationsOnboardingUz onboarding = TranslationsOnboardingUz.internal(_root);
	late final TranslationsAuthUz auth = TranslationsAuthUz.internal(_root);
	late final TranslationsCountryUz country = TranslationsCountryUz.internal(_root);
	late final TranslationsHomeUz home = TranslationsHomeUz.internal(_root);
	late final TranslationsCalculatePageUz calculatePage = TranslationsCalculatePageUz.internal(_root);
	late final TranslationsProfileUz profile = TranslationsProfileUz.internal(_root);
	late final TranslationsDashboardUz dashboard = TranslationsDashboardUz.internal(_root);
	late final TranslationsOrdersUz orders = TranslationsOrdersUz.internal(_root);
	late final TranslationsOwnOrdersUz ownOrders = TranslationsOwnOrdersUz.internal(_root);
	late final TranslationsOrderFormUz orderForm = TranslationsOrderFormUz.internal(_root);
	late final TranslationsChatUz chat = TranslationsChatUz.internal(_root);
	late final TranslationsNotificationsUz notifications = TranslationsNotificationsUz.internal(_root);
	late final TranslationsMastersUz masters = TranslationsMastersUz.internal(_root);
	late final TranslationsOrderFlowUz orderFlow = TranslationsOrderFlowUz.internal(_root);
	late final TranslationsCompanyUz company = TranslationsCompanyUz.internal(_root);
	late final TranslationsCompanyRatesUz companyRates = TranslationsCompanyRatesUz.internal(_root);
	late final TranslationsMaterialsUz materials = TranslationsMaterialsUz.internal(_root);
	late final TranslationsProfessionalUz professional = TranslationsProfessionalUz.internal(_root);
	late final TranslationsAppUpdateUz appUpdate = TranslationsAppUpdateUz.internal(_root);
}

// Path: common
class TranslationsCommonUz {
	TranslationsCommonUz.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// uz: 'OK'
	String get ok => 'OK';

	/// uz: 'Boshlash'
	String get start => 'Boshlash';

	/// uz: 'Bekor qilish'
	String get cancel => 'Bekor qilish';

	/// uz: 'Saqlash'
	String get save => 'Saqlash';

	/// uz: 'O'chirish'
	String get delete => 'O\'chirish';

	/// uz: 'Tahrirlash'
	String get edit => 'Tahrirlash';

	/// uz: 'Yopish'
	String get close => 'Yopish';

	/// uz: 'Orqaga'
	String get back => 'Orqaga';

	/// uz: 'Keyingi'
	String get next => 'Keyingi';

	/// uz: 'O'tkazib yuborish'
	String get skip => 'O\'tkazib yuborish';

	/// uz: 'Kiriting'
	String get enter => 'Kiriting';

	/// uz: 'Xatolik yuz berdi. Iltimos birozdan so'ng qayta urining!'
	String get wentWrong => 'Xatolik yuz berdi. Iltimos birozdan so\'ng qayta urining!';

	/// uz: 'Asosiy'
	String get common => 'Asosiy';

	/// uz: 'Tanlash'
	String get select => 'Tanlash';

	/// uz: 'Qayta urinish'
	String get retry => 'Qayta urinish';

	/// uz: 'Yangilash'
	String get refresh => 'Yangilash';

	/// uz: 'Saqlandi'
	String get saved => 'Saqlandi';

	/// uz: 'Saqlanmadi — qayta urinib ko'ring'
	String get saveFailed => 'Saqlanmadi — qayta urinib ko\'ring';

	/// uz: 'Topilmadi'
	String get notFound => 'Topilmadi';

	/// uz: 'Bo'sh'
	String get empty => 'Bo\'sh';

	/// uz: 'Yuklanmoqda…'
	String get loading => 'Yuklanmoqda…';

	/// uz: 'Ha'
	String get yes => 'Ha';

	/// uz: 'Yo'q'
	String get no => 'Yo\'q';

	/// uz: 'Qo'shish'
	String get add => 'Qo\'shish';

	/// uz: 'Nusxalash'
	String get copy => 'Nusxalash';

	/// uz: 'Qo'llash'
	String get apply => 'Qo\'llash';

	/// uz: 'Qaytarish'
	String get reset => 'Qaytarish';

	/// uz: 'Tayyor'
	String get done => 'Tayyor';

	/// uz: 'Hammasi'
	String get all => 'Hammasi';

	/// uz: 'so'm'
	String get som => 'so\'m';

	/// uz: 'sm'
	String get cm => 'sm';

	/// uz: 'mm'
	String get mm => 'mm';

	/// uz: 'dona'
	String get pcs => 'dona';

	/// uz: 'soat'
	String get hoursShort => 'soat';

	/// uz: 'daq'
	String get minutesShort => 'daq';

	List<String> get months => [
		'yanvar',
		'fevral',
		'mart',
		'aprel',
		'may',
		'iyun',
		'iyul',
		'avgust',
		'sentabr',
		'oktabr',
		'noyabr',
		'dekabr',
	];
	List<String> get weekdays => [
		'Yakshanba',
		'Dushanba',
		'Seshanba',
		'Chorshanba',
		'Payshanba',
		'Juma',
		'Shanba',
	];

	/// uz: 'Bugun'
	String get today => 'Bugun';

	/// uz: 'Ertaga'
	String get tomorrow => 'Ertaga';

	/// uz: 'Tez kunda'
	String get comingSoon => 'Tez kunda';
}

// Path: onboarding
class TranslationsOnboardingUz {
	TranslationsOnboardingUz.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final TranslationsOnboardingStep1Uz step1 = TranslationsOnboardingStep1Uz.internal(_root);
	late final TranslationsOnboardingStep2Uz step2 = TranslationsOnboardingStep2Uz.internal(_root);
	late final TranslationsOnboardingStep3Uz step3 = TranslationsOnboardingStep3Uz.internal(_root);
}

// Path: auth
class TranslationsAuthUz {
	TranslationsAuthUz.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// uz: 'USTANING ISH MAYDONI'
	String get tagline => 'USTANING ISH MAYDONI';

	late final TranslationsAuthCommonUz common = TranslationsAuthCommonUz.internal(_root);
	late final TranslationsAuthPhoneUz phone = TranslationsAuthPhoneUz.internal(_root);
	late final TranslationsAuthOtpUz otp = TranslationsAuthOtpUz.internal(_root);
	late final TranslationsAuthProfileUz profile = TranslationsAuthProfileUz.internal(_root);
	late final TranslationsAuthTelegramUz telegram = TranslationsAuthTelegramUz.internal(_root);
}

// Path: country
class TranslationsCountryUz {
	TranslationsCountryUz.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// uz: 'Davlatni tanlang'
	String get title => 'Davlatni tanlang';

	/// uz: 'Ilova tili shu davlatga qarab tanlanadi. Keyinroq profilingizdan o‘zgartirishingiz mumkin.'
	String get subtitle => 'Ilova tili shu davlatga qarab tanlanadi. Keyinroq profilingizdan o‘zgartirishingiz mumkin.';

	/// uz: 'Davom etish'
	String get continueBtn => 'Davom etish';

	/// uz: 'Davlat va til'
	String get changeTitle => 'Davlat va til';
}

// Path: home
class TranslationsHomeUz {
	TranslationsHomeUz.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// uz: 'Asosiy'
	String get main => 'Asosiy';

	/// uz: 'Chat'
	String get chatting => 'Chat';

	/// uz: 'Profil'
	String get profile => 'Profil';

	/// uz: 'Profil'
	String get title => 'Profil';

	/// uz: 'Profil yuklanmadi'
	String get loadError => 'Profil yuklanmadi';

	/// uz: 'Qayta urinish'
	String get retry => 'Qayta urinish';

	/// uz: 'Telefon'
	String get phone => 'Telefon';

	/// uz: 'Rol'
	String get role => 'Rol';

	/// uz: 'Holat'
	String get status => 'Holat';

	/// uz: 'Faol'
	String get active => 'Faol';

	/// uz: 'Nofaol'
	String get inactive => 'Nofaol';

	/// uz: 'Chiqish'
	String get logout => 'Chiqish';

	/// uz: 'Salom'
	String get hi => 'Salom';

	/// uz: 'Xizmat turlari'
	String get serviceType => 'Xizmat turlari';

	/// uz: 'Oxirgi buyurtmalar'
	String get lastOrders => 'Oxirgi buyurtmalar';

	/// uz: 'Hammasi'
	String get all => 'Hammasi';

	/// uz: 'Kran ta'mirlash'
	String get tapRepair => 'Kran ta\'mirlash';

	/// uz: 'Lyustra o'rnatish'
	String get chandelierInstallation => 'Lyustra o\'rnatish';

	/// uz: 'Bajarildi'
	String get completed => 'Bajarildi';

	/// uz: 'Jarayonda'
	String get inProgress => 'Jarayonda';

	/// uz: 'Rom'
	String get window => 'Rom';

	/// uz: 'Mebel'
	String get furtiniture => 'Mebel';

	/// uz: 'Elektrika'
	String get electric => 'Elektrika';

	/// uz: 'Santexnika'
	String get plumber => 'Santexnika';
}

// Path: calculatePage
class TranslationsCalculatePageUz {
	TranslationsCalculatePageUz.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// uz: 'Deraza'
	String get window => 'Deraza';

	/// uz: 'Eshik'
	String get door => 'Eshik';

	/// uz: 'Arkalar'
	String get glass => 'Arkalar';

	/// uz: 'Deraza konfiguratsiyasi'
	String get windowConfigurator => 'Deraza konfiguratsiyasi';

	/// uz: 'Bo'linma turlari'
	String get windowLayouts => 'Bo\'linma turlari';

	/// uz: 'Premium variantlar'
	String get windowPremiumLayouts => 'Premium variantlar';

	/// uz: 'Zamonaviy variantlar'
	String get windowModernLayouts => 'Zamonaviy variantlar';

	/// uz: 'Eshik konfiguratsiyasi'
	String get doorConfigurator => 'Eshik konfiguratsiyasi';

	/// uz: 'Eshik modellari'
	String get doorModels => 'Eshik modellari';

	/// uz: 'Qo'shimcha modellari'
	String get doorExtraModels => 'Qo\'shimcha modellari';

	/// uz: 'Material'
	String get material => 'Material';

	/// uz: 'Plastik'
	String get plastic => 'Plastik';

	/// uz: 'Alyumin'
	String get aluminium => 'Alyumin';

	/// uz: 'Termo'
	String get termo => 'Termo';

	/// uz: 'Arkalar variantlari'
	String get glassShowcase => 'Arkalar variantlari';

	/// uz: 'O'z derazangizni yasang'
	String get customTemplateTitleWindow => 'O\'z derazangizni yasang';

	/// uz: 'O'z eshigingizni yasang'
	String get customTemplateTitleDoor => 'O\'z eshigingizni yasang';

	/// uz: 'O'z arkangizni yasang'
	String get customTemplateTitleArch => 'O\'z arkangizni yasang';

	/// uz: 'Tayyor shablon emas — o'lcham va bo'linmani o'zingiz chizasiz'
	String get customTemplateSubtitle => 'Tayyor shablon emas — o\'lcham va bo\'linmani o\'zingiz chizasiz';

	/// uz: 'Boshlash'
	String get customTemplateAction => 'Boshlash';

	/// uz: 'Tayyor shablonlar'
	String get readyTemplates => 'Tayyor shablonlar';
}

// Path: profile
class TranslationsProfileUz {
	TranslationsProfileUz.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// uz: 'Shaxsiy ma'lumotlar'
	String get personalData => 'Shaxsiy ma\'lumotlar';

	/// uz: 'Kasbiy ma'lumot'
	String get professional => 'Kasbiy ma\'lumot';

	/// uz: 'Korxona'
	String get company => 'Korxona';

	/// uz: 'Mening buyurtmalarim'
	String get myOrders => 'Mening buyurtmalarim';

	/// uz: 'Sozlamalar'
	String get settings => 'Sozlamalar';

	/// uz: 'Biz bilan aloqa'
	String get support => 'Biz bilan aloqa';

	/// uz: 'Chiqish'
	String get logout => 'Chiqish';

	/// uz: 'Hisobdan chiqasizmi?'
	String get logoutTitle => 'Hisobdan chiqasizmi?';

	/// uz: 'Yuklab olingan narxlar va hisob-kitob ma'lumotlari qurilmadan o'chiriladi. Qayta kirganingizda ular yangidan yuklab olinadi.'
	String get logoutMessage => 'Yuklab olingan narxlar va hisob-kitob ma\'lumotlari qurilmadan o\'chiriladi. Qayta kirganingizda ular yangidan yuklab olinadi.';

	/// uz: 'Ha, chiqaman'
	String get logoutConfirm => 'Ha, chiqaman';

	/// uz: 'Chiqilmoqda...'
	String get loggingOut => 'Chiqilmoqda...';

	/// uz: 'Sessiya yopilib, narxlar keshi tozalanmoqda'
	String get loggingOutHint => 'Sessiya yopilib, narxlar keshi tozalanmoqda';

	/// uz: 'Serverdan chiqib bo'lmadi, lekin qurilmadagi ma'lumotlar tozalandi'
	String get logoutFailed => 'Serverdan chiqib bo\'lmadi, lekin qurilmadagi ma\'lumotlar tozalandi';

	late final TranslationsProfilePersonalUz personal = TranslationsProfilePersonalUz.internal(_root);
	late final TranslationsProfileHelpUz help = TranslationsProfileHelpUz.internal(_root);
}

// Path: dashboard
class TranslationsDashboardUz {
	TranslationsDashboardUz.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// uz: 'Ish stoli'
	String get title => 'Ish stoli';

	/// uz: 'Xayrli tong,'
	String get greetingMorning => 'Xayrli tong,';

	/// uz: 'Xayrli kun,'
	String get greetingDay => 'Xayrli kun,';

	/// uz: 'Xayrli kech,'
	String get greetingEvening => 'Xayrli kech,';

	/// uz: 'usta'
	String get master => 'usta';

	/// uz: 'Buyurtma qabul qilaman'
	String get availableTitle => 'Buyurtma qabul qilaman';

	/// uz: 'Yangi so'rovlar kelaveradi'
	String get availableOn => 'Yangi so\'rovlar kelaveradi';

	/// uz: 'So'rovlar to'xtatildi'
	String get availableOff => 'So\'rovlar to\'xtatildi';

	/// uz: 'Ta'mirga chiqaman'
	String get repairTitle => 'Ta\'mirga chiqaman';

	/// uz: 'Ta'mir so'rovlari ham keladi'
	String get repairOn => 'Ta\'mir so\'rovlari ham keladi';

	/// uz: 'Ta'mir so'rovlari kelmaydi'
	String get repairOff => 'Ta\'mir so\'rovlari kelmaydi';

	/// uz: 'Eski rom-eshikni sozlash, furnitura yoki oyna almashtirish'
	String get repairHint => 'Eski rom-eshikni sozlash, furnitura yoki oyna almashtirish';

	/// uz: 'Yangi so'rovlar'
	String get newRequests => 'Yangi so\'rovlar';

	/// uz: 'Faol buyurtmalar'
	String get activeOrders => 'Faol buyurtmalar';

	/// uz: 'Barchasi'
	String get all => 'Barchasi';

	/// uz: 'Rom chizish'
	String get quickCalculate => 'Rom chizish';

	/// uz: 'Deraza va eshik chizmasi'
	String get quickCalculateHint => 'Deraza va eshik chizmasi';

	/// uz: 'Ish namunasi'
	String get quickPortfolio => 'Ish namunasi';

	/// uz: 'Yakunlangan ishdan qo'shing'
	String get quickPortfolioHint => 'Yakunlangan ishdan qo\'shing';

	/// uz: 'Yangi so'rov yo'q'
	String get emptyRequests => 'Yangi so\'rov yo\'q';

	/// uz: 'Bandlik tugmasi yoqilgan bo'lsa, so'rovlar shu yerga tushadi.'
	String get emptyRequestsHint => 'Bandlik tugmasi yoqilgan bo\'lsa, so\'rovlar shu yerga tushadi.';

	/// uz: 'Korxona'
	String get quickCompany => 'Korxona';

	/// uz: 'Nom va logotip'
	String get quickCompanyHint => 'Nom va logotip';

	/// uz: 'Xizmat narxlarim'
	String get quickRates => 'Xizmat narxlarim';

	/// uz: 'Sohangiz bo'yicha ish stavkalari'
	String get quickRatesHint => 'Sohangiz bo\'yicha ish stavkalari';

	/// uz: 'Yangi buyurtmalar va Bozor'
	String get quickOrdersHeroTitle => 'Yangi buyurtmalar va Bozor';

	/// uz: 'Sohangizdagi e'lonlarni ko'ring va taklif yuboring'
	String get quickOrdersHeroHint => 'Sohangizdagi e\'lonlarni ko\'ring va taklif yuboring';

	/// uz: 'Ochiq buyurtmalar'
	String get quickOpenOrders => 'Ochiq buyurtmalar';

	/// uz: 'Usta tanlanmagan e'lonlar — taklif bering'
	String get quickOpenOrdersHint => 'Usta tanlanmagan e\'lonlar — taklif bering';

	/// uz: 'Rom tanlang'
	String get calcStep1 => 'Rom tanlang';

	/// uz: 'Sozlang'
	String get calcStep2 => 'Sozlang';

	/// uz: 'Chizma tayyor'
	String get calcStep3 => 'Chizma tayyor';
}

// Path: orders
class TranslationsOrdersUz {
	TranslationsOrdersUz.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// uz: 'Buyurtmalar'
	String get title => 'Buyurtmalar';

	/// uz: 'Ochiq'
	String get segmentNew => 'Ochiq';

	/// uz: 'Jarayonda'
	String get segmentActive => 'Jarayonda';

	/// uz: 'Yakunlangan'
	String get segmentDone => 'Yakunlangan';

	/// uz: '${step}-bosqich / ${total}'
	String stepOf({required Object step, required Object total}) => '${step}-bosqich / ${total}';

	/// uz: '${days} kun kechikdi'
	String lateDays({required Object days}) => '${days} kun kechikdi';

	/// uz: 'Bugun tugaydi'
	String get dueToday => 'Bugun tugaydi';

	/// uz: '${days} kun qoldi'
	String daysLeft({required Object days}) => '${days} kun qoldi';

	/// uz: 'Taklif ber'
	String get offerBtn => 'Taklif ber';

	/// uz: 'Qayta urinish'
	String get retry => 'Qayta urinish';

	/// uz: 'Buyurtmalarni yuklab bo'lmadi'
	String get loadFailed => 'Buyurtmalarni yuklab bo\'lmadi';

	/// uz: 'Ochiq buyurtma yo'q'
	String get emptyNewTitle => 'Ochiq buyurtma yo\'q';

	/// uz: 'Hududingizda yangi e'lon paydo bo'lishi bilan shu yerda ko'rinadi.'
	String get emptyNewMessage => 'Hududingizda yangi e\'lon paydo bo\'lishi bilan shu yerda ko\'rinadi.';

	/// uz: 'Faol buyurtma yo'q'
	String get emptyActiveTitle => 'Faol buyurtma yo\'q';

	/// uz: 'Yangi so'rovni qabul qilsangiz, u shu yerda paydo bo'ladi.'
	String get emptyActiveMessage => 'Yangi so\'rovni qabul qilsangiz, u shu yerda paydo bo\'ladi.';

	/// uz: 'Yakunlangan ish yo'q'
	String get emptyDoneTitle => 'Yakunlangan ish yo\'q';

	/// uz: 'Birinchi buyurtmani topshirganingizdan keyin bu yerda ko'rinadi.'
	String get emptyDoneMessage => 'Birinchi buyurtmani topshirganingizdan keyin bu yerda ko\'rinadi.';

	late final TranslationsOrdersStageUz stage = TranslationsOrdersStageUz.internal(_root);
	late final TranslationsOrdersDetailUz detail = TranslationsOrdersDetailUz.internal(_root);
	late final TranslationsOrdersRequestUz request = TranslationsOrdersRequestUz.internal(_root);
	late final TranslationsOrdersSpecUz spec = TranslationsOrdersSpecUz.internal(_root);

	/// uz: 'Noto'g'ri buyurtma raqami.'
	String get invalidId => 'Noto\'g\'ri buyurtma raqami.';

	/// uz: 'Noto'g'ri so'rov raqami.'
	String get invalidRequestId => 'Noto\'g\'ri so\'rov raqami.';

	late final TranslationsOrdersOpenUz open = TranslationsOrdersOpenUz.internal(_root);

	/// uz: 'Shaxsiy buyurtmalar'
	String get personalTitle => 'Shaxsiy buyurtmalar';
}

// Path: ownOrders
class TranslationsOwnOrdersUz {
	TranslationsOwnOrdersUz.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// uz: 'Buyurtma'
	String get orderTitle => 'Buyurtma';

	/// uz: '${count} ta rom'
	String itemsCount({required Object count}) => '${count} ta rom';

	/// uz: 'Buyurtma holati'
	String get statusTitle => 'Buyurtma holati';

	/// uz: 'Holat'
	String get statusRow => 'Holat';

	/// uz: 'Saqlanyapti…'
	String get saving => 'Saqlanyapti…';

	/// uz: 'O'zgartirish uchun bosing'
	String get tapToChange => 'O\'zgartirish uchun bosing';

	/// uz: 'Bu buyurtma allaqachon yakunlangan.'
	String get alreadyDone => 'Bu buyurtma allaqachon yakunlangan.';

	/// uz: 'Bu buyurtma holatini o'zgartirib bo'lmaydi.'
	String get cannotChange => 'Bu buyurtma holatini o\'zgartirib bo\'lmaydi.';

	late final TranslationsOwnOrdersStatusUz status = TranslationsOwnOrdersStatusUz.internal(_root);
	late final TranslationsOwnOrdersHintUz hint = TranslationsOwnOrdersHintUz.internal(_root);
}

// Path: orderForm
class TranslationsOrderFormUz {
	TranslationsOrderFormUz.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// uz: 'Buyurtmada mahsulot yo'q.'
	String get noProducts => 'Buyurtmada mahsulot yo\'q.';

	/// uz: 'Internet yo'q — buyurtma navbatga qo'yildi, o'zi yuboriladi.'
	String get queued => 'Internet yo\'q — buyurtma navbatga qo\'yildi, o\'zi yuboriladi.';

	/// uz: 'Buyurtma saqlandi'
	String get saved => 'Buyurtma saqlandi';

	/// uz: 'Buyurtmani saqlash'
	String get saveTitle => 'Buyurtmani saqlash';

	/// uz: 'Buyurtmachi'
	String get customer => 'Buyurtmachi';

	/// uz: 'Ismi'
	String get nameLabel => 'Ismi';

	/// uz: 'Aziz aka'
	String get nameHint => 'Aziz aka';

	/// uz: 'Ismni yozing'
	String get nameRequired => 'Ismni yozing';

	/// uz: 'Chilonzor 9-kvartal'
	String get addressHint => 'Chilonzor 9-kvartal';

	/// uz: 'Qo'shimcha izoh'
	String get noteLabel => 'Qo\'shimcha izoh';

	/// uz: '2-qavat, lift yo'q'
	String get noteHint => '2-qavat, lift yo\'q';

	/// uz: '${kinds} xil rom · ${count} dona'
	String itemsSummary({required Object kinds, required Object count}) => '${kinds} xil rom · ${count} dona';
}

// Path: chat
class TranslationsChatUz {
	TranslationsChatUz.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// uz: 'Suhbatlar'
	String get threadsTitle => 'Suhbatlar';

	/// uz: 'Suhbat'
	String get conversation => 'Suhbat';

	/// uz: 'Xabar yozing...'
	String get messageHint => 'Xabar yozing...';

	/// uz: 'Narx va shartni shu yerda kelishasiz'
	String get emptyChat => 'Narx va shartni shu yerda kelishasiz';

	/// uz: 'Hali suhbat yo'q'
	String get emptyThreadsTitle => 'Hali suhbat yo\'q';

	/// uz: 'Buyurtmangizga usta javob berganda shu yerda yozishasiz.'
	String get emptyThreadsMessage => 'Buyurtmangizga usta javob berganda shu yerda yozishasiz.';
}

// Path: notifications
class TranslationsNotificationsUz {
	TranslationsNotificationsUz.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// uz: 'Bildirishnomalar'
	String get title => 'Bildirishnomalar';

	/// uz: 'Hammasini o'qish'
	String get markAllRead => 'Hammasini o\'qish';

	/// uz: 'Bildirishnoma yo'q'
	String get empty => 'Bildirishnoma yo\'q';

	/// uz: 'Ko'rish'
	String get open => 'Ko\'rish';
}

// Path: masters
class TranslationsMastersUz {
	TranslationsMastersUz.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// uz: 'Usta haqida'
	String get title => 'Usta haqida';

	/// uz: 'Usta'
	String get master => 'Usta';

	/// uz: 'Mijoz'
	String get client => 'Mijoz';

	/// uz: 'Yozish'
	String get write => 'Yozish';

	/// uz: 'Shu ustani tanlash'
	String get chooseThis => 'Shu ustani tanlash';

	/// uz: 'Tanlash'
	String get choose => 'Tanlash';

	/// uz: 'Tanlangan usta'
	String get chosen => 'Tanlangan usta';

	/// uz: 'Ma'lumot topilmadi'
	String get notFound => 'Ma\'lumot topilmadi';

	/// uz: 'Qilgan ishlari'
	String get works => 'Qilgan ishlari';

	/// uz: 'Sharhlar (${count})'
	String reviews({required Object count}) => 'Sharhlar (${count})';

	/// uz: 'Sharhlar'
	String get reviewsLabel => 'Sharhlar';

	/// uz: 'Hali sharh yo'q — siz birinchi bo'lishingiz mumkin.'
	String get noReviews => 'Hali sharh yo\'q — siz birinchi bo\'lishingiz mumkin.';

	/// uz: '${years} yil tajriba'
	String experienceYears({required Object years}) => '${years} yil tajriba';

	/// uz: 'Reyting'
	String get rating => 'Reyting';

	/// uz: 'Bajarilgan'
	String get completed => 'Bajarilgan';

	/// uz: '${count} javob'
	String responses({required Object count}) => '${count} javob';

	/// uz: 'Hisob'
	String get estimate => 'Hisob';
}

// Path: orderFlow
class TranslationsOrderFlowUz {
	TranslationsOrderFlowUz.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final TranslationsOrderFlowStatusUz status = TranslationsOrderFlowStatusUz.internal(_root);
	late final TranslationsOrderFlowStageUz stage = TranslationsOrderFlowStageUz.internal(_root);
	late final TranslationsOrderFlowResponseUz response = TranslationsOrderFlowResponseUz.internal(_root);
}

// Path: company
class TranslationsCompanyUz {
	TranslationsCompanyUz.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// uz: 'Korxona'
	String get title => 'Korxona';

	/// uz: 'Korxona nomi'
	String get nameLabel => 'Korxona nomi';

	/// uz: 'Masalan: Ustachi Servis'
	String get nameHint => 'Masalan: Ustachi Servis';

	/// uz: 'Korxona nomi kiritilmagan'
	String get nameEmpty => 'Korxona nomi kiritilmagan';

	/// uz: 'Buyurtma varag'ida ko'rinadi'
	String get nameNote => 'Buyurtma varag\'ida ko\'rinadi';

	/// uz: 'Logotip qo'shish'
	String get logoHint => 'Logotip qo\'shish';
}

// Path: companyRates
class TranslationsCompanyRatesUz {
	TranslationsCompanyRatesUz.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// uz: 'Faqat raqam'
	String get onlyDigits => 'Faqat raqam';
}

// Path: materials
class TranslationsMaterialsUz {
	TranslationsMaterialsUz.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// uz: 'Materiallar'
	String get title => 'Materiallar';

	/// uz: 'Shu materialda ishlayman — buyurtmalar keladi'
	String get on => 'Shu materialda ishlayman — buyurtmalar keladi';

	/// uz: 'O'chirilgan — bu materialdagi buyurtmalar kelmaydi'
	String get off => 'O\'chirilgan — bu materialdagi buyurtmalar kelmaydi';

	/// uz: 'Kamida bitta material yoqiq turishi kerak'
	String get allOff => 'Kamida bitta material yoqiq turishi kerak';
}

// Path: professional
class TranslationsProfessionalUz {
	TranslationsProfessionalUz.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// uz: 'Kasbiy ma'lumot'
	String get title => 'Kasbiy ma\'lumot';

	/// uz: 'Qanday usta ekaningizni ayting'
	String get headline => 'Qanday usta ekaningizni ayting';

	/// uz: 'Mijoz sizni tanlashdan oldin shu ma'lumotni ko'radi. Keyin istalgan vaqtda o'zgartirishingiz mumkin.'
	String get headlineHint => 'Mijoz sizni tanlashdan oldin shu ma\'lumotni ko\'radi. Keyin istalgan vaqtda o\'zgartirishingiz mumkin.';

	/// uz: 'Yo'nalishlar'
	String get specialty => 'Yo\'nalishlar';

	/// uz: 'Yo'nalishlaringizni tanlang'
	String get specialtyPick => 'Yo\'nalishlaringizni tanlang';

	/// uz: 'Yo'nalishlar ro'yxati yuklanmadi — internetni tekshirib, qayta kiring.'
	String get specialtyLoadFailed => 'Yo\'nalishlar ro\'yxati yuklanmadi — internetni tekshirib, qayta kiring.';

	/// uz: 'Necha yillik tajribangiz bor?'
	String get experienceQuestion => 'Necha yillik tajribangiz bor?';

	/// uz: 'Masalan: 5'
	String get experienceHint => 'Masalan: 5';

	/// uz: 'Tajribani kiriting'
	String get experienceRequired => 'Tajribani kiriting';

	/// uz: 'Tajriba 0 dan 70 gacha bo'lishi kerak'
	String get experienceRange => 'Tajriba 0 dan 70 gacha bo\'lishi kerak';

	/// uz: 'O'zingiz haqingizda (ixtiyoriy)'
	String get aboutLabel => 'O\'zingiz haqingizda (ixtiyoriy)';

	/// uz: 'Qanday ishlarni qilasiz, nimaga e'tibor berasiz — qisqacha yozing.'
	String get aboutHint => 'Qanday ishlarni qilasiz, nimaga e\'tibor berasiz — qisqacha yozing.';

	/// uz: 'Qilgan ishlaringiz'
	String get works => 'Qilgan ishlaringiz';

	/// uz: 'Rasm qo'shsangiz mijoz ishingizni ko'radi va sizni tanlash ehtimoli ortadi. Ixtiyoriy — keyin ham qo'shsa bo'ladi.'
	String get worksHint => 'Rasm qo\'shsangiz mijoz ishingizni ko\'radi va sizni tanlash ehtimoli ortadi. Ixtiyoriy — keyin ham qo\'shsa bo\'ladi.';

	/// uz: 'Namunani o'chirasizmi?'
	String get deleteSampleTitle => 'Namunani o\'chirasizmi?';

	/// uz: 'Bu rasm mijozlarga ko'rinmay qoladi.'
	String get deleteSampleMessage => 'Bu rasm mijozlarga ko\'rinmay qoladi.';

	/// uz: 'O'chirilmadi'
	String get deleteFailed => 'O\'chirilmadi';

	/// uz: 'Kamida bitta yo'nalish tanlang'
	String get pickSpecialty => 'Kamida bitta yo\'nalish tanlang';

	/// uz: 'Bir nechtasini tanlashingiz mumkin — buyurtma faqat shu yo'nalishlar bo'yicha keladi.'
	String get specialtyHint => 'Bir nechtasini tanlashingiz mumkin — buyurtma faqat shu yo\'nalishlar bo\'yicha keladi.';
}

// Path: appUpdate
class TranslationsAppUpdateUz {
	TranslationsAppUpdateUz.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// uz: 'YANGILANISH'
	String get eyebrow => 'YANGILANISH';

	/// uz: 'Yangi versiya tayyor'
	String get titleOptional => 'Yangi versiya tayyor';

	/// uz: 'Yangilash talab qilinadi'
	String get titleRequired => 'Yangilash talab qilinadi';

	/// uz: 'Ustachi Pro'ning yangi versiyasi chiqdi. Yangilasangiz oxirgi tuzatish va imkoniyatlar bilan ishlaysiz.'
	String get bodyOptional => 'Ustachi Pro\'ning yangi versiyasi chiqdi. Yangilasangiz oxirgi tuzatish va imkoniyatlar bilan ishlaysiz.';

	/// uz: 'Bu versiya endi qo'llab-quvvatlanmaydi. Ilovadan foydalanishni davom ettirish uchun yangilang.'
	String get bodyRequired => 'Bu versiya endi qo\'llab-quvvatlanmaydi. Ilovadan foydalanishni davom ettirish uchun yangilang.';

	/// uz: 'NIMA YANGILANDI'
	String get whatsNew => 'NIMA YANGILANDI';

	/// uz: 'Sizda'
	String get versionFrom => 'Sizda';

	/// uz: 'Yangi'
	String get versionTo => 'Yangi';

	/// uz: 'Yangilash'
	String get update => 'Yangilash';

	/// uz: 'Keyinroq'
	String get later => 'Keyinroq';

	/// uz: 'Havolani ochib bo'lmadi. Ilovani do'kondan qo'lda yangilang.'
	String get openFailed => 'Havolani ochib bo\'lmadi. Ilovani do\'kondan qo\'lda yangilang.';
}

// Path: onboarding.step1
class TranslationsOnboardingStep1Uz {
	TranslationsOnboardingStep1Uz.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// uz: 'O'z yo'nalishingizni tanlang'
	String get title => 'O\'z yo\'nalishingizni tanlang';

	/// uz: 'Rom, tom, g'isht, elektrik, santexnik, kafel, bo'yoq… 25 dan ortiq yo'nalish. Qaysi ishni qilsangiz, o'sha buyurtmalar keladi.'
	String get description => 'Rom, tom, g\'isht, elektrik, santexnik, kafel, bo\'yoq… 25 dan ortiq yo\'nalish. Qaysi ishni qilsangiz, o\'sha buyurtmalar keladi.';
}

// Path: onboarding.step2
class TranslationsOnboardingStep2Uz {
	TranslationsOnboardingStep2Uz.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// uz: 'Buyurtma o'zi topib keladi'
	String get title => 'Buyurtma o\'zi topib keladi';

	/// uz: 'Hududingiz va yo'nalishingizga mos yangi e'lonlar darhol bildirishnoma bo'lib keladi — qidirib yurmaysiz.'
	String get description => 'Hududingiz va yo\'nalishingizga mos yangi e\'lonlar darhol bildirishnoma bo\'lib keladi — qidirib yurmaysiz.';
}

// Path: onboarding.step3
class TranslationsOnboardingStep3Uz {
	TranslationsOnboardingStep3Uz.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// uz: 'Narxni o'zingiz belgilaysiz'
	String get title => 'Narxni o\'zingiz belgilaysiz';

	/// uz: 'O'z narxlaringizni kiritasiz, mijoz bilan chatda kelishasiz va ish bosqichlarini belgilab borasiz.'
	String get description => 'O\'z narxlaringizni kiritasiz, mijoz bilan chatda kelishasiz va ish bosqichlarini belgilab borasiz.';
}

// Path: auth.common
class TranslationsAuthCommonUz {
	TranslationsAuthCommonUz.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// uz: 'Telefon raqamini to'g'ri kiriting'
	String get invalidPhone => 'Telefon raqamini to\'g\'ri kiriting';

	/// uz: 'Bekor qilish'
	String get cancel => 'Bekor qilish';
}

// Path: auth.phone
class TranslationsAuthPhoneUz {
	TranslationsAuthPhoneUz.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// uz: 'Ilovaga kirish'
	String get title => 'Ilovaga kirish';

	/// uz: 'Raqamingizni kiriting — SMS orqali 6 xonali kod yuboramiz. Parol kerak emas.'
	String get subtitle => 'Raqamingizni kiriting — SMS orqali 6 xonali kod yuboramiz. Parol kerak emas.';

	/// uz: 'Telefon raqam'
	String get label => 'Telefon raqam';

	/// uz: 'Davom etish'
	String get continueBtn => 'Davom etish';

	/// uz: 'yoki'
	String get orOption => 'yoki';

	/// uz: 'Telegram orqali kirish'
	String get telegramBtn => 'Telegram orqali kirish';

	/// uz: 'Bot Telegram hisobingizdagi raqamni kirish uchun so'raydi. SMS yuborilmaydi.'
	String get telegramHint => 'Bot Telegram hisobingizdagi raqamni kirish uchun so\'raydi. SMS yuborilmaydi.';

	/// uz: 'Telegram botni ochib bo'lmadi. Qayta urinib ko'ring.'
	String get telegramOpenError => 'Telegram botni ochib bo\'lmadi. Qayta urinib ko\'ring.';

	/// uz: 'Davom etish orqali siz '
	String get agreementPrefix => 'Davom etish orqali siz ';

	/// uz: 'Foydalanish shartlari'
	String get terms => 'Foydalanish shartlari';

	/// uz: ' va '
	String get and => ' va ';

	/// uz: 'Maxfiylik siyosati'
	String get privacy => 'Maxfiylik siyosati';

	/// uz: 'ga rozilik bildirasiz.'
	String get agreementSuffix => 'ga rozilik bildirasiz.';

	/// uz: 'Usta qidirayotgan bo'lsangiz — «Ustachi» ni yuklang'
	String get audienceRedirect => 'Usta qidirayotgan bo\'lsangiz — «Ustachi» ni yuklang';

	/// uz: 'Diqqat: bu ilova ustalar uchun'
	String get audienceTitle => 'Diqqat: bu ilova ustalar uchun';
}

// Path: auth.otp
class TranslationsAuthOtpUz {
	TranslationsAuthOtpUz.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// uz: 'Kodni kiriting'
	String get title => 'Kodni kiriting';

	/// uz: '${phone} raqamiga yuborilgan 6 xonali kodni kiriting'
	String sentMessage({required Object phone}) => '${phone} raqamiga yuborilgan 6 xonali kodni kiriting';

	/// uz: '6 xonali kodni to'liq kiriting'
	String get invalidCode => '6 xonali kodni to\'liq kiriting';

	/// uz: 'Kodni qayta yuborish'
	String get resend => 'Kodni qayta yuborish';

	/// uz: 'Qayta yuborish'
	String get resendIn => 'Qayta yuborish';

	/// uz: 'Tasdiqlash'
	String get confirmBtn => 'Tasdiqlash';

	/// uz: 'Boshqa raqam kiritish'
	String get changeNumber => 'Boshqa raqam kiritish';
}

// Path: auth.profile
class TranslationsAuthProfileUz {
	TranslationsAuthProfileUz.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// uz: 'O'zingiz haqingizda'
	String get title => 'O\'zingiz haqingizda';

	/// uz: 'Mijozlar sizni shu nom bilan ko'radi. Keyinroq profilingizdan o'zgartirasiz.'
	String get subtitle => 'Mijozlar sizni shu nom bilan ko\'radi. Keyinroq profilingizdan o\'zgartirasiz.';

	/// uz: 'Ism familiya'
	String get fullNameLabel => 'Ism familiya';

	/// uz: 'Kiriting'
	String get fullNameHint => 'Kiriting';

	/// uz: 'Ism familiyangizni kiriting'
	String get requiredName => 'Ism familiyangizni kiriting';

	/// uz: 'Rasm qo'shish'
	String get addPhoto => 'Rasm qo\'shish';

	/// uz: 'Rasmni almashtirish'
	String get changePhoto => 'Rasmni almashtirish';

	/// uz: 'Saqlash va davom etish'
	String get saveBtn => 'Saqlash va davom etish';

	/// uz: 'Keyinroq to'ldiraman'
	String get skip => 'Keyinroq to\'ldiraman';

	/// uz: 'Viloyat'
	String get regionLabel => 'Viloyat';

	/// uz: 'Viloyatni tanlang'
	String get regionHint => 'Viloyatni tanlang';

	/// uz: 'Tuman / shahar'
	String get districtLabel => 'Tuman / shahar';

	/// uz: 'Tumanni tanlang'
	String get districtHint => 'Tumanni tanlang';

	/// uz: 'Manzil'
	String get addressLabel => 'Manzil';

	/// uz: 'Ko'cha, uy raqami'
	String get addressHint => 'Ko\'cha, uy raqami';

	/// uz: 'Viloyatni tanlang'
	String get requiredRegion => 'Viloyatni tanlang';

	/// uz: 'Tumanni tanlang'
	String get requiredDistrict => 'Tumanni tanlang';

	/// uz: 'Ro'yxatni yuklab bo'lmadi'
	String get loadFailed => 'Ro\'yxatni yuklab bo\'lmadi';
}

// Path: auth.telegram
class TranslationsAuthTelegramUz {
	TranslationsAuthTelegramUz.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// uz: 'Telegram orqali kirilmoqda'
	String get loadingTitle => 'Telegram orqali kirilmoqda';

	/// uz: 'Bir martalik havola tekshirilmoqda…'
	String get loadingHint => 'Bir martalik havola tekshirilmoqda…';

	/// uz: 'Telegram havolasi yaroqsiz.'
	String get invalidLink => 'Telegram havolasi yaroqsiz.';

	/// uz: 'Havola muddati tugagan yoki avval ishlatilgan. Botda qayta boshlang.'
	String get expiredLink => 'Havola muddati tugagan yoki avval ishlatilgan. Botda qayta boshlang.';

	/// uz: 'Qayta urinish'
	String get retry => 'Qayta urinish';

	/// uz: 'Botda qayta boshlash'
	String get restartBot => 'Botda qayta boshlash';

	/// uz: 'SMS orqali kirish'
	String get smsOption => 'SMS orqali kirish';
}

// Path: profile.personal
class TranslationsProfilePersonalUz {
	TranslationsProfilePersonalUz.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// uz: 'Shaxsiy'
	String get sectionPersonal => 'Shaxsiy';

	/// uz: 'Manzil'
	String get sectionAddress => 'Manzil';

	/// uz: 'Kasbiy'
	String get sectionProfessional => 'Kasbiy';

	/// uz: 'Telefon'
	String get phoneLabel => 'Telefon';

	/// uz: 'Raqam — hisob identifikatori, o'zgartirilmaydi'
	String get phoneNote => 'Raqam — hisob identifikatori, o\'zgartirilmaydi';

	/// uz: 'Ro'yxatdan o'tgan'
	String get joinedLabel => 'Ro\'yxatdan o\'tgan';

	/// uz: 'Kiritilmagan'
	String get empty => 'Kiritilmagan';

	/// uz: 'Tahrirlash'
	String get edit => 'Tahrirlash';

	/// uz: 'Yo'nalish, tajriba va ish namunalari'
	String get openProfessional => 'Yo\'nalish, tajriba va ish namunalari';

	/// uz: 'Ma'lumotni yuklab bo'lmadi'
	String get loadFailed => 'Ma\'lumotni yuklab bo\'lmadi';
}

// Path: profile.help
class TranslationsProfileHelpUz {
	TranslationsProfileHelpUz.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// uz: 'Savol yoki muammo bo'lsa — yozing yoki qo'ng'iroq qiling'
	String get subtitle => 'Savol yoki muammo bo\'lsa — yozing yoki qo\'ng\'iroq qiling';

	/// uz: 'Qo'ng'iroq qilish'
	String get callLabel => 'Qo\'ng\'iroq qilish';

	/// uz: 'Elektron pochta'
	String get emailLabel => 'Elektron pochta';

	/// uz: 'Telegram kanalimiz'
	String get telegramLabel => 'Telegram kanalimiz';

	/// uz: 'Yangiliklar va e'lonlar'
	String get telegramHint => 'Yangiliklar va e\'lonlar';

	/// uz: 'Dushanba–shanba, 9:00–19:00'
	String get workHours => 'Dushanba–shanba, 9:00–19:00';

	/// uz: 'Nusxalandi'
	String get copied => 'Nusxalandi';
}

// Path: orders.stage
class TranslationsOrdersStageUz {
	TranslationsOrdersStageUz.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// uz: 'Taklif qabul qilindi'
	String get accepted => 'Taklif qabul qilindi';

	/// uz: 'O'lchov olindi'
	String get measured => 'O\'lchov olindi';

	/// uz: 'Ishlab chiqarish'
	String get production => 'Ishlab chiqarish';

	/// uz: 'O'rnatish'
	String get installation => 'O\'rnatish';

	/// uz: 'Topshirish va to'lov'
	String get handover => 'Topshirish va to\'lov';
}

// Path: orders.detail
class TranslationsOrdersDetailUz {
	TranslationsOrdersDetailUz.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// uz: 'Bosqichlar'
	String get stages => 'Bosqichlar';

	/// uz: 'Spetsifikatsiya'
	String get spec => 'Spetsifikatsiya';

	/// uz: 'Mijoz'
	String get client => 'Mijoz';

	/// uz: 'Jami'
	String get total => 'Jami';

	/// uz: 'Oldindan to'lov'
	String get prepaid => 'Oldindan to\'lov';

	/// uz: 'Qoldiq'
	String get remaining => 'Qoldiq';

	/// uz: 'Kelishilgan muddat'
	String get dueDate => 'Kelishilgan muddat';

	/// uz: 'Topshirish va yakunlash'
	String get finishOrder => 'Topshirish va yakunlash';

	/// uz: 'Buyurtma yakunlandi'
	String get completed => 'Buyurtma yakunlandi';

	/// uz: '${stage} yakunlandi'
	String stageDone({required Object stage}) => '${stage} yakunlandi';

	/// uz: 'Buyurtma topilmadi'
	String get notFound => 'Buyurtma topilmadi';

	/// uz: 'Chizmalar'
	String get drawings => 'Chizmalar';

	/// uz: 'Ikki barmoq bilan kattalashtiring · o'lchamlar mm da'
	String get drawingsHint => 'Ikki barmoq bilan kattalashtiring · o\'lchamlar mm da';

	/// uz: 'O'lchov olindi'
	String get markMeasured => 'O\'lchov olindi';

	/// uz: 'Ishlab chiqarish boshlandi'
	String get markProduction => 'Ishlab chiqarish boshlandi';

	/// uz: 'O'rnatishga chiqdik'
	String get markInstallation => 'O\'rnatishga chiqdik';

	/// uz: 'Belgilandi — mijozga xabar ketdi'
	String get stageSaved => 'Belgilandi — mijozga xabar ketdi';
}

// Path: orders.request
class TranslationsOrdersRequestUz {
	TranslationsOrdersRequestUz.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// uz: 'So'rov'
	String get title => 'So\'rov';

	/// uz: 'Mijoz hisoblagan spetsifikatsiya'
	String get clientSpec => 'Mijoz hisoblagan spetsifikatsiya';

	/// uz: 'Narx taklifi'
	String get priceOffer => 'Narx taklifi';

	/// uz: 'Montaj va olib borish'
	String get serviceFee => 'Montaj va olib borish';

	/// uz: 'Sizning taklifingiz'
	String get yourOffer => 'Sizning taklifingiz';

	/// uz: 'Muddat — ish kuni'
	String get workDays => 'Muddat — ish kuni';

	/// uz: 'Izoh (ixtiyoriy)'
	String get note => 'Izoh (ixtiyoriy)';

	/// uz: 'Mijozga qo'shimcha izoh…'
	String get notePlaceholder => 'Mijozga qo\'shimcha izoh…';

	/// uz: 'Taklifni yuborish'
	String get send => 'Taklifni yuborish';

	/// uz: 'Rad etish'
	String get decline => 'Rad etish';

	/// uz: 'So'rovni rad etasizmi?'
	String get declineTitle => 'So\'rovni rad etasizmi?';

	/// uz: 'Bu so'rov ro'yxatdan butunlay o'chadi.'
	String get declineMessage => 'Bu so\'rov ro\'yxatdan butunlay o\'chadi.';

	/// uz: '${time} qoldi'
	String expiresIn({required Object time}) => '${time} qoldi';

	/// uz: 'Muddati o'tdi'
	String get expired => 'Muddati o\'tdi';

	/// uz: '${km} km'
	String distance({required Object km}) => '${km} km';

	/// uz: 'Taklif yuborildi'
	String get sent => 'Taklif yuborildi';

	/// uz: 'Ish haqi manfiy bo'lishi mumkin emas'
	String get invalidFee => 'Ish haqi manfiy bo\'lishi mumkin emas';

	/// uz: 'Narx va shartni mijoz bilan chatda kelishasiz.'
	String get chatNote => 'Narx va shartni mijoz bilan chatda kelishasiz.';

	/// uz: 'Taklifni qaytarib olish'
	String get withdrawOffer => 'Taklifni qaytarib olish';

	/// uz: 'Taklifni rad etasizmi?'
	String get declineInviteTitle => 'Taklifni rad etasizmi?';

	/// uz: 'Mijozga darhol xabar boradi va u boshqa usta tanlaydi.'
	String get declineInviteMessage => 'Mijozga darhol xabar boradi va u boshqa usta tanlaydi.';

	/// uz: 'Buyurtma narxi'
	String get clientPrice => 'Buyurtma narxi';

	/// uz: 'Narx chatda kelishiladi'
	String get priceInChat => 'Narx chatda kelishiladi';
}

// Path: orders.spec
class TranslationsOrdersSpecUz {
	TranslationsOrdersSpecUz.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// uz: 'O'lcham (mm)'
	String get size => 'O\'lcham (mm)';

	/// uz: 'Shakl'
	String get shape => 'Shakl';

	/// uz: 'Brend'
	String get brand => 'Brend';

	/// uz: 'Rang'
	String get color => 'Rang';

	/// uz: 'Material'
	String get material => 'Material';

	/// uz: 'Oyna'
	String get glass => 'Oyna';

	/// uz: 'Tokcha (sm)'
	String get sill => 'Tokcha (sm)';

	/// uz: 'Gul'
	String get flower => 'Gul';

	/// uz: 'Manzil'
	String get address => 'Manzil';

	/// uz: 'Mahsulot'
	String get product => 'Mahsulot';

	/// uz: 'Telefon'
	String get phone => 'Telefon';

	/// uz: 'Chegirma'
	String get discount => 'Chegirma';

	/// uz: 'Izoh'
	String get note => 'Izoh';

	/// uz: '${kinds} xil · ${count} dona'
	String itemsValue({required Object kinds, required Object count}) => '${kinds} xil · ${count} dona';

	late final TranslationsOrdersSpecValuesUz values = TranslationsOrdersSpecValuesUz.internal(_root);

	/// uz: 'Maydon'
	String get area => 'Maydon';

	/// uz: '1 m² narxi'
	String get unitPrice => '1 m² narxi';

	/// uz: 'Daraja'
	String get variant => 'Daraja';
}

// Path: orders.open
class TranslationsOrdersOpenUz {
	TranslationsOrdersOpenUz.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// uz: 'Taklif yuborildi'
	String get offerSent => 'Taklif yuborildi';

	/// uz: 'Mijoz javobini kutmoqda'
	String get waitingClient => 'Mijoz javobini kutmoqda';

	/// uz: '${count} ta taklif'
	String offersCount({required Object count}) => '${count} ta taklif';

	/// uz: 'Birinchi bo'ling'
	String get beFirst => 'Birinchi bo\'ling';

	/// uz: 'Yangi'
	String get newBadge => 'Yangi';

	/// uz: 'Ochiq buyurtmalar'
	String get pageTitle => 'Ochiq buyurtmalar';

	/// uz: 'Javob kutmoqda'
	String get tabWaiting => 'Javob kutmoqda';

	/// uz: 'Taklif berilgan'
	String get tabSent => 'Taklif berilgan';

	/// uz: 'Yuborilgan taklif yo'q'
	String get emptySentTitle => 'Yuborilgan taklif yo\'q';

	/// uz: 'Taklif bergan e'lonlaringiz shu yerda mijoz javobini kutib turadi.'
	String get emptySentMessage => 'Taklif bergan e\'lonlaringiz shu yerda mijoz javobini kutib turadi.';

	/// uz: 'Sizga taklif'
	String get tabInvited => 'Sizga taklif';

	/// uz: 'Sizga taklif'
	String get invitedBadge => 'Sizga taklif';

	/// uz: 'Ta'mir'
	String get repairBadge => 'Ta\'mir';

	/// uz: 'Qabul qilaman'
	String get acceptInvite => 'Qabul qilaman';

	/// uz: 'Shaxsiy taklif yo'q'
	String get emptyInvitedTitle => 'Shaxsiy taklif yo\'q';

	/// uz: 'Mijoz sizni tanlab yuborgan buyurtmalar shu yerda ko'rinadi.'
	String get emptyInvitedMessage => 'Mijoz sizni tanlab yuborgan buyurtmalar shu yerda ko\'rinadi.';

	/// uz: 'Bu buyurtmani mijoz AYNAN sizga yubordi — boshqa ustalar ko'rmaydi.'
	String get invitedNote => 'Bu buyurtmani mijoz AYNAN sizga yubordi — boshqa ustalar ko\'rmaydi.';
}

// Path: ownOrders.status
class TranslationsOwnOrdersStatusUz {
	TranslationsOwnOrdersStatusUz.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// uz: 'Qoralama'
	String get draft => 'Qoralama';

	/// uz: 'Yangi'
	String get newOrder => 'Yangi';

	/// uz: 'Jarayonda'
	String get inProgress => 'Jarayonda';

	/// uz: 'Yakunlangan'
	String get done => 'Yakunlangan';

	/// uz: 'Qarzdor'
	String get debt => 'Qarzdor';

	/// uz: 'Bekor qilingan'
	String get cancelled => 'Bekor qilingan';
}

// Path: ownOrders.hint
class TranslationsOwnOrdersHintUz {
	TranslationsOwnOrdersHintUz.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// uz: 'Qabul qilindi, hali boshlanmagan'
	String get newOrder => 'Qabul qilindi, hali boshlanmagan';

	/// uz: 'Ishlab chiqarish yoki o'rnatish ketyapti'
	String get inProgress => 'Ishlab chiqarish yoki o\'rnatish ketyapti';

	/// uz: 'Topshirildi va to'liq hisob-kitob qilindi'
	String get done => 'Topshirildi va to\'liq hisob-kitob qilindi';

	/// uz: 'Ish tugadi, lekin pul to'liq olinmagan'
	String get debt => 'Ish tugadi, lekin pul to\'liq olinmagan';

	/// uz: 'Buyurtma bekor qilindi'
	String get cancelled => 'Buyurtma bekor qilindi';
}

// Path: orderFlow.status
class TranslationsOrderFlowStatusUz {
	TranslationsOrderFlowStatusUz.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// uz: 'E'lon qilingan'
	String get published => 'E\'lon qilingan';

	/// uz: 'Usta tanlangan'
	String get assigned => 'Usta tanlangan';

	/// uz: 'Yakunlangan'
	String get completed => 'Yakunlangan';

	/// uz: 'Bekor qilingan'
	String get cancelled => 'Bekor qilingan';

	/// uz: 'Muddati o'tgan'
	String get expired => 'Muddati o\'tgan';
}

// Path: orderFlow.stage
class TranslationsOrderFlowStageUz {
	TranslationsOrderFlowStageUz.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// uz: 'Qabul qilindi'
	String get accepted => 'Qabul qilindi';

	/// uz: 'O'lchov olindi'
	String get measured => 'O\'lchov olindi';

	/// uz: 'Ishlab chiqarish'
	String get production => 'Ishlab chiqarish';

	/// uz: 'O'rnatish'
	String get installation => 'O\'rnatish';

	/// uz: 'Topshirildi'
	String get handover => 'Topshirildi';
}

// Path: orderFlow.response
class TranslationsOrderFlowResponseUz {
	TranslationsOrderFlowResponseUz.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// uz: 'Qabul qilaman'
	String get interested => 'Qabul qilaman';

	/// uz: 'Voz kechdi'
	String get withdrawn => 'Voz kechdi';

	/// uz: 'Tanlandi'
	String get chosen => 'Tanlandi';

	/// uz: 'Tanlanmadi'
	String get rejected => 'Tanlanmadi';
}

// Path: orders.spec.values
class TranslationsOrdersSpecValuesUz {
	TranslationsOrdersSpecValuesUz.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// uz: 'Plastik'
	String get plastic => 'Plastik';

	/// uz: 'Alumin'
	String get aluminium => 'Alumin';

	/// uz: 'Termo'
	String get termo => 'Termo';

	/// uz: 'Ikki qavat'
	String get doubleGlass => 'Ikki qavat';

	/// uz: 'Bir qavat'
	String get singleGlass => 'Bir qavat';

	/// uz: 'Katta'
	String get large => 'Katta';

	/// uz: 'O'rta'
	String get medium => 'O\'rta';

	/// uz: 'Kichik'
	String get small => 'Kichik';
}

/// The flat map containing all translations for locale <uz>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on Translations {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'applicationName' => 'Ustachi',
			'common.ok' => 'OK',
			'common.start' => 'Boshlash',
			'common.cancel' => 'Bekor qilish',
			'common.save' => 'Saqlash',
			'common.delete' => 'O\'chirish',
			'common.edit' => 'Tahrirlash',
			'common.close' => 'Yopish',
			'common.back' => 'Orqaga',
			'common.next' => 'Keyingi',
			'common.skip' => 'O\'tkazib yuborish',
			'common.enter' => 'Kiriting',
			'common.wentWrong' => 'Xatolik yuz berdi. Iltimos birozdan so\'ng qayta urining!',
			'common.common' => 'Asosiy',
			'common.select' => 'Tanlash',
			'common.retry' => 'Qayta urinish',
			'common.refresh' => 'Yangilash',
			'common.saved' => 'Saqlandi',
			'common.saveFailed' => 'Saqlanmadi — qayta urinib ko\'ring',
			'common.notFound' => 'Topilmadi',
			'common.empty' => 'Bo\'sh',
			'common.loading' => 'Yuklanmoqda…',
			'common.yes' => 'Ha',
			'common.no' => 'Yo\'q',
			'common.add' => 'Qo\'shish',
			'common.copy' => 'Nusxalash',
			'common.apply' => 'Qo\'llash',
			'common.reset' => 'Qaytarish',
			'common.done' => 'Tayyor',
			'common.all' => 'Hammasi',
			'common.som' => 'so\'m',
			'common.cm' => 'sm',
			'common.mm' => 'mm',
			'common.pcs' => 'dona',
			'common.hoursShort' => 'soat',
			'common.minutesShort' => 'daq',
			'common.months.0' => 'yanvar',
			'common.months.1' => 'fevral',
			'common.months.2' => 'mart',
			'common.months.3' => 'aprel',
			'common.months.4' => 'may',
			'common.months.5' => 'iyun',
			'common.months.6' => 'iyul',
			'common.months.7' => 'avgust',
			'common.months.8' => 'sentabr',
			'common.months.9' => 'oktabr',
			'common.months.10' => 'noyabr',
			'common.months.11' => 'dekabr',
			'common.weekdays.0' => 'Yakshanba',
			'common.weekdays.1' => 'Dushanba',
			'common.weekdays.2' => 'Seshanba',
			'common.weekdays.3' => 'Chorshanba',
			'common.weekdays.4' => 'Payshanba',
			'common.weekdays.5' => 'Juma',
			'common.weekdays.6' => 'Shanba',
			'common.today' => 'Bugun',
			'common.tomorrow' => 'Ertaga',
			'common.comingSoon' => 'Tez kunda',
			'onboarding.step1.title' => 'O\'z yo\'nalishingizni tanlang',
			'onboarding.step1.description' => 'Rom, tom, g\'isht, elektrik, santexnik, kafel, bo\'yoq… 25 dan ortiq yo\'nalish. Qaysi ishni qilsangiz, o\'sha buyurtmalar keladi.',
			'onboarding.step2.title' => 'Buyurtma o\'zi topib keladi',
			'onboarding.step2.description' => 'Hududingiz va yo\'nalishingizga mos yangi e\'lonlar darhol bildirishnoma bo\'lib keladi — qidirib yurmaysiz.',
			'onboarding.step3.title' => 'Narxni o\'zingiz belgilaysiz',
			'onboarding.step3.description' => 'O\'z narxlaringizni kiritasiz, mijoz bilan chatda kelishasiz va ish bosqichlarini belgilab borasiz.',
			'auth.tagline' => 'USTANING ISH MAYDONI',
			'auth.common.invalidPhone' => 'Telefon raqamini to\'g\'ri kiriting',
			'auth.common.cancel' => 'Bekor qilish',
			'auth.phone.title' => 'Ilovaga kirish',
			'auth.phone.subtitle' => 'Raqamingizni kiriting — SMS orqali 6 xonali kod yuboramiz. Parol kerak emas.',
			'auth.phone.label' => 'Telefon raqam',
			'auth.phone.continueBtn' => 'Davom etish',
			'auth.phone.orOption' => 'yoki',
			'auth.phone.telegramBtn' => 'Telegram orqali kirish',
			'auth.phone.telegramHint' => 'Bot Telegram hisobingizdagi raqamni kirish uchun so\'raydi. SMS yuborilmaydi.',
			'auth.phone.telegramOpenError' => 'Telegram botni ochib bo\'lmadi. Qayta urinib ko\'ring.',
			'auth.phone.agreementPrefix' => 'Davom etish orqali siz ',
			'auth.phone.terms' => 'Foydalanish shartlari',
			'auth.phone.and' => ' va ',
			'auth.phone.privacy' => 'Maxfiylik siyosati',
			'auth.phone.agreementSuffix' => 'ga rozilik bildirasiz.',
			'auth.phone.audienceRedirect' => 'Usta qidirayotgan bo\'lsangiz — «Ustachi» ni yuklang',
			'auth.phone.audienceTitle' => 'Diqqat: bu ilova ustalar uchun',
			'auth.otp.title' => 'Kodni kiriting',
			'auth.otp.sentMessage' => ({required Object phone}) => '${phone} raqamiga yuborilgan 6 xonali kodni kiriting',
			'auth.otp.invalidCode' => '6 xonali kodni to\'liq kiriting',
			'auth.otp.resend' => 'Kodni qayta yuborish',
			'auth.otp.resendIn' => 'Qayta yuborish',
			'auth.otp.confirmBtn' => 'Tasdiqlash',
			'auth.otp.changeNumber' => 'Boshqa raqam kiritish',
			'auth.profile.title' => 'O\'zingiz haqingizda',
			'auth.profile.subtitle' => 'Mijozlar sizni shu nom bilan ko\'radi. Keyinroq profilingizdan o\'zgartirasiz.',
			'auth.profile.fullNameLabel' => 'Ism familiya',
			'auth.profile.fullNameHint' => 'Kiriting',
			'auth.profile.requiredName' => 'Ism familiyangizni kiriting',
			'auth.profile.addPhoto' => 'Rasm qo\'shish',
			'auth.profile.changePhoto' => 'Rasmni almashtirish',
			'auth.profile.saveBtn' => 'Saqlash va davom etish',
			'auth.profile.skip' => 'Keyinroq to\'ldiraman',
			'auth.profile.regionLabel' => 'Viloyat',
			'auth.profile.regionHint' => 'Viloyatni tanlang',
			'auth.profile.districtLabel' => 'Tuman / shahar',
			'auth.profile.districtHint' => 'Tumanni tanlang',
			'auth.profile.addressLabel' => 'Manzil',
			'auth.profile.addressHint' => 'Ko\'cha, uy raqami',
			'auth.profile.requiredRegion' => 'Viloyatni tanlang',
			'auth.profile.requiredDistrict' => 'Tumanni tanlang',
			'auth.profile.loadFailed' => 'Ro\'yxatni yuklab bo\'lmadi',
			'auth.telegram.loadingTitle' => 'Telegram orqali kirilmoqda',
			'auth.telegram.loadingHint' => 'Bir martalik havola tekshirilmoqda…',
			'auth.telegram.invalidLink' => 'Telegram havolasi yaroqsiz.',
			'auth.telegram.expiredLink' => 'Havola muddati tugagan yoki avval ishlatilgan. Botda qayta boshlang.',
			'auth.telegram.retry' => 'Qayta urinish',
			'auth.telegram.restartBot' => 'Botda qayta boshlash',
			'auth.telegram.smsOption' => 'SMS orqali kirish',
			'country.title' => 'Davlatni tanlang',
			'country.subtitle' => 'Ilova tili shu davlatga qarab tanlanadi. Keyinroq profilingizdan o‘zgartirishingiz mumkin.',
			'country.continueBtn' => 'Davom etish',
			'country.changeTitle' => 'Davlat va til',
			'home.main' => 'Asosiy',
			'home.chatting' => 'Chat',
			'home.profile' => 'Profil',
			'home.title' => 'Profil',
			'home.loadError' => 'Profil yuklanmadi',
			'home.retry' => 'Qayta urinish',
			'home.phone' => 'Telefon',
			'home.role' => 'Rol',
			'home.status' => 'Holat',
			'home.active' => 'Faol',
			'home.inactive' => 'Nofaol',
			'home.logout' => 'Chiqish',
			'home.hi' => 'Salom',
			'home.serviceType' => 'Xizmat turlari',
			'home.lastOrders' => 'Oxirgi buyurtmalar',
			'home.all' => 'Hammasi',
			'home.tapRepair' => 'Kran ta\'mirlash',
			'home.chandelierInstallation' => 'Lyustra o\'rnatish',
			'home.completed' => 'Bajarildi',
			'home.inProgress' => 'Jarayonda',
			'home.window' => 'Rom',
			'home.furtiniture' => 'Mebel',
			'home.electric' => 'Elektrika',
			'home.plumber' => 'Santexnika',
			'calculatePage.window' => 'Deraza',
			'calculatePage.door' => 'Eshik',
			'calculatePage.glass' => 'Arkalar',
			'calculatePage.windowConfigurator' => 'Deraza konfiguratsiyasi',
			'calculatePage.windowLayouts' => 'Bo\'linma turlari',
			'calculatePage.windowPremiumLayouts' => 'Premium variantlar',
			'calculatePage.windowModernLayouts' => 'Zamonaviy variantlar',
			'calculatePage.doorConfigurator' => 'Eshik konfiguratsiyasi',
			'calculatePage.doorModels' => 'Eshik modellari',
			'calculatePage.doorExtraModels' => 'Qo\'shimcha modellari',
			'calculatePage.material' => 'Material',
			'calculatePage.plastic' => 'Plastik',
			'calculatePage.aluminium' => 'Alyumin',
			'calculatePage.termo' => 'Termo',
			'calculatePage.glassShowcase' => 'Arkalar variantlari',
			'calculatePage.customTemplateTitleWindow' => 'O\'z derazangizni yasang',
			'calculatePage.customTemplateTitleDoor' => 'O\'z eshigingizni yasang',
			'calculatePage.customTemplateTitleArch' => 'O\'z arkangizni yasang',
			'calculatePage.customTemplateSubtitle' => 'Tayyor shablon emas — o\'lcham va bo\'linmani o\'zingiz chizasiz',
			'calculatePage.customTemplateAction' => 'Boshlash',
			'calculatePage.readyTemplates' => 'Tayyor shablonlar',
			'profile.personalData' => 'Shaxsiy ma\'lumotlar',
			'profile.professional' => 'Kasbiy ma\'lumot',
			'profile.company' => 'Korxona',
			'profile.myOrders' => 'Mening buyurtmalarim',
			'profile.settings' => 'Sozlamalar',
			'profile.support' => 'Biz bilan aloqa',
			'profile.logout' => 'Chiqish',
			'profile.logoutTitle' => 'Hisobdan chiqasizmi?',
			'profile.logoutMessage' => 'Yuklab olingan narxlar va hisob-kitob ma\'lumotlari qurilmadan o\'chiriladi. Qayta kirganingizda ular yangidan yuklab olinadi.',
			'profile.logoutConfirm' => 'Ha, chiqaman',
			'profile.loggingOut' => 'Chiqilmoqda...',
			'profile.loggingOutHint' => 'Sessiya yopilib, narxlar keshi tozalanmoqda',
			'profile.logoutFailed' => 'Serverdan chiqib bo\'lmadi, lekin qurilmadagi ma\'lumotlar tozalandi',
			'profile.personal.sectionPersonal' => 'Shaxsiy',
			'profile.personal.sectionAddress' => 'Manzil',
			'profile.personal.sectionProfessional' => 'Kasbiy',
			'profile.personal.phoneLabel' => 'Telefon',
			'profile.personal.phoneNote' => 'Raqam — hisob identifikatori, o\'zgartirilmaydi',
			'profile.personal.joinedLabel' => 'Ro\'yxatdan o\'tgan',
			'profile.personal.empty' => 'Kiritilmagan',
			'profile.personal.edit' => 'Tahrirlash',
			'profile.personal.openProfessional' => 'Yo\'nalish, tajriba va ish namunalari',
			'profile.personal.loadFailed' => 'Ma\'lumotni yuklab bo\'lmadi',
			'profile.help.subtitle' => 'Savol yoki muammo bo\'lsa — yozing yoki qo\'ng\'iroq qiling',
			'profile.help.callLabel' => 'Qo\'ng\'iroq qilish',
			'profile.help.emailLabel' => 'Elektron pochta',
			'profile.help.telegramLabel' => 'Telegram kanalimiz',
			'profile.help.telegramHint' => 'Yangiliklar va e\'lonlar',
			'profile.help.workHours' => 'Dushanba–shanba, 9:00–19:00',
			'profile.help.copied' => 'Nusxalandi',
			'dashboard.title' => 'Ish stoli',
			'dashboard.greetingMorning' => 'Xayrli tong,',
			'dashboard.greetingDay' => 'Xayrli kun,',
			'dashboard.greetingEvening' => 'Xayrli kech,',
			'dashboard.master' => 'usta',
			'dashboard.availableTitle' => 'Buyurtma qabul qilaman',
			'dashboard.availableOn' => 'Yangi so\'rovlar kelaveradi',
			'dashboard.availableOff' => 'So\'rovlar to\'xtatildi',
			'dashboard.repairTitle' => 'Ta\'mirga chiqaman',
			'dashboard.repairOn' => 'Ta\'mir so\'rovlari ham keladi',
			'dashboard.repairOff' => 'Ta\'mir so\'rovlari kelmaydi',
			'dashboard.repairHint' => 'Eski rom-eshikni sozlash, furnitura yoki oyna almashtirish',
			'dashboard.newRequests' => 'Yangi so\'rovlar',
			'dashboard.activeOrders' => 'Faol buyurtmalar',
			'dashboard.all' => 'Barchasi',
			'dashboard.quickCalculate' => 'Rom chizish',
			'dashboard.quickCalculateHint' => 'Deraza va eshik chizmasi',
			'dashboard.quickPortfolio' => 'Ish namunasi',
			'dashboard.quickPortfolioHint' => 'Yakunlangan ishdan qo\'shing',
			'dashboard.emptyRequests' => 'Yangi so\'rov yo\'q',
			'dashboard.emptyRequestsHint' => 'Bandlik tugmasi yoqilgan bo\'lsa, so\'rovlar shu yerga tushadi.',
			'dashboard.quickCompany' => 'Korxona',
			'dashboard.quickCompanyHint' => 'Nom va logotip',
			'dashboard.quickRates' => 'Xizmat narxlarim',
			'dashboard.quickRatesHint' => 'Sohangiz bo\'yicha ish stavkalari',
			'dashboard.quickOrdersHeroTitle' => 'Yangi buyurtmalar va Bozor',
			'dashboard.quickOrdersHeroHint' => 'Sohangizdagi e\'lonlarni ko\'ring va taklif yuboring',
			'dashboard.quickOpenOrders' => 'Ochiq buyurtmalar',
			'dashboard.quickOpenOrdersHint' => 'Usta tanlanmagan e\'lonlar — taklif bering',
			'dashboard.calcStep1' => 'Rom tanlang',
			'dashboard.calcStep2' => 'Sozlang',
			'dashboard.calcStep3' => 'Chizma tayyor',
			'orders.title' => 'Buyurtmalar',
			'orders.segmentNew' => 'Ochiq',
			'orders.segmentActive' => 'Jarayonda',
			'orders.segmentDone' => 'Yakunlangan',
			'orders.stepOf' => ({required Object step, required Object total}) => '${step}-bosqich / ${total}',
			'orders.lateDays' => ({required Object days}) => '${days} kun kechikdi',
			'orders.dueToday' => 'Bugun tugaydi',
			'orders.daysLeft' => ({required Object days}) => '${days} kun qoldi',
			'orders.offerBtn' => 'Taklif ber',
			'orders.retry' => 'Qayta urinish',
			'orders.loadFailed' => 'Buyurtmalarni yuklab bo\'lmadi',
			'orders.emptyNewTitle' => 'Ochiq buyurtma yo\'q',
			'orders.emptyNewMessage' => 'Hududingizda yangi e\'lon paydo bo\'lishi bilan shu yerda ko\'rinadi.',
			'orders.emptyActiveTitle' => 'Faol buyurtma yo\'q',
			'orders.emptyActiveMessage' => 'Yangi so\'rovni qabul qilsangiz, u shu yerda paydo bo\'ladi.',
			'orders.emptyDoneTitle' => 'Yakunlangan ish yo\'q',
			'orders.emptyDoneMessage' => 'Birinchi buyurtmani topshirganingizdan keyin bu yerda ko\'rinadi.',
			'orders.stage.accepted' => 'Taklif qabul qilindi',
			'orders.stage.measured' => 'O\'lchov olindi',
			'orders.stage.production' => 'Ishlab chiqarish',
			'orders.stage.installation' => 'O\'rnatish',
			'orders.stage.handover' => 'Topshirish va to\'lov',
			'orders.detail.stages' => 'Bosqichlar',
			'orders.detail.spec' => 'Spetsifikatsiya',
			'orders.detail.client' => 'Mijoz',
			'orders.detail.total' => 'Jami',
			'orders.detail.prepaid' => 'Oldindan to\'lov',
			'orders.detail.remaining' => 'Qoldiq',
			'orders.detail.dueDate' => 'Kelishilgan muddat',
			'orders.detail.finishOrder' => 'Topshirish va yakunlash',
			'orders.detail.completed' => 'Buyurtma yakunlandi',
			'orders.detail.stageDone' => ({required Object stage}) => '${stage} yakunlandi',
			'orders.detail.notFound' => 'Buyurtma topilmadi',
			'orders.detail.drawings' => 'Chizmalar',
			'orders.detail.drawingsHint' => 'Ikki barmoq bilan kattalashtiring · o\'lchamlar mm da',
			'orders.detail.markMeasured' => 'O\'lchov olindi',
			'orders.detail.markProduction' => 'Ishlab chiqarish boshlandi',
			'orders.detail.markInstallation' => 'O\'rnatishga chiqdik',
			'orders.detail.stageSaved' => 'Belgilandi — mijozga xabar ketdi',
			'orders.request.title' => 'So\'rov',
			'orders.request.clientSpec' => 'Mijoz hisoblagan spetsifikatsiya',
			'orders.request.priceOffer' => 'Narx taklifi',
			'orders.request.serviceFee' => 'Montaj va olib borish',
			'orders.request.yourOffer' => 'Sizning taklifingiz',
			'orders.request.workDays' => 'Muddat — ish kuni',
			'orders.request.note' => 'Izoh (ixtiyoriy)',
			'orders.request.notePlaceholder' => 'Mijozga qo\'shimcha izoh…',
			'orders.request.send' => 'Taklifni yuborish',
			'orders.request.decline' => 'Rad etish',
			'orders.request.declineTitle' => 'So\'rovni rad etasizmi?',
			'orders.request.declineMessage' => 'Bu so\'rov ro\'yxatdan butunlay o\'chadi.',
			'orders.request.expiresIn' => ({required Object time}) => '${time} qoldi',
			'orders.request.expired' => 'Muddati o\'tdi',
			'orders.request.distance' => ({required Object km}) => '${km} km',
			'orders.request.sent' => 'Taklif yuborildi',
			'orders.request.invalidFee' => 'Ish haqi manfiy bo\'lishi mumkin emas',
			'orders.request.chatNote' => 'Narx va shartni mijoz bilan chatda kelishasiz.',
			'orders.request.withdrawOffer' => 'Taklifni qaytarib olish',
			'orders.request.declineInviteTitle' => 'Taklifni rad etasizmi?',
			'orders.request.declineInviteMessage' => 'Mijozga darhol xabar boradi va u boshqa usta tanlaydi.',
			'orders.request.clientPrice' => 'Buyurtma narxi',
			'orders.request.priceInChat' => 'Narx chatda kelishiladi',
			'orders.spec.size' => 'O\'lcham (mm)',
			'orders.spec.shape' => 'Shakl',
			'orders.spec.brand' => 'Brend',
			'orders.spec.color' => 'Rang',
			'orders.spec.material' => 'Material',
			'orders.spec.glass' => 'Oyna',
			'orders.spec.sill' => 'Tokcha (sm)',
			'orders.spec.flower' => 'Gul',
			'orders.spec.address' => 'Manzil',
			'orders.spec.product' => 'Mahsulot',
			'orders.spec.phone' => 'Telefon',
			'orders.spec.discount' => 'Chegirma',
			'orders.spec.note' => 'Izoh',
			'orders.spec.itemsValue' => ({required Object kinds, required Object count}) => '${kinds} xil · ${count} dona',
			'orders.spec.values.plastic' => 'Plastik',
			'orders.spec.values.aluminium' => 'Alumin',
			'orders.spec.values.termo' => 'Termo',
			'orders.spec.values.doubleGlass' => 'Ikki qavat',
			'orders.spec.values.singleGlass' => 'Bir qavat',
			'orders.spec.values.large' => 'Katta',
			'orders.spec.values.medium' => 'O\'rta',
			'orders.spec.values.small' => 'Kichik',
			'orders.spec.area' => 'Maydon',
			'orders.spec.unitPrice' => '1 m² narxi',
			'orders.spec.variant' => 'Daraja',
			'orders.invalidId' => 'Noto\'g\'ri buyurtma raqami.',
			'orders.invalidRequestId' => 'Noto\'g\'ri so\'rov raqami.',
			'orders.open.offerSent' => 'Taklif yuborildi',
			'orders.open.waitingClient' => 'Mijoz javobini kutmoqda',
			'orders.open.offersCount' => ({required Object count}) => '${count} ta taklif',
			'orders.open.beFirst' => 'Birinchi bo\'ling',
			'orders.open.newBadge' => 'Yangi',
			'orders.open.pageTitle' => 'Ochiq buyurtmalar',
			'orders.open.tabWaiting' => 'Javob kutmoqda',
			'orders.open.tabSent' => 'Taklif berilgan',
			'orders.open.emptySentTitle' => 'Yuborilgan taklif yo\'q',
			'orders.open.emptySentMessage' => 'Taklif bergan e\'lonlaringiz shu yerda mijoz javobini kutib turadi.',
			'orders.open.tabInvited' => 'Sizga taklif',
			'orders.open.invitedBadge' => 'Sizga taklif',
			'orders.open.repairBadge' => 'Ta\'mir',
			'orders.open.acceptInvite' => 'Qabul qilaman',
			'orders.open.emptyInvitedTitle' => 'Shaxsiy taklif yo\'q',
			'orders.open.emptyInvitedMessage' => 'Mijoz sizni tanlab yuborgan buyurtmalar shu yerda ko\'rinadi.',
			'orders.open.invitedNote' => 'Bu buyurtmani mijoz AYNAN sizga yubordi — boshqa ustalar ko\'rmaydi.',
			'orders.personalTitle' => 'Shaxsiy buyurtmalar',
			'ownOrders.orderTitle' => 'Buyurtma',
			'ownOrders.itemsCount' => ({required Object count}) => '${count} ta rom',
			'ownOrders.statusTitle' => 'Buyurtma holati',
			'ownOrders.statusRow' => 'Holat',
			'ownOrders.saving' => 'Saqlanyapti…',
			'ownOrders.tapToChange' => 'O\'zgartirish uchun bosing',
			'ownOrders.alreadyDone' => 'Bu buyurtma allaqachon yakunlangan.',
			'ownOrders.cannotChange' => 'Bu buyurtma holatini o\'zgartirib bo\'lmaydi.',
			'ownOrders.status.draft' => 'Qoralama',
			'ownOrders.status.newOrder' => 'Yangi',
			'ownOrders.status.inProgress' => 'Jarayonda',
			'ownOrders.status.done' => 'Yakunlangan',
			'ownOrders.status.debt' => 'Qarzdor',
			'ownOrders.status.cancelled' => 'Bekor qilingan',
			'ownOrders.hint.newOrder' => 'Qabul qilindi, hali boshlanmagan',
			'ownOrders.hint.inProgress' => 'Ishlab chiqarish yoki o\'rnatish ketyapti',
			'ownOrders.hint.done' => 'Topshirildi va to\'liq hisob-kitob qilindi',
			'ownOrders.hint.debt' => 'Ish tugadi, lekin pul to\'liq olinmagan',
			'ownOrders.hint.cancelled' => 'Buyurtma bekor qilindi',
			'orderForm.noProducts' => 'Buyurtmada mahsulot yo\'q.',
			'orderForm.queued' => 'Internet yo\'q — buyurtma navbatga qo\'yildi, o\'zi yuboriladi.',
			'orderForm.saved' => 'Buyurtma saqlandi',
			'orderForm.saveTitle' => 'Buyurtmani saqlash',
			'orderForm.customer' => 'Buyurtmachi',
			'orderForm.nameLabel' => 'Ismi',
			'orderForm.nameHint' => 'Aziz aka',
			'orderForm.nameRequired' => 'Ismni yozing',
			'orderForm.addressHint' => 'Chilonzor 9-kvartal',
			'orderForm.noteLabel' => 'Qo\'shimcha izoh',
			'orderForm.noteHint' => '2-qavat, lift yo\'q',
			'orderForm.itemsSummary' => ({required Object kinds, required Object count}) => '${kinds} xil rom · ${count} dona',
			'chat.threadsTitle' => 'Suhbatlar',
			'chat.conversation' => 'Suhbat',
			'chat.messageHint' => 'Xabar yozing...',
			'chat.emptyChat' => 'Narx va shartni shu yerda kelishasiz',
			'chat.emptyThreadsTitle' => 'Hali suhbat yo\'q',
			'chat.emptyThreadsMessage' => 'Buyurtmangizga usta javob berganda shu yerda yozishasiz.',
			'notifications.title' => 'Bildirishnomalar',
			'notifications.markAllRead' => 'Hammasini o\'qish',
			'notifications.empty' => 'Bildirishnoma yo\'q',
			'notifications.open' => 'Ko\'rish',
			'masters.title' => 'Usta haqida',
			'masters.master' => 'Usta',
			'masters.client' => 'Mijoz',
			'masters.write' => 'Yozish',
			'masters.chooseThis' => 'Shu ustani tanlash',
			'masters.choose' => 'Tanlash',
			'masters.chosen' => 'Tanlangan usta',
			'masters.notFound' => 'Ma\'lumot topilmadi',
			'masters.works' => 'Qilgan ishlari',
			'masters.reviews' => ({required Object count}) => 'Sharhlar (${count})',
			'masters.reviewsLabel' => 'Sharhlar',
			'masters.noReviews' => 'Hali sharh yo\'q — siz birinchi bo\'lishingiz mumkin.',
			'masters.experienceYears' => ({required Object years}) => '${years} yil tajriba',
			'masters.rating' => 'Reyting',
			'masters.completed' => 'Bajarilgan',
			'masters.responses' => ({required Object count}) => '${count} javob',
			'masters.estimate' => 'Hisob',
			'orderFlow.status.published' => 'E\'lon qilingan',
			'orderFlow.status.assigned' => 'Usta tanlangan',
			'orderFlow.status.completed' => 'Yakunlangan',
			'orderFlow.status.cancelled' => 'Bekor qilingan',
			'orderFlow.status.expired' => 'Muddati o\'tgan',
			'orderFlow.stage.accepted' => 'Qabul qilindi',
			'orderFlow.stage.measured' => 'O\'lchov olindi',
			'orderFlow.stage.production' => 'Ishlab chiqarish',
			'orderFlow.stage.installation' => 'O\'rnatish',
			'orderFlow.stage.handover' => 'Topshirildi',
			'orderFlow.response.interested' => 'Qabul qilaman',
			'orderFlow.response.withdrawn' => 'Voz kechdi',
			'orderFlow.response.chosen' => 'Tanlandi',
			'orderFlow.response.rejected' => 'Tanlanmadi',
			'company.title' => 'Korxona',
			'company.nameLabel' => 'Korxona nomi',
			'company.nameHint' => 'Masalan: Ustachi Servis',
			'company.nameEmpty' => 'Korxona nomi kiritilmagan',
			'company.nameNote' => 'Buyurtma varag\'ida ko\'rinadi',
			'company.logoHint' => 'Logotip qo\'shish',
			'companyRates.onlyDigits' => 'Faqat raqam',
			'materials.title' => 'Materiallar',
			'materials.on' => 'Shu materialda ishlayman — buyurtmalar keladi',
			'materials.off' => 'O\'chirilgan — bu materialdagi buyurtmalar kelmaydi',
			'materials.allOff' => 'Kamida bitta material yoqiq turishi kerak',
			'professional.title' => 'Kasbiy ma\'lumot',
			'professional.headline' => 'Qanday usta ekaningizni ayting',
			'professional.headlineHint' => 'Mijoz sizni tanlashdan oldin shu ma\'lumotni ko\'radi. Keyin istalgan vaqtda o\'zgartirishingiz mumkin.',
			'professional.specialty' => 'Yo\'nalishlar',
			'professional.specialtyPick' => 'Yo\'nalishlaringizni tanlang',
			'professional.specialtyLoadFailed' => 'Yo\'nalishlar ro\'yxati yuklanmadi — internetni tekshirib, qayta kiring.',
			'professional.experienceQuestion' => 'Necha yillik tajribangiz bor?',
			'professional.experienceHint' => 'Masalan: 5',
			'professional.experienceRequired' => 'Tajribani kiriting',
			'professional.experienceRange' => 'Tajriba 0 dan 70 gacha bo\'lishi kerak',
			'professional.aboutLabel' => 'O\'zingiz haqingizda (ixtiyoriy)',
			'professional.aboutHint' => 'Qanday ishlarni qilasiz, nimaga e\'tibor berasiz — qisqacha yozing.',
			'professional.works' => 'Qilgan ishlaringiz',
			'professional.worksHint' => 'Rasm qo\'shsangiz mijoz ishingizni ko\'radi va sizni tanlash ehtimoli ortadi. Ixtiyoriy — keyin ham qo\'shsa bo\'ladi.',
			'professional.deleteSampleTitle' => 'Namunani o\'chirasizmi?',
			'professional.deleteSampleMessage' => 'Bu rasm mijozlarga ko\'rinmay qoladi.',
			'professional.deleteFailed' => 'O\'chirilmadi',
			'professional.pickSpecialty' => 'Kamida bitta yo\'nalish tanlang',
			'professional.specialtyHint' => 'Bir nechtasini tanlashingiz mumkin — buyurtma faqat shu yo\'nalishlar bo\'yicha keladi.',
			'appUpdate.eyebrow' => 'YANGILANISH',
			'appUpdate.titleOptional' => 'Yangi versiya tayyor',
			'appUpdate.titleRequired' => 'Yangilash talab qilinadi',
			'appUpdate.bodyOptional' => 'Ustachi Pro\'ning yangi versiyasi chiqdi. Yangilasangiz oxirgi tuzatish va imkoniyatlar bilan ishlaysiz.',
			'appUpdate.bodyRequired' => 'Bu versiya endi qo\'llab-quvvatlanmaydi. Ilovadan foydalanishni davom ettirish uchun yangilang.',
			'appUpdate.whatsNew' => 'NIMA YANGILANDI',
			'appUpdate.versionFrom' => 'Sizda',
			'appUpdate.versionTo' => 'Yangi',
			'appUpdate.update' => 'Yangilash',
			'appUpdate.later' => 'Keyinroq',
			'appUpdate.openFailed' => 'Havolani ochib bo\'lmadi. Ilovani do\'kondan qo\'lda yangilang.',
			_ => null,
		};
	}
}
