///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import
// dart format off

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:slang/generated.dart';
import 'strings.g.dart';

// Path: <root>
class TranslationsKk extends Translations with BaseTranslations<AppLocale, Translations> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	TranslationsKk({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.kk,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		super.$meta.setFlatMapFunction($meta.getTranslation); // copy base translations to super.$meta
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <kk>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	@override dynamic operator[](String key) => $meta.getTranslation(key) ?? super.$meta.getTranslation(key);

	late final TranslationsKk _root = this; // ignore: unused_field

	@override 
	TranslationsKk $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => TranslationsKk(meta: meta ?? this.$meta);

	// Translations
	@override String get applicationName => 'Ustachi';
	@override late final _TranslationsCommonKk common = _TranslationsCommonKk._(_root);
	@override late final _TranslationsOnboardingKk onboarding = _TranslationsOnboardingKk._(_root);
	@override late final _TranslationsAuthKk auth = _TranslationsAuthKk._(_root);
	@override late final _TranslationsCountryKk country = _TranslationsCountryKk._(_root);
	@override late final _TranslationsHomeKk home = _TranslationsHomeKk._(_root);
	@override late final _TranslationsCalculatePageKk calculatePage = _TranslationsCalculatePageKk._(_root);
	@override late final _TranslationsProfileKk profile = _TranslationsProfileKk._(_root);
	@override late final _TranslationsDashboardKk dashboard = _TranslationsDashboardKk._(_root);
	@override late final _TranslationsOrdersKk orders = _TranslationsOrdersKk._(_root);
	@override late final _TranslationsOwnOrdersKk ownOrders = _TranslationsOwnOrdersKk._(_root);
	@override late final _TranslationsOrderFormKk orderForm = _TranslationsOrderFormKk._(_root);
	@override late final _TranslationsChatKk chat = _TranslationsChatKk._(_root);
	@override late final _TranslationsNotificationsKk notifications = _TranslationsNotificationsKk._(_root);
	@override late final _TranslationsMastersKk masters = _TranslationsMastersKk._(_root);
	@override late final _TranslationsOrderFlowKk orderFlow = _TranslationsOrderFlowKk._(_root);
	@override late final _TranslationsCompanyKk company = _TranslationsCompanyKk._(_root);
	@override late final _TranslationsCompanyRatesKk companyRates = _TranslationsCompanyRatesKk._(_root);
	@override late final _TranslationsMaterialsKk materials = _TranslationsMaterialsKk._(_root);
	@override late final _TranslationsProfessionalKk professional = _TranslationsProfessionalKk._(_root);
	@override late final _TranslationsAppUpdateKk appUpdate = _TranslationsAppUpdateKk._(_root);
}

// Path: common
class _TranslationsCommonKk extends TranslationsCommonUz {
	_TranslationsCommonKk._(TranslationsKk root) : this._root = root, super.internal(root);

	final TranslationsKk _root; // ignore: unused_field

	// Translations
	@override String get ok => 'OK';
	@override String get start => 'Бастау';
	@override String get cancel => 'Болдырмау';
	@override String get save => 'Сақтау';
	@override String get delete => 'Жою';
	@override String get edit => 'Өңдеу';
	@override String get close => 'Жабу';
	@override String get back => 'Артқа';
	@override String get next => 'Келесі';
	@override String get skip => 'Өткізу';
	@override String get enter => 'Енгізіңіз';
	@override String get wentWrong => 'Қате шықты. Сәлден соң қайта көріңіз!';
	@override String get common => 'Негізгі';
	@override String get select => 'Таңдау';
	@override String get retry => 'Қайталау';
	@override String get refresh => 'Жаңарту';
	@override String get saved => 'Сақталды';
	@override String get saveFailed => 'Сақталмады — қайта көріңіз';
	@override String get notFound => 'Табылмады';
	@override String get empty => 'Бос';
	@override String get loading => 'Жүктелуде…';
	@override String get yes => 'Иә';
	@override String get no => 'Жоқ';
	@override String get add => 'Қосу';
	@override String get copy => 'Көшіру';
	@override String get apply => 'Қолдану';
	@override String get reset => 'Қайтару';
	@override String get done => 'Дайын';
	@override String get all => 'Барлығы';
	@override String get som => 'сом';
	@override String get cm => 'см';
	@override String get mm => 'мм';
	@override String get pcs => 'дана';
	@override String get hoursShort => 'сағ';
	@override String get minutesShort => 'мин';
	@override List<String> get months => [
		'қаңтар',
		'ақпан',
		'наурыз',
		'сәуір',
		'мамыр',
		'маусым',
		'шілде',
		'тамыз',
		'қыркүйек',
		'қазан',
		'қараша',
		'желтоқсан',
	];
	@override List<String> get weekdays => [
		'Жексенбі',
		'Дүйсенбі',
		'Сейсенбі',
		'Сәрсенбі',
		'Бейсенбі',
		'Жұма',
		'Сенбі',
	];
	@override String get today => 'Бүгін';
	@override String get tomorrow => 'Ертең';
	@override String get comingSoon => 'Жақында';
}

// Path: onboarding
class _TranslationsOnboardingKk extends TranslationsOnboardingUz {
	_TranslationsOnboardingKk._(TranslationsKk root) : this._root = root, super.internal(root);

	final TranslationsKk _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsOnboardingStep1Kk step1 = _TranslationsOnboardingStep1Kk._(_root);
	@override late final _TranslationsOnboardingStep2Kk step2 = _TranslationsOnboardingStep2Kk._(_root);
	@override late final _TranslationsOnboardingStep3Kk step3 = _TranslationsOnboardingStep3Kk._(_root);
}

// Path: auth
class _TranslationsAuthKk extends TranslationsAuthUz {
	_TranslationsAuthKk._(TranslationsKk root) : this._root = root, super.internal(root);

	final TranslationsKk _root; // ignore: unused_field

	// Translations
	@override String get tagline => 'ШЕБЕРДІҢ ЖҰМЫС КЕҢІСТІГІ';
	@override late final _TranslationsAuthCommonKk common = _TranslationsAuthCommonKk._(_root);
	@override late final _TranslationsAuthPhoneKk phone = _TranslationsAuthPhoneKk._(_root);
	@override late final _TranslationsAuthOtpKk otp = _TranslationsAuthOtpKk._(_root);
	@override late final _TranslationsAuthProfileKk profile = _TranslationsAuthProfileKk._(_root);
	@override late final _TranslationsAuthTelegramKk telegram = _TranslationsAuthTelegramKk._(_root);
}

// Path: country
class _TranslationsCountryKk extends TranslationsCountryUz {
	_TranslationsCountryKk._(TranslationsKk root) : this._root = root, super.internal(root);

	final TranslationsKk _root; // ignore: unused_field

	// Translations
	@override String get title => 'Елді таңдаңыз';
	@override String get subtitle => 'Қолданба тілі елге қарай таңдалады. Кейін профильде өзгерте аласыз.';
	@override String get continueBtn => 'Жалғастыру';
	@override String get changeTitle => 'Ел және тіл';
}

// Path: home
class _TranslationsHomeKk extends TranslationsHomeUz {
	_TranslationsHomeKk._(TranslationsKk root) : this._root = root, super.internal(root);

	final TranslationsKk _root; // ignore: unused_field

	// Translations
	@override String get main => 'Басты';
	@override String get chatting => 'Чат';
	@override String get profile => 'Профиль';
	@override String get title => 'Профиль';
	@override String get loadError => 'Профиль жүктелмеді';
	@override String get retry => 'Қайталау';
	@override String get phone => 'Телефон';
	@override String get role => 'Рөлі';
	@override String get status => 'Күйі';
	@override String get active => 'Белсенді';
	@override String get inactive => 'Белсенді емес';
	@override String get logout => 'Шығу';
	@override String get hi => 'Сәлем';
	@override String get serviceType => 'Қызмет түрлері';
	@override String get lastOrders => 'Соңғы тапсырыстар';
	@override String get all => 'Барлығы';
	@override String get tapRepair => 'Кран жөндеу';
	@override String get chandelierInstallation => 'Люстра орнату';
	@override String get completed => 'Орындалды';
	@override String get inProgress => 'Орындалуда';
	@override String get window => 'Терезе';
	@override String get furtiniture => 'Жиһаз';
	@override String get electric => 'Электрика';
	@override String get plumber => 'Сантехника';
}

// Path: calculatePage
class _TranslationsCalculatePageKk extends TranslationsCalculatePageUz {
	_TranslationsCalculatePageKk._(TranslationsKk root) : this._root = root, super.internal(root);

	final TranslationsKk _root; // ignore: unused_field

	// Translations
	@override String get window => 'Терезе';
	@override String get door => 'Есік';
	@override String get glass => 'Аркалар';
	@override String get windowConfigurator => 'Терезе конфигурациясы';
	@override String get windowLayouts => 'Бөліну түрлері';
	@override String get windowPremiumLayouts => 'Премиум нұсқалар';
	@override String get windowModernLayouts => 'Заманауи нұсқалар';
	@override String get doorConfigurator => 'Есік конфигурациясы';
	@override String get doorModels => 'Есік модельдері';
	@override String get doorExtraModels => 'Қосымша модельдер';
	@override String get material => 'Материал';
	@override String get plastic => 'Пластик';
	@override String get aluminium => 'Алюминий';
	@override String get termo => 'Термо';
	@override String get glassShowcase => 'Арка нұсқалары';
	@override String get customTemplateTitleWindow => 'Өз терезеңізді жасаңыз';
	@override String get customTemplateTitleDoor => 'Өз есігіңізді жасаңыз';
	@override String get customTemplateTitleArch => 'Өз аркаңызды жасаңыз';
	@override String get customTemplateSubtitle => 'Дайын үлгі емес — өлшем мен бөлінуді өзіңіз саласыз';
	@override String get customTemplateAction => 'Бастау';
	@override String get readyTemplates => 'Дайын үлгілер';
}

// Path: profile
class _TranslationsProfileKk extends TranslationsProfileUz {
	_TranslationsProfileKk._(TranslationsKk root) : this._root = root, super.internal(root);

	final TranslationsKk _root; // ignore: unused_field

	// Translations
	@override String get personalData => 'Жеке деректер';
	@override String get professional => 'Кәсіби деректер';
	@override String get company => 'Кәсіпорын';
	@override String get myOrders => 'Менің тапсырыстарым';
	@override String get settings => 'Параметрлер';
	@override String get support => 'Бізбен байланыс';
	@override String get logout => 'Шығу';
	@override String get logoutTitle => 'Аккаунттан шығасыз ба?';
	@override String get logoutMessage => 'Жүктелген бағалар мен есептеу деректері құрылғыдан өшіріледі. Қайта кіргенде олар қайтадан жүктеледі.';
	@override String get logoutConfirm => 'Иә, шығамын';
	@override String get loggingOut => 'Шығуда...';
	@override String get loggingOutHint => 'Сессия жабылып, баға кэші тазартылуда';
	@override String get logoutFailed => 'Серверден шығу мүмкін болмады, бірақ құрылғыдағы деректер тазартылды';
	@override late final _TranslationsProfilePersonalKk personal = _TranslationsProfilePersonalKk._(_root);
	@override late final _TranslationsProfileHelpKk help = _TranslationsProfileHelpKk._(_root);
}

// Path: dashboard
class _TranslationsDashboardKk extends TranslationsDashboardUz {
	_TranslationsDashboardKk._(TranslationsKk root) : this._root = root, super.internal(root);

	final TranslationsKk _root; // ignore: unused_field

	// Translations
	@override String get title => 'Жұмыс үстелі';
	@override String get greetingMorning => 'Қайырлы таң,';
	@override String get greetingDay => 'Қайырлы күн,';
	@override String get greetingEvening => 'Қайырлы кеш,';
	@override String get master => 'шебер';
	@override String get availableTitle => 'Тапсырыс қабылдаймын';
	@override String get availableOn => 'Жаңа сұраныстар келе береді';
	@override String get availableOff => 'Сұраныстар тоқтатылды';
	@override String get newRequests => 'Жаңа сұраныстар';
	@override String get activeOrders => 'Белсенді тапсырыстар';
	@override String get all => 'Барлығы';
	@override String get quickCalculate => 'Терезе сызбасы';
	@override String get quickCalculateHint => 'Терезе мен есік сызбасы';
	@override String get quickPortfolio => 'Жұмыс үлгісі';
	@override String get quickPortfolioHint => 'Аяқталған жұмыстан қосыңыз';
	@override String get emptyRequests => 'Жаңа сұраныс жоқ';
	@override String get emptyRequestsHint => 'Бос емес қосқышы қосулы болса, сұраныстар осында түседі.';
	@override String get quickCompany => 'Кәсіпорын';
	@override String get quickCompanyHint => 'Атауы және логотип';
	@override String get quickRates => 'Қызмет бағаларым';
	@override String get quickRatesHint => 'Сала бойынша жұмыс мөлшерлемелері';
	@override String get quickOrdersHeroTitle => 'Жаңа тапсырыстар және Базар';
	@override String get quickOrdersHeroHint => 'Саладағы хабарландыруларды көріп, ұсыныс жіберіңіз';
	@override String get quickOpenOrders => 'Ашық тапсырыстар';
	@override String get quickOpenOrdersHint => 'Шебері таңдалмаған хабарландырулар — ұсыныс жіберіңіз';
	@override String get calcStep1 => 'Жақтау таңдаңыз';
	@override String get calcStep2 => 'Баптаңыз';
	@override String get calcStep3 => 'Сызба дайын';
	@override String get repairTitle => 'Жөндеу тапсырыстарын қабылдаймын';
	@override String get repairOn => 'Жөндеу өтінімдері де келеді';
	@override String get repairOff => 'Жөндеу өтінімдері келмейді';
	@override String get repairHint => 'Ескі терезе мен есікті реттеу, фурнитура немесе әйнек ауыстыру';
}

// Path: orders
class _TranslationsOrdersKk extends TranslationsOrdersUz {
	_TranslationsOrdersKk._(TranslationsKk root) : this._root = root, super.internal(root);

	final TranslationsKk _root; // ignore: unused_field

	// Translations
	@override String get title => 'Тапсырыстар';
	@override String get segmentNew => 'Ашық';
	@override String get segmentActive => 'Орындалуда';
	@override String get segmentDone => 'Аяқталған';
	@override String stepOf({required Object total, required Object step}) => '${total} кезеңнің ${step}-і';
	@override String lateDays({required Object days}) => '${days} күн кешікті';
	@override String get dueToday => 'Мерзімі — бүгін';
	@override String daysLeft({required Object days}) => '${days} күн қалды';
	@override String get offerBtn => 'Ұсыныс беру';
	@override String get retry => 'Қайталау';
	@override String get loadFailed => 'Тапсырыстарды жүктеу мүмкін болмады';
	@override String get emptyNewTitle => 'Ашық тапсырыс жоқ';
	@override String get emptyNewMessage => 'Аймағыңызда жаңа хабарландыру пайда болғанда осында көрінеді.';
	@override String get emptyActiveTitle => 'Белсенді тапсырыс жоқ';
	@override String get emptyActiveMessage => 'Жаңа сұранысты қабылдасаңыз, ол осында пайда болады.';
	@override String get emptyDoneTitle => 'Аяқталған жұмыс жоқ';
	@override String get emptyDoneMessage => 'Алғашқы тапсырысты тапсырғаннан кейін ол осында көрінеді.';
	@override late final _TranslationsOrdersStageKk stage = _TranslationsOrdersStageKk._(_root);
	@override late final _TranslationsOrdersDetailKk detail = _TranslationsOrdersDetailKk._(_root);
	@override late final _TranslationsOrdersRequestKk request = _TranslationsOrdersRequestKk._(_root);
	@override late final _TranslationsOrdersSpecKk spec = _TranslationsOrdersSpecKk._(_root);
	@override String get invalidId => 'Тапсырыс нөмірі қате.';
	@override String get invalidRequestId => 'Сұраныс нөмірі қате.';
	@override late final _TranslationsOrdersOpenKk open = _TranslationsOrdersOpenKk._(_root);
	@override String get personalTitle => 'Менің тапсырыстарым';
}

// Path: ownOrders
class _TranslationsOwnOrdersKk extends TranslationsOwnOrdersUz {
	_TranslationsOwnOrdersKk._(TranslationsKk root) : this._root = root, super.internal(root);

	final TranslationsKk _root; // ignore: unused_field

	// Translations
	@override String get orderTitle => 'Тапсырыс';
	@override String itemsCount({required Object count}) => '${count} терезе';
	@override String get statusTitle => 'Тапсырыс күйі';
	@override String get statusRow => 'Күйі';
	@override String get saving => 'Сақталуда…';
	@override String get tapToChange => 'Өзгерту үшін басыңыз';
	@override String get alreadyDone => 'Бұл тапсырыс аяқталған.';
	@override String get cannotChange => 'Бұл тапсырыстың күйін өзгерту мүмкін емес.';
	@override late final _TranslationsOwnOrdersStatusKk status = _TranslationsOwnOrdersStatusKk._(_root);
	@override late final _TranslationsOwnOrdersHintKk hint = _TranslationsOwnOrdersHintKk._(_root);
}

// Path: orderForm
class _TranslationsOrderFormKk extends TranslationsOrderFormUz {
	_TranslationsOrderFormKk._(TranslationsKk root) : this._root = root, super.internal(root);

	final TranslationsKk _root; // ignore: unused_field

	// Translations
	@override String get noProducts => 'Тапсырыста бұйым жоқ.';
	@override String get queued => 'Интернет жоқ — тапсырыс кезекке қойылды, өзі жіберіледі.';
	@override String get saved => 'Тапсырыс сақталды';
	@override String get saveTitle => 'Тапсырысты сақтау';
	@override String get customer => 'Тапсырыс беруші';
	@override String get nameLabel => 'Аты';
	@override String get nameHint => 'Азиз';
	@override String get nameRequired => 'Атын жазыңыз';
	@override String get addressHint => 'Чиланзар 9-шағын аудан';
	@override String get noteLabel => 'Қосымша түсініктеме';
	@override String get noteHint => '2-қабат, лифт жоқ';
	@override String itemsSummary({required Object kinds, required Object count}) => '${kinds} түрлі терезе · ${count} дана';
}

// Path: chat
class _TranslationsChatKk extends TranslationsChatUz {
	_TranslationsChatKk._(TranslationsKk root) : this._root = root, super.internal(root);

	final TranslationsKk _root; // ignore: unused_field

	// Translations
	@override String get threadsTitle => 'Әңгімелер';
	@override String get conversation => 'Әңгіме';
	@override String get messageHint => 'Хабар жазыңыз...';
	@override String get emptyChat => 'Баға мен шартты осында келісесіз';
	@override String get emptyThreadsTitle => 'Әзірге әңгіме жоқ';
	@override String get emptyThreadsMessage => 'Шебер тапсырысыңызға жауап бергенде осында жазысасыз.';
}

// Path: notifications
class _TranslationsNotificationsKk extends TranslationsNotificationsUz {
	_TranslationsNotificationsKk._(TranslationsKk root) : this._root = root, super.internal(root);

	final TranslationsKk _root; // ignore: unused_field

	// Translations
	@override String get title => 'Хабарламалар';
	@override String get markAllRead => 'Барлығын оқылды деу';
	@override String get empty => 'Хабарлама жоқ';
	@override String get open => 'Ашу';
}

// Path: masters
class _TranslationsMastersKk extends TranslationsMastersUz {
	_TranslationsMastersKk._(TranslationsKk root) : this._root = root, super.internal(root);

	final TranslationsKk _root; // ignore: unused_field

	// Translations
	@override String get title => 'Шебер туралы';
	@override String get master => 'Шебер';
	@override String get client => 'Клиент';
	@override String get write => 'Жазу';
	@override String get chooseThis => 'Осы шеберді таңдау';
	@override String get choose => 'Таңдау';
	@override String get chosen => 'Таңдалған шебер';
	@override String get notFound => 'Дерек табылмады';
	@override String get works => 'Атқарған жұмыстары';
	@override String reviews({required Object count}) => 'Пікірлер (${count})';
	@override String get reviewsLabel => 'Пікірлер';
	@override String get noReviews => 'Әзірге пікір жоқ — бірінші сіз бола аласыз.';
	@override String experienceYears({required Object years}) => '${years} жыл тәжірибе';
	@override String get rating => 'Рейтинг';
	@override String get completed => 'Орындалды';
	@override String responses({required Object count}) => '${count} жауап';
	@override String get estimate => 'Есеп';
}

// Path: orderFlow
class _TranslationsOrderFlowKk extends TranslationsOrderFlowUz {
	_TranslationsOrderFlowKk._(TranslationsKk root) : this._root = root, super.internal(root);

	final TranslationsKk _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsOrderFlowStatusKk status = _TranslationsOrderFlowStatusKk._(_root);
	@override late final _TranslationsOrderFlowStageKk stage = _TranslationsOrderFlowStageKk._(_root);
	@override late final _TranslationsOrderFlowResponseKk response = _TranslationsOrderFlowResponseKk._(_root);
}

// Path: company
class _TranslationsCompanyKk extends TranslationsCompanyUz {
	_TranslationsCompanyKk._(TranslationsKk root) : this._root = root, super.internal(root);

	final TranslationsKk _root; // ignore: unused_field

	// Translations
	@override String get title => 'Кәсіпорын';
	@override String get nameLabel => 'Кәсіпорын атауы';
	@override String get nameHint => 'Мысалы: Ustachi Servis';
	@override String get nameEmpty => 'Кәсіпорын атауы енгізілмеген';
	@override String get nameNote => 'Тапсырыс парағында көрінеді';
	@override String get logoHint => 'Логотип қосу';
}

// Path: companyRates
class _TranslationsCompanyRatesKk extends TranslationsCompanyRatesUz {
	_TranslationsCompanyRatesKk._(TranslationsKk root) : this._root = root, super.internal(root);

	final TranslationsKk _root; // ignore: unused_field

	// Translations
	@override String get onlyDigits => 'Тек сандар';
}

// Path: materials
class _TranslationsMaterialsKk extends TranslationsMaterialsUz {
	_TranslationsMaterialsKk._(TranslationsKk root) : this._root = root, super.internal(root);

	final TranslationsKk _root; // ignore: unused_field

	// Translations
	@override String get title => 'Материалдар';
	@override String get on => 'Осы материалмен жұмыс істеймін — тапсырыстар келеді';
	@override String get off => 'Өшірулі — осы материалға тапсырыстар келмейді';
	@override String get allOff => 'Кемінде бір материал қосулы болуы керек';
}

// Path: professional
class _TranslationsProfessionalKk extends TranslationsProfessionalUz {
	_TranslationsProfessionalKk._(TranslationsKk root) : this._root = root, super.internal(root);

	final TranslationsKk _root; // ignore: unused_field

	// Translations
	@override String get title => 'Кәсіби деректер';
	@override String get headline => 'Қандай шебер екеніңізді айтыңыз';
	@override String get headlineHint => 'Клиент сізді таңдамас бұрын осы деректі көреді. Кейін кез келген уақытта өзгерте аласыз.';
	@override String get specialty => 'Бағыттар';
	@override String get specialtyPick => 'Бағыттарыңызды таңдаңыз';
	@override String get specialtyLoadFailed => 'Бағыттар тізімі жүктелмеді — интернетті тексеріп, қайта кіріңіз.';
	@override String get experienceQuestion => 'Тәжірибеңіз неше жыл?';
	@override String get experienceHint => 'Мысалы: 5';
	@override String get experienceRequired => 'Тәжірибені енгізіңіз';
	@override String get experienceRange => 'Тәжірибе 0 мен 70 аралығында болуы керек';
	@override String get aboutLabel => 'Өзіңіз туралы (міндетті емес)';
	@override String get aboutHint => 'Қандай жұмыс істейсіз, неге көңіл бөлесіз — қысқаша жазыңыз.';
	@override String get works => 'Жұмыстарыңыз';
	@override String get worksHint => 'Сурет қоссаңыз, клиент жұмысыңызды көреді және сізді таңдау ықтималдығы артады. Міндетті емес — кейін де қосуға болады.';
	@override String get deleteSampleTitle => 'Үлгіні жоясыз ба?';
	@override String get deleteSampleMessage => 'Клиенттер бұл суретті бұдан былай көрмейді.';
	@override String get deleteFailed => 'Жойылмады';
	@override String get pickSpecialty => 'Кемінде бір бағыт таңдаңыз';
	@override String get specialtyHint => 'Бірнешеуін таңдауға болады — тапсырыс тек осы бағыттар бойынша келеді.';
}

// Path: appUpdate
class _TranslationsAppUpdateKk extends TranslationsAppUpdateUz {
	_TranslationsAppUpdateKk._(TranslationsKk root) : this._root = root, super.internal(root);

	final TranslationsKk _root; // ignore: unused_field

	// Translations
	@override String get eyebrow => 'ЖАҢАРТУ';
	@override String get titleOptional => 'Жаңа нұсқа дайын';
	@override String get titleRequired => 'Жаңарту қажет';
	@override String get bodyOptional => 'Ustachi Pro-ның жаңа нұсқасы шықты. Соңғы түзетулер мен мүмкіндіктер үшін жаңартыңыз.';
	@override String get bodyRequired => 'Бұл нұсқа енді қолдау көрмейді. Қолданбаны пайдалануды жалғастыру үшін жаңартыңыз.';
	@override String get whatsNew => 'НЕ ЖАҢАРДЫ';
	@override String get versionFrom => 'Сізде';
	@override String get versionTo => 'Жаңа';
	@override String get update => 'Жаңарту';
	@override String get later => 'Кейінірек';
	@override String get openFailed => 'Сілтемені ашу мүмкін болмады. Қолданбаны дүкеннен қолмен жаңартыңыз.';
}

// Path: onboarding.step1
class _TranslationsOnboardingStep1Kk extends TranslationsOnboardingStep1Uz {
	_TranslationsOnboardingStep1Kk._(TranslationsKk root) : this._root = root, super.internal(root);

	final TranslationsKk _root; // ignore: unused_field

	// Translations
	@override String get title => 'Өз бағытыңызды таңдаңыз';
	@override String get description => 'Терезе, шатыр, кірпіш, электрик, сантехник, кафель, бояу… 25-тен астам бағыт. Тапсырыстар сіздің бағытыңыз бойынша келеді.';
}

// Path: onboarding.step2
class _TranslationsOnboardingStep2Kk extends TranslationsOnboardingStep2Uz {
	_TranslationsOnboardingStep2Kk._(TranslationsKk root) : this._root = root, super.internal(root);

	final TranslationsKk _root; // ignore: unused_field

	// Translations
	@override String get title => 'Тапсырыс өзі табады';
	@override String get description => 'Аймағыңыз бен бағытыңызға сай жаңа хабарландырулар бірден хабарлама болып келеді — іздеудің қажеті жоқ.';
}

// Path: onboarding.step3
class _TranslationsOnboardingStep3Kk extends TranslationsOnboardingStep3Uz {
	_TranslationsOnboardingStep3Kk._(TranslationsKk root) : this._root = root, super.internal(root);

	final TranslationsKk _root; // ignore: unused_field

	// Translations
	@override String get title => 'Бағаны өзіңіз белгілейсіз';
	@override String get description => 'Өз бағаңызды енгізесіз, тапсырыс берушімен чатта келісесіз және жұмыс кезеңдерін белгілеп отырасыз.';
}

// Path: auth.common
class _TranslationsAuthCommonKk extends TranslationsAuthCommonUz {
	_TranslationsAuthCommonKk._(TranslationsKk root) : this._root = root, super.internal(root);

	final TranslationsKk _root; // ignore: unused_field

	// Translations
	@override String get invalidPhone => 'Телефон нөмірін дұрыс енгізіңіз';
	@override String get cancel => 'Болдырмау';
}

// Path: auth.phone
class _TranslationsAuthPhoneKk extends TranslationsAuthPhoneUz {
	_TranslationsAuthPhoneKk._(TranslationsKk root) : this._root = root, super.internal(root);

	final TranslationsKk _root; // ignore: unused_field

	// Translations
	@override String get title => 'Қолданбаға кіру';
	@override String get subtitle => 'Нөміріңізді енгізіңіз — SMS арқылы 6 таңбалы код жібереміз. Құпия сөз керек емес.';
	@override String get label => 'Телефон нөмірі';
	@override String get continueBtn => 'Жалғастыру';
	@override String get orOption => 'немесе';
	@override String get telegramBtn => 'Telegram арқылы кіру';
	@override String get telegramHint => 'Бот кіру үшін Telegram аккаунтыңызға байланысты нөмірді сұрайды. SMS жіберілмейді.';
	@override String get telegramOpenError => 'Telegram ботын ашу мүмкін болмады. Қайта көріңіз.';
	@override String get agreementPrefix => 'Жалғастыру арқылы сіз ';
	@override String get terms => 'Пайдалану шарттарымен';
	@override String get and => ' және ';
	@override String get privacy => 'Құпиялылық саясатымен';
	@override String get agreementSuffix => ' келісесіз.';
	@override String get audienceRedirect => 'Шебер іздесеңіз — «Ustachi» жүктеңіз';
	@override String get audienceTitle => 'Назар аударыңыз: қосымша шеберлерге';
}

// Path: auth.otp
class _TranslationsAuthOtpKk extends TranslationsAuthOtpUz {
	_TranslationsAuthOtpKk._(TranslationsKk root) : this._root = root, super.internal(root);

	final TranslationsKk _root; // ignore: unused_field

	// Translations
	@override String get title => 'Кодты енгізіңіз';
	@override String sentMessage({required Object phone}) => '${phone} нөміріне жіберілген 6 таңбалы кодты енгізіңіз';
	@override String get invalidCode => '6 таңбаның барлығын енгізіңіз';
	@override String get resend => 'Кодты қайта жіберу';
	@override String get resendIn => 'Қайта жіберу';
	@override String get confirmBtn => 'Растау';
	@override String get changeNumber => 'Басқа нөмір енгізу';
}

// Path: auth.profile
class _TranslationsAuthProfileKk extends TranslationsAuthProfileUz {
	_TranslationsAuthProfileKk._(TranslationsKk root) : this._root = root, super.internal(root);

	final TranslationsKk _root; // ignore: unused_field

	// Translations
	@override String get title => 'Өзіңіз туралы';
	@override String get subtitle => 'Клиенттер сізді осы атпен көреді. Кейін профильде өзгерте аласыз.';
	@override String get fullNameLabel => 'Аты-жөні';
	@override String get fullNameHint => 'Енгізіңіз';
	@override String get requiredName => 'Аты-жөніңізді енгізіңіз';
	@override String get addPhoto => 'Сурет қосу';
	@override String get changePhoto => 'Суретті ауыстыру';
	@override String get saveBtn => 'Сақтап, жалғастыру';
	@override String get skip => 'Кейін толтырамын';
	@override String get regionLabel => 'Облыс';
	@override String get regionHint => 'Облысты таңдаңыз';
	@override String get districtLabel => 'Аудан / қала';
	@override String get districtHint => 'Ауданды таңдаңыз';
	@override String get addressLabel => 'Мекенжай';
	@override String get addressHint => 'Көше, үй нөмірі';
	@override String get requiredRegion => 'Облысты таңдаңыз';
	@override String get requiredDistrict => 'Ауданды таңдаңыз';
	@override String get loadFailed => 'Тізімді жүктеу мүмкін болмады';
}

// Path: auth.telegram
class _TranslationsAuthTelegramKk extends TranslationsAuthTelegramUz {
	_TranslationsAuthTelegramKk._(TranslationsKk root) : this._root = root, super.internal(root);

	final TranslationsKk _root; // ignore: unused_field

	// Translations
	@override String get loadingTitle => 'Telegram арқылы кіру';
	@override String get loadingHint => 'Бір реттік сілтеме тексерілуде…';
	@override String get invalidLink => 'Telegram сілтемесі жарамсыз.';
	@override String get expiredLink => 'Сілтеменің мерзімі өтті немесе бұрын пайдаланылған. Ботта қайтадан бастаңыз.';
	@override String get retry => 'Қайталау';
	@override String get restartBot => 'Ботта қайта бастау';
	@override String get smsOption => 'SMS арқылы кіру';
}

// Path: profile.personal
class _TranslationsProfilePersonalKk extends TranslationsProfilePersonalUz {
	_TranslationsProfilePersonalKk._(TranslationsKk root) : this._root = root, super.internal(root);

	final TranslationsKk _root; // ignore: unused_field

	// Translations
	@override String get sectionPersonal => 'Жеке';
	@override String get sectionAddress => 'Мекенжай';
	@override String get sectionProfessional => 'Кәсіби';
	@override String get phoneLabel => 'Телефон';
	@override String get phoneNote => 'Нөмір — аккаунт идентификаторы, өзгермейді';
	@override String get joinedLabel => 'Тіркелген';
	@override String get empty => 'Көрсетілмеген';
	@override String get edit => 'Өңдеу';
	@override String get openProfessional => 'Мамандық, тәжірибе және жұмыстар';
	@override String get loadFailed => 'Деректерді жүктеу мүмкін болмады';
}

// Path: profile.help
class _TranslationsProfileHelpKk extends TranslationsProfileHelpUz {
	_TranslationsProfileHelpKk._(TranslationsKk root) : this._root = root, super.internal(root);

	final TranslationsKk _root; // ignore: unused_field

	// Translations
	@override String get subtitle => 'Сұрақ немесе мәселе болса — жазыңыз не қоңырау шалыңыз';
	@override String get callLabel => 'Қоңырау шалу';
	@override String get emailLabel => 'Электрондық пошта';
	@override String get telegramLabel => 'Telegram арнамыз';
	@override String get telegramHint => 'Жаңалықтар мен хабарландырулар';
	@override String get workHours => 'Дс–сб, 9:00–19:00';
	@override String get copied => 'Көшірілді';
}

// Path: orders.stage
class _TranslationsOrdersStageKk extends TranslationsOrdersStageUz {
	_TranslationsOrdersStageKk._(TranslationsKk root) : this._root = root, super.internal(root);

	final TranslationsKk _root; // ignore: unused_field

	// Translations
	@override String get accepted => 'Ұсыныс қабылданды';
	@override String get measured => 'Өлшем алынды';
	@override String get production => 'Өндіріс';
	@override String get installation => 'Орнату';
	@override String get handover => 'Тапсыру және төлем';
}

// Path: orders.detail
class _TranslationsOrdersDetailKk extends TranslationsOrdersDetailUz {
	_TranslationsOrdersDetailKk._(TranslationsKk root) : this._root = root, super.internal(root);

	final TranslationsKk _root; // ignore: unused_field

	// Translations
	@override String get stages => 'Кезеңдер';
	@override String get spec => 'Спецификация';
	@override String get client => 'Клиент';
	@override String get total => 'Барлығы';
	@override String get prepaid => 'Алдын ала төлем';
	@override String get remaining => 'Қалдық';
	@override String get dueDate => 'Келісілген мерзім';
	@override String get finishOrder => 'Тапсырып, аяқтау';
	@override String get completed => 'Тапсырыс аяқталды';
	@override String stageDone({required Object stage}) => '${stage} аяқталды';
	@override String get notFound => 'Тапсырыс табылмады';
	@override String get drawings => 'Сызбалар';
	@override String get drawingsHint => 'Екі саусақпен үлкейтіңіз · өлшемдер мм-де';
	@override String get markMeasured => 'Өлшем алынды';
	@override String get markProduction => 'Өндіріс басталды';
	@override String get markInstallation => 'Орнатуға шықтық';
	@override String get stageSaved => 'Белгіленді — клиентке хабар кетті';
}

// Path: orders.request
class _TranslationsOrdersRequestKk extends TranslationsOrdersRequestUz {
	_TranslationsOrdersRequestKk._(TranslationsKk root) : this._root = root, super.internal(root);

	final TranslationsKk _root; // ignore: unused_field

	// Translations
	@override String get title => 'Сұраныс';
	@override String get clientSpec => 'Клиент есептеген спецификация';
	@override String get priceOffer => 'Баға ұсынысы';
	@override String get serviceFee => 'Монтаж және жеткізу';
	@override String get yourOffer => 'Сіздің ұсынысыңыз';
	@override String get workDays => 'Мерзім — жұмыс күні';
	@override String get note => 'Түсініктеме (міндетті емес)';
	@override String get notePlaceholder => 'Клиентке қосымша түсініктеме…';
	@override String get send => 'Ұсынысты жіберу';
	@override String get decline => 'Бас тарту';
	@override String get declineTitle => 'Сұранысты қабылдамайсыз ба?';
	@override String get declineMessage => 'Бұл сұраныс тізімнен мүлдем жойылады.';
	@override String expiresIn({required Object time}) => '${time} қалды';
	@override String get expired => 'Мерзімі өтті';
	@override String distance({required Object km}) => '${km} км';
	@override String get sent => 'Ұсыныс жіберілді';
	@override String get invalidFee => 'Жұмыс ақысы теріс бола алмайды';
	@override String get chatNote => 'Баға мен шартты клиентпен чатта келісесіз.';
	@override String get withdrawOffer => 'Ұсынысты қайтарып алу';
	@override String get declineInviteTitle => 'Ұсынысты қабылдамайсыз ба?';
	@override String get declineInviteMessage => 'Клиентке дереу хабар барады және ол басқа шебер таңдайды.';
	@override String get clientPrice => 'Тапсырыс бағасы';
	@override String get priceInChat => 'Баға чатта келісіледі';
}

// Path: orders.spec
class _TranslationsOrdersSpecKk extends TranslationsOrdersSpecUz {
	_TranslationsOrdersSpecKk._(TranslationsKk root) : this._root = root, super.internal(root);

	final TranslationsKk _root; // ignore: unused_field

	// Translations
	@override String get size => 'Өлшемі (мм)';
	@override String get shape => 'Пішіні';
	@override String get brand => 'Бренд';
	@override String get color => 'Түсі';
	@override String get material => 'Материал';
	@override String get glass => 'Шыны';
	@override String get sill => 'Терезе алды (см)';
	@override String get flower => 'Өрнек';
	@override String get address => 'Мекенжай';
	@override String get product => 'Бұйымдар';
	@override String get phone => 'Телефон';
	@override String get discount => 'Жеңілдік';
	@override String get note => 'Түсініктеме';
	@override String itemsValue({required Object kinds, required Object count}) => '${kinds} түр · ${count} дана';
	@override late final _TranslationsOrdersSpecValuesKk values = _TranslationsOrdersSpecValuesKk._(_root);
	@override String get area => 'Аумағы';
	@override String get unitPrice => '1 м² бағасы';
	@override String get variant => 'Деңгей';
}

// Path: orders.open
class _TranslationsOrdersOpenKk extends TranslationsOrdersOpenUz {
	_TranslationsOrdersOpenKk._(TranslationsKk root) : this._root = root, super.internal(root);

	final TranslationsKk _root; // ignore: unused_field

	// Translations
	@override String get offerSent => 'Ұсыныс жіберілді';
	@override String get waitingClient => 'Клиенттің жауабын күтуде';
	@override String offersCount({required Object count}) => '${count} ұсыныс';
	@override String get beFirst => 'Бірінші болыңыз';
	@override String get newBadge => 'Жаңа';
	@override String get pageTitle => 'Ашық тапсырыстар';
	@override String get tabWaiting => 'Жауап күтуде';
	@override String get tabSent => 'Ұсыныс жіберілді';
	@override String get emptySentTitle => 'Жіберілген ұсыныс жоқ';
	@override String get emptySentMessage => 'Жауап берген хабарландыруларыңыз осында клиенттің жауабын күтеді.';
	@override String get tabInvited => 'Сізге ұсыныс';
	@override String get invitedBadge => 'Сізге ұсыныс';
	@override String get acceptInvite => 'Қабылдаймын';
	@override String get emptyInvitedTitle => 'Жеке ұсыныс жоқ';
	@override String get emptyInvitedMessage => 'Клиент сізді таңдаған тапсырыстар осы жерде көрінеді.';
	@override String get invitedNote => 'Клиент бұл тапсырысты тікелей сізге жіберді — басқа шеберлер көрмейді.';
	@override String get repairBadge => 'Жөндеу';
}

// Path: ownOrders.status
class _TranslationsOwnOrdersStatusKk extends TranslationsOwnOrdersStatusUz {
	_TranslationsOwnOrdersStatusKk._(TranslationsKk root) : this._root = root, super.internal(root);

	final TranslationsKk _root; // ignore: unused_field

	// Translations
	@override String get draft => 'Жоба';
	@override String get newOrder => 'Жаңа';
	@override String get inProgress => 'Орындалуда';
	@override String get done => 'Аяқталды';
	@override String get debt => 'Қарыз бар';
	@override String get cancelled => 'Бас тартылды';
}

// Path: ownOrders.hint
class _TranslationsOwnOrdersHintKk extends TranslationsOwnOrdersHintUz {
	_TranslationsOwnOrdersHintKk._(TranslationsKk root) : this._root = root, super.internal(root);

	final TranslationsKk _root; // ignore: unused_field

	// Translations
	@override String get newOrder => 'Қабылданды, әлі басталмады';
	@override String get inProgress => 'Өндіріс не монтаж жүріп жатыр';
	@override String get done => 'Тапсырылды және толық төленді';
	@override String get debt => 'Жұмыс бітті, бірақ төлем толық емес';
	@override String get cancelled => 'Тапсырыс тоқтатылды';
}

// Path: orderFlow.status
class _TranslationsOrderFlowStatusKk extends TranslationsOrderFlowStatusUz {
	_TranslationsOrderFlowStatusKk._(TranslationsKk root) : this._root = root, super.internal(root);

	final TranslationsKk _root; // ignore: unused_field

	// Translations
	@override String get published => 'Жарияланды';
	@override String get assigned => 'Шебер таңдалды';
	@override String get completed => 'Аяқталды';
	@override String get cancelled => 'Бас тартылды';
	@override String get expired => 'Мерзімі өтті';
}

// Path: orderFlow.stage
class _TranslationsOrderFlowStageKk extends TranslationsOrderFlowStageUz {
	_TranslationsOrderFlowStageKk._(TranslationsKk root) : this._root = root, super.internal(root);

	final TranslationsKk _root; // ignore: unused_field

	// Translations
	@override String get accepted => 'Қабылданды';
	@override String get measured => 'Өлшем алынды';
	@override String get production => 'Өндіріс';
	@override String get installation => 'Орнату';
	@override String get handover => 'Тапсырылды';
}

// Path: orderFlow.response
class _TranslationsOrderFlowResponseKk extends TranslationsOrderFlowResponseUz {
	_TranslationsOrderFlowResponseKk._(TranslationsKk root) : this._root = root, super.internal(root);

	final TranslationsKk _root; // ignore: unused_field

	// Translations
	@override String get interested => 'Қабылдаймын';
	@override String get withdrawn => 'Бас тартты';
	@override String get chosen => 'Таңдалды';
	@override String get rejected => 'Таңдалмады';
}

// Path: orders.spec.values
class _TranslationsOrdersSpecValuesKk extends TranslationsOrdersSpecValuesUz {
	_TranslationsOrdersSpecValuesKk._(TranslationsKk root) : this._root = root, super.internal(root);

	final TranslationsKk _root; // ignore: unused_field

	// Translations
	@override String get plastic => 'Пластик';
	@override String get aluminium => 'Алюминий';
	@override String get termo => 'Термо';
	@override String get doubleGlass => 'Екі қабат';
	@override String get singleGlass => 'Бір қабат';
	@override String get large => 'Үлкен';
	@override String get medium => 'Орташа';
	@override String get small => 'Кіші';
}

/// The flat map containing all translations for locale <kk>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on TranslationsKk {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'applicationName' => 'Ustachi',
			'common.ok' => 'OK',
			'common.start' => 'Бастау',
			'common.cancel' => 'Болдырмау',
			'common.save' => 'Сақтау',
			'common.delete' => 'Жою',
			'common.edit' => 'Өңдеу',
			'common.close' => 'Жабу',
			'common.back' => 'Артқа',
			'common.next' => 'Келесі',
			'common.skip' => 'Өткізу',
			'common.enter' => 'Енгізіңіз',
			'common.wentWrong' => 'Қате шықты. Сәлден соң қайта көріңіз!',
			'common.common' => 'Негізгі',
			'common.select' => 'Таңдау',
			'common.retry' => 'Қайталау',
			'common.refresh' => 'Жаңарту',
			'common.saved' => 'Сақталды',
			'common.saveFailed' => 'Сақталмады — қайта көріңіз',
			'common.notFound' => 'Табылмады',
			'common.empty' => 'Бос',
			'common.loading' => 'Жүктелуде…',
			'common.yes' => 'Иә',
			'common.no' => 'Жоқ',
			'common.add' => 'Қосу',
			'common.copy' => 'Көшіру',
			'common.apply' => 'Қолдану',
			'common.reset' => 'Қайтару',
			'common.done' => 'Дайын',
			'common.all' => 'Барлығы',
			'common.som' => 'сом',
			'common.cm' => 'см',
			'common.mm' => 'мм',
			'common.pcs' => 'дана',
			'common.hoursShort' => 'сағ',
			'common.minutesShort' => 'мин',
			'common.months.0' => 'қаңтар',
			'common.months.1' => 'ақпан',
			'common.months.2' => 'наурыз',
			'common.months.3' => 'сәуір',
			'common.months.4' => 'мамыр',
			'common.months.5' => 'маусым',
			'common.months.6' => 'шілде',
			'common.months.7' => 'тамыз',
			'common.months.8' => 'қыркүйек',
			'common.months.9' => 'қазан',
			'common.months.10' => 'қараша',
			'common.months.11' => 'желтоқсан',
			'common.weekdays.0' => 'Жексенбі',
			'common.weekdays.1' => 'Дүйсенбі',
			'common.weekdays.2' => 'Сейсенбі',
			'common.weekdays.3' => 'Сәрсенбі',
			'common.weekdays.4' => 'Бейсенбі',
			'common.weekdays.5' => 'Жұма',
			'common.weekdays.6' => 'Сенбі',
			'common.today' => 'Бүгін',
			'common.tomorrow' => 'Ертең',
			'common.comingSoon' => 'Жақында',
			'onboarding.step1.title' => 'Өз бағытыңызды таңдаңыз',
			'onboarding.step1.description' => 'Терезе, шатыр, кірпіш, электрик, сантехник, кафель, бояу… 25-тен астам бағыт. Тапсырыстар сіздің бағытыңыз бойынша келеді.',
			'onboarding.step2.title' => 'Тапсырыс өзі табады',
			'onboarding.step2.description' => 'Аймағыңыз бен бағытыңызға сай жаңа хабарландырулар бірден хабарлама болып келеді — іздеудің қажеті жоқ.',
			'onboarding.step3.title' => 'Бағаны өзіңіз белгілейсіз',
			'onboarding.step3.description' => 'Өз бағаңызды енгізесіз, тапсырыс берушімен чатта келісесіз және жұмыс кезеңдерін белгілеп отырасыз.',
			'auth.tagline' => 'ШЕБЕРДІҢ ЖҰМЫС КЕҢІСТІГІ',
			'auth.common.invalidPhone' => 'Телефон нөмірін дұрыс енгізіңіз',
			'auth.common.cancel' => 'Болдырмау',
			'auth.phone.title' => 'Қолданбаға кіру',
			'auth.phone.subtitle' => 'Нөміріңізді енгізіңіз — SMS арқылы 6 таңбалы код жібереміз. Құпия сөз керек емес.',
			'auth.phone.label' => 'Телефон нөмірі',
			'auth.phone.continueBtn' => 'Жалғастыру',
			'auth.phone.orOption' => 'немесе',
			'auth.phone.telegramBtn' => 'Telegram арқылы кіру',
			'auth.phone.telegramHint' => 'Бот кіру үшін Telegram аккаунтыңызға байланысты нөмірді сұрайды. SMS жіберілмейді.',
			'auth.phone.telegramOpenError' => 'Telegram ботын ашу мүмкін болмады. Қайта көріңіз.',
			'auth.phone.agreementPrefix' => 'Жалғастыру арқылы сіз ',
			'auth.phone.terms' => 'Пайдалану шарттарымен',
			'auth.phone.and' => ' және ',
			'auth.phone.privacy' => 'Құпиялылық саясатымен',
			'auth.phone.agreementSuffix' => ' келісесіз.',
			'auth.phone.audienceRedirect' => 'Шебер іздесеңіз — «Ustachi» жүктеңіз',
			'auth.phone.audienceTitle' => 'Назар аударыңыз: қосымша шеберлерге',
			'auth.otp.title' => 'Кодты енгізіңіз',
			'auth.otp.sentMessage' => ({required Object phone}) => '${phone} нөміріне жіберілген 6 таңбалы кодты енгізіңіз',
			'auth.otp.invalidCode' => '6 таңбаның барлығын енгізіңіз',
			'auth.otp.resend' => 'Кодты қайта жіберу',
			'auth.otp.resendIn' => 'Қайта жіберу',
			'auth.otp.confirmBtn' => 'Растау',
			'auth.otp.changeNumber' => 'Басқа нөмір енгізу',
			'auth.profile.title' => 'Өзіңіз туралы',
			'auth.profile.subtitle' => 'Клиенттер сізді осы атпен көреді. Кейін профильде өзгерте аласыз.',
			'auth.profile.fullNameLabel' => 'Аты-жөні',
			'auth.profile.fullNameHint' => 'Енгізіңіз',
			'auth.profile.requiredName' => 'Аты-жөніңізді енгізіңіз',
			'auth.profile.addPhoto' => 'Сурет қосу',
			'auth.profile.changePhoto' => 'Суретті ауыстыру',
			'auth.profile.saveBtn' => 'Сақтап, жалғастыру',
			'auth.profile.skip' => 'Кейін толтырамын',
			'auth.profile.regionLabel' => 'Облыс',
			'auth.profile.regionHint' => 'Облысты таңдаңыз',
			'auth.profile.districtLabel' => 'Аудан / қала',
			'auth.profile.districtHint' => 'Ауданды таңдаңыз',
			'auth.profile.addressLabel' => 'Мекенжай',
			'auth.profile.addressHint' => 'Көше, үй нөмірі',
			'auth.profile.requiredRegion' => 'Облысты таңдаңыз',
			'auth.profile.requiredDistrict' => 'Ауданды таңдаңыз',
			'auth.profile.loadFailed' => 'Тізімді жүктеу мүмкін болмады',
			'auth.telegram.loadingTitle' => 'Telegram арқылы кіру',
			'auth.telegram.loadingHint' => 'Бір реттік сілтеме тексерілуде…',
			'auth.telegram.invalidLink' => 'Telegram сілтемесі жарамсыз.',
			'auth.telegram.expiredLink' => 'Сілтеменің мерзімі өтті немесе бұрын пайдаланылған. Ботта қайтадан бастаңыз.',
			'auth.telegram.retry' => 'Қайталау',
			'auth.telegram.restartBot' => 'Ботта қайта бастау',
			'auth.telegram.smsOption' => 'SMS арқылы кіру',
			'country.title' => 'Елді таңдаңыз',
			'country.subtitle' => 'Қолданба тілі елге қарай таңдалады. Кейін профильде өзгерте аласыз.',
			'country.continueBtn' => 'Жалғастыру',
			'country.changeTitle' => 'Ел және тіл',
			'home.main' => 'Басты',
			'home.chatting' => 'Чат',
			'home.profile' => 'Профиль',
			'home.title' => 'Профиль',
			'home.loadError' => 'Профиль жүктелмеді',
			'home.retry' => 'Қайталау',
			'home.phone' => 'Телефон',
			'home.role' => 'Рөлі',
			'home.status' => 'Күйі',
			'home.active' => 'Белсенді',
			'home.inactive' => 'Белсенді емес',
			'home.logout' => 'Шығу',
			'home.hi' => 'Сәлем',
			'home.serviceType' => 'Қызмет түрлері',
			'home.lastOrders' => 'Соңғы тапсырыстар',
			'home.all' => 'Барлығы',
			'home.tapRepair' => 'Кран жөндеу',
			'home.chandelierInstallation' => 'Люстра орнату',
			'home.completed' => 'Орындалды',
			'home.inProgress' => 'Орындалуда',
			'home.window' => 'Терезе',
			'home.furtiniture' => 'Жиһаз',
			'home.electric' => 'Электрика',
			'home.plumber' => 'Сантехника',
			'calculatePage.window' => 'Терезе',
			'calculatePage.door' => 'Есік',
			'calculatePage.glass' => 'Аркалар',
			'calculatePage.windowConfigurator' => 'Терезе конфигурациясы',
			'calculatePage.windowLayouts' => 'Бөліну түрлері',
			'calculatePage.windowPremiumLayouts' => 'Премиум нұсқалар',
			'calculatePage.windowModernLayouts' => 'Заманауи нұсқалар',
			'calculatePage.doorConfigurator' => 'Есік конфигурациясы',
			'calculatePage.doorModels' => 'Есік модельдері',
			'calculatePage.doorExtraModels' => 'Қосымша модельдер',
			'calculatePage.material' => 'Материал',
			'calculatePage.plastic' => 'Пластик',
			'calculatePage.aluminium' => 'Алюминий',
			'calculatePage.termo' => 'Термо',
			'calculatePage.glassShowcase' => 'Арка нұсқалары',
			'calculatePage.customTemplateTitleWindow' => 'Өз терезеңізді жасаңыз',
			'calculatePage.customTemplateTitleDoor' => 'Өз есігіңізді жасаңыз',
			'calculatePage.customTemplateTitleArch' => 'Өз аркаңызды жасаңыз',
			'calculatePage.customTemplateSubtitle' => 'Дайын үлгі емес — өлшем мен бөлінуді өзіңіз саласыз',
			'calculatePage.customTemplateAction' => 'Бастау',
			'calculatePage.readyTemplates' => 'Дайын үлгілер',
			'profile.personalData' => 'Жеке деректер',
			'profile.professional' => 'Кәсіби деректер',
			'profile.company' => 'Кәсіпорын',
			'profile.myOrders' => 'Менің тапсырыстарым',
			'profile.settings' => 'Параметрлер',
			'profile.support' => 'Бізбен байланыс',
			'profile.logout' => 'Шығу',
			'profile.logoutTitle' => 'Аккаунттан шығасыз ба?',
			'profile.logoutMessage' => 'Жүктелген бағалар мен есептеу деректері құрылғыдан өшіріледі. Қайта кіргенде олар қайтадан жүктеледі.',
			'profile.logoutConfirm' => 'Иә, шығамын',
			'profile.loggingOut' => 'Шығуда...',
			'profile.loggingOutHint' => 'Сессия жабылып, баға кэші тазартылуда',
			'profile.logoutFailed' => 'Серверден шығу мүмкін болмады, бірақ құрылғыдағы деректер тазартылды',
			'profile.personal.sectionPersonal' => 'Жеке',
			'profile.personal.sectionAddress' => 'Мекенжай',
			'profile.personal.sectionProfessional' => 'Кәсіби',
			'profile.personal.phoneLabel' => 'Телефон',
			'profile.personal.phoneNote' => 'Нөмір — аккаунт идентификаторы, өзгермейді',
			'profile.personal.joinedLabel' => 'Тіркелген',
			'profile.personal.empty' => 'Көрсетілмеген',
			'profile.personal.edit' => 'Өңдеу',
			'profile.personal.openProfessional' => 'Мамандық, тәжірибе және жұмыстар',
			'profile.personal.loadFailed' => 'Деректерді жүктеу мүмкін болмады',
			'profile.help.subtitle' => 'Сұрақ немесе мәселе болса — жазыңыз не қоңырау шалыңыз',
			'profile.help.callLabel' => 'Қоңырау шалу',
			'profile.help.emailLabel' => 'Электрондық пошта',
			'profile.help.telegramLabel' => 'Telegram арнамыз',
			'profile.help.telegramHint' => 'Жаңалықтар мен хабарландырулар',
			'profile.help.workHours' => 'Дс–сб, 9:00–19:00',
			'profile.help.copied' => 'Көшірілді',
			'dashboard.title' => 'Жұмыс үстелі',
			'dashboard.greetingMorning' => 'Қайырлы таң,',
			'dashboard.greetingDay' => 'Қайырлы күн,',
			'dashboard.greetingEvening' => 'Қайырлы кеш,',
			'dashboard.master' => 'шебер',
			'dashboard.availableTitle' => 'Тапсырыс қабылдаймын',
			'dashboard.availableOn' => 'Жаңа сұраныстар келе береді',
			'dashboard.availableOff' => 'Сұраныстар тоқтатылды',
			'dashboard.newRequests' => 'Жаңа сұраныстар',
			'dashboard.activeOrders' => 'Белсенді тапсырыстар',
			'dashboard.all' => 'Барлығы',
			'dashboard.quickCalculate' => 'Терезе сызбасы',
			'dashboard.quickCalculateHint' => 'Терезе мен есік сызбасы',
			'dashboard.quickPortfolio' => 'Жұмыс үлгісі',
			'dashboard.quickPortfolioHint' => 'Аяқталған жұмыстан қосыңыз',
			'dashboard.emptyRequests' => 'Жаңа сұраныс жоқ',
			'dashboard.emptyRequestsHint' => 'Бос емес қосқышы қосулы болса, сұраныстар осында түседі.',
			'dashboard.quickCompany' => 'Кәсіпорын',
			'dashboard.quickCompanyHint' => 'Атауы және логотип',
			'dashboard.quickRates' => 'Қызмет бағаларым',
			'dashboard.quickRatesHint' => 'Сала бойынша жұмыс мөлшерлемелері',
			'dashboard.quickOrdersHeroTitle' => 'Жаңа тапсырыстар және Базар',
			'dashboard.quickOrdersHeroHint' => 'Саладағы хабарландыруларды көріп, ұсыныс жіберіңіз',
			'dashboard.quickOpenOrders' => 'Ашық тапсырыстар',
			'dashboard.quickOpenOrdersHint' => 'Шебері таңдалмаған хабарландырулар — ұсыныс жіберіңіз',
			'dashboard.calcStep1' => 'Жақтау таңдаңыз',
			'dashboard.calcStep2' => 'Баптаңыз',
			'dashboard.calcStep3' => 'Сызба дайын',
			'dashboard.repairTitle' => 'Жөндеу тапсырыстарын қабылдаймын',
			'dashboard.repairOn' => 'Жөндеу өтінімдері де келеді',
			'dashboard.repairOff' => 'Жөндеу өтінімдері келмейді',
			'dashboard.repairHint' => 'Ескі терезе мен есікті реттеу, фурнитура немесе әйнек ауыстыру',
			'orders.title' => 'Тапсырыстар',
			'orders.segmentNew' => 'Ашық',
			'orders.segmentActive' => 'Орындалуда',
			'orders.segmentDone' => 'Аяқталған',
			'orders.stepOf' => ({required Object total, required Object step}) => '${total} кезеңнің ${step}-і',
			'orders.lateDays' => ({required Object days}) => '${days} күн кешікті',
			'orders.dueToday' => 'Мерзімі — бүгін',
			'orders.daysLeft' => ({required Object days}) => '${days} күн қалды',
			'orders.offerBtn' => 'Ұсыныс беру',
			'orders.retry' => 'Қайталау',
			'orders.loadFailed' => 'Тапсырыстарды жүктеу мүмкін болмады',
			'orders.emptyNewTitle' => 'Ашық тапсырыс жоқ',
			'orders.emptyNewMessage' => 'Аймағыңызда жаңа хабарландыру пайда болғанда осында көрінеді.',
			'orders.emptyActiveTitle' => 'Белсенді тапсырыс жоқ',
			'orders.emptyActiveMessage' => 'Жаңа сұранысты қабылдасаңыз, ол осында пайда болады.',
			'orders.emptyDoneTitle' => 'Аяқталған жұмыс жоқ',
			'orders.emptyDoneMessage' => 'Алғашқы тапсырысты тапсырғаннан кейін ол осында көрінеді.',
			'orders.stage.accepted' => 'Ұсыныс қабылданды',
			'orders.stage.measured' => 'Өлшем алынды',
			'orders.stage.production' => 'Өндіріс',
			'orders.stage.installation' => 'Орнату',
			'orders.stage.handover' => 'Тапсыру және төлем',
			'orders.detail.stages' => 'Кезеңдер',
			'orders.detail.spec' => 'Спецификация',
			'orders.detail.client' => 'Клиент',
			'orders.detail.total' => 'Барлығы',
			'orders.detail.prepaid' => 'Алдын ала төлем',
			'orders.detail.remaining' => 'Қалдық',
			'orders.detail.dueDate' => 'Келісілген мерзім',
			'orders.detail.finishOrder' => 'Тапсырып, аяқтау',
			'orders.detail.completed' => 'Тапсырыс аяқталды',
			'orders.detail.stageDone' => ({required Object stage}) => '${stage} аяқталды',
			'orders.detail.notFound' => 'Тапсырыс табылмады',
			'orders.detail.drawings' => 'Сызбалар',
			'orders.detail.drawingsHint' => 'Екі саусақпен үлкейтіңіз · өлшемдер мм-де',
			'orders.detail.markMeasured' => 'Өлшем алынды',
			'orders.detail.markProduction' => 'Өндіріс басталды',
			'orders.detail.markInstallation' => 'Орнатуға шықтық',
			'orders.detail.stageSaved' => 'Белгіленді — клиентке хабар кетті',
			'orders.request.title' => 'Сұраныс',
			'orders.request.clientSpec' => 'Клиент есептеген спецификация',
			'orders.request.priceOffer' => 'Баға ұсынысы',
			'orders.request.serviceFee' => 'Монтаж және жеткізу',
			'orders.request.yourOffer' => 'Сіздің ұсынысыңыз',
			'orders.request.workDays' => 'Мерзім — жұмыс күні',
			'orders.request.note' => 'Түсініктеме (міндетті емес)',
			'orders.request.notePlaceholder' => 'Клиентке қосымша түсініктеме…',
			'orders.request.send' => 'Ұсынысты жіберу',
			'orders.request.decline' => 'Бас тарту',
			'orders.request.declineTitle' => 'Сұранысты қабылдамайсыз ба?',
			'orders.request.declineMessage' => 'Бұл сұраныс тізімнен мүлдем жойылады.',
			'orders.request.expiresIn' => ({required Object time}) => '${time} қалды',
			'orders.request.expired' => 'Мерзімі өтті',
			'orders.request.distance' => ({required Object km}) => '${km} км',
			'orders.request.sent' => 'Ұсыныс жіберілді',
			'orders.request.invalidFee' => 'Жұмыс ақысы теріс бола алмайды',
			'orders.request.chatNote' => 'Баға мен шартты клиентпен чатта келісесіз.',
			'orders.request.withdrawOffer' => 'Ұсынысты қайтарып алу',
			'orders.request.declineInviteTitle' => 'Ұсынысты қабылдамайсыз ба?',
			'orders.request.declineInviteMessage' => 'Клиентке дереу хабар барады және ол басқа шебер таңдайды.',
			'orders.request.clientPrice' => 'Тапсырыс бағасы',
			'orders.request.priceInChat' => 'Баға чатта келісіледі',
			'orders.spec.size' => 'Өлшемі (мм)',
			'orders.spec.shape' => 'Пішіні',
			'orders.spec.brand' => 'Бренд',
			'orders.spec.color' => 'Түсі',
			'orders.spec.material' => 'Материал',
			'orders.spec.glass' => 'Шыны',
			'orders.spec.sill' => 'Терезе алды (см)',
			'orders.spec.flower' => 'Өрнек',
			'orders.spec.address' => 'Мекенжай',
			'orders.spec.product' => 'Бұйымдар',
			'orders.spec.phone' => 'Телефон',
			'orders.spec.discount' => 'Жеңілдік',
			'orders.spec.note' => 'Түсініктеме',
			'orders.spec.itemsValue' => ({required Object kinds, required Object count}) => '${kinds} түр · ${count} дана',
			'orders.spec.values.plastic' => 'Пластик',
			'orders.spec.values.aluminium' => 'Алюминий',
			'orders.spec.values.termo' => 'Термо',
			'orders.spec.values.doubleGlass' => 'Екі қабат',
			'orders.spec.values.singleGlass' => 'Бір қабат',
			'orders.spec.values.large' => 'Үлкен',
			'orders.spec.values.medium' => 'Орташа',
			'orders.spec.values.small' => 'Кіші',
			'orders.spec.area' => 'Аумағы',
			'orders.spec.unitPrice' => '1 м² бағасы',
			'orders.spec.variant' => 'Деңгей',
			'orders.invalidId' => 'Тапсырыс нөмірі қате.',
			'orders.invalidRequestId' => 'Сұраныс нөмірі қате.',
			'orders.open.offerSent' => 'Ұсыныс жіберілді',
			'orders.open.waitingClient' => 'Клиенттің жауабын күтуде',
			'orders.open.offersCount' => ({required Object count}) => '${count} ұсыныс',
			'orders.open.beFirst' => 'Бірінші болыңыз',
			'orders.open.newBadge' => 'Жаңа',
			'orders.open.pageTitle' => 'Ашық тапсырыстар',
			'orders.open.tabWaiting' => 'Жауап күтуде',
			'orders.open.tabSent' => 'Ұсыныс жіберілді',
			'orders.open.emptySentTitle' => 'Жіберілген ұсыныс жоқ',
			'orders.open.emptySentMessage' => 'Жауап берген хабарландыруларыңыз осында клиенттің жауабын күтеді.',
			'orders.open.tabInvited' => 'Сізге ұсыныс',
			'orders.open.invitedBadge' => 'Сізге ұсыныс',
			'orders.open.acceptInvite' => 'Қабылдаймын',
			'orders.open.emptyInvitedTitle' => 'Жеке ұсыныс жоқ',
			'orders.open.emptyInvitedMessage' => 'Клиент сізді таңдаған тапсырыстар осы жерде көрінеді.',
			'orders.open.invitedNote' => 'Клиент бұл тапсырысты тікелей сізге жіберді — басқа шеберлер көрмейді.',
			'orders.open.repairBadge' => 'Жөндеу',
			'orders.personalTitle' => 'Менің тапсырыстарым',
			'ownOrders.orderTitle' => 'Тапсырыс',
			'ownOrders.itemsCount' => ({required Object count}) => '${count} терезе',
			'ownOrders.statusTitle' => 'Тапсырыс күйі',
			'ownOrders.statusRow' => 'Күйі',
			'ownOrders.saving' => 'Сақталуда…',
			'ownOrders.tapToChange' => 'Өзгерту үшін басыңыз',
			'ownOrders.alreadyDone' => 'Бұл тапсырыс аяқталған.',
			'ownOrders.cannotChange' => 'Бұл тапсырыстың күйін өзгерту мүмкін емес.',
			'ownOrders.status.draft' => 'Жоба',
			'ownOrders.status.newOrder' => 'Жаңа',
			'ownOrders.status.inProgress' => 'Орындалуда',
			'ownOrders.status.done' => 'Аяқталды',
			'ownOrders.status.debt' => 'Қарыз бар',
			'ownOrders.status.cancelled' => 'Бас тартылды',
			'ownOrders.hint.newOrder' => 'Қабылданды, әлі басталмады',
			'ownOrders.hint.inProgress' => 'Өндіріс не монтаж жүріп жатыр',
			'ownOrders.hint.done' => 'Тапсырылды және толық төленді',
			'ownOrders.hint.debt' => 'Жұмыс бітті, бірақ төлем толық емес',
			'ownOrders.hint.cancelled' => 'Тапсырыс тоқтатылды',
			'orderForm.noProducts' => 'Тапсырыста бұйым жоқ.',
			'orderForm.queued' => 'Интернет жоқ — тапсырыс кезекке қойылды, өзі жіберіледі.',
			'orderForm.saved' => 'Тапсырыс сақталды',
			'orderForm.saveTitle' => 'Тапсырысты сақтау',
			'orderForm.customer' => 'Тапсырыс беруші',
			'orderForm.nameLabel' => 'Аты',
			'orderForm.nameHint' => 'Азиз',
			'orderForm.nameRequired' => 'Атын жазыңыз',
			'orderForm.addressHint' => 'Чиланзар 9-шағын аудан',
			'orderForm.noteLabel' => 'Қосымша түсініктеме',
			'orderForm.noteHint' => '2-қабат, лифт жоқ',
			'orderForm.itemsSummary' => ({required Object kinds, required Object count}) => '${kinds} түрлі терезе · ${count} дана',
			'chat.threadsTitle' => 'Әңгімелер',
			'chat.conversation' => 'Әңгіме',
			'chat.messageHint' => 'Хабар жазыңыз...',
			'chat.emptyChat' => 'Баға мен шартты осында келісесіз',
			'chat.emptyThreadsTitle' => 'Әзірге әңгіме жоқ',
			'chat.emptyThreadsMessage' => 'Шебер тапсырысыңызға жауап бергенде осында жазысасыз.',
			'notifications.title' => 'Хабарламалар',
			'notifications.markAllRead' => 'Барлығын оқылды деу',
			'notifications.empty' => 'Хабарлама жоқ',
			'notifications.open' => 'Ашу',
			'masters.title' => 'Шебер туралы',
			'masters.master' => 'Шебер',
			'masters.client' => 'Клиент',
			'masters.write' => 'Жазу',
			'masters.chooseThis' => 'Осы шеберді таңдау',
			'masters.choose' => 'Таңдау',
			'masters.chosen' => 'Таңдалған шебер',
			'masters.notFound' => 'Дерек табылмады',
			'masters.works' => 'Атқарған жұмыстары',
			'masters.reviews' => ({required Object count}) => 'Пікірлер (${count})',
			'masters.reviewsLabel' => 'Пікірлер',
			'masters.noReviews' => 'Әзірге пікір жоқ — бірінші сіз бола аласыз.',
			'masters.experienceYears' => ({required Object years}) => '${years} жыл тәжірибе',
			'masters.rating' => 'Рейтинг',
			'masters.completed' => 'Орындалды',
			'masters.responses' => ({required Object count}) => '${count} жауап',
			'masters.estimate' => 'Есеп',
			'orderFlow.status.published' => 'Жарияланды',
			'orderFlow.status.assigned' => 'Шебер таңдалды',
			'orderFlow.status.completed' => 'Аяқталды',
			'orderFlow.status.cancelled' => 'Бас тартылды',
			'orderFlow.status.expired' => 'Мерзімі өтті',
			'orderFlow.stage.accepted' => 'Қабылданды',
			'orderFlow.stage.measured' => 'Өлшем алынды',
			'orderFlow.stage.production' => 'Өндіріс',
			'orderFlow.stage.installation' => 'Орнату',
			'orderFlow.stage.handover' => 'Тапсырылды',
			'orderFlow.response.interested' => 'Қабылдаймын',
			'orderFlow.response.withdrawn' => 'Бас тартты',
			'orderFlow.response.chosen' => 'Таңдалды',
			'orderFlow.response.rejected' => 'Таңдалмады',
			'company.title' => 'Кәсіпорын',
			'company.nameLabel' => 'Кәсіпорын атауы',
			'company.nameHint' => 'Мысалы: Ustachi Servis',
			'company.nameEmpty' => 'Кәсіпорын атауы енгізілмеген',
			'company.nameNote' => 'Тапсырыс парағында көрінеді',
			'company.logoHint' => 'Логотип қосу',
			'companyRates.onlyDigits' => 'Тек сандар',
			'materials.title' => 'Материалдар',
			'materials.on' => 'Осы материалмен жұмыс істеймін — тапсырыстар келеді',
			'materials.off' => 'Өшірулі — осы материалға тапсырыстар келмейді',
			'materials.allOff' => 'Кемінде бір материал қосулы болуы керек',
			'professional.title' => 'Кәсіби деректер',
			'professional.headline' => 'Қандай шебер екеніңізді айтыңыз',
			'professional.headlineHint' => 'Клиент сізді таңдамас бұрын осы деректі көреді. Кейін кез келген уақытта өзгерте аласыз.',
			'professional.specialty' => 'Бағыттар',
			'professional.specialtyPick' => 'Бағыттарыңызды таңдаңыз',
			'professional.specialtyLoadFailed' => 'Бағыттар тізімі жүктелмеді — интернетті тексеріп, қайта кіріңіз.',
			'professional.experienceQuestion' => 'Тәжірибеңіз неше жыл?',
			'professional.experienceHint' => 'Мысалы: 5',
			'professional.experienceRequired' => 'Тәжірибені енгізіңіз',
			'professional.experienceRange' => 'Тәжірибе 0 мен 70 аралығында болуы керек',
			'professional.aboutLabel' => 'Өзіңіз туралы (міндетті емес)',
			'professional.aboutHint' => 'Қандай жұмыс істейсіз, неге көңіл бөлесіз — қысқаша жазыңыз.',
			'professional.works' => 'Жұмыстарыңыз',
			'professional.worksHint' => 'Сурет қоссаңыз, клиент жұмысыңызды көреді және сізді таңдау ықтималдығы артады. Міндетті емес — кейін де қосуға болады.',
			'professional.deleteSampleTitle' => 'Үлгіні жоясыз ба?',
			'professional.deleteSampleMessage' => 'Клиенттер бұл суретті бұдан былай көрмейді.',
			'professional.deleteFailed' => 'Жойылмады',
			'professional.pickSpecialty' => 'Кемінде бір бағыт таңдаңыз',
			'professional.specialtyHint' => 'Бірнешеуін таңдауға болады — тапсырыс тек осы бағыттар бойынша келеді.',
			'appUpdate.eyebrow' => 'ЖАҢАРТУ',
			'appUpdate.titleOptional' => 'Жаңа нұсқа дайын',
			'appUpdate.titleRequired' => 'Жаңарту қажет',
			'appUpdate.bodyOptional' => 'Ustachi Pro-ның жаңа нұсқасы шықты. Соңғы түзетулер мен мүмкіндіктер үшін жаңартыңыз.',
			'appUpdate.bodyRequired' => 'Бұл нұсқа енді қолдау көрмейді. Қолданбаны пайдалануды жалғастыру үшін жаңартыңыз.',
			'appUpdate.whatsNew' => 'НЕ ЖАҢАРДЫ',
			'appUpdate.versionFrom' => 'Сізде',
			'appUpdate.versionTo' => 'Жаңа',
			'appUpdate.update' => 'Жаңарту',
			'appUpdate.later' => 'Кейінірек',
			'appUpdate.openFailed' => 'Сілтемені ашу мүмкін болмады. Қолданбаны дүкеннен қолмен жаңартыңыз.',
			_ => null,
		};
	}
}
