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
		  _meta = meta ?? TranslationMetadata(
		    locale: AppLocale.uz,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <uz>.
	final TranslationMetadata<AppLocale, Translations> _meta;
	@override TranslationMetadata<AppLocale, Translations> get $meta => _meta;

	/// Access flat map
	dynamic operator[](String key) => _meta.getTranslation(key);

	late final Translations _root = this; // ignore: unused_field

	Translations $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => Translations(meta: meta ?? this.$meta);

	// Translations

	/// uz: 'Ustachi'
	String get applicationName => 'Ustachi';

	late final Translations$common$uz common = Translations$common$uz.internal(_root);
	late final Translations$onboarding$uz onboarding = Translations$onboarding$uz.internal(_root);
	late final Translations$auth$uz auth = Translations$auth$uz.internal(_root);
	late final Translations$home$uz home = Translations$home$uz.internal(_root);
	late final Translations$calculatePage$uz calculatePage = Translations$calculatePage$uz.internal(_root);
	late final Translations$marketplace$uz marketplace = Translations$marketplace$uz.internal(_root);
	late final Translations$profile$uz profile = Translations$profile$uz.internal(_root);
	late final Translations$masters$uz masters = Translations$masters$uz.internal(_root);
	late final Translations$appUpdate$uz appUpdate = Translations$appUpdate$uz.internal(_root);
}

// Path: common
class Translations$common$uz {
	Translations$common$uz.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// uz: 'Yuklanmoqda…'
	String get loading => 'Yuklanmoqda…';

	/// uz: 'Yuklash cho‘zilib ketdi. Internetni tekshirib, qayta urinib ko‘ring.'
	String get loadingTimeout => 'Yuklash cho‘zilib ketdi. Internetni tekshirib, qayta urinib ko‘ring.';

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

	/// uz: 'Nusxalash'
	String get copy => 'Nusxalash';

	/// uz: 'Saqlandi'
	String get saved => 'Saqlandi';

	/// uz: 'Qayta urinish'
	String get retry => 'Qayta urinish';

	/// uz: 'Topilmadi'
	String get notFound => 'Topilmadi';
}

// Path: onboarding
class Translations$onboarding$uz {
	Translations$onboarding$uz.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$onboarding$step1$uz step1 = Translations$onboarding$step1$uz.internal(_root);
	late final Translations$onboarding$step2$uz step2 = Translations$onboarding$step2$uz.internal(_root);
	late final Translations$onboarding$step3$uz step3 = Translations$onboarding$step3$uz.internal(_root);
}

// Path: auth
class Translations$auth$uz {
	Translations$auth$uz.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final Translations$auth$common$uz common = Translations$auth$common$uz.internal(_root);
	late final Translations$auth$selection$uz selection = Translations$auth$selection$uz.internal(_root);
	late final Translations$auth$login$uz login = Translations$auth$login$uz.internal(_root);
	late final Translations$auth$register$uz register = Translations$auth$register$uz.internal(_root);
	late final Translations$auth$otp$uz otp = Translations$auth$otp$uz.internal(_root);
	late final Translations$auth$forgot$uz forgot = Translations$auth$forgot$uz.internal(_root);
	late final Translations$auth$reset$uz reset = Translations$auth$reset$uz.internal(_root);
	late final Translations$auth$phone$uz phone = Translations$auth$phone$uz.internal(_root);
	late final Translations$auth$telegram$uz telegram = Translations$auth$telegram$uz.internal(_root);
	late final Translations$auth$profile$uz profile = Translations$auth$profile$uz.internal(_root);
}

// Path: home
class Translations$home$uz {
	Translations$home$uz.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// uz: 'Asosiy'
	String get main => 'Asosiy';

	/// uz: 'Hisoblash'
	String get calculate => 'Hisoblash';

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

	/// uz: 'Bugun nimani hisoblaymiz?'
	String get todayQuestion => 'Bugun nimani hisoblaymiz?';

	/// uz: 'Narx hisoblash'
	String get calculatePrice => 'Narx hisoblash';

	/// uz: 'Usta topish'
	String get findMaster => 'Usta topish';

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

	/// uz: 'Tom'
	String get roof => 'Tom';

	/// uz: 'Beton'
	String get concrete => 'Beton';

	/// uz: 'Darvoza'
	String get gate => 'Darvoza';

	/// uz: 'G'isht'
	String get brick => 'G\'isht';

	/// uz: 'Ustalar'
	String get masters => 'Ustalar';

	/// uz: 'E’lonlaringiz va ishlarning bajarilishini kuzating'
	String get ordersSubtitle => 'E’lonlaringiz va ishlarning bajarilishini kuzating';

	/// uz: 'Bir necha savol — va aniq hisob'
	String get calculateHeroSubtitle => 'Bir necha savol — va aniq hisob';

	/// uz: 'O'lchamni ayting'
	String get step1 => 'O\'lchamni ayting';

	/// uz: 'Taklif va narx'
	String get step2 => 'Taklif va narx';

	/// uz: 'Usta chaqiring'
	String get step3 => 'Usta chaqiring';

	/// uz: 'Qidirish: tom, g'isht, elektrik…'
	String get searchHint => 'Qidirish: tom, g\'isht, elektrik…';

	/// uz: 'Yo'nalishlar ro'yxati yuklanmadi.'
	String get notFoundEmpty => 'Yo\'nalishlar ro\'yxati yuklanmadi.';

	/// uz: '"$query" bo'yicha yo'nalish yo'q.'
	String notFoundQuery({required Object query}) => '"${query}" bo\'yicha yo\'nalish yo\'q.';
}

// Path: calculatePage
class Translations$calculatePage$uz {
	Translations$calculatePage$uz.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// uz: 'so'm'
	String get som => 'so\'m';
}

// Path: marketplace
class Translations$marketplace$uz {
	Translations$marketplace$uz.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// uz: 'Suhbatlar'
	String get chats => 'Suhbatlar';

	/// uz: 'Usta bilan bog'lanish'
	String get contactMaster => 'Usta bilan bog\'lanish';

	/// uz: 'Yana rom qo'shish'
	String get addMoreWindow => 'Yana rom qo\'shish';

