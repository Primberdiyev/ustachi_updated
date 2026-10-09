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
class TranslationsKy extends Translations with BaseTranslations<AppLocale, Translations> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	TranslationsKy({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.ky,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		super.$meta.setFlatMapFunction($meta.getTranslation); // copy base translations to super.$meta
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <ky>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	@override dynamic operator[](String key) => $meta.getTranslation(key) ?? super.$meta.getTranslation(key);

	late final TranslationsKy _root = this; // ignore: unused_field

	@override 
	TranslationsKy $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => TranslationsKy(meta: meta ?? this.$meta);

	// Translations
	@override String get applicationName => 'Ustachi';
	@override late final _TranslationsCommonKy common = _TranslationsCommonKy._(_root);
	@override late final _TranslationsOnboardingKy onboarding = _TranslationsOnboardingKy._(_root);
	@override late final _TranslationsAuthKy auth = _TranslationsAuthKy._(_root);
	@override late final _TranslationsCountryKy country = _TranslationsCountryKy._(_root);
	@override late final _TranslationsHomeKy home = _TranslationsHomeKy._(_root);
	@override late final _TranslationsCalculatePageKy calculatePage = _TranslationsCalculatePageKy._(_root);
	@override late final _TranslationsProfileKy profile = _TranslationsProfileKy._(_root);
	@override late final _TranslationsDashboardKy dashboard = _TranslationsDashboardKy._(_root);
	@override late final _TranslationsOrdersKy orders = _TranslationsOrdersKy._(_root);
	@override late final _TranslationsOwnOrdersKy ownOrders = _TranslationsOwnOrdersKy._(_root);
	@override late final _TranslationsOrderFormKy orderForm = _TranslationsOrderFormKy._(_root);
	@override late final _TranslationsChatKy chat = _TranslationsChatKy._(_root);
	@override late final _TranslationsNotificationsKy notifications = _TranslationsNotificationsKy._(_root);
	@override late final _TranslationsMastersKy masters = _TranslationsMastersKy._(_root);
	@override late final _TranslationsOrderFlowKy orderFlow = _TranslationsOrderFlowKy._(_root);
	@override late final _TranslationsCompanyKy company = _TranslationsCompanyKy._(_root);
	@override late final _TranslationsCompanyRatesKy companyRates = _TranslationsCompanyRatesKy._(_root);
	@override late final _TranslationsMaterialsKy materials = _TranslationsMaterialsKy._(_root);
	@override late final _TranslationsProfessionalKy professional = _TranslationsProfessionalKy._(_root);
	@override late final _TranslationsAppUpdateKy appUpdate = _TranslationsAppUpdateKy._(_root);
}

// Path: common
class _TranslationsCommonKy extends TranslationsCommonUz {
	_TranslationsCommonKy._(TranslationsKy root) : this._root = root, super.internal(root);

	final TranslationsKy _root; // ignore: unused_field

	// Translations
	@override String get ok => 'OK';
	@override String get start => 'Баштоо';
	@override String get cancel => 'Жокко чыгаруу';
	@override String get save => 'Сактоо';
	@override String get delete => 'Өчүрүү';
	@override String get edit => 'Түзөтүү';
	@override String get close => 'Жабуу';
	@override String get back => 'Артка';
	@override String get next => 'Кийинки';
	@override String get skip => 'Өткөрүп жиберүү';
	@override String get enter => 'Киргизиңиз';
	@override String get wentWrong => 'Ката кетти. Бир аздан кийин кайра аракет кылыңыз!';
	@override String get common => 'Негизги';
	@override String get select => 'Тандоо';
	@override String get retry => 'Кайталоо';
	@override String get refresh => 'Жаңылоо';
	@override String get saved => 'Сакталды';
	@override String get saveFailed => 'Сакталган жок — кайра аракет кылыңыз';
	@override String get notFound => 'Табылган жок';
	@override String get empty => 'Бош';
	@override String get loading => 'Жүктөлүүдө…';
	@override String get yes => 'Ооба';
	@override String get no => 'Жок';
	@override String get add => 'Кошуу';
	@override String get copy => 'Көчүрүү';
	@override String get apply => 'Колдонуу';
	@override String get reset => 'Кайтаруу';
	@override String get done => 'Даяр';
	@override String get all => 'Баары';
	@override String get som => 'сом';
	@override String get cm => 'см';
	@override String get mm => 'мм';
	@override String get pcs => 'даана';
	@override String get hoursShort => 'с';
	@override String get minutesShort => 'мүн';
	@override List<String> get months => [
		'январь',
		'февраль',
		'март',
		'апрель',
		'май',
		'июнь',
		'июль',
		'август',
		'сентябрь',
		'октябрь',
		'ноябрь',
		'декабрь',
	];
	@override List<String> get weekdays => [
		'Жекшемби',
		'Дүйшөмбү',
		'Шейшемби',
		'Шаршемби',
		'Бейшемби',
		'Жума',
		'Ишемби',
	];
	@override String get today => 'Бүгүн';
	@override String get tomorrow => 'Эртең';
	@override String get comingSoon => 'Жакында';
}

// Path: onboarding
class _TranslationsOnboardingKy extends TranslationsOnboardingUz {
	_TranslationsOnboardingKy._(TranslationsKy root) : this._root = root, super.internal(root);

	final TranslationsKy _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsOnboardingStep1Ky step1 = _TranslationsOnboardingStep1Ky._(_root);
	@override late final _TranslationsOnboardingStep2Ky step2 = _TranslationsOnboardingStep2Ky._(_root);
	@override late final _TranslationsOnboardingStep3Ky step3 = _TranslationsOnboardingStep3Ky._(_root);
}

// Path: auth
class _TranslationsAuthKy extends TranslationsAuthUz {
	_TranslationsAuthKy._(TranslationsKy root) : this._root = root, super.internal(root);

	final TranslationsKy _root; // ignore: unused_field

	// Translations
	@override String get tagline => 'УСТАНЫН ИШ МЕЙКИНДИГИ';
	@override late final _TranslationsAuthCommonKy common = _TranslationsAuthCommonKy._(_root);
	@override late final _TranslationsAuthPhoneKy phone = _TranslationsAuthPhoneKy._(_root);
	@override late final _TranslationsAuthOtpKy otp = _TranslationsAuthOtpKy._(_root);
	@override late final _TranslationsAuthProfileKy profile = _TranslationsAuthProfileKy._(_root);
	@override late final _TranslationsAuthTelegramKy telegram = _TranslationsAuthTelegramKy._(_root);
}

// Path: country
class _TranslationsCountryKy extends TranslationsCountryUz {
	_TranslationsCountryKy._(TranslationsKy root) : this._root = root, super.internal(root);

	final TranslationsKy _root; // ignore: unused_field

	// Translations
	@override String get title => 'Өлкөнү тандаңыз';
	@override String get subtitle => 'Колдонмонун тили өлкөгө жараша тандалат. Кийин профилден өзгөртө аласыз.';
	@override String get continueBtn => 'Улантуу';
	@override String get changeTitle => 'Өлкө жана тил';
}

// Path: home
class _TranslationsHomeKy extends TranslationsHomeUz {
	_TranslationsHomeKy._(TranslationsKy root) : this._root = root, super.internal(root);

	final TranslationsKy _root; // ignore: unused_field

	// Translations
	@override String get main => 'Башкы';
	@override String get chatting => 'Чат';
	@override String get profile => 'Профиль';
	@override String get title => 'Профиль';
	@override String get loadError => 'Профиль жүктөлгөн жок';
	@override String get retry => 'Кайталоо';
	@override String get phone => 'Телефон';
	@override String get role => 'Ролу';
	@override String get status => 'Абалы';
	@override String get active => 'Активдүү';
	@override String get inactive => 'Активдүү эмес';
	@override String get logout => 'Чыгуу';
	@override String get hi => 'Салам';
	@override String get serviceType => 'Кызмат түрлөрү';
	@override String get lastOrders => 'Акыркы буйрутмалар';
	@override String get all => 'Баары';
	@override String get tapRepair => 'Кран оңдоо';
	@override String get chandelierInstallation => 'Люстра орнотуу';
	@override String get completed => 'Аткарылды';
	@override String get inProgress => 'Жүрүүдө';
	@override String get window => 'Терезе';
	@override String get furtiniture => 'Эмерек';
	@override String get electric => 'Электрика';
	@override String get plumber => 'Сантехника';
}

// Path: calculatePage
class _TranslationsCalculatePageKy extends TranslationsCalculatePageUz {
	_TranslationsCalculatePageKy._(TranslationsKy root) : this._root = root, super.internal(root);

	final TranslationsKy _root; // ignore: unused_field

	// Translations
	@override String get window => 'Терезе';
	@override String get door => 'Эшик';
	@override String get glass => 'Аркалар';
	@override String get windowConfigurator => 'Терезе конфигурациясы';
	@override String get windowLayouts => 'Бөлүнүү түрлөрү';
	@override String get windowPremiumLayouts => 'Премиум варианттар';
	@override String get windowModernLayouts => 'Заманбап варианттар';
	@override String get doorConfigurator => 'Эшик конфигурациясы';
	@override String get doorModels => 'Эшик моделдери';
	@override String get doorExtraModels => 'Кошумча моделдер';
	@override String get material => 'Материал';
	@override String get plastic => 'Пластик';
	@override String get aluminium => 'Алюминий';
	@override String get termo => 'Термо';
	@override String get glassShowcase => 'Арка варианттары';
	@override String get customTemplateTitleWindow => 'Өз терезеңизди түзүңүз';
	@override String get customTemplateTitleDoor => 'Өз эшигиңизди түзүңүз';
	@override String get customTemplateTitleArch => 'Өз аркаңызды түзүңүз';
	@override String get customTemplateSubtitle => 'Даяр үлгү эмес — өлчөм менен бөлүнүүнү өзүңүз тартасыз';
	@override String get customTemplateAction => 'Баштоо';
	@override String get readyTemplates => 'Даяр үлгүлөр';
}

// Path: profile
class _TranslationsProfileKy extends TranslationsProfileUz {
	_TranslationsProfileKy._(TranslationsKy root) : this._root = root, super.internal(root);

	final TranslationsKy _root; // ignore: unused_field

	// Translations
	@override String get personalData => 'Жеке маалыматтар';
	@override String get professional => 'Кесиптик маалымат';
	@override String get company => 'Ишкана';
	@override String get myOrders => 'Менин буйрутмаларым';
	@override String get settings => 'Жөндөөлөр';
	@override String get support => 'Биз менен байланыш';
	@override String get logout => 'Чыгуу';
	@override String get logoutTitle => 'Аккаунттан чыгасызбы?';
	@override String get logoutMessage => 'Жүктөлгөн баалар жана эсептөө маалыматтары түзмөктөн өчүрүлөт. Кайра киргенде алар жаңыдан жүктөлөт.';
	@override String get logoutConfirm => 'Ооба, чыгам';
	@override String get loggingOut => 'Чыгууда...';
	@override String get loggingOutHint => 'Сессия жабылып, баа кэши тазаланууда';
	@override String get logoutFailed => 'Серверден чыгуу мүмкүн болбоду, бирок түзмөктөгү маалыматтар тазаланды';
	@override late final _TranslationsProfilePersonalKy personal = _TranslationsProfilePersonalKy._(_root);
	@override late final _TranslationsProfileHelpKy help = _TranslationsProfileHelpKy._(_root);
}

// Path: dashboard
class _TranslationsDashboardKy extends TranslationsDashboardUz {
	_TranslationsDashboardKy._(TranslationsKy root) : this._root = root, super.internal(root);

	final TranslationsKy _root; // ignore: unused_field

	// Translations
	@override String get title => 'Иш столу';
	@override String get greetingMorning => 'Кутмандуу таң,';
	@override String get greetingDay => 'Кутмандуу күн,';
	@override String get greetingEvening => 'Кутмандуу кеч,';
	@override String get master => 'уста';
	@override String get availableTitle => 'Буйрутма кабыл алам';
	@override String get availableOn => 'Жаңы сурамдар келе берет';
	@override String get availableOff => 'Сурамдар токтотулду';
	@override String get newRequests => 'Жаңы сурамдар';
	@override String get activeOrders => 'Активдүү буйрутмалар';
	@override String get all => 'Баары';
	@override String get quickCalculate => 'Терезе чиймеси';
	@override String get quickCalculateHint => 'Терезе жана эшик чиймеси';
	@override String get quickPortfolio => 'Иш үлгүсү';
	@override String get quickPortfolioHint => 'Аяктаган иштен кошуңуз';
	@override String get emptyRequests => 'Жаңы сурам жок';
	@override String get emptyRequestsHint => 'Бош эместик которгучу күйгүзүлсө, сурамдар ушул жерге түшөт.';
	@override String get quickCompany => 'Ишкана';
	@override String get quickCompanyHint => 'Аты жана логотип';
	@override String get quickRates => 'Кызмат бааларым';
	@override String get quickRatesHint => 'Тармак боюнча иш баалары';
	@override String get quickOrdersHeroTitle => 'Жаңы буйрутмалар жана Базар';
	@override String get quickOrdersHeroHint => 'Тармагыңыздагы жарыяларды көрүп, сунуш жөнөтүңүз';
	@override String get quickOpenOrders => 'Ачык буйрутмалар';
	@override String get quickOpenOrdersHint => 'Уста тандалбаган жарыялар — сунуш жөнөтүңүз';
	@override String get calcStep1 => 'Рам тандаңыз';
	@override String get calcStep2 => 'Ырастаңыз';
	@override String get calcStep3 => 'Чийме даяр';
	@override String get repairTitle => 'Оңдоо иштерин кабыл алам';
	@override String get repairOn => 'Оңдоо боюнча билдирүүлөр да келет';
	@override String get repairOff => 'Оңдоо боюнча билдирүүлөр келбейт';
	@override String get repairHint => 'Эски терезе-эшиктерди жөндөө, фурнитура же айнек алмаштыруу';
}

// Path: orders
class _TranslationsOrdersKy extends TranslationsOrdersUz {
	_TranslationsOrdersKy._(TranslationsKy root) : this._root = root, super.internal(root);

	final TranslationsKy _root; // ignore: unused_field

	// Translations
	@override String get title => 'Буйрутмалар';
	@override String get segmentNew => 'Ачык';
	@override String get segmentActive => 'Жүрүүдө';
	@override String get segmentDone => 'Аяктаган';
	@override String stepOf({required Object total, required Object step}) => '${total} этаптын ${step}-си';
	@override String lateDays({required Object days}) => '${days} күн кечикти';
	@override String get dueToday => 'Мөөнөтү — бүгүн';
	@override String daysLeft({required Object days}) => '${days} күн калды';
	@override String get offerBtn => 'Сунуш берүү';
	@override String get retry => 'Кайталоо';
	@override String get loadFailed => 'Буйрутмаларды жүктөө мүмкүн болбоду';
	@override String get emptyNewTitle => 'Ачык буйрутма жок';
	@override String get emptyNewMessage => 'Аймагыңызда жаңы жарыя пайда болсо ушул жерде көрүнөт.';
	@override String get emptyActiveTitle => 'Активдүү буйрутма жок';
	@override String get emptyActiveMessage => 'Жаңы сурамды кабыл алсаңыз, ал ушул жерде пайда болот.';
	@override String get emptyDoneTitle => 'Аяктаган иш жок';
	@override String get emptyDoneMessage => 'Биринчи буйрутманы тапшыргандан кийин ал ушул жерде көрүнөт.';
	@override late final _TranslationsOrdersStageKy stage = _TranslationsOrdersStageKy._(_root);
	@override late final _TranslationsOrdersDetailKy detail = _TranslationsOrdersDetailKy._(_root);
	@override late final _TranslationsOrdersRequestKy request = _TranslationsOrdersRequestKy._(_root);
	@override late final _TranslationsOrdersSpecKy spec = _TranslationsOrdersSpecKy._(_root);
	@override String get invalidId => 'Буйрутма номери туура эмес.';
	@override String get invalidRequestId => 'Сурам номери туура эмес.';
	@override late final _TranslationsOrdersOpenKy open = _TranslationsOrdersOpenKy._(_root);
	@override String get personalTitle => 'Менин буйрутмаларым';
}

// Path: ownOrders
class _TranslationsOwnOrdersKy extends TranslationsOwnOrdersUz {
	_TranslationsOwnOrdersKy._(TranslationsKy root) : this._root = root, super.internal(root);

	final TranslationsKy _root; // ignore: unused_field

	// Translations
	@override String get orderTitle => 'Буйрутма';
	@override String itemsCount({required Object count}) => '${count} терезе';
	@override String get statusTitle => 'Буйрутманын абалы';
	@override String get statusRow => 'Абалы';
	@override String get saving => 'Сакталууда…';
	@override String get tapToChange => 'Өзгөртүү үчүн басыңыз';
	@override String get alreadyDone => 'Бул буйрутма мурунтан эле аякталган.';
	@override String get cannotChange => 'Бул буйрутманын абалын өзгөртүүгө болбойт.';
	@override late final _TranslationsOwnOrdersStatusKy status = _TranslationsOwnOrdersStatusKy._(_root);
	@override late final _TranslationsOwnOrdersHintKy hint = _TranslationsOwnOrdersHintKy._(_root);
}

// Path: orderForm
class _TranslationsOrderFormKy extends TranslationsOrderFormUz {
	_TranslationsOrderFormKy._(TranslationsKy root) : this._root = root, super.internal(root);

	final TranslationsKy _root; // ignore: unused_field

	// Translations
	@override String get noProducts => 'Буйрутмада буюм жок.';
	@override String get queued => 'Интернет жок — буйрутма кезекке коюлду, өзү жиберилет.';
	@override String get saved => 'Буйрутма сакталды';
	@override String get saveTitle => 'Буйрутманы сактоо';
	@override String get customer => 'Буйрутмачы';
	@override String get nameLabel => 'Аты';
	@override String get nameHint => 'Азиз';
	@override String get nameRequired => 'Атын жазыңыз';
	@override String get addressHint => 'Чиланзар 9-кичи район';
	@override String get noteLabel => 'Кошумча комментарий';
	@override String get noteHint => '2-кабат, лифт жок';
	@override String itemsSummary({required Object kinds, required Object count}) => '${kinds} түрдүү терезе · ${count} даана';
}

// Path: chat
class _TranslationsChatKy extends TranslationsChatUz {
	_TranslationsChatKy._(TranslationsKy root) : this._root = root, super.internal(root);

	final TranslationsKy _root; // ignore: unused_field

	// Translations
	@override String get threadsTitle => 'Маектешүүлөр';
	@override String get conversation => 'Маектешүү';
	@override String get messageHint => 'Билдирүү жазыңыз...';
	@override String get emptyChat => 'Баа менен шартты ушул жерде макулдашасыз';
	@override String get emptyThreadsTitle => 'Азырынча маектешүү жок';
	@override String get emptyThreadsMessage => 'Уста буйрутмаңызга жооп бергенде ушул жерде жазышасыз.';
}

// Path: notifications
class _TranslationsNotificationsKy extends TranslationsNotificationsUz {
	_TranslationsNotificationsKy._(TranslationsKy root) : this._root = root, super.internal(root);

	final TranslationsKy _root; // ignore: unused_field

	// Translations
	@override String get title => 'Билдирүүлөр';
	@override String get markAllRead => 'Баарын окулду деп белгилөө';
	@override String get empty => 'Билдирүү жок';
	@override String get open => 'Ачуу';
}

// Path: masters
class _TranslationsMastersKy extends TranslationsMastersUz {
	_TranslationsMastersKy._(TranslationsKy root) : this._root = root, super.internal(root);

	final TranslationsKy _root; // ignore: unused_field

	// Translations
	@override String get title => 'Уста жөнүндө';
	@override String get master => 'Уста';
	@override String get client => 'Кардар';
	@override String get write => 'Жазуу';
	@override String get chooseThis => 'Ушул устаны тандоо';
	@override String get choose => 'Тандоо';
	@override String get chosen => 'Тандалган уста';
	@override String get notFound => 'Маалымат табылган жок';
	@override String get works => 'Аткарган иштери';
	@override String reviews({required Object count}) => 'Пикирлер (${count})';
	@override String get reviewsLabel => 'Пикирлер';
	@override String get noReviews => 'Азырынча пикир жок — биринчи сиз болсоңуз болот.';
	@override String experienceYears({required Object years}) => '${years} жыл тажрыйба';
	@override String get rating => 'Рейтинг';
	@override String get completed => 'Аткарылды';
	@override String responses({required Object count}) => '${count} жооп';
	@override String get estimate => 'Эсеп';
}

// Path: orderFlow
class _TranslationsOrderFlowKy extends TranslationsOrderFlowUz {
	_TranslationsOrderFlowKy._(TranslationsKy root) : this._root = root, super.internal(root);

	final TranslationsKy _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsOrderFlowStatusKy status = _TranslationsOrderFlowStatusKy._(_root);
	@override late final _TranslationsOrderFlowStageKy stage = _TranslationsOrderFlowStageKy._(_root);
	@override late final _TranslationsOrderFlowResponseKy response = _TranslationsOrderFlowResponseKy._(_root);
}

// Path: company
class _TranslationsCompanyKy extends TranslationsCompanyUz {
	_TranslationsCompanyKy._(TranslationsKy root) : this._root = root, super.internal(root);

	final TranslationsKy _root; // ignore: unused_field

	// Translations
	@override String get title => 'Ишкана';
	@override String get nameLabel => 'Ишкананын аты';
	@override String get nameHint => 'Мисалы: Ustachi Servis';
	@override String get nameEmpty => 'Ишкананын аты киргизилген эмес';
	@override String get nameNote => 'Буйрутма барагында көрүнөт';
	@override String get logoHint => 'Логотип кошуу';
}

// Path: companyRates
class _TranslationsCompanyRatesKy extends TranslationsCompanyRatesUz {
	_TranslationsCompanyRatesKy._(TranslationsKy root) : this._root = root, super.internal(root);

	final TranslationsKy _root; // ignore: unused_field

	// Translations
	@override String get onlyDigits => 'Сандар гана';
}

// Path: materials
class _TranslationsMaterialsKy extends TranslationsMaterialsUz {
	_TranslationsMaterialsKy._(TranslationsKy root) : this._root = root, super.internal(root);

	final TranslationsKy _root; // ignore: unused_field

	// Translations
	@override String get title => 'Материалдар';
	@override String get on => 'Бул материал менен иштейм — буюртмалар келет';
	@override String get off => 'Өчүк — бул материал боюнча буюртмалар келбейт';
	@override String get allOff => 'Кеминде бир материал күйүп турушу керек';
}

// Path: professional
class _TranslationsProfessionalKy extends TranslationsProfessionalUz {
	_TranslationsProfessionalKy._(TranslationsKy root) : this._root = root, super.internal(root);

	final TranslationsKy _root; // ignore: unused_field

	// Translations
	@override String get title => 'Кесиптик маалымат';
	@override String get headline => 'Кандай уста экениңизди айтыңыз';
	@override String get headlineHint => 'Кардар сизди тандаардан мурун ушул маалыматты көрөт. Кийин каалаган убакта өзгөртө аласыз.';
	@override String get specialty => 'Багыттар';
	@override String get specialtyPick => 'Багыттарыңызды тандаңыз';
	@override String get specialtyLoadFailed => 'Багыттардын тизмеси жүктөлгөн жок — интернетти текшерип, кайра кириңиз.';
	@override String get experienceQuestion => 'Канча жылдык тажрыйбаңыз бар?';
	@override String get experienceHint => 'Мисалы: 5';
	@override String get experienceRequired => 'Тажрыйбаны киргизиңиз';
	@override String get experienceRange => 'Тажрыйба 0дөн 70ке чейин болушу керек';
	@override String get aboutLabel => 'Өзүңүз жөнүндө (милдеттүү эмес)';
	@override String get aboutHint => 'Кандай иштерди аткарасыз, эмнеге көңүл бурасыз — кыскача жазыңыз.';
	@override String get works => 'Иштериңиз';
	@override String get worksHint => 'Сүрөт кошсоңуз, кардар ишиңизди көрөт жана сизди тандоо ыктымалдыгы жогорулайт. Милдеттүү эмес — кийин да кошсо болот.';
	@override String get deleteSampleTitle => 'Үлгүнү өчүрөсүзбү?';
	@override String get deleteSampleMessage => 'Кардарлар бул сүрөттү мындан ары көрбөйт.';
	@override String get deleteFailed => 'Өчүрүлгөн жок';
	@override String get pickSpecialty => 'Жок дегенде бир багыт тандаңыз';
	@override String get specialtyHint => 'Бир нечесин тандасаңыз болот — буйрутма ушул багыттар боюнча гана келет.';
}

// Path: appUpdate
class _TranslationsAppUpdateKy extends TranslationsAppUpdateUz {
	_TranslationsAppUpdateKy._(TranslationsKy root) : this._root = root, super.internal(root);

	final TranslationsKy _root; // ignore: unused_field

	// Translations
	@override String get eyebrow => 'ЖАҢЫРТУУ';
	@override String get titleOptional => 'Жаңы версия даяр';
	@override String get titleRequired => 'Жаңыртуу талап кылынат';
	@override String get bodyOptional => 'Ustachi Pro\'нун жаңы версиясы чыкты. Акыркы оңдоолор жана мүмкүнчүлүктөр үчүн жаңыртыңыз.';
	@override String get bodyRequired => 'Бул версия мындан ары колдоого алынбайт. Колдонмону улантуу үчүн жаңыртыңыз.';
	@override String get whatsNew => 'ЭМНЕ ЖАҢЫРДЫ';
	@override String get versionFrom => 'Сизде';
	@override String get versionTo => 'Жаңы';
	@override String get update => 'Жаңыртуу';
	@override String get later => 'Кийинчерээк';
	@override String get openFailed => 'Шилтемени ачуу мүмкүн болбоду. Колдонмону дүкөндөн кол менен жаңыртыңыз.';
}

// Path: onboarding.step1
class _TranslationsOnboardingStep1Ky extends TranslationsOnboardingStep1Uz {
	_TranslationsOnboardingStep1Ky._(TranslationsKy root) : this._root = root, super.internal(root);

	final TranslationsKy _root; // ignore: unused_field

	// Translations
	@override String get title => 'Өз багытыңызды тандаңыз';
	@override String get description => 'Терезе, чатыр, кыш, электрик, сантехник, кафель, боёк… 25тен ашык багыт. Буйрутмалар сиздин багытыңыз боюнча келет.';
}

// Path: onboarding.step2
class _TranslationsOnboardingStep2Ky extends TranslationsOnboardingStep2Uz {
	_TranslationsOnboardingStep2Ky._(TranslationsKy root) : this._root = root, super.internal(root);

	final TranslationsKy _root; // ignore: unused_field

	// Translations
	@override String get title => 'Буйрутма өзү табат';
	@override String get description => 'Аймагыңызга жана багытыңызга дал келген жаңы жарыялар дароо билдирме болуп келет — издөөнүн кереги жок.';
}

// Path: onboarding.step3
class _TranslationsOnboardingStep3Ky extends TranslationsOnboardingStep3Uz {
	_TranslationsOnboardingStep3Ky._(TranslationsKy root) : this._root = root, super.internal(root);

	final TranslationsKy _root; // ignore: unused_field

	// Translations
	@override String get title => 'Баа сиздики';
	@override String get description => 'Өз бааңызды киргизесиз, кардар менен чатта макулдашасыз жана иштин этаптарын белгилеп барасыз.';
}

// Path: auth.common
class _TranslationsAuthCommonKy extends TranslationsAuthCommonUz {
	_TranslationsAuthCommonKy._(TranslationsKy root) : this._root = root, super.internal(root);

	final TranslationsKy _root; // ignore: unused_field

	// Translations
	@override String get invalidPhone => 'Телефон номерин туура киргизиңиз';
	@override String get cancel => 'Жокко чыгаруу';
}

// Path: auth.phone
class _TranslationsAuthPhoneKy extends TranslationsAuthPhoneUz {
	_TranslationsAuthPhoneKy._(TranslationsKy root) : this._root = root, super.internal(root);

	final TranslationsKy _root; // ignore: unused_field

	// Translations
	@override String get title => 'Колдонмого кирүү';
	@override String get subtitle => 'Номериңизди киргизиңиз — SMS аркылуу 6 сандуу код жиберебиз. Сырсөз керек эмес.';
	@override String get label => 'Телефон номери';
	@override String get continueBtn => 'Улантуу';
	@override String get orOption => 'же';
	@override String get telegramBtn => 'Telegram аркылуу кирүү';
	@override String get telegramHint => 'Бот кирүү үчүн Telegram аккаунтуңузга байланыштуу номерди сурайт. SMS жөнөтүлбөйт.';
	@override String get telegramOpenError => 'Telegram ботун ачуу мүмкүн болбоду. Кайра аракет кылыңыз.';
	@override String get agreementPrefix => 'Улантуу менен сиз ';
	@override String get terms => 'Колдонуу шарттары';
	@override String get and => ' жана ';
	@override String get privacy => 'Купуялык саясаты';
	@override String get agreementSuffix => ' менен макул болосуз.';
	@override String get audienceRedirect => 'Уста издесеңиз — «Ustachi» жүктөңүз';
	@override String get audienceTitle => 'Көңүл буруңуз: колдонмо усталар үчүн';
}

// Path: auth.otp
class _TranslationsAuthOtpKy extends TranslationsAuthOtpUz {
	_TranslationsAuthOtpKy._(TranslationsKy root) : this._root = root, super.internal(root);

	final TranslationsKy _root; // ignore: unused_field

	// Translations
	@override String get title => 'Кодду киргизиңиз';
	@override String sentMessage({required Object phone}) => '${phone} номерине жиберилген 6 сандуу кодду киргизиңиз';
	@override String get invalidCode => '6 сандын баарын киргизиңиз';
	@override String get resend => 'Кодду кайра жиберүү';
	@override String get resendIn => 'Кайра жиберүү';
	@override String get confirmBtn => 'Ырастоо';
	@override String get changeNumber => 'Башка номер киргизүү';
}

// Path: auth.profile
class _TranslationsAuthProfileKy extends TranslationsAuthProfileUz {
	_TranslationsAuthProfileKy._(TranslationsKy root) : this._root = root, super.internal(root);

	final TranslationsKy _root; // ignore: unused_field

	// Translations
	@override String get title => 'Өзүңүз жөнүндө';
	@override String get subtitle => 'Кардарлар сизди ушул ат менен көрөт. Кийин профилден өзгөртө аласыз.';
	@override String get fullNameLabel => 'Аты-жөнү';
	@override String get fullNameHint => 'Киргизиңиз';
	@override String get requiredName => 'Аты-жөнүңүздү киргизиңиз';
	@override String get addPhoto => 'Сүрөт кошуу';
	@override String get changePhoto => 'Сүрөттү алмаштыруу';
	@override String get saveBtn => 'Сактап, улантуу';
	@override String get skip => 'Кийин толтурам';
	@override String get regionLabel => 'Облус';
	@override String get regionHint => 'Облусту тандаңыз';
	@override String get districtLabel => 'Район / шаар';
	@override String get districtHint => 'Районду тандаңыз';
	@override String get addressLabel => 'Дарек';
	@override String get addressHint => 'Көчө, үй номери';
	@override String get requiredRegion => 'Облусту тандаңыз';
	@override String get requiredDistrict => 'Районду тандаңыз';
	@override String get loadFailed => 'Тизмени жүктөө мүмкүн болбоду';
}

// Path: auth.telegram
class _TranslationsAuthTelegramKy extends TranslationsAuthTelegramUz {
	_TranslationsAuthTelegramKy._(TranslationsKy root) : this._root = root, super.internal(root);

	final TranslationsKy _root; // ignore: unused_field

	// Translations
	@override String get loadingTitle => 'Telegram аркылуу кирүү';
	@override String get loadingHint => 'Бир жолку шилтеме текшерилүүдө…';
	@override String get invalidLink => 'Telegram шилтемеси жараксыз.';
	@override String get expiredLink => 'Шилтеменин мөөнөтү бүттү же мурда колдонулган. Ботто кайра баштаңыз.';
	@override String get retry => 'Кайра аракет кылуу';
	@override String get restartBot => 'Ботто кайра баштоо';
	@override String get smsOption => 'SMS аркылуу кирүү';
}

// Path: profile.personal
class _TranslationsProfilePersonalKy extends TranslationsProfilePersonalUz {
	_TranslationsProfilePersonalKy._(TranslationsKy root) : this._root = root, super.internal(root);

	final TranslationsKy _root; // ignore: unused_field

	// Translations
	@override String get sectionPersonal => 'Жеке';
	@override String get sectionAddress => 'Дарек';
	@override String get sectionProfessional => 'Кесиптик';
	@override String get phoneLabel => 'Телефон';
	@override String get phoneNote => 'Номер — аккаунттун идентификатору, өзгөрбөйт';
	@override String get joinedLabel => 'Катталган';
	@override String get empty => 'Көрсөтүлгөн эмес';
	@override String get edit => 'Түзөтүү';
	@override String get openProfessional => 'Адистик, тажрыйба жана иштер';
	@override String get loadFailed => 'Маалыматты жүктөө мүмкүн болбоду';
}

// Path: profile.help
class _TranslationsProfileHelpKy extends TranslationsProfileHelpUz {
	_TranslationsProfileHelpKy._(TranslationsKy root) : this._root = root, super.internal(root);

	final TranslationsKy _root; // ignore: unused_field

	// Translations
	@override String get subtitle => 'Суроо же көйгөй болсо — жазыңыз же чалыңыз';
	@override String get callLabel => 'Чалуу';
	@override String get emailLabel => 'Электрондук почта';
	@override String get telegramLabel => 'Telegram каналыбыз';
	@override String get telegramHint => 'Жаңылыктар жана жарыялар';
	@override String get workHours => 'Дүй–ишм, 9:00–19:00';
	@override String get copied => 'Көчүрүлдү';
}

// Path: orders.stage
class _TranslationsOrdersStageKy extends TranslationsOrdersStageUz {
	_TranslationsOrdersStageKy._(TranslationsKy root) : this._root = root, super.internal(root);

	final TranslationsKy _root; // ignore: unused_field

	// Translations
	@override String get accepted => 'Сунуш кабыл алынды';
	@override String get measured => 'Ченем алынды';
	@override String get production => 'Өндүрүш';
	@override String get installation => 'Орнотуу';
	@override String get handover => 'Тапшыруу жана төлөм';
}

// Path: orders.detail
class _TranslationsOrdersDetailKy extends TranslationsOrdersDetailUz {
	_TranslationsOrdersDetailKy._(TranslationsKy root) : this._root = root, super.internal(root);

	final TranslationsKy _root; // ignore: unused_field

	// Translations
	@override String get stages => 'Этаптар';
	@override String get spec => 'Спецификация';
	@override String get client => 'Кардар';
	@override String get total => 'Жалпы';
	@override String get prepaid => 'Алдын ала төлөм';
	@override String get remaining => 'Калдык';
	@override String get dueDate => 'Макулдашылган мөөнөт';
	@override String get finishOrder => 'Тапшырып, аяктоо';
	@override String get completed => 'Буйрутма аякталды';
	@override String stageDone({required Object stage}) => '${stage} аякталды';
	@override String get notFound => 'Буйрутма табылган жок';
	@override String get drawings => 'Сызмалар';
	@override String get drawingsHint => 'Эки манжа менен чоңойтуңуз · өлчөмдөр мм менен';
	@override String get markMeasured => 'Өлчөм алынды';
	@override String get markProduction => 'Өндүрүш башталды';
	@override String get markInstallation => 'Орнотууга чыктык';
	@override String get stageSaved => 'Белгиленди — кардарга кабар кетти';
}

// Path: orders.request
class _TranslationsOrdersRequestKy extends TranslationsOrdersRequestUz {
	_TranslationsOrdersRequestKy._(TranslationsKy root) : this._root = root, super.internal(root);

	final TranslationsKy _root; // ignore: unused_field

	// Translations
	@override String get title => 'Сурам';
	@override String get clientSpec => 'Кардар эсептеген спецификация';
	@override String get priceOffer => 'Баа сунушу';
	@override String get serviceFee => 'Монтаж жана жеткирүү';
	@override String get yourOffer => 'Сиздин сунушуңуз';
	@override String get workDays => 'Мөөнөт — жумуш күнү';
	@override String get note => 'Комментарий (милдеттүү эмес)';
	@override String get notePlaceholder => 'Кардарга кошумча комментарий…';
	@override String get send => 'Сунушту жиберүү';
	@override String get decline => 'Четке кагуу';
	@override String get declineTitle => 'Сурамды четке кагасызбы?';
	@override String get declineMessage => 'Бул сурам тизмеден таптакыр өчүрүлөт.';
	@override String expiresIn({required Object time}) => '${time} калды';
	@override String get expired => 'Мөөнөтү өттү';
	@override String distance({required Object km}) => '${km} км';
	@override String get sent => 'Сунуш жиберилди';
	@override String get invalidFee => 'Иш акысы терс боло албайт';
	@override String get chatNote => 'Баа менен шартты кардар менен чатта макулдашасыз.';
	@override String get withdrawOffer => 'Сунушту кайтарып алуу';
	@override String get declineInviteTitle => 'Сунушту четке кагасызбы?';
	@override String get declineInviteMessage => 'Кардарга дароо кабар барат жана ал башка уста тандайт.';
	@override String get clientPrice => 'Буйрутма баасы';
	@override String get priceInChat => 'Баа чатта макулдашылат';
}

// Path: orders.spec
class _TranslationsOrdersSpecKy extends TranslationsOrdersSpecUz {
	_TranslationsOrdersSpecKy._(TranslationsKy root) : this._root = root, super.internal(root);

	final TranslationsKy _root; // ignore: unused_field

	// Translations
	@override String get size => 'Өлчөмү (мм)';
	@override String get shape => 'Формасы';
	@override String get brand => 'Бренд';
	@override String get color => 'Түсү';
	@override String get material => 'Материал';
	@override String get glass => 'Айнек';
	@override String get sill => 'Терезе алды (см)';
	@override String get flower => 'Оюу';
	@override String get address => 'Дарек';
	@override String get product => 'Буюмдар';
	@override String get phone => 'Телефон';
	@override String get discount => 'Арзандатуу';
	@override String get note => 'Комментарий';
	@override String itemsValue({required Object kinds, required Object count}) => '${kinds} түр · ${count} даана';
	@override late final _TranslationsOrdersSpecValuesKy values = _TranslationsOrdersSpecValuesKy._(_root);
	@override String get area => 'Аянты';
	@override String get unitPrice => '1 м² баасы';
	@override String get variant => 'Деңгээл';
}

// Path: orders.open
class _TranslationsOrdersOpenKy extends TranslationsOrdersOpenUz {
	_TranslationsOrdersOpenKy._(TranslationsKy root) : this._root = root, super.internal(root);

	final TranslationsKy _root; // ignore: unused_field

	// Translations
	@override String get offerSent => 'Сунуш жөнөтүлдү';
	@override String get waitingClient => 'Кардардын жообун күтүүдө';
	@override String offersCount({required Object count}) => '${count} сунуш';
	@override String get beFirst => 'Биринчи болуңуз';
	@override String get newBadge => 'Жаңы';
	@override String get pageTitle => 'Ачык буйрутмалар';
	@override String get tabWaiting => 'Жооп күтүүдө';
	@override String get tabSent => 'Сунуш жөнөтүлдү';
	@override String get emptySentTitle => 'Жөнөтүлгөн сунуш жок';
	@override String get emptySentMessage => 'Жооп берген жарыяларыңыз бул жерде кардардын жообун күтөт.';
	@override String get tabInvited => 'Сизге сунуш';
	@override String get invitedBadge => 'Сизге сунуш';
	@override String get acceptInvite => 'Кабыл алам';
	@override String get emptyInvitedTitle => 'Жеке сунуш жок';
	@override String get emptyInvitedMessage => 'Кардар сизди тандаган буйрутмалар ушул жерде көрүнөт.';
	@override String get invitedNote => 'Кардар бул буйрутманы түз сизге жөнөттү — башка усталар көрбөйт.';
	@override String get repairBadge => 'Оңдоо';
}

// Path: ownOrders.status
class _TranslationsOwnOrdersStatusKy extends TranslationsOwnOrdersStatusUz {
	_TranslationsOwnOrdersStatusKy._(TranslationsKy root) : this._root = root, super.internal(root);

	final TranslationsKy _root; // ignore: unused_field

	// Translations
	@override String get draft => 'Долбоор';
	@override String get newOrder => 'Жаңы';
	@override String get inProgress => 'Жүрүүдө';
	@override String get done => 'Аякталды';
	@override String get debt => 'Карыз бар';
	@override String get cancelled => 'Жокко чыгарылды';
}

// Path: ownOrders.hint
class _TranslationsOwnOrdersHintKy extends TranslationsOwnOrdersHintUz {
	_TranslationsOwnOrdersHintKy._(TranslationsKy root) : this._root = root, super.internal(root);

	final TranslationsKy _root; // ignore: unused_field

	// Translations
	@override String get newOrder => 'Кабыл алынды, азырынча башталган жок';
	@override String get inProgress => 'Өндүрүш же монтаж жүрүүдө';
	@override String get done => 'Тапшырылды жана толук төлөндү';
	@override String get debt => 'Иш бүттү, бирок төлөм толук эмес';
	@override String get cancelled => 'Буйрутма жокко чыгарылды';
}

// Path: orderFlow.status
class _TranslationsOrderFlowStatusKy extends TranslationsOrderFlowStatusUz {
	_TranslationsOrderFlowStatusKy._(TranslationsKy root) : this._root = root, super.internal(root);

	final TranslationsKy _root; // ignore: unused_field

	// Translations
	@override String get published => 'Жарыяланды';
	@override String get assigned => 'Уста тандалды';
	@override String get completed => 'Аякталды';
	@override String get cancelled => 'Жокко чыгарылды';
	@override String get expired => 'Мөөнөтү өттү';
}

// Path: orderFlow.stage
class _TranslationsOrderFlowStageKy extends TranslationsOrderFlowStageUz {
	_TranslationsOrderFlowStageKy._(TranslationsKy root) : this._root = root, super.internal(root);

	final TranslationsKy _root; // ignore: unused_field

	// Translations
	@override String get accepted => 'Кабыл алынды';
	@override String get measured => 'Ченем алынды';
	@override String get production => 'Өндүрүш';
	@override String get installation => 'Орнотуу';
	@override String get handover => 'Тапшырылды';
}

// Path: orderFlow.response
class _TranslationsOrderFlowResponseKy extends TranslationsOrderFlowResponseUz {
	_TranslationsOrderFlowResponseKy._(TranslationsKy root) : this._root = root, super.internal(root);

	final TranslationsKy _root; // ignore: unused_field

	// Translations
	@override String get interested => 'Кабыл алам';
	@override String get withdrawn => 'Баш тартты';
	@override String get chosen => 'Тандалды';
	@override String get rejected => 'Тандалган жок';
}

// Path: orders.spec.values
class _TranslationsOrdersSpecValuesKy extends TranslationsOrdersSpecValuesUz {
	_TranslationsOrdersSpecValuesKy._(TranslationsKy root) : this._root = root, super.internal(root);

	final TranslationsKy _root; // ignore: unused_field

	// Translations
	@override String get plastic => 'Пластик';
	@override String get aluminium => 'Алюминий';
	@override String get termo => 'Термо';
	@override String get doubleGlass => 'Эки катмар';
	@override String get singleGlass => 'Бир катмар';
	@override String get large => 'Чоң';
	@override String get medium => 'Орточо';
	@override String get small => 'Кичине';
}

/// The flat map containing all translations for locale <ky>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on TranslationsKy {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'applicationName' => 'Ustachi',
			'common.ok' => 'OK',
			'common.start' => 'Баштоо',
			'common.cancel' => 'Жокко чыгаруу',
			'common.save' => 'Сактоо',
			'common.delete' => 'Өчүрүү',
			'common.edit' => 'Түзөтүү',
			'common.close' => 'Жабуу',
			'common.back' => 'Артка',
			'common.next' => 'Кийинки',
			'common.skip' => 'Өткөрүп жиберүү',
			'common.enter' => 'Киргизиңиз',
			'common.wentWrong' => 'Ката кетти. Бир аздан кийин кайра аракет кылыңыз!',
			'common.common' => 'Негизги',
			'common.select' => 'Тандоо',
			'common.retry' => 'Кайталоо',
			'common.refresh' => 'Жаңылоо',
			'common.saved' => 'Сакталды',
			'common.saveFailed' => 'Сакталган жок — кайра аракет кылыңыз',
			'common.notFound' => 'Табылган жок',
			'common.empty' => 'Бош',
			'common.loading' => 'Жүктөлүүдө…',
			'common.yes' => 'Ооба',
			'common.no' => 'Жок',
			'common.add' => 'Кошуу',
			'common.copy' => 'Көчүрүү',
			'common.apply' => 'Колдонуу',
			'common.reset' => 'Кайтаруу',
			'common.done' => 'Даяр',
			'common.all' => 'Баары',
			'common.som' => 'сом',
			'common.cm' => 'см',
			'common.mm' => 'мм',
			'common.pcs' => 'даана',
			'common.hoursShort' => 'с',
			'common.minutesShort' => 'мүн',
			'common.months.0' => 'январь',
			'common.months.1' => 'февраль',
			'common.months.2' => 'март',
			'common.months.3' => 'апрель',
			'common.months.4' => 'май',
			'common.months.5' => 'июнь',
			'common.months.6' => 'июль',
			'common.months.7' => 'август',
			'common.months.8' => 'сентябрь',
			'common.months.9' => 'октябрь',
			'common.months.10' => 'ноябрь',
			'common.months.11' => 'декабрь',
			'common.weekdays.0' => 'Жекшемби',
			'common.weekdays.1' => 'Дүйшөмбү',
			'common.weekdays.2' => 'Шейшемби',
			'common.weekdays.3' => 'Шаршемби',
			'common.weekdays.4' => 'Бейшемби',
			'common.weekdays.5' => 'Жума',
			'common.weekdays.6' => 'Ишемби',
			'common.today' => 'Бүгүн',
			'common.tomorrow' => 'Эртең',
			'common.comingSoon' => 'Жакында',
			'onboarding.step1.title' => 'Өз багытыңызды тандаңыз',
			'onboarding.step1.description' => 'Терезе, чатыр, кыш, электрик, сантехник, кафель, боёк… 25тен ашык багыт. Буйрутмалар сиздин багытыңыз боюнча келет.',
			'onboarding.step2.title' => 'Буйрутма өзү табат',
			'onboarding.step2.description' => 'Аймагыңызга жана багытыңызга дал келген жаңы жарыялар дароо билдирме болуп келет — издөөнүн кереги жок.',
			'onboarding.step3.title' => 'Баа сиздики',
			'onboarding.step3.description' => 'Өз бааңызды киргизесиз, кардар менен чатта макулдашасыз жана иштин этаптарын белгилеп барасыз.',
			'auth.tagline' => 'УСТАНЫН ИШ МЕЙКИНДИГИ',
			'auth.common.invalidPhone' => 'Телефон номерин туура киргизиңиз',
			'auth.common.cancel' => 'Жокко чыгаруу',
			'auth.phone.title' => 'Колдонмого кирүү',
			'auth.phone.subtitle' => 'Номериңизди киргизиңиз — SMS аркылуу 6 сандуу код жиберебиз. Сырсөз керек эмес.',
			'auth.phone.label' => 'Телефон номери',
			'auth.phone.continueBtn' => 'Улантуу',
			'auth.phone.orOption' => 'же',
			'auth.phone.telegramBtn' => 'Telegram аркылуу кирүү',
			'auth.phone.telegramHint' => 'Бот кирүү үчүн Telegram аккаунтуңузга байланыштуу номерди сурайт. SMS жөнөтүлбөйт.',
			'auth.phone.telegramOpenError' => 'Telegram ботун ачуу мүмкүн болбоду. Кайра аракет кылыңыз.',
			'auth.phone.agreementPrefix' => 'Улантуу менен сиз ',
			'auth.phone.terms' => 'Колдонуу шарттары',
			'auth.phone.and' => ' жана ',
			'auth.phone.privacy' => 'Купуялык саясаты',
			'auth.phone.agreementSuffix' => ' менен макул болосуз.',
			'auth.phone.audienceRedirect' => 'Уста издесеңиз — «Ustachi» жүктөңүз',
			'auth.phone.audienceTitle' => 'Көңүл буруңуз: колдонмо усталар үчүн',
			'auth.otp.title' => 'Кодду киргизиңиз',
			'auth.otp.sentMessage' => ({required Object phone}) => '${phone} номерине жиберилген 6 сандуу кодду киргизиңиз',
			'auth.otp.invalidCode' => '6 сандын баарын киргизиңиз',
			'auth.otp.resend' => 'Кодду кайра жиберүү',
			'auth.otp.resendIn' => 'Кайра жиберүү',
			'auth.otp.confirmBtn' => 'Ырастоо',
			'auth.otp.changeNumber' => 'Башка номер киргизүү',
			'auth.profile.title' => 'Өзүңүз жөнүндө',
			'auth.profile.subtitle' => 'Кардарлар сизди ушул ат менен көрөт. Кийин профилден өзгөртө аласыз.',
			'auth.profile.fullNameLabel' => 'Аты-жөнү',
			'auth.profile.fullNameHint' => 'Киргизиңиз',
			'auth.profile.requiredName' => 'Аты-жөнүңүздү киргизиңиз',
			'auth.profile.addPhoto' => 'Сүрөт кошуу',
			'auth.profile.changePhoto' => 'Сүрөттү алмаштыруу',
			'auth.profile.saveBtn' => 'Сактап, улантуу',
			'auth.profile.skip' => 'Кийин толтурам',
			'auth.profile.regionLabel' => 'Облус',
			'auth.profile.regionHint' => 'Облусту тандаңыз',
			'auth.profile.districtLabel' => 'Район / шаар',
			'auth.profile.districtHint' => 'Районду тандаңыз',
			'auth.profile.addressLabel' => 'Дарек',
			'auth.profile.addressHint' => 'Көчө, үй номери',
			'auth.profile.requiredRegion' => 'Облусту тандаңыз',
			'auth.profile.requiredDistrict' => 'Районду тандаңыз',
			'auth.profile.loadFailed' => 'Тизмени жүктөө мүмкүн болбоду',
			'auth.telegram.loadingTitle' => 'Telegram аркылуу кирүү',
			'auth.telegram.loadingHint' => 'Бир жолку шилтеме текшерилүүдө…',
			'auth.telegram.invalidLink' => 'Telegram шилтемеси жараксыз.',
			'auth.telegram.expiredLink' => 'Шилтеменин мөөнөтү бүттү же мурда колдонулган. Ботто кайра баштаңыз.',
			'auth.telegram.retry' => 'Кайра аракет кылуу',
			'auth.telegram.restartBot' => 'Ботто кайра баштоо',
			'auth.telegram.smsOption' => 'SMS аркылуу кирүү',
			'country.title' => 'Өлкөнү тандаңыз',
			'country.subtitle' => 'Колдонмонун тили өлкөгө жараша тандалат. Кийин профилден өзгөртө аласыз.',
			'country.continueBtn' => 'Улантуу',
			'country.changeTitle' => 'Өлкө жана тил',
			'home.main' => 'Башкы',
			'home.chatting' => 'Чат',
			'home.profile' => 'Профиль',
			'home.title' => 'Профиль',
			'home.loadError' => 'Профиль жүктөлгөн жок',
			'home.retry' => 'Кайталоо',
			'home.phone' => 'Телефон',
			'home.role' => 'Ролу',
			'home.status' => 'Абалы',
			'home.active' => 'Активдүү',
			'home.inactive' => 'Активдүү эмес',
			'home.logout' => 'Чыгуу',
			'home.hi' => 'Салам',
			'home.serviceType' => 'Кызмат түрлөрү',
			'home.lastOrders' => 'Акыркы буйрутмалар',
			'home.all' => 'Баары',
			'home.tapRepair' => 'Кран оңдоо',
			'home.chandelierInstallation' => 'Люстра орнотуу',
			'home.completed' => 'Аткарылды',
			'home.inProgress' => 'Жүрүүдө',
			'home.window' => 'Терезе',
			'home.furtiniture' => 'Эмерек',
			'home.electric' => 'Электрика',
			'home.plumber' => 'Сантехника',
			'calculatePage.window' => 'Терезе',
			'calculatePage.door' => 'Эшик',
			'calculatePage.glass' => 'Аркалар',
			'calculatePage.windowConfigurator' => 'Терезе конфигурациясы',
			'calculatePage.windowLayouts' => 'Бөлүнүү түрлөрү',
			'calculatePage.windowPremiumLayouts' => 'Премиум варианттар',
			'calculatePage.windowModernLayouts' => 'Заманбап варианттар',
			'calculatePage.doorConfigurator' => 'Эшик конфигурациясы',
			'calculatePage.doorModels' => 'Эшик моделдери',
			'calculatePage.doorExtraModels' => 'Кошумча моделдер',
			'calculatePage.material' => 'Материал',
			'calculatePage.plastic' => 'Пластик',
			'calculatePage.aluminium' => 'Алюминий',
			'calculatePage.termo' => 'Термо',
			'calculatePage.glassShowcase' => 'Арка варианттары',
			'calculatePage.customTemplateTitleWindow' => 'Өз терезеңизди түзүңүз',
			'calculatePage.customTemplateTitleDoor' => 'Өз эшигиңизди түзүңүз',
			'calculatePage.customTemplateTitleArch' => 'Өз аркаңызды түзүңүз',
			'calculatePage.customTemplateSubtitle' => 'Даяр үлгү эмес — өлчөм менен бөлүнүүнү өзүңүз тартасыз',
			'calculatePage.customTemplateAction' => 'Баштоо',
			'calculatePage.readyTemplates' => 'Даяр үлгүлөр',
			'profile.personalData' => 'Жеке маалыматтар',
			'profile.professional' => 'Кесиптик маалымат',
			'profile.company' => 'Ишкана',
			'profile.myOrders' => 'Менин буйрутмаларым',
			'profile.settings' => 'Жөндөөлөр',
			'profile.support' => 'Биз менен байланыш',
			'profile.logout' => 'Чыгуу',
			'profile.logoutTitle' => 'Аккаунттан чыгасызбы?',
			'profile.logoutMessage' => 'Жүктөлгөн баалар жана эсептөө маалыматтары түзмөктөн өчүрүлөт. Кайра киргенде алар жаңыдан жүктөлөт.',
			'profile.logoutConfirm' => 'Ооба, чыгам',
			'profile.loggingOut' => 'Чыгууда...',
			'profile.loggingOutHint' => 'Сессия жабылып, баа кэши тазаланууда',
			'profile.logoutFailed' => 'Серверден чыгуу мүмкүн болбоду, бирок түзмөктөгү маалыматтар тазаланды',
			'profile.personal.sectionPersonal' => 'Жеке',
			'profile.personal.sectionAddress' => 'Дарек',
			'profile.personal.sectionProfessional' => 'Кесиптик',
			'profile.personal.phoneLabel' => 'Телефон',
			'profile.personal.phoneNote' => 'Номер — аккаунттун идентификатору, өзгөрбөйт',
			'profile.personal.joinedLabel' => 'Катталган',
			'profile.personal.empty' => 'Көрсөтүлгөн эмес',
			'profile.personal.edit' => 'Түзөтүү',
			'profile.personal.openProfessional' => 'Адистик, тажрыйба жана иштер',
			'profile.personal.loadFailed' => 'Маалыматты жүктөө мүмкүн болбоду',
			'profile.help.subtitle' => 'Суроо же көйгөй болсо — жазыңыз же чалыңыз',
			'profile.help.callLabel' => 'Чалуу',
			'profile.help.emailLabel' => 'Электрондук почта',
			'profile.help.telegramLabel' => 'Telegram каналыбыз',
			'profile.help.telegramHint' => 'Жаңылыктар жана жарыялар',
			'profile.help.workHours' => 'Дүй–ишм, 9:00–19:00',
			'profile.help.copied' => 'Көчүрүлдү',
			'dashboard.title' => 'Иш столу',
			'dashboard.greetingMorning' => 'Кутмандуу таң,',
			'dashboard.greetingDay' => 'Кутмандуу күн,',
			'dashboard.greetingEvening' => 'Кутмандуу кеч,',
			'dashboard.master' => 'уста',
			'dashboard.availableTitle' => 'Буйрутма кабыл алам',
			'dashboard.availableOn' => 'Жаңы сурамдар келе берет',
			'dashboard.availableOff' => 'Сурамдар токтотулду',
			'dashboard.newRequests' => 'Жаңы сурамдар',
			'dashboard.activeOrders' => 'Активдүү буйрутмалар',
			'dashboard.all' => 'Баары',
			'dashboard.quickCalculate' => 'Терезе чиймеси',
			'dashboard.quickCalculateHint' => 'Терезе жана эшик чиймеси',
			'dashboard.quickPortfolio' => 'Иш үлгүсү',
			'dashboard.quickPortfolioHint' => 'Аяктаган иштен кошуңуз',
			'dashboard.emptyRequests' => 'Жаңы сурам жок',
			'dashboard.emptyRequestsHint' => 'Бош эместик которгучу күйгүзүлсө, сурамдар ушул жерге түшөт.',
			'dashboard.quickCompany' => 'Ишкана',
			'dashboard.quickCompanyHint' => 'Аты жана логотип',
			'dashboard.quickRates' => 'Кызмат бааларым',
			'dashboard.quickRatesHint' => 'Тармак боюнча иш баалары',
			'dashboard.quickOrdersHeroTitle' => 'Жаңы буйрутмалар жана Базар',
			'dashboard.quickOrdersHeroHint' => 'Тармагыңыздагы жарыяларды көрүп, сунуш жөнөтүңүз',
			'dashboard.quickOpenOrders' => 'Ачык буйрутмалар',
			'dashboard.quickOpenOrdersHint' => 'Уста тандалбаган жарыялар — сунуш жөнөтүңүз',
			'dashboard.calcStep1' => 'Рам тандаңыз',
			'dashboard.calcStep2' => 'Ырастаңыз',
			'dashboard.calcStep3' => 'Чийме даяр',
			'dashboard.repairTitle' => 'Оңдоо иштерин кабыл алам',
			'dashboard.repairOn' => 'Оңдоо боюнча билдирүүлөр да келет',
			'dashboard.repairOff' => 'Оңдоо боюнча билдирүүлөр келбейт',
			'dashboard.repairHint' => 'Эски терезе-эшиктерди жөндөө, фурнитура же айнек алмаштыруу',
			'orders.title' => 'Буйрутмалар',
			'orders.segmentNew' => 'Ачык',
			'orders.segmentActive' => 'Жүрүүдө',
			'orders.segmentDone' => 'Аяктаган',
			'orders.stepOf' => ({required Object total, required Object step}) => '${total} этаптын ${step}-си',
			'orders.lateDays' => ({required Object days}) => '${days} күн кечикти',
			'orders.dueToday' => 'Мөөнөтү — бүгүн',
			'orders.daysLeft' => ({required Object days}) => '${days} күн калды',
			'orders.offerBtn' => 'Сунуш берүү',
			'orders.retry' => 'Кайталоо',
			'orders.loadFailed' => 'Буйрутмаларды жүктөө мүмкүн болбоду',
			'orders.emptyNewTitle' => 'Ачык буйрутма жок',
			'orders.emptyNewMessage' => 'Аймагыңызда жаңы жарыя пайда болсо ушул жерде көрүнөт.',
			'orders.emptyActiveTitle' => 'Активдүү буйрутма жок',
			'orders.emptyActiveMessage' => 'Жаңы сурамды кабыл алсаңыз, ал ушул жерде пайда болот.',
			'orders.emptyDoneTitle' => 'Аяктаган иш жок',
			'orders.emptyDoneMessage' => 'Биринчи буйрутманы тапшыргандан кийин ал ушул жерде көрүнөт.',
			'orders.stage.accepted' => 'Сунуш кабыл алынды',
			'orders.stage.measured' => 'Ченем алынды',
			'orders.stage.production' => 'Өндүрүш',
			'orders.stage.installation' => 'Орнотуу',
			'orders.stage.handover' => 'Тапшыруу жана төлөм',
			'orders.detail.stages' => 'Этаптар',
			'orders.detail.spec' => 'Спецификация',
			'orders.detail.client' => 'Кардар',
			'orders.detail.total' => 'Жалпы',
			'orders.detail.prepaid' => 'Алдын ала төлөм',
			'orders.detail.remaining' => 'Калдык',
			'orders.detail.dueDate' => 'Макулдашылган мөөнөт',
			'orders.detail.finishOrder' => 'Тапшырып, аяктоо',
			'orders.detail.completed' => 'Буйрутма аякталды',
			'orders.detail.stageDone' => ({required Object stage}) => '${stage} аякталды',
			'orders.detail.notFound' => 'Буйрутма табылган жок',
			'orders.detail.drawings' => 'Сызмалар',
			'orders.detail.drawingsHint' => 'Эки манжа менен чоңойтуңуз · өлчөмдөр мм менен',
			'orders.detail.markMeasured' => 'Өлчөм алынды',
			'orders.detail.markProduction' => 'Өндүрүш башталды',
			'orders.detail.markInstallation' => 'Орнотууга чыктык',
			'orders.detail.stageSaved' => 'Белгиленди — кардарга кабар кетти',
			'orders.request.title' => 'Сурам',
			'orders.request.clientSpec' => 'Кардар эсептеген спецификация',
			'orders.request.priceOffer' => 'Баа сунушу',
			'orders.request.serviceFee' => 'Монтаж жана жеткирүү',
			'orders.request.yourOffer' => 'Сиздин сунушуңуз',
			'orders.request.workDays' => 'Мөөнөт — жумуш күнү',
			'orders.request.note' => 'Комментарий (милдеттүү эмес)',
			'orders.request.notePlaceholder' => 'Кардарга кошумча комментарий…',
			'orders.request.send' => 'Сунушту жиберүү',
			'orders.request.decline' => 'Четке кагуу',
			'orders.request.declineTitle' => 'Сурамды четке кагасызбы?',
			'orders.request.declineMessage' => 'Бул сурам тизмеден таптакыр өчүрүлөт.',
			'orders.request.expiresIn' => ({required Object time}) => '${time} калды',
			'orders.request.expired' => 'Мөөнөтү өттү',
			'orders.request.distance' => ({required Object km}) => '${km} км',
			'orders.request.sent' => 'Сунуш жиберилди',
			'orders.request.invalidFee' => 'Иш акысы терс боло албайт',
			'orders.request.chatNote' => 'Баа менен шартты кардар менен чатта макулдашасыз.',
			'orders.request.withdrawOffer' => 'Сунушту кайтарып алуу',
			'orders.request.declineInviteTitle' => 'Сунушту четке кагасызбы?',
			'orders.request.declineInviteMessage' => 'Кардарга дароо кабар барат жана ал башка уста тандайт.',
			'orders.request.clientPrice' => 'Буйрутма баасы',
			'orders.request.priceInChat' => 'Баа чатта макулдашылат',
			'orders.spec.size' => 'Өлчөмү (мм)',
			'orders.spec.shape' => 'Формасы',
			'orders.spec.brand' => 'Бренд',
			'orders.spec.color' => 'Түсү',
			'orders.spec.material' => 'Материал',
			'orders.spec.glass' => 'Айнек',
			'orders.spec.sill' => 'Терезе алды (см)',
			'orders.spec.flower' => 'Оюу',
			'orders.spec.address' => 'Дарек',
			'orders.spec.product' => 'Буюмдар',
			'orders.spec.phone' => 'Телефон',
			'orders.spec.discount' => 'Арзандатуу',
			'orders.spec.note' => 'Комментарий',
			'orders.spec.itemsValue' => ({required Object kinds, required Object count}) => '${kinds} түр · ${count} даана',
			'orders.spec.values.plastic' => 'Пластик',
			'orders.spec.values.aluminium' => 'Алюминий',
			'orders.spec.values.termo' => 'Термо',
			'orders.spec.values.doubleGlass' => 'Эки катмар',
			'orders.spec.values.singleGlass' => 'Бир катмар',
			'orders.spec.values.large' => 'Чоң',
			'orders.spec.values.medium' => 'Орточо',
			'orders.spec.values.small' => 'Кичине',
			'orders.spec.area' => 'Аянты',
			'orders.spec.unitPrice' => '1 м² баасы',
			'orders.spec.variant' => 'Деңгээл',
			'orders.invalidId' => 'Буйрутма номери туура эмес.',
			'orders.invalidRequestId' => 'Сурам номери туура эмес.',
			'orders.open.offerSent' => 'Сунуш жөнөтүлдү',
			'orders.open.waitingClient' => 'Кардардын жообун күтүүдө',
			'orders.open.offersCount' => ({required Object count}) => '${count} сунуш',
			'orders.open.beFirst' => 'Биринчи болуңуз',
			'orders.open.newBadge' => 'Жаңы',
			'orders.open.pageTitle' => 'Ачык буйрутмалар',
			'orders.open.tabWaiting' => 'Жооп күтүүдө',
			'orders.open.tabSent' => 'Сунуш жөнөтүлдү',
			'orders.open.emptySentTitle' => 'Жөнөтүлгөн сунуш жок',
			'orders.open.emptySentMessage' => 'Жооп берген жарыяларыңыз бул жерде кардардын жообун күтөт.',
			'orders.open.tabInvited' => 'Сизге сунуш',
			'orders.open.invitedBadge' => 'Сизге сунуш',
			'orders.open.acceptInvite' => 'Кабыл алам',
			'orders.open.emptyInvitedTitle' => 'Жеке сунуш жок',
			'orders.open.emptyInvitedMessage' => 'Кардар сизди тандаган буйрутмалар ушул жерде көрүнөт.',
			'orders.open.invitedNote' => 'Кардар бул буйрутманы түз сизге жөнөттү — башка усталар көрбөйт.',
			'orders.open.repairBadge' => 'Оңдоо',
			'orders.personalTitle' => 'Менин буйрутмаларым',
			'ownOrders.orderTitle' => 'Буйрутма',
			'ownOrders.itemsCount' => ({required Object count}) => '${count} терезе',
			'ownOrders.statusTitle' => 'Буйрутманын абалы',
			'ownOrders.statusRow' => 'Абалы',
			'ownOrders.saving' => 'Сакталууда…',
			'ownOrders.tapToChange' => 'Өзгөртүү үчүн басыңыз',
			'ownOrders.alreadyDone' => 'Бул буйрутма мурунтан эле аякталган.',
			'ownOrders.cannotChange' => 'Бул буйрутманын абалын өзгөртүүгө болбойт.',
			'ownOrders.status.draft' => 'Долбоор',
			'ownOrders.status.newOrder' => 'Жаңы',
			'ownOrders.status.inProgress' => 'Жүрүүдө',
			'ownOrders.status.done' => 'Аякталды',
			'ownOrders.status.debt' => 'Карыз бар',
			'ownOrders.status.cancelled' => 'Жокко чыгарылды',
			'ownOrders.hint.newOrder' => 'Кабыл алынды, азырынча башталган жок',
			'ownOrders.hint.inProgress' => 'Өндүрүш же монтаж жүрүүдө',
			'ownOrders.hint.done' => 'Тапшырылды жана толук төлөндү',
			'ownOrders.hint.debt' => 'Иш бүттү, бирок төлөм толук эмес',
			'ownOrders.hint.cancelled' => 'Буйрутма жокко чыгарылды',
			'orderForm.noProducts' => 'Буйрутмада буюм жок.',
			'orderForm.queued' => 'Интернет жок — буйрутма кезекке коюлду, өзү жиберилет.',
			'orderForm.saved' => 'Буйрутма сакталды',
			'orderForm.saveTitle' => 'Буйрутманы сактоо',
			'orderForm.customer' => 'Буйрутмачы',
			'orderForm.nameLabel' => 'Аты',
			'orderForm.nameHint' => 'Азиз',
			'orderForm.nameRequired' => 'Атын жазыңыз',
			'orderForm.addressHint' => 'Чиланзар 9-кичи район',
			'orderForm.noteLabel' => 'Кошумча комментарий',
			'orderForm.noteHint' => '2-кабат, лифт жок',
			'orderForm.itemsSummary' => ({required Object kinds, required Object count}) => '${kinds} түрдүү терезе · ${count} даана',
			'chat.threadsTitle' => 'Маектешүүлөр',
			'chat.conversation' => 'Маектешүү',
			'chat.messageHint' => 'Билдирүү жазыңыз...',
			'chat.emptyChat' => 'Баа менен шартты ушул жерде макулдашасыз',
			'chat.emptyThreadsTitle' => 'Азырынча маектешүү жок',
			'chat.emptyThreadsMessage' => 'Уста буйрутмаңызга жооп бергенде ушул жерде жазышасыз.',
			'notifications.title' => 'Билдирүүлөр',
			'notifications.markAllRead' => 'Баарын окулду деп белгилөө',
			'notifications.empty' => 'Билдирүү жок',
			'notifications.open' => 'Ачуу',
			'masters.title' => 'Уста жөнүндө',
			'masters.master' => 'Уста',
			'masters.client' => 'Кардар',
			'masters.write' => 'Жазуу',
			'masters.chooseThis' => 'Ушул устаны тандоо',
			'masters.choose' => 'Тандоо',
			'masters.chosen' => 'Тандалган уста',
			'masters.notFound' => 'Маалымат табылган жок',
			'masters.works' => 'Аткарган иштери',
			'masters.reviews' => ({required Object count}) => 'Пикирлер (${count})',
			'masters.reviewsLabel' => 'Пикирлер',
			'masters.noReviews' => 'Азырынча пикир жок — биринчи сиз болсоңуз болот.',
			'masters.experienceYears' => ({required Object years}) => '${years} жыл тажрыйба',
			'masters.rating' => 'Рейтинг',
			'masters.completed' => 'Аткарылды',
			'masters.responses' => ({required Object count}) => '${count} жооп',
			'masters.estimate' => 'Эсеп',
			'orderFlow.status.published' => 'Жарыяланды',
			'orderFlow.status.assigned' => 'Уста тандалды',
			'orderFlow.status.completed' => 'Аякталды',
			'orderFlow.status.cancelled' => 'Жокко чыгарылды',
			'orderFlow.status.expired' => 'Мөөнөтү өттү',
			'orderFlow.stage.accepted' => 'Кабыл алынды',
			'orderFlow.stage.measured' => 'Ченем алынды',
			'orderFlow.stage.production' => 'Өндүрүш',
			'orderFlow.stage.installation' => 'Орнотуу',
			'orderFlow.stage.handover' => 'Тапшырылды',
			'orderFlow.response.interested' => 'Кабыл алам',
			'orderFlow.response.withdrawn' => 'Баш тартты',
			'orderFlow.response.chosen' => 'Тандалды',
			'orderFlow.response.rejected' => 'Тандалган жок',
			'company.title' => 'Ишкана',
			'company.nameLabel' => 'Ишкананын аты',
			'company.nameHint' => 'Мисалы: Ustachi Servis',
			'company.nameEmpty' => 'Ишкананын аты киргизилген эмес',
			'company.nameNote' => 'Буйрутма барагында көрүнөт',
			'company.logoHint' => 'Логотип кошуу',
			'companyRates.onlyDigits' => 'Сандар гана',
			'materials.title' => 'Материалдар',
			'materials.on' => 'Бул материал менен иштейм — буюртмалар келет',
			'materials.off' => 'Өчүк — бул материал боюнча буюртмалар келбейт',
			'materials.allOff' => 'Кеминде бир материал күйүп турушу керек',
			'professional.title' => 'Кесиптик маалымат',
			'professional.headline' => 'Кандай уста экениңизди айтыңыз',
			'professional.headlineHint' => 'Кардар сизди тандаардан мурун ушул маалыматты көрөт. Кийин каалаган убакта өзгөртө аласыз.',
			'professional.specialty' => 'Багыттар',
			'professional.specialtyPick' => 'Багыттарыңызды тандаңыз',
			'professional.specialtyLoadFailed' => 'Багыттардын тизмеси жүктөлгөн жок — интернетти текшерип, кайра кириңиз.',
			'professional.experienceQuestion' => 'Канча жылдык тажрыйбаңыз бар?',
			'professional.experienceHint' => 'Мисалы: 5',
			'professional.experienceRequired' => 'Тажрыйбаны киргизиңиз',
			'professional.experienceRange' => 'Тажрыйба 0дөн 70ке чейин болушу керек',
			'professional.aboutLabel' => 'Өзүңүз жөнүндө (милдеттүү эмес)',
			'professional.aboutHint' => 'Кандай иштерди аткарасыз, эмнеге көңүл бурасыз — кыскача жазыңыз.',
			'professional.works' => 'Иштериңиз',
			'professional.worksHint' => 'Сүрөт кошсоңуз, кардар ишиңизди көрөт жана сизди тандоо ыктымалдыгы жогорулайт. Милдеттүү эмес — кийин да кошсо болот.',
			'professional.deleteSampleTitle' => 'Үлгүнү өчүрөсүзбү?',
			'professional.deleteSampleMessage' => 'Кардарлар бул сүрөттү мындан ары көрбөйт.',
			'professional.deleteFailed' => 'Өчүрүлгөн жок',
			'professional.pickSpecialty' => 'Жок дегенде бир багыт тандаңыз',
			'professional.specialtyHint' => 'Бир нечесин тандасаңыз болот — буйрутма ушул багыттар боюнча гана келет.',
			'appUpdate.eyebrow' => 'ЖАҢЫРТУУ',
			'appUpdate.titleOptional' => 'Жаңы версия даяр',
			'appUpdate.titleRequired' => 'Жаңыртуу талап кылынат',
			'appUpdate.bodyOptional' => 'Ustachi Pro\'нун жаңы версиясы чыкты. Акыркы оңдоолор жана мүмкүнчүлүктөр үчүн жаңыртыңыз.',
			'appUpdate.bodyRequired' => 'Бул версия мындан ары колдоого алынбайт. Колдонмону улантуу үчүн жаңыртыңыз.',
			'appUpdate.whatsNew' => 'ЭМНЕ ЖАҢЫРДЫ',
			'appUpdate.versionFrom' => 'Сизде',
			'appUpdate.versionTo' => 'Жаңы',
			'appUpdate.update' => 'Жаңыртуу',
			'appUpdate.later' => 'Кийинчерээк',
			'appUpdate.openFailed' => 'Шилтемени ачуу мүмкүн болбоду. Колдонмону дүкөндөн кол менен жаңыртыңыз.',
			_ => null,
		};
	}
}