	/// uz: 'Usta tanlash'
	String get selectMaster => 'Usta tanlash';

	/// uz: 'Yozish'
	String get write => 'Yozish';

	/// uz: 'Shu ustani tanlash'
	String get selectThisMaster => 'Shu ustani tanlash';

	/// uz: 'Bildirishnomalar'
	String get notifications => 'Bildirishnomalar';

	/// uz: 'Hammasini o'qish'
	String get readAll => 'Hammasini o\'qish';
}

// Path: profile
class Translations$profile$uz {
	Translations$profile$uz.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// uz: 'Shaxsiy ma'lumotlar'
	String get personalData => 'Shaxsiy ma\'lumotlar';

	/// uz: 'Mening buyurtmalarim'
	String get myOrders => 'Mening buyurtmalarim';

	/// uz: 'Sozlamalar'
	String get settings => 'Sozlamalar';

	/// uz: 'Ilova tili'
	String get language => 'Ilova tili';

	/// uz: 'Ilova ko'rinishi'
	String get theme => 'Ilova ko\'rinishi';

	/// uz: 'Yorug''
	String get themeLight => 'Yorug\'';

	/// uz: 'Qorong'i'
	String get themeDark => 'Qorong\'i';

	/// uz: 'Telefondagidek'
	String get themeSystem => 'Telefondagidek';

	/// uz: 'Telefon sozlamasiga qarab o'zgaradi'
	String get themeSystemHint => 'Telefon sozlamasiga qarab o\'zgaradi';

	/// uz: 'Biz bilan aloqa'
	String get support => 'Biz bilan aloqa';

	/// uz: 'Chiqish'
	String get logout => 'Chiqish';

	late final Translations$profile$help$uz help = Translations$profile$help$uz.internal(_root);

	/// uz: 'Hisobdan chiqasizmi?'
	String get logoutTitle => 'Hisobdan chiqasizmi?';

	/// uz: 'Sessiya yopiladi va qurilmadagi hisob ma'lumotlari o'chiriladi. Qayta kirganingizda ular yangidan yuklab olinadi.'
	String get logoutMessage => 'Sessiya yopiladi va qurilmadagi hisob ma\'lumotlari o\'chiriladi. Qayta kirganingizda ular yangidan yuklab olinadi.';

	/// uz: 'Ha, chiqaman'
	String get logoutConfirm => 'Ha, chiqaman';

	/// uz: 'Chiqilmoqda...'
	String get loggingOut => 'Chiqilmoqda...';

	/// uz: 'Sessiya yopilmoqda'
	String get loggingOutHint => 'Sessiya yopilmoqda';

	/// uz: 'Serverdan chiqib bo'lmadi, lekin qurilmadagi ma'lumotlar tozalandi'
	String get logoutFailed => 'Serverdan chiqib bo\'lmadi, lekin qurilmadagi ma\'lumotlar tozalandi';

	late final Translations$profile$personal$uz personal = Translations$profile$personal$uz.internal(_root);
}

// Path: masters
class Translations$masters$uz {
	Translations$masters$uz.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// uz: 'Profilni ko‘rish'
	String get viewProfile => 'Profilni ko‘rish';

	/// uz: 'Yana ustalarni ko‘rsatish'
	String get loadMore => 'Yana ustalarni ko‘rsatish';

	/// uz: 'Qidiruv yuklangan ustalar orasida. Qolganlarini ko‘rish uchun yana yuklang.'
	String get searchLoadedOnly => 'Qidiruv yuklangan ustalar orasida. Qolganlarini ko‘rish uchun yana yuklang.';

	/// uz: 'Ustalar ro'yhati'
	String get masterList => 'Ustalar ro\'yhati';

	/// uz: 'BAJARILGAN'
	String get completedWorks => 'BAJARILGAN';

	/// uz: 'TAJRIBA'
	String get experience => 'TAJRIBA';

	/// uz: 'QAYTA ALOQA'
	String get repeatContact => 'QAYTA ALOQA';

	/// uz: 'Qidiruv sozlamalari'
	String get filterTitle => 'Qidiruv sozlamalari';

	/// uz: 'Xizmat turi'
	String get professionType => 'Xizmat turi';

	/// uz: 'VILOYAT / TUMAN'
	String get regionAndDistrict => 'VILOYAT / TUMAN';

	/// uz: 'Viloyat'
	String get region => 'Viloyat';

	/// uz: 'Viloyatni tanlang'
	String get selectRegion => 'Viloyatni tanlang';

	/// uz: 'Barcha viloyatlar'
	String get allRegions => 'Barcha viloyatlar';

	/// uz: 'NARX ORALIG'I (SO'M)'
	String get priceRange => 'NARX ORALIG\'I (SO\'M)';

	/// uz: 'Min'
	String get minPrice => 'Min';

	/// uz: 'Max'
	String get maxPrice => 'Max';

	/// uz: 'MINIMAL REYTING'
	String get minimumRating => 'MINIMAL REYTING';

	/// uz: 'Tozalash'
	String get clear => 'Tozalash';

	/// uz: 'Qo'llash'
	String get apply => 'Qo\'llash';

	/// uz: 'Biz haqimizda'
	String get aboutTitle => 'Biz haqimizda';

	/// uz: 'Professional plitka terish xizmati. 5 yillik tajriba va yuqori sifat kafolati. Har qanday murakkablikdagi ishlarni o'z vaqtida bajaramiz. Zamonaviy uskunalar bilan ishlaymiz.'
	String get aboutDescription => 'Professional plitka terish xizmati. 5 yillik tajriba va yuqori sifat kafolati. Har qanday murakkablikdagi ishlarni o\'z vaqtida bajaramiz. Zamonaviy uskunalar bilan ishlaymiz.';

	/// uz: 'Qilgan ishlari'
	String get portfolioTitle => 'Qilgan ishlari';

	/// uz: 'Sharhlar'
	String get reviewsTitle => 'Sharhlar';

	/// uz: 'Sharhlar (${count})'
	String reviewsCount({required Object count}) => 'Sharhlar (${count})';

	/// uz: 'Hali sharh yo'q — siz birinchi bo'lishingiz mumkin.'
	String get noReviews => 'Hali sharh yo\'q — siz birinchi bo\'lishingiz mumkin.';

	/// uz: 'Mo'ljal narx — aniq summani ish hajmiga qarab chatda kelishasiz.'
	String get estimatedPriceNotice => 'Mo\'ljal narx — aniq summani ish hajmiga qarab chatda kelishasiz.';

	/// uz: 'Barchasi'
	String get all => 'Barchasi';

	/// uz: 'Rom'
	String get windowProfession => 'Rom';

	/// uz: 'Tom'
	String get roofProfession => 'Tom';

	/// uz: 'Sement'
	String get cementProfession => 'Sement';

	/// uz: 'Pol'
	String get floorProfession => 'Pol';

	/// uz: 'Toshkent shahri'
	String get tashkentCity => 'Toshkent shahri';

	/// uz: 'Toshkent viloyati'
	String get tashkentRegion => 'Toshkent viloyati';

	/// uz: 'Farg'ona viloyati'
	String get ferganaRegion => 'Farg\'ona viloyati';

	/// uz: 'Samarqand viloyati'
	String get samarkandRegion => 'Samarqand viloyati';

	/// uz: 'Andijon viloyati'
	String get andijanRegion => 'Andijon viloyati';

	/// uz: 'Namangan viloyati'
	String get namanganRegion => 'Namangan viloyati';

	/// uz: 'Buxoro viloyati'
	String get bukharaRegion => 'Buxoro viloyati';

	/// uz: 'Xorazm viloyati'
	String get khorezmRegion => 'Xorazm viloyati';

	/// uz: 'Qashqadaryo viloyati'
	String get kashkadaryaRegion => 'Qashqadaryo viloyati';

	/// uz: 'Surxondaryo viloyati'
	String get surkhandaryaRegion => 'Surxondaryo viloyati';

	/// uz: 'Usta chaqirish'
	String get callMaster => 'Usta chaqirish';

	/// uz: 'Usta haqida'
	String get aboutMaster => 'Usta haqida';

	/// uz: 'Ism, yo'nalish yoki telefon raqam'
	String get searchHint => 'Ism, yo\'nalish yoki telefon raqam';

	/// uz: 'Ism ko'rsatilmagan'
	String get noName => 'Ism ko\'rsatilmagan';

	/// uz: 'Yo'nalish ko'rsatilmagan'
	String get noSpecialty => 'Yo\'nalish ko\'rsatilmagan';

	/// uz: 'Tajriba ko'rsatilmagan'
	String get noExperience => 'Tajriba ko\'rsatilmagan';

	/// uz: '$count yil tajriba'
	String experienceYears({required Object count}) => '${count} yil tajriba';

	/// uz: 'Manzil yo'q'
	String get noAddress => 'Manzil yo\'q';

	/// uz: '$count ta ish'
	String completedOrders({required Object count}) => '${count} ta ish';

	/// uz: 'Yangi usta'
	String get newMaster => 'Yangi usta';

	/// uz: 'Ro'yxat yuklanmadi'
	String get loadFailed => 'Ro\'yxat yuklanmadi';

	/// uz: 'Hozircha usta yo'q'
	String get noMastersYet => 'Hozircha usta yo\'q';

	/// uz: '"$query" bo'yicha usta topilmadi.'
	String searchNotFound({required Object query}) => '"${query}" bo\'yicha usta topilmadi.';

	/// uz: '$region da mos usta topilmadi.'
	String regionNotFound({required Object region}) => '${region} da mos usta topilmadi.';

	/// uz: 'Bu yo'nalishda hali usta ro'yxatdan o'tmagan.'
	String get specialtyNotFound => 'Bu yo\'nalishda hali usta ro\'yxatdan o\'tmagan.';

	/// uz: 'Ustalar ro'yxatdan o'tgach shu yerda ko'rinadi.'
	String get defaultEmpty => 'Ustalar ro\'yxatdan o\'tgach shu yerda ko\'rinadi.';

	/// uz: 'Narxlari'
	String get prices => 'Narxlari';

	/// uz: 'Hali baholanmagan'
	String get notRated => 'Hali baholanmagan';

	/// uz: 'Reyting'
	String get rating => 'Reyting';

	/// uz: 'Bajarilgan'
	String get completed => 'Bajarilgan';

	/// uz: 'Sharhlar'
	String get reviews => 'Sharhlar';
}

// Path: appUpdate
class Translations$appUpdate$uz {
	Translations$appUpdate$uz.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// uz: 'YANGILANISH'
	String get eyebrow => 'YANGILANISH';

	/// uz: 'Yangi versiya tayyor'
	String get titleOptional => 'Yangi versiya tayyor';

	/// uz: 'Yangilash talab qilinadi'
	String get titleRequired => 'Yangilash talab qilinadi';

	/// uz: 'Ustachining yangi versiyasi chiqdi. Yangilasangiz oxirgi tuzatish va imkoniyatlar bilan ishlaysiz.'
	String get bodyOptional => 'Ustachining yangi versiyasi chiqdi. Yangilasangiz oxirgi tuzatish va imkoniyatlar bilan ishlaysiz.';

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
class Translations$onboarding$step1$uz {
	Translations$onboarding$step1$uz.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// uz: 'Uydagi har qanday ish uchun usta'
	String get title => 'Uydagi har qanday ish uchun usta';

	/// uz: 'Rom, tom, g'isht, elektrik, santexnik, kafel, bo'yoq… 25 dan ortiq yo'nalish. Kerakli ustani bitta ilovadan topasiz.'
	String get description => 'Rom, tom, g\'isht, elektrik, santexnik, kafel, bo\'yoq… 25 dan ortiq yo\'nalish. Kerakli ustani bitta ilovadan topasiz.';
}

// Path: onboarding.step2
class Translations$onboarding$step2$uz {
	Translations$onboarding$step2$uz.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// uz: 'Narxni oldindan biling'
	String get title => 'Narxni oldindan biling';

	/// uz: 'Rom uchun o'lcham va shaklni tanlaysiz — chizma tayyor bo'ladi. Narxni ustalar aytadi — bir nechtasini solishtirib tanlaysiz.'
	String get description => 'Rom uchun o\'lcham va shaklni tanlaysiz — chizma tayyor bo\'ladi. Narxni ustalar aytadi — bir nechtasini solishtirib tanlaysiz.';
}

// Path: onboarding.step3
class Translations$onboarding$step3$uz {
	Translations$onboarding$step3$uz.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// uz: 'Ishonchli ustani tanlang'
	String get title => 'Ishonchli ustani tanlang';

	/// uz: 'Reyting, ish namunalari va sharhlarga qarab tanlaysiz. Kelishuv chatda, ish bosqichlari esa ilovada ko'rinib turadi.'
	String get description => 'Reyting, ish namunalari va sharhlarga qarab tanlaysiz. Kelishuv chatda, ish bosqichlari esa ilovada ko\'rinib turadi.';
}

// Path: auth.common
class Translations$auth$common$uz {
	Translations$auth$common$uz.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// uz: 'Telefon raqamini to'g'ri kiriting'
	String get invalidPhone => 'Telefon raqamini to\'g\'ri kiriting';

	/// uz: 'Parol kamida 6 belgidan iborat bo'lishi kerak'
	String get minPassword => 'Parol kamida 6 belgidan iborat bo\'lishi kerak';

	/// uz: 'Bekor qilish'
	String get cancel => 'Bekor qilish';
}

// Path: auth.selection
class Translations$auth$selection$uz {
	Translations$auth$selection$uz.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// uz: 'Xush kelibsiz!'
	String get welcome => 'Xush kelibsiz!';

	/// uz: 'Davom etish uchun tizimga kiring yoki yangi hisob yarating'
	String get chooseRole => 'Davom etish uchun tizimga kiring yoki yangi hisob yarating';

	/// uz: 'Mijoz'
	String get customerRole => 'Mijoz';

	/// uz: 'Usta'
	String get craftsmanRole => 'Usta';

	/// uz: 'Davom etish'
	String get continueBtn => 'Davom etish';

	/// uz: 'Hisobingiz bormi?'
	String get alreadyHaveAccount => 'Hisobingiz bormi?';

	/// uz: 'Kirish'
	String get login => 'Kirish';

	/// uz: 'Tizimga kirish'
	String get loginBtn => 'Tizimga kirish';

	/// uz: 'Ro'yhatdan o'tish'
	String get registerBtn => 'Ro\'yhatdan o\'tish';

	/// uz: 'Usta qidirish endi oson'
	String get easyFindMaster => 'Usta qidirish endi oson';
}

// Path: auth.login
class Translations$auth$login$uz {
	Translations$auth$login$uz.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// uz: 'Xush kelibsiz!'
	String get welcome => 'Xush kelibsiz!';

	/// uz: 'Buyurtmalar, ustalar va shaxsiy ma'lumotlaringizga kirish uchun tizimga kiring.'
	String get subtitle => 'Buyurtmalar, ustalar va shaxsiy ma\'lumotlaringizga kirish uchun tizimga kiring.';

	/// uz: 'Telefon raqami'
	String get phoneNumber => 'Telefon raqami';

	/// uz: 'Parol'
	String get password => 'Parol';

	/// uz: 'Parolni unutdingizmi?'
	String get forgotPassword => 'Parolni unutdingizmi?';

	/// uz: 'OTP kodni tasdiqlash'
	String get verifyOtp => 'OTP kodni tasdiqlash';

	/// uz: 'Hisob tasdiqlanmagan'
	String get inactiveAccountTitle => 'Hisob tasdiqlanmagan';

	/// uz: 'Telefon raqamingizni OTP orqali tasdiqlash sahifasiga o'tishni xohlaysizmi?'
	String get inactiveAccountMessage => 'Telefon raqamingizni OTP orqali tasdiqlash sahifasiga o\'tishni xohlaysizmi?';

	/// uz: 'Tizimga kirish'
	String get loginBtn => 'Tizimga kirish';

	/// uz: 'Hisobingiz yo'qmi?'
	String get noAccount => 'Hisobingiz yo\'qmi?';

	/// uz: 'Ro'yxatdan o'ting'
	String get register => 'Ro\'yxatdan o\'ting';
}

// Path: auth.register
class Translations$auth$register$uz {
	Translations$auth$register$uz.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// uz: 'Hisob yarating'
	String get title => 'Hisob yarating';

	/// uz: 'Bir necha daqiqada hisob yarating va kerakli ustani topishni boshlang.'
	String get subtitle => 'Bir necha daqiqada hisob yarating va kerakli ustani topishni boshlang.';

	/// uz: 'Ism'
	String get firstName => 'Ism';

	/// uz: 'Familiya'
	String get lastName => 'Familiya';

	/// uz: 'Jasur'
	String get firstNameHint => 'Jasur';

	/// uz: 'Abdullayev'
	String get lastNameHint => 'Abdullayev';

	/// uz: 'Telefon raqam'
	String get phoneNumber => 'Telefon raqam';

	/// uz: 'Parol'
	String get password => 'Parol';

	/// uz: '{field} kiritilishi shart'
	String get requiredField => '{field} kiritilishi shart';

	/// uz: 'Ro'yxatdan o'tish'
	String get registerBtn => 'Ro\'yxatdan o\'tish';

	/// uz: 'Ro'yxatdan o'tish orqali siz bizning '
	String get agreementPrefix => 'Ro\'yxatdan o\'tish orqali siz bizning ';

	/// uz: 'Foydalanish shartlari'
	String get terms => 'Foydalanish shartlari';

	/// uz: ' va '
	String get and => ' va ';

	/// uz: 'Maxfiylik siyosati'
	String get privacy => 'Maxfiylik siyosati';

	/// uz: 'ga rozilik bildirasiz.'
	String get agreementSuffix => 'ga rozilik bildirasiz.';

	/// uz: 'Hisobingiz bormi?'
	String get haveAccount => 'Hisobingiz bormi?';

	/// uz: 'Tizimga kiring'
	String get login => 'Tizimga kiring';
}

// Path: auth.otp
class Translations$auth$otp$uz {
	Translations$auth$otp$uz.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// uz: 'Tasdiqlash'
	String get title => 'Tasdiqlash';

	/// uz: 'Telefoningizga yuborilgan 6 xonali tasdiqlash kodini kiriting.'
	String get subtitle => 'Telefoningizga yuborilgan 6 xonali tasdiqlash kodini kiriting.';

	/// uz: '${phone} raqamiga yuborilgan 6 xonali kodni kiriting'
	String sentMessage({required Object phone}) => '${phone} raqamiga yuborilgan 6 xonali kodni kiriting';

	/// uz: '6 xonali kodni to'liq kiriting'
	String get invalidCode => '6 xonali kodni to\'liq kiriting';

	/// uz: 'Qayta yuborish'
	String get resend => 'Qayta yuborish';

	/// uz: 'Tasdiqlash'
	String get confirmBtn => 'Tasdiqlash';

	/// uz: 'Qayta yuborish'
	String get resendIn => 'Qayta yuborish';

	/// uz: 'Boshqa raqam kiritish'
	String get changeNumber => 'Boshqa raqam kiritish';
}

// Path: auth.forgot
class Translations$auth$forgot$uz {
	Translations$auth$forgot$uz.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// uz: 'Parolni tiklash uchun telefon raqamingizni kiriting. SMS orqali kelgan kodni tasdiqlab, yangi parol o'rnatasiz.'
	String get subtitle => 'Parolni tiklash uchun telefon raqamingizni kiriting. SMS orqali kelgan kodni tasdiqlab, yangi parol o\'rnatasiz.';

	/// uz: 'SMS kod olish'
	String get requestCode => 'SMS kod olish';

	/// uz: 'Kodni qayta yuborish'
	String get resendCode => 'Kodni qayta yuborish';

	/// uz: 'Tasdiqlash kodi'
	String get codeLabel => 'Tasdiqlash kodi';

	/// uz: '6 xonali kod kiriting'
	String get codeHint => '6 xonali kod kiriting';

	/// uz: 'Kodni tasdiqlash'
	String get verifyCode => 'Kodni tasdiqlash';

	/// uz: 'Kod tasdiqlandi'
	String get codeVerified => 'Kod tasdiqlandi';

	/// uz: 'Yangi parol'
	String get newPassword => 'Yangi parol';

	/// uz: 'Parolni yangilash'
	String get updatePassword => 'Parolni yangilash';

	/// uz: 'Parol muvaffaqiyatli yangilandi.'
	String get passwordUpdated => 'Parol muvaffaqiyatli yangilandi.';

	/// uz: 'Login sahifasiga qaytish'
	String get backToLogin => 'Login sahifasiga qaytish';

	/// uz: 'Qayta yuborish mumkin:'
	String get resendAvailable => 'Qayta yuborish mumkin:';

	/// uz: 'Kod kelmadimi? Taymer tugagach uni qayta yuborishingiz mumkin.'
	String get resendHint => 'Kod kelmadimi? Taymer tugagach uni qayta yuborishingiz mumkin.';
}

// Path: auth.reset
class Translations$auth$reset$uz {
	Translations$auth$reset$uz.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// uz: 'Yangi parol o'rnating'
	String get title => 'Yangi parol o\'rnating';

	/// uz: 'Hisobingiz xavfsizligi uchun yangi parolni ikki marta kiriting.'
	String get subtitle => 'Hisobingiz xavfsizligi uchun yangi parolni ikki marta kiriting.';

	/// uz: 'Yangi parol'
	String get newPasswordLabel => 'Yangi parol';

	/// uz: 'Parolni qayta kiriting'
	String get confirmPasswordLabel => 'Parolni qayta kiriting';

	/// uz: 'Parolni saqlash'
	String get updatePassword => 'Parolni saqlash';

	/// uz: 'Parollar bir xil emas'
	String get passwordMismatch => 'Parollar bir xil emas';
}

// Path: auth.phone
class Translations$auth$phone$uz {
	Translations$auth$phone$uz.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// uz: 'Ilovaga kirish'
	String get title => 'Ilovaga kirish';

	/// uz: 'Telegram botda hisobingizga ulangan telefon raqamini ulashing va ilovaga qayting.'
	String get subtitle => 'Telegram botda hisobingizga ulangan telefon raqamini ulashing va ilovaga qayting.';

	/// uz: 'Telegram orqali kirish'
	String get telegramBtn => 'Telegram orqali kirish';

	/// uz: 'Bot Telegram hisobingizdagi raqamni kirish uchun so'raydi. SMS yuborilmaydi.'
	String get telegramHint => 'Bot Telegram hisobingizdagi raqamni kirish uchun so\'raydi. SMS yuborilmaydi.';

	/// uz: 'SMS orqali kirish'
	String get smsOption => 'SMS orqali kirish';

	/// uz: 'yoki'
	String get orOption => 'yoki';

	/// uz: 'Telegram botni ochib bo'lmadi. Qayta urinib ko'ring.'
	String get telegramOpenError => 'Telegram botni ochib bo\'lmadi. Qayta urinib ko\'ring.';

	/// uz: 'Telefon raqam'
	String get label => 'Telefon raqam';

	/// uz: 'Davom etish'
	String get continueBtn => 'Davom etish';

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

	/// uz: 'Usta bo'lsangiz — «Ustachi Pro» ni yuklang'
	String get audienceRedirect => 'Usta bo\'lsangiz — «Ustachi Pro» ni yuklang';

	/// uz: 'Diqqat: bu ilova mijozlar uchun'
	String get audienceTitle => 'Diqqat: bu ilova mijozlar uchun';
}

// Path: auth.telegram
class Translations$auth$telegram$uz {
	Translations$auth$telegram$uz.internal(this._root);

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

// Path: auth.profile
class Translations$auth$profile$uz {
	Translations$auth$profile$uz.internal(this._root);

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

// Path: profile.help
class Translations$profile$help$uz {
	Translations$profile$help$uz.internal(this._root);

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

// Path: profile.personal
class Translations$profile$personal$uz {
	Translations$profile$personal$uz.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// uz: 'Shaxsiy'
	String get sectionPersonal => 'Shaxsiy';

	/// uz: 'Manzil'
	String get sectionAddress => 'Manzil';

	/// uz: 'Telefon'
	String get phoneLabel => 'Telefon';

	/// uz: 'Raqam — hisob identifikatori, o'zgartirilmaydi'
	String get phoneNote => 'Raqam — hisob identifikatori, o\'zgartirilmaydi';

	/// uz: 'Ro'yxatdan o me'zo'
	String get joinedLabel => 'Ro\'yxatdan o me\'zo';

	/// uz: 'Kiritilmagan'
	String get empty => 'Kiritilmagan';

	/// uz: 'Tahrirlash'
	String get edit => 'Tahrirlash';

	/// uz: 'Ma'lumotni yuklab bo'lmadi'
	String get loadFailed => 'Ma\'lumotni yuklab bo\'lmadi';
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
			'common.loading' => 'Yuklanmoqda…',
			'common.loadingTimeout' => 'Yuklash cho‘zilib ketdi. Internetni tekshirib, qayta urinib ko‘ring.',
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
			'common.copy' => 'Nusxalash',
			'common.saved' => 'Saqlandi',
			'common.retry' => 'Qayta urinish',
			'common.notFound' => 'Topilmadi',
			'onboarding.step1.title' => 'Uydagi har qanday ish uchun usta',
			'onboarding.step1.description' => 'Rom, tom, g\'isht, elektrik, santexnik, kafel, bo\'yoq… 25 dan ortiq yo\'nalish. Kerakli ustani bitta ilovadan topasiz.',
			'onboarding.step2.title' => 'Narxni oldindan biling',
			'onboarding.step2.description' => 'Rom uchun o\'lcham va shaklni tanlaysiz — chizma tayyor bo\'ladi. Narxni ustalar aytadi — bir nechtasini solishtirib tanlaysiz.',
			'onboarding.step3.title' => 'Ishonchli ustani tanlang',
			'onboarding.step3.description' => 'Reyting, ish namunalari va sharhlarga qarab tanlaysiz. Kelishuv chatda, ish bosqichlari esa ilovada ko\'rinib turadi.',
			'auth.common.invalidPhone' => 'Telefon raqamini to\'g\'ri kiriting',
			'auth.common.minPassword' => 'Parol kamida 6 belgidan iborat bo\'lishi kerak',
			'auth.common.cancel' => 'Bekor qilish',
			'auth.selection.welcome' => 'Xush kelibsiz!',
			'auth.selection.chooseRole' => 'Davom etish uchun tizimga kiring yoki yangi hisob yarating',
			'auth.selection.customerRole' => 'Mijoz',
			'auth.selection.craftsmanRole' => 'Usta',
			'auth.selection.continueBtn' => 'Davom etish',
			'auth.selection.alreadyHaveAccount' => 'Hisobingiz bormi?',
			'auth.selection.login' => 'Kirish',
			'auth.selection.loginBtn' => 'Tizimga kirish',
			'auth.selection.registerBtn' => 'Ro\'yhatdan o\'tish',
			'auth.selection.easyFindMaster' => 'Usta qidirish endi oson',
			'auth.login.welcome' => 'Xush kelibsiz!',
			'auth.login.subtitle' => 'Buyurtmalar, ustalar va shaxsiy ma\'lumotlaringizga kirish uchun tizimga kiring.',
			'auth.login.phoneNumber' => 'Telefon raqami',
			'auth.login.password' => 'Parol',
			'auth.login.forgotPassword' => 'Parolni unutdingizmi?',
			'auth.login.verifyOtp' => 'OTP kodni tasdiqlash',
			'auth.login.inactiveAccountTitle' => 'Hisob tasdiqlanmagan',
			'auth.login.inactiveAccountMessage' => 'Telefon raqamingizni OTP orqali tasdiqlash sahifasiga o\'tishni xohlaysizmi?',
			'auth.login.loginBtn' => 'Tizimga kirish',
			'auth.login.noAccount' => 'Hisobingiz yo\'qmi?',
			'auth.login.register' => 'Ro\'yxatdan o\'ting',
			'auth.register.title' => 'Hisob yarating',
			'auth.register.subtitle' => 'Bir necha daqiqada hisob yarating va kerakli ustani topishni boshlang.',
			'auth.register.firstName' => 'Ism',
			'auth.register.lastName' => 'Familiya',
			'auth.register.firstNameHint' => 'Jasur',
			'auth.register.lastNameHint' => 'Abdullayev',
			'auth.register.phoneNumber' => 'Telefon raqam',
			'auth.register.password' => 'Parol',
			'auth.register.requiredField' => '{field} kiritilishi shart',
			'auth.register.registerBtn' => 'Ro\'yxatdan o\'tish',
			'auth.register.agreementPrefix' => 'Ro\'yxatdan o\'tish orqali siz bizning ',
			'auth.register.terms' => 'Foydalanish shartlari',
			'auth.register.and' => ' va ',
			'auth.register.privacy' => 'Maxfiylik siyosati',
			'auth.register.agreementSuffix' => 'ga rozilik bildirasiz.',
			'auth.register.haveAccount' => 'Hisobingiz bormi?',
			'auth.register.login' => 'Tizimga kiring',
			'auth.otp.title' => 'Tasdiqlash',
			'auth.otp.subtitle' => 'Telefoningizga yuborilgan 6 xonali tasdiqlash kodini kiriting.',
			'auth.otp.sentMessage' => ({required Object phone}) => '${phone} raqamiga yuborilgan 6 xonali kodni kiriting',
			'auth.otp.invalidCode' => '6 xonali kodni to\'liq kiriting',
			'auth.otp.resend' => 'Qayta yuborish',
			'auth.otp.confirmBtn' => 'Tasdiqlash',
			'auth.otp.resendIn' => 'Qayta yuborish',
			'auth.otp.changeNumber' => 'Boshqa raqam kiritish',
			'auth.forgot.subtitle' => 'Parolni tiklash uchun telefon raqamingizni kiriting. SMS orqali kelgan kodni tasdiqlab, yangi parol o\'rnatasiz.',
			'auth.forgot.requestCode' => 'SMS kod olish',
			'auth.forgot.resendCode' => 'Kodni qayta yuborish',
			'auth.forgot.codeLabel' => 'Tasdiqlash kodi',
			'auth.forgot.codeHint' => '6 xonali kod kiriting',
			'auth.forgot.verifyCode' => 'Kodni tasdiqlash',
			'auth.forgot.codeVerified' => 'Kod tasdiqlandi',
			'auth.forgot.newPassword' => 'Yangi parol',
			'auth.forgot.updatePassword' => 'Parolni yangilash',
			'auth.forgot.passwordUpdated' => 'Parol muvaffaqiyatli yangilandi.',
			'auth.forgot.backToLogin' => 'Login sahifasiga qaytish',
			'auth.forgot.resendAvailable' => 'Qayta yuborish mumkin:',
			'auth.forgot.resendHint' => 'Kod kelmadimi? Taymer tugagach uni qayta yuborishingiz mumkin.',
			'auth.reset.title' => 'Yangi parol o\'rnating',
			'auth.reset.subtitle' => 'Hisobingiz xavfsizligi uchun yangi parolni ikki marta kiriting.',
			'auth.reset.newPasswordLabel' => 'Yangi parol',
			'auth.reset.confirmPasswordLabel' => 'Parolni qayta kiriting',
			'auth.reset.updatePassword' => 'Parolni saqlash',
			'auth.reset.passwordMismatch' => 'Parollar bir xil emas',
			'auth.phone.title' => 'Ilovaga kirish',
			'auth.phone.subtitle' => 'Telegram botda hisobingizga ulangan telefon raqamini ulashing va ilovaga qayting.',
			'auth.phone.telegramBtn' => 'Telegram orqali kirish',
			'auth.phone.telegramHint' => 'Bot Telegram hisobingizdagi raqamni kirish uchun so\'raydi. SMS yuborilmaydi.',
			'auth.phone.smsOption' => 'SMS orqali kirish',
			'auth.phone.orOption' => 'yoki',
			'auth.phone.telegramOpenError' => 'Telegram botni ochib bo\'lmadi. Qayta urinib ko\'ring.',
			'auth.phone.label' => 'Telefon raqam',
			'auth.phone.continueBtn' => 'Davom etish',
			'auth.phone.agreementPrefix' => 'Davom etish orqali siz ',
			'auth.phone.terms' => 'Foydalanish shartlari',
			'auth.phone.and' => ' va ',
			'auth.phone.privacy' => 'Maxfiylik siyosati',
			'auth.phone.agreementSuffix' => 'ga rozilik bildirasiz.',
			'auth.phone.audienceRedirect' => 'Usta bo\'lsangiz — «Ustachi Pro» ni yuklang',
			'auth.phone.audienceTitle' => 'Diqqat: bu ilova mijozlar uchun',
			'auth.telegram.loadingTitle' => 'Telegram orqali kirilmoqda',
			'auth.telegram.loadingHint' => 'Bir martalik havola tekshirilmoqda…',
			'auth.telegram.invalidLink' => 'Telegram havolasi yaroqsiz.',
			'auth.telegram.expiredLink' => 'Havola muddati tugagan yoki avval ishlatilgan. Botda qayta boshlang.',
			'auth.telegram.retry' => 'Qayta urinish',
			'auth.telegram.restartBot' => 'Botda qayta boshlash',
			'auth.telegram.smsOption' => 'SMS orqali kirish',
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
			'home.main' => 'Asosiy',
			'home.calculate' => 'Hisoblash',
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
			'home.todayQuestion' => 'Bugun nimani hisoblaymiz?',
			'home.calculatePrice' => 'Narx hisoblash',
			'home.findMaster' => 'Usta topish',
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
			'home.roof' => 'Tom',
			'home.concrete' => 'Beton',
			'home.gate' => 'Darvoza',
			'home.brick' => 'G\'isht',
			'home.masters' => 'Ustalar',
			'home.ordersSubtitle' => 'E’lonlaringiz va ishlarning bajarilishini kuzating',
			'home.calculateHeroSubtitle' => 'Bir necha savol — va aniq hisob',
			'home.step1' => 'O\'lchamni ayting',
			'home.step2' => 'Taklif va narx',
			'home.step3' => 'Usta chaqiring',
			'home.searchHint' => 'Qidirish: tom, g\'isht, elektrik…',
			'home.notFoundEmpty' => 'Yo\'nalishlar ro\'yxati yuklanmadi.',
			'home.notFoundQuery' => ({required Object query}) => '"${query}" bo\'yicha yo\'nalish yo\'q.',
			'calculatePage.som' => 'so\'m',
			'marketplace.chats' => 'Suhbatlar',
			'marketplace.contactMaster' => 'Usta bilan bog\'lanish',
			'marketplace.addMoreWindow' => 'Yana rom qo\'shish',
			'marketplace.selectMaster' => 'Usta tanlash',
			'marketplace.write' => 'Yozish',
			'marketplace.selectThisMaster' => 'Shu ustani tanlash',
			'marketplace.notifications' => 'Bildirishnomalar',
			'marketplace.readAll' => 'Hammasini o\'qish',
			'profile.personalData' => 'Shaxsiy ma\'lumotlar',
			'profile.myOrders' => 'Mening buyurtmalarim',
			'profile.settings' => 'Sozlamalar',
			'profile.language' => 'Ilova tili',
			'profile.theme' => 'Ilova ko\'rinishi',
			'profile.themeLight' => 'Yorug\'',
			'profile.themeDark' => 'Qorong\'i',
			'profile.themeSystem' => 'Telefondagidek',
			'profile.themeSystemHint' => 'Telefon sozlamasiga qarab o\'zgaradi',
			'profile.support' => 'Biz bilan aloqa',
			'profile.logout' => 'Chiqish',
			'profile.help.subtitle' => 'Savol yoki muammo bo\'lsa — yozing yoki qo\'ng\'iroq qiling',
			'profile.help.callLabel' => 'Qo\'ng\'iroq qilish',
			'profile.help.emailLabel' => 'Elektron pochta',
			'profile.help.telegramLabel' => 'Telegram kanalimiz',
			'profile.help.telegramHint' => 'Yangiliklar va e\'lonlar',
			'profile.help.workHours' => 'Dushanba–shanba, 9:00–19:00',
			'profile.help.copied' => 'Nusxalandi',
			'profile.logoutTitle' => 'Hisobdan chiqasizmi?',
			'profile.logoutMessage' => 'Sessiya yopiladi va qurilmadagi hisob ma\'lumotlari o\'chiriladi. Qayta kirganingizda ular yangidan yuklab olinadi.',
			'profile.logoutConfirm' => 'Ha, chiqaman',
			'profile.loggingOut' => 'Chiqilmoqda...',
			'profile.loggingOutHint' => 'Sessiya yopilmoqda',
			'profile.logoutFailed' => 'Serverdan chiqib bo\'lmadi, lekin qurilmadagi ma\'lumotlar tozalandi',
			'profile.personal.sectionPersonal' => 'Shaxsiy',
			'profile.personal.sectionAddress' => 'Manzil',
			'profile.personal.phoneLabel' => 'Telefon',
			'profile.personal.phoneNote' => 'Raqam — hisob identifikatori, o\'zgartirilmaydi',
			'profile.personal.joinedLabel' => 'Ro\'yxatdan o me\'zo',
			'profile.personal.empty' => 'Kiritilmagan',
			'profile.personal.edit' => 'Tahrirlash',
			'profile.personal.loadFailed' => 'Ma\'lumotni yuklab bo\'lmadi',
			'masters.viewProfile' => 'Profilni ko‘rish',
			'masters.loadMore' => 'Yana ustalarni ko‘rsatish',
			'masters.searchLoadedOnly' => 'Qidiruv yuklangan ustalar orasida. Qolganlarini ko‘rish uchun yana yuklang.',
			'masters.masterList' => 'Ustalar ro\'yhati',
			'masters.completedWorks' => 'BAJARILGAN',
			'masters.experience' => 'TAJRIBA',
			'masters.repeatContact' => 'QAYTA ALOQA',
			'masters.filterTitle' => 'Qidiruv sozlamalari',
			'masters.professionType' => 'Xizmat turi',
			'masters.regionAndDistrict' => 'VILOYAT / TUMAN',
			'masters.region' => 'Viloyat',
			'masters.selectRegion' => 'Viloyatni tanlang',
			'masters.allRegions' => 'Barcha viloyatlar',
			'masters.priceRange' => 'NARX ORALIG\'I (SO\'M)',
			'masters.minPrice' => 'Min',
			'masters.maxPrice' => 'Max',
			'masters.minimumRating' => 'MINIMAL REYTING',
			'masters.clear' => 'Tozalash',
			'masters.apply' => 'Qo\'llash',
			'masters.aboutTitle' => 'Biz haqimizda',
			'masters.aboutDescription' => 'Professional plitka terish xizmati. 5 yillik tajriba va yuqori sifat kafolati. Har qanday murakkablikdagi ishlarni o\'z vaqtida bajaramiz. Zamonaviy uskunalar bilan ishlaymiz.',
			'masters.portfolioTitle' => 'Qilgan ishlari',
			'masters.reviewsTitle' => 'Sharhlar',
			'masters.reviewsCount' => ({required Object count}) => 'Sharhlar (${count})',
			'masters.noReviews' => 'Hali sharh yo\'q — siz birinchi bo\'lishingiz mumkin.',
			'masters.estimatedPriceNotice' => 'Mo\'ljal narx — aniq summani ish hajmiga qarab chatda kelishasiz.',
			'masters.all' => 'Barchasi',
			'masters.windowProfession' => 'Rom',
			'masters.roofProfession' => 'Tom',
			'masters.cementProfession' => 'Sement',
			'masters.floorProfession' => 'Pol',
			'masters.tashkentCity' => 'Toshkent shahri',
			'masters.tashkentRegion' => 'Toshkent viloyati',
			'masters.ferganaRegion' => 'Farg\'ona viloyati',
			'masters.samarkandRegion' => 'Samarqand viloyati',
			'masters.andijanRegion' => 'Andijon viloyati',
			'masters.namanganRegion' => 'Namangan viloyati',
			'masters.bukharaRegion' => 'Buxoro viloyati',
			'masters.khorezmRegion' => 'Xorazm viloyati',
			'masters.kashkadaryaRegion' => 'Qashqadaryo viloyati',
			'masters.surkhandaryaRegion' => 'Surxondaryo viloyati',
			'masters.callMaster' => 'Usta chaqirish',
			'masters.aboutMaster' => 'Usta haqida',
			'masters.searchHint' => 'Ism, yo\'nalish yoki telefon raqam',
			'masters.noName' => 'Ism ko\'rsatilmagan',
			'masters.noSpecialty' => 'Yo\'nalish ko\'rsatilmagan',
			'masters.noExperience' => 'Tajriba ko\'rsatilmagan',
			'masters.experienceYears' => ({required Object count}) => '${count} yil tajriba',
			'masters.noAddress' => 'Manzil yo\'q',
			'masters.completedOrders' => ({required Object count}) => '${count} ta ish',
			'masters.newMaster' => 'Yangi usta',
			'masters.loadFailed' => 'Ro\'yxat yuklanmadi',
			'masters.noMastersYet' => 'Hozircha usta yo\'q',
			'masters.searchNotFound' => ({required Object query}) => '"${query}" bo\'yicha usta topilmadi.',
			'masters.regionNotFound' => ({required Object region}) => '${region} da mos usta topilmadi.',
			'masters.specialtyNotFound' => 'Bu yo\'nalishda hali usta ro\'yxatdan o\'tmagan.',
			'masters.defaultEmpty' => 'Ustalar ro\'yxatdan o\'tgach shu yerda ko\'rinadi.',
			'masters.prices' => 'Narxlari',
			'masters.notRated' => 'Hali baholanmagan',
			'masters.rating' => 'Reyting',
			'masters.completed' => 'Bajarilgan',
			'masters.reviews' => 'Sharhlar',
			'appUpdate.eyebrow' => 'YANGILANISH',
			'appUpdate.titleOptional' => 'Yangi versiya tayyor',
			'appUpdate.titleRequired' => 'Yangilash talab qilinadi',
			'appUpdate.bodyOptional' => 'Ustachining yangi versiyasi chiqdi. Yangilasangiz oxirgi tuzatish va imkoniyatlar bilan ishlaysiz.',
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
