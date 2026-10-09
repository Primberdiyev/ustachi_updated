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
class TranslationsTg extends Translations with BaseTranslations<AppLocale, Translations> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	TranslationsTg({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.tg,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		super.$meta.setFlatMapFunction($meta.getTranslation); // copy base translations to super.$meta
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <tg>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	@override dynamic operator[](String key) => $meta.getTranslation(key) ?? super.$meta.getTranslation(key);

	late final TranslationsTg _root = this; // ignore: unused_field

	@override 
	TranslationsTg $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => TranslationsTg(meta: meta ?? this.$meta);

	// Translations
	@override String get applicationName => 'Ustachi';
	@override late final _TranslationsCommonTg common = _TranslationsCommonTg._(_root);
	@override late final _TranslationsOnboardingTg onboarding = _TranslationsOnboardingTg._(_root);
	@override late final _TranslationsAuthTg auth = _TranslationsAuthTg._(_root);
	@override late final _TranslationsCountryTg country = _TranslationsCountryTg._(_root);
	@override late final _TranslationsHomeTg home = _TranslationsHomeTg._(_root);
	@override late final _TranslationsCalculatePageTg calculatePage = _TranslationsCalculatePageTg._(_root);
	@override late final _TranslationsProfileTg profile = _TranslationsProfileTg._(_root);
	@override late final _TranslationsDashboardTg dashboard = _TranslationsDashboardTg._(_root);
	@override late final _TranslationsOrdersTg orders = _TranslationsOrdersTg._(_root);
	@override late final _TranslationsOwnOrdersTg ownOrders = _TranslationsOwnOrdersTg._(_root);
	@override late final _TranslationsOrderFormTg orderForm = _TranslationsOrderFormTg._(_root);
	@override late final _TranslationsChatTg chat = _TranslationsChatTg._(_root);
	@override late final _TranslationsNotificationsTg notifications = _TranslationsNotificationsTg._(_root);
	@override late final _TranslationsMastersTg masters = _TranslationsMastersTg._(_root);
	@override late final _TranslationsOrderFlowTg orderFlow = _TranslationsOrderFlowTg._(_root);
	@override late final _TranslationsCompanyTg company = _TranslationsCompanyTg._(_root);
	@override late final _TranslationsCompanyRatesTg companyRates = _TranslationsCompanyRatesTg._(_root);
	@override late final _TranslationsMaterialsTg materials = _TranslationsMaterialsTg._(_root);
	@override late final _TranslationsProfessionalTg professional = _TranslationsProfessionalTg._(_root);
	@override late final _TranslationsAppUpdateTg appUpdate = _TranslationsAppUpdateTg._(_root);
}

// Path: common
class _TranslationsCommonTg extends TranslationsCommonUz {
	_TranslationsCommonTg._(TranslationsTg root) : this._root = root, super.internal(root);

	final TranslationsTg _root; // ignore: unused_field

	// Translations
	@override String get ok => 'OK';
	@override String get start => 'Оғоз';
	@override String get cancel => 'Бекор кардан';
	@override String get save => 'Нигоҳ доштан';
	@override String get delete => 'Нест кардан';
	@override String get edit => 'Таҳрир';
	@override String get close => 'Пӯшидан';
	@override String get back => 'Ба қафо';
	@override String get next => 'Баъдӣ';
	@override String get skip => 'Гузарондан';
	@override String get enter => 'Ворид кунед';
	@override String get wentWrong => 'Хатогӣ рӯй дод. Лутфан баъдтар боз кӯшиш кунед!';
	@override String get common => 'Асосӣ';
	@override String get select => 'Интихоб';
	@override String get retry => 'Такрор';
	@override String get refresh => 'Навсозӣ';
	@override String get saved => 'Нигоҳ дошта шуд';
	@override String get saveFailed => 'Нигоҳ дошта нашуд — боз кӯшиш кунед';
	@override String get notFound => 'Ёфт нашуд';
	@override String get empty => 'Холӣ';
	@override String get loading => 'Боргирӣ…';
	@override String get yes => 'Ҳа';
	@override String get no => 'Не';
	@override String get add => 'Илова кардан';
	@override String get copy => 'Нусха';
	@override String get apply => 'Татбиқ';
	@override String get reset => 'Барқарор';
	@override String get done => 'Тайёр';
	@override String get all => 'Ҳама';
	@override String get som => 'сӯм';
	@override String get cm => 'см';
	@override String get mm => 'мм';
	@override String get pcs => 'дона';
	@override String get hoursShort => 'соат';
	@override String get minutesShort => 'дақ';
	@override List<String> get months => [
		'январ',
		'феврал',
		'март',
		'апрел',
		'май',
		'июн',
		'июл',
		'август',
		'сентябр',
		'октябр',
		'ноябр',
		'декабр',
	];
	@override List<String> get weekdays => [
		'Якшанбе',
		'Душанбе',
		'Сешанбе',
		'Чоршанбе',
		'Панҷшанбе',
		'Ҷумъа',
		'Шанбе',
	];
	@override String get today => 'Имрӯз';
	@override String get tomorrow => 'Пагоҳ';
	@override String get comingSoon => 'Ба зудӣ';
}

// Path: onboarding
class _TranslationsOnboardingTg extends TranslationsOnboardingUz {
	_TranslationsOnboardingTg._(TranslationsTg root) : this._root = root, super.internal(root);

	final TranslationsTg _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsOnboardingStep1Tg step1 = _TranslationsOnboardingStep1Tg._(_root);
	@override late final _TranslationsOnboardingStep2Tg step2 = _TranslationsOnboardingStep2Tg._(_root);
	@override late final _TranslationsOnboardingStep3Tg step3 = _TranslationsOnboardingStep3Tg._(_root);
}

// Path: auth
class _TranslationsAuthTg extends TranslationsAuthUz {
	_TranslationsAuthTg._(TranslationsTg root) : this._root = root, super.internal(root);

	final TranslationsTg _root; // ignore: unused_field

	// Translations
	@override String get tagline => 'ФАЗОИ КОРИИ УСТО';
	@override late final _TranslationsAuthCommonTg common = _TranslationsAuthCommonTg._(_root);
	@override late final _TranslationsAuthPhoneTg phone = _TranslationsAuthPhoneTg._(_root);
	@override late final _TranslationsAuthOtpTg otp = _TranslationsAuthOtpTg._(_root);
	@override late final _TranslationsAuthProfileTg profile = _TranslationsAuthProfileTg._(_root);
	@override late final _TranslationsAuthTelegramTg telegram = _TranslationsAuthTelegramTg._(_root);
}

// Path: country
class _TranslationsCountryTg extends TranslationsCountryUz {
	_TranslationsCountryTg._(TranslationsTg root) : this._root = root, super.internal(root);

	final TranslationsTg _root; // ignore: unused_field

	// Translations
	@override String get title => 'Кишварро интихоб кунед';
	@override String get subtitle => 'Забони барнома аз рӯи кишвар интихоб мешавад. Баъдтар аз профил тағйир дода метавонед.';
	@override String get continueBtn => 'Идома';
	@override String get changeTitle => 'Кишвар ва забон';
}

// Path: home
class _TranslationsHomeTg extends TranslationsHomeUz {
	_TranslationsHomeTg._(TranslationsTg root) : this._root = root, super.internal(root);

	final TranslationsTg _root; // ignore: unused_field

	// Translations
	@override String get main => 'Асосӣ';
	@override String get chatting => 'Чат';
	@override String get profile => 'Профил';
	@override String get title => 'Профил';
	@override String get loadError => 'Профил бор нашуд';
	@override String get retry => 'Такрор';
	@override String get phone => 'Телефон';
	@override String get role => 'Нақш';
	@override String get status => 'Ҳолат';
	@override String get active => 'Фаъол';
	@override String get inactive => 'Ғайрифаъол';
	@override String get logout => 'Баромадан';
	@override String get hi => 'Салом';
	@override String get serviceType => 'Навъҳои хидмат';
	@override String get lastOrders => 'Фармоишҳои охирин';
	@override String get all => 'Ҳама';
	@override String get tapRepair => 'Таъмири крон';
	@override String get chandelierInstallation => 'Насби қандил';
	@override String get completed => 'Иҷро шуд';
	@override String get inProgress => 'Дар ҷараён';
	@override String get window => 'Тиреза';
	@override String get furtiniture => 'Мебел';
	@override String get electric => 'Барқ';
	@override String get plumber => 'Сантехника';
}

// Path: calculatePage
class _TranslationsCalculatePageTg extends TranslationsCalculatePageUz {
	_TranslationsCalculatePageTg._(TranslationsTg root) : this._root = root, super.internal(root);

	final TranslationsTg _root; // ignore: unused_field

	// Translations
	@override String get window => 'Тиреза';
	@override String get door => 'Дар';
	@override String get glass => 'Тоқҳо';
	@override String get windowConfigurator => 'Танзими тиреза';
	@override String get windowLayouts => 'Навъҳои тақсимот';
	@override String get windowPremiumLayouts => 'Вариантҳои премиум';
	@override String get windowModernLayouts => 'Вариантҳои муосир';
	@override String get doorConfigurator => 'Танзими дар';
	@override String get doorModels => 'Моделҳои дар';
	@override String get doorExtraModels => 'Моделҳои иловагӣ';
	@override String get material => 'Мавод';
	@override String get plastic => 'Пластик';
	@override String get aluminium => 'Алюминий';
	@override String get termo => 'Термо';
	@override String get glassShowcase => 'Вариантҳои тоқ';
	@override String get customTemplateTitleWindow => 'Тирезаи худро созед';
	@override String get customTemplateTitleDoor => 'Дари худро созед';
	@override String get customTemplateTitleArch => 'Тоқи худро созед';
	@override String get customTemplateSubtitle => 'Шаблони тайёр не — андоза ва тақсимотро худатон мекашед';
	@override String get customTemplateAction => 'Оғоз';
	@override String get readyTemplates => 'Шаблонҳои тайёр';
}

// Path: profile
class _TranslationsProfileTg extends TranslationsProfileUz {
	_TranslationsProfileTg._(TranslationsTg root) : this._root = root, super.internal(root);

	final TranslationsTg _root; // ignore: unused_field

	// Translations
	@override String get personalData => 'Маълумоти шахсӣ';
	@override String get professional => 'Маълумоти касбӣ';
	@override String get company => 'Корхона';
	@override String get myOrders => 'Фармоишҳои ман';
	@override String get settings => 'Танзимот';
	@override String get support => 'Тамос бо мо';
	@override String get logout => 'Баромадан';
	@override String get logoutTitle => 'Аз ҳисоб мебароед?';
	@override String get logoutMessage => 'Нархҳои боршуда ва маълумоти ҳисоб аз дастгоҳ нест мешаванд. Ҳангоми бозгашт онҳо аз нав бор мешаванд.';
	@override String get logoutConfirm => 'Ҳа, мебароям';
	@override String get loggingOut => 'Баромада истодааст...';
	@override String get loggingOutHint => 'Сессия пӯшида, кеши нархҳо тоза мешавад';
	@override String get logoutFailed => 'Аз сервер баромадан муяссар нашуд, аммо маълумоти дастгоҳ тоза шуд';
	@override late final _TranslationsProfilePersonalTg personal = _TranslationsProfilePersonalTg._(_root);
	@override late final _TranslationsProfileHelpTg help = _TranslationsProfileHelpTg._(_root);
}

// Path: dashboard
class _TranslationsDashboardTg extends TranslationsDashboardUz {
	_TranslationsDashboardTg._(TranslationsTg root) : this._root = root, super.internal(root);

	final TranslationsTg _root; // ignore: unused_field

	// Translations
	@override String get title => 'Мизи корӣ';
	@override String get greetingMorning => 'Субҳ ба хайр,';
	@override String get greetingDay => 'Рӯз ба хайр,';
	@override String get greetingEvening => 'Шом ба хайр,';
	@override String get master => 'усто';
	@override String get availableTitle => 'Фармоиш қабул мекунам';
	@override String get availableOn => 'Дархостҳои нав меоянд';
	@override String get availableOff => 'Дархостҳо қатъ шуданд';
	@override String get newRequests => 'Дархостҳои нав';
	@override String get activeOrders => 'Фармоишҳои фаъол';
	@override String get all => 'Ҳама';
	@override String get quickCalculate => 'Нақшаи тиреза';
	@override String get quickCalculateHint => 'Нақшаи тиреза ва дар';
	@override String get quickPortfolio => 'Намунаи кор';
	@override String get quickPortfolioHint => 'Аз кори анҷомёфта илова кунед';
	@override String get emptyRequests => 'Дархости нав нест';
	@override String get emptyRequestsHint => 'Агар тугмаи қабул фаъол бошад, дархостҳо дар ин ҷо пайдо мешаванд.';
	@override String get quickCompany => 'Корхона';
	@override String get quickCompanyHint => 'Ном ва логотип';
	@override String get quickRates => 'Нархҳои хидмати ман';
	@override String get quickRatesHint => 'Меъёрҳои кор аз рӯи соҳа';
	@override String get quickOrdersHeroTitle => 'Фармоишҳои нав ва Бозор';
	@override String get quickOrdersHeroHint => 'Эълонҳои соҳаи худро бинед ва пешниҳод фиристед';
	@override String get quickOpenOrders => 'Фармоишҳои кушода';
	@override String get quickOpenOrdersHint => 'Эълонҳои бе устод — пешниҳод фиристед';
	@override String get calcStep1 => 'Чорчӯба интихоб кунед';
	@override String get calcStep2 => 'Танзим кунед';
	@override String get calcStep3 => 'Нақша тайёр';
	@override String get repairTitle => 'Фармоишҳои таъмирро қабул мекунам';
	@override String get repairOn => 'Дархостҳои таъмир ҳам меоянд';
	@override String get repairOff => 'Дархостҳои таъмир намеоянд';
	@override String get repairHint => 'Танзими дару тирезаҳои кӯҳна, фурнитура ё иваз кардани шиша';
}

// Path: orders
class _TranslationsOrdersTg extends TranslationsOrdersUz {
	_TranslationsOrdersTg._(TranslationsTg root) : this._root = root, super.internal(root);

	final TranslationsTg _root; // ignore: unused_field

	// Translations
	@override String get title => 'Фармоишҳо';
	@override String get segmentNew => 'Кушода';
	@override String get segmentActive => 'Дар ҷараён';
	@override String get segmentDone => 'Анҷомёфта';
	@override String stepOf({required Object step, required Object total}) => 'Марҳилаи ${step} аз ${total}';
	@override String lateDays({required Object days}) => '${days} рӯз дер шуд';
	@override String get dueToday => 'Мӯҳлат — имрӯз';
	@override String daysLeft({required Object days}) => '${days} рӯз мондааст';
	@override String get offerBtn => 'Пешниҳод кардан';
	@override String get retry => 'Такрор';
	@override String get loadFailed => 'Фармоишҳо бор нашуданд';
	@override String get emptyNewTitle => 'Фармоиши кушода нест';
	@override String get emptyNewMessage => 'Ҳамин ки дар минтақаи шумо эълони нав пайдо шавад, дар ин ҷо намоён мешавад.';
	@override String get emptyActiveTitle => 'Фармоиши фаъол нест';
	@override String get emptyActiveMessage => 'Вақте дархости навро қабул кунед, он дар ин ҷо пайдо мешавад.';
	@override String get emptyDoneTitle => 'Кори анҷомёфта нест';
	@override String get emptyDoneMessage => 'Пас аз супоридани фармоиши аввал он дар ин ҷо пайдо мешавад.';
	@override late final _TranslationsOrdersStageTg stage = _TranslationsOrdersStageTg._(_root);
	@override late final _TranslationsOrdersDetailTg detail = _TranslationsOrdersDetailTg._(_root);
	@override late final _TranslationsOrdersRequestTg request = _TranslationsOrdersRequestTg._(_root);
	@override late final _TranslationsOrdersSpecTg spec = _TranslationsOrdersSpecTg._(_root);
	@override String get invalidId => 'Рақами фармоиш нодуруст аст.';
	@override String get invalidRequestId => 'Рақами дархост нодуруст аст.';
	@override late final _TranslationsOrdersOpenTg open = _TranslationsOrdersOpenTg._(_root);
	@override String get personalTitle => 'Фармоишҳои ман';
}

// Path: ownOrders
class _TranslationsOwnOrdersTg extends TranslationsOwnOrdersUz {
	_TranslationsOwnOrdersTg._(TranslationsTg root) : this._root = root, super.internal(root);

	final TranslationsTg _root; // ignore: unused_field

	// Translations
	@override String get orderTitle => 'Фармоиш';
	@override String itemsCount({required Object count}) => '${count} тиреза';
	@override String get statusTitle => 'Ҳолати фармоиш';
	@override String get statusRow => 'Ҳолат';
	@override String get saving => 'Нигоҳ дошта мешавад…';
	@override String get tapToChange => 'Барои тағйир зер кунед';
	@override String get alreadyDone => 'Ин фармоиш аллакай анҷом ёфтааст.';
	@override String get cannotChange => 'Ҳолати ин фармоишро тағйир додан мумкин нест.';
	@override late final _TranslationsOwnOrdersStatusTg status = _TranslationsOwnOrdersStatusTg._(_root);
	@override late final _TranslationsOwnOrdersHintTg hint = _TranslationsOwnOrdersHintTg._(_root);
}

// Path: orderForm
class _TranslationsOrderFormTg extends TranslationsOrderFormUz {
	_TranslationsOrderFormTg._(TranslationsTg root) : this._root = root, super.internal(root);

	final TranslationsTg _root; // ignore: unused_field

	// Translations
	@override String get noProducts => 'Дар фармоиш маҳсулот нест.';
	@override String get queued => 'Интернет нест — фармоиш ба навбат гузошта шуд ва худаш фиристода мешавад.';
	@override String get saved => 'Фармоиш нигоҳ дошта шуд';
	@override String get saveTitle => 'Нигоҳ доштани фармоиш';
	@override String get customer => 'Фармоишдиҳанда';
	@override String get nameLabel => 'Ном';
	@override String get nameHint => 'Азиз';
	@override String get nameRequired => 'Номро нависед';
	@override String get addressHint => 'Чилонзор, маҳаллаи 9';
	@override String get noteLabel => 'Эзоҳи иловагӣ';
	@override String get noteHint => 'Ошёнаи 2, лифт нест';
	@override String itemsSummary({required Object kinds, required Object count}) => '${kinds} навъ тиреза · ${count} дона';
}

// Path: chat
class _TranslationsChatTg extends TranslationsChatUz {
	_TranslationsChatTg._(TranslationsTg root) : this._root = root, super.internal(root);

	final TranslationsTg _root; // ignore: unused_field

	// Translations
	@override String get threadsTitle => 'Гуфтугӯҳо';
	@override String get conversation => 'Гуфтугӯ';
	@override String get messageHint => 'Паём нависед...';
	@override String get emptyChat => 'Нарх ва шартро дар ин ҷо мувофиқа мекунед';
	@override String get emptyThreadsTitle => 'Ҳоло гуфтугӯ нест';
	@override String get emptyThreadsMessage => 'Вақте усто ба фармоишатон ҷавоб диҳад, дар ин ҷо менависед.';
}

// Path: notifications
class _TranslationsNotificationsTg extends TranslationsNotificationsUz {
	_TranslationsNotificationsTg._(TranslationsTg root) : this._root = root, super.internal(root);

	final TranslationsTg _root; // ignore: unused_field

	// Translations
	@override String get title => 'Огоҳиномаҳо';
	@override String get markAllRead => 'Ҳамаро хондашуда кардан';
	@override String get empty => 'Огоҳинома нест';
	@override String get open => 'Кушодан';
}

// Path: masters
class _TranslationsMastersTg extends TranslationsMastersUz {
	_TranslationsMastersTg._(TranslationsTg root) : this._root = root, super.internal(root);

	final TranslationsTg _root; // ignore: unused_field

	// Translations
	@override String get title => 'Дар бораи усто';
	@override String get master => 'Усто';
	@override String get client => 'Муштарӣ';
	@override String get write => 'Навиштан';
	@override String get chooseThis => 'Интихоби ин усто';
	@override String get choose => 'Интихоб';
	@override String get chosen => 'Устои интихобшуда';
	@override String get notFound => 'Маълумот ёфт нашуд';
	@override String get works => 'Корҳои иҷрошуда';
	@override String reviews({required Object count}) => 'Шарҳҳо (${count})';
	@override String get reviewsLabel => 'Шарҳҳо';
	@override String get noReviews => 'Ҳоло шарҳ нест — шумо метавонед аввалин бошед.';
	@override String experienceYears({required Object years}) => '${years} сол таҷриба';
	@override String get rating => 'Рейтинг';
	@override String get completed => 'Иҷрошуда';
	@override String responses({required Object count}) => '${count} ҷавоб';
	@override String get estimate => 'Ҳисоб';
}

// Path: orderFlow
class _TranslationsOrderFlowTg extends TranslationsOrderFlowUz {
	_TranslationsOrderFlowTg._(TranslationsTg root) : this._root = root, super.internal(root);

	final TranslationsTg _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsOrderFlowStatusTg status = _TranslationsOrderFlowStatusTg._(_root);
	@override late final _TranslationsOrderFlowStageTg stage = _TranslationsOrderFlowStageTg._(_root);
	@override late final _TranslationsOrderFlowResponseTg response = _TranslationsOrderFlowResponseTg._(_root);
}

// Path: company
class _TranslationsCompanyTg extends TranslationsCompanyUz {
	_TranslationsCompanyTg._(TranslationsTg root) : this._root = root, super.internal(root);

	final TranslationsTg _root; // ignore: unused_field

	// Translations
	@override String get title => 'Корхона';
	@override String get nameLabel => 'Номи корхона';
	@override String get nameHint => 'Масалан: Ustachi Servis';
	@override String get nameEmpty => 'Номи корхона ворид нашудааст';
	@override String get nameNote => 'Дар варақаи фармоиш намоён мешавад';
	@override String get logoHint => 'Илова кардани логотип';
}

// Path: companyRates
class _TranslationsCompanyRatesTg extends TranslationsCompanyRatesUz {
	_TranslationsCompanyRatesTg._(TranslationsTg root) : this._root = root, super.internal(root);

	final TranslationsTg _root; // ignore: unused_field

	// Translations
	@override String get onlyDigits => 'Танҳо рақам';
}

// Path: materials
class _TranslationsMaterialsTg extends TranslationsMaterialsUz {
	_TranslationsMaterialsTg._(TranslationsTg root) : this._root = root, super.internal(root);

	final TranslationsTg _root; // ignore: unused_field

	// Translations
	@override String get title => 'Маводҳо';
	@override String get on => 'Бо ин мавод кор мекунам — фармоишҳо меоянд';
	@override String get off => 'Хомӯш — фармоишҳои ин мавод намеоянд';
	@override String get allOff => 'Ақаллан як мавод бояд фаъол бошад';
}

// Path: professional
class _TranslationsProfessionalTg extends TranslationsProfessionalUz {
	_TranslationsProfessionalTg._(TranslationsTg root) : this._root = root, super.internal(root);

	final TranslationsTg _root; // ignore: unused_field

	// Translations
	@override String get title => 'Маълумоти касбӣ';
	@override String get headline => 'Бигӯед, ки чӣ гуна усто ҳастед';
	@override String get headlineHint => 'Муштарӣ пеш аз интихоб ин маълумотро мебинад. Баъдтар дар ҳар вақт тағйир дода метавонед.';
	@override String get specialty => 'Самтҳо';
	@override String get specialtyPick => 'Самтҳои худро интихоб кунед';
	@override String get specialtyLoadFailed => 'Рӯйхати ихтисосҳо бор нашуд — интернетро санҷед ва боз ворид шавед.';
	@override String get experienceQuestion => 'Чанд соли таҷриба доред?';
	@override String get experienceHint => 'Масалан: 5';
	@override String get experienceRequired => 'Таҷрибаро ворид кунед';
	@override String get experienceRange => 'Таҷриба бояд аз 0 то 70 бошад';
	@override String get aboutLabel => 'Дар бораи худ (ихтиёрӣ)';
	@override String get aboutHint => 'Кадом корҳоро иҷро мекунед, ба чӣ диққат медиҳед — мухтасар нависед.';
	@override String get works => 'Корҳои шумо';
	@override String get worksHint => 'Агар акс илова кунед, муштарӣ кори шуморо мебинад ва эҳтимоли интихоби шумо меафзояд. Ихтиёрӣ — баъдтар ҳам илова кардан мумкин.';
	@override String get deleteSampleTitle => 'Намунаро нест мекунед?';
	@override String get deleteSampleMessage => 'Муштариён ин аксро дигар намебинанд.';
	@override String get deleteFailed => 'Нест карда нашуд';
	@override String get pickSpecialty => 'Ҳадди ақал як самт интихоб кунед';
	@override String get specialtyHint => 'Метавонед якчандтоашро интихоб кунед — фармоиш танҳо аз рӯи ин самтҳо меояд.';
}

// Path: appUpdate
class _TranslationsAppUpdateTg extends TranslationsAppUpdateUz {
	_TranslationsAppUpdateTg._(TranslationsTg root) : this._root = root, super.internal(root);

	final TranslationsTg _root; // ignore: unused_field

	// Translations
	@override String get eyebrow => 'НАВСОЗӢ';
	@override String get titleOptional => 'Нусхаи нав тайёр аст';
	@override String get titleRequired => 'Навсозӣ талаб мешавад';
	@override String get bodyOptional => 'Нусхаи нави Ustachi Pro баромад. Барои ислоҳот ва имкониятҳои охирин навсозӣ кунед.';
	@override String get bodyRequired => 'Ин нусха дигар дастгирӣ намешавад. Барои идома додани кор барномаро навсозӣ кунед.';
	@override String get whatsNew => 'ЧӢ НАВ ШУД';
	@override String get versionFrom => 'Дар шумо';
	@override String get versionTo => 'Нав';
	@override String get update => 'Навсозӣ';
	@override String get later => 'Баъдтар';
	@override String get openFailed => 'Пайвандро кушода нашуд. Барномаро аз мағоза дастӣ навсозӣ кунед.';
}

// Path: onboarding.step1
class _TranslationsOnboardingStep1Tg extends TranslationsOnboardingStep1Uz {
	_TranslationsOnboardingStep1Tg._(TranslationsTg root) : this._root = root, super.internal(root);

	final TranslationsTg _root; // ignore: unused_field

	// Translations
	@override String get title => 'Самти худро интихоб кунед';
	@override String get description => 'Тиреза, бом, хишт, барқкор, сантехник, кошинкор, рангмолӣ… зиёда аз 25 самт. Фармоишҳо аз рӯи самти шумо меоянд.';
}

// Path: onboarding.step2
class _TranslationsOnboardingStep2Tg extends TranslationsOnboardingStep2Uz {
	_TranslationsOnboardingStep2Tg._(TranslationsTg root) : this._root = root, super.internal(root);

	final TranslationsTg _root; // ignore: unused_field

	// Translations
	@override String get title => 'Фармоиш худаш меёбад';
	@override String get description => 'Эълонҳои нав аз рӯи вилоят ва самти шумо фавран ҳамчун огоҳинома меоянд — ҷустуҷӯ лозим нест.';
}

// Path: onboarding.step3
class _TranslationsOnboardingStep3Tg extends TranslationsOnboardingStep3Uz {
	_TranslationsOnboardingStep3Tg._(TranslationsTg root) : this._root = root, super.internal(root);

	final TranslationsTg _root; // ignore: unused_field

	// Translations
	@override String get title => 'Нархро худатон муайян мекунед';
	@override String get description => 'Нархҳои худро ворид мекунед, бо мизоҷ дар чат мувофиқа мекунед ва марҳилаҳои корро қайд мекунед.';
}

// Path: auth.common
class _TranslationsAuthCommonTg extends TranslationsAuthCommonUz {
	_TranslationsAuthCommonTg._(TranslationsTg root) : this._root = root, super.internal(root);

	final TranslationsTg _root; // ignore: unused_field

	// Translations
	@override String get invalidPhone => 'Рақами телефонро дуруст ворид кунед';
	@override String get cancel => 'Бекор кардан';
}

// Path: auth.phone
class _TranslationsAuthPhoneTg extends TranslationsAuthPhoneUz {
	_TranslationsAuthPhoneTg._(TranslationsTg root) : this._root = root, super.internal(root);

	final TranslationsTg _root; // ignore: unused_field

	// Translations
	@override String get title => 'Ворид шудан ба барнома';
	@override String get subtitle => 'Рақамро ворид кунед — тавассути SMS рамзи 6-рақама мефиристем. Гузарвожа лозим нест.';
	@override String get label => 'Рақами телефон';
	@override String get continueBtn => 'Идома';
	@override String get orOption => 'ё';
	@override String get telegramBtn => 'Тавассути Telegram ворид шавед';
	@override String get telegramHint => 'Бот барои вуруд рақами марбут ба ҳисоби Telegram-и шуморо мепурсад. SMS фиристода намешавад.';
	@override String get telegramOpenError => 'Боти Telegram кушода нашуд. Аз нав кӯшиш кунед.';
	@override String get agreementPrefix => 'Бо идома додан шумо бо ';
	@override String get terms => 'Шартҳои истифода';
	@override String get and => ' ва ';
	@override String get privacy => 'Сиёсати махфият';
	@override String get agreementSuffix => ' розӣ мешавед.';
	@override String get audienceRedirect => 'Усто ҷустуҷӯ мекунед? «Ustachi»-ро боргирӣ кунед';
	@override String get audienceTitle => 'Диққат: барнома барои устоҳо';
}

// Path: auth.otp
class _TranslationsAuthOtpTg extends TranslationsAuthOtpUz {
	_TranslationsAuthOtpTg._(TranslationsTg root) : this._root = root, super.internal(root);

	final TranslationsTg _root; // ignore: unused_field

	// Translations
	@override String get title => 'Рамзро ворид кунед';
	@override String sentMessage({required Object phone}) => 'Рамзи 6-рақамаи ба ${phone} фиристодашударо ворид кунед';
	@override String get invalidCode => 'Ҳар 6 рақамро ворид кунед';
	@override String get resend => 'Такрор фиристодани рамз';
	@override String get resendIn => 'Такрор фиристодан';
	@override String get confirmBtn => 'Тасдиқ';
	@override String get changeNumber => 'Рақами дигар';
}

// Path: auth.profile
class _TranslationsAuthProfileTg extends TranslationsAuthProfileUz {
	_TranslationsAuthProfileTg._(TranslationsTg root) : this._root = root, super.internal(root);

	final TranslationsTg _root; // ignore: unused_field

	// Translations
	@override String get title => 'Дар бораи худ';
	@override String get subtitle => 'Муштариён шуморо бо ин ном мебинанд. Баъдтар аз профил тағйир дода метавонед.';
	@override String get fullNameLabel => 'Ном ва насаб';
	@override String get fullNameHint => 'Ворид кунед';
	@override String get requiredName => 'Ном ва насабатонро ворид кунед';
	@override String get addPhoto => 'Илова кардани акс';
	@override String get changePhoto => 'Иваз кардани акс';
	@override String get saveBtn => 'Нигоҳ дошта, идома';
	@override String get skip => 'Баъдтар пур мекунам';
	@override String get regionLabel => 'Вилоят';
	@override String get regionHint => 'Вилоятро интихоб кунед';
	@override String get districtLabel => 'Ноҳия / шаҳр';
	@override String get districtHint => 'Ноҳияро интихоб кунед';
	@override String get addressLabel => 'Суроға';
	@override String get addressHint => 'Кӯча, рақами хона';
	@override String get requiredRegion => 'Вилоятро интихоб кунед';
	@override String get requiredDistrict => 'Ноҳияро интихоб кунед';
	@override String get loadFailed => 'Рӯйхат бор нашуд';
}

// Path: auth.telegram
class _TranslationsAuthTelegramTg extends TranslationsAuthTelegramUz {
	_TranslationsAuthTelegramTg._(TranslationsTg root) : this._root = root, super.internal(root);

	final TranslationsTg _root; // ignore: unused_field

	// Translations
	@override String get loadingTitle => 'Вуруд тавассути Telegram';
	@override String get loadingHint => 'Пайванди якдафъина тафтиш мешавад…';
	@override String get invalidLink => 'Пайванди Telegram нодуруст аст.';
	@override String get expiredLink => 'Мӯҳлати пайванд гузаштааст ё қаблан истифода шудааст. Дар бот аз нав оғоз кунед.';
	@override String get retry => 'Аз нав кӯшиш кардан';
	@override String get restartBot => 'Дар бот аз нав сар кардан';
	@override String get smsOption => 'Тавассути SMS ворид шавед';
}

// Path: profile.personal
class _TranslationsProfilePersonalTg extends TranslationsProfilePersonalUz {
	_TranslationsProfilePersonalTg._(TranslationsTg root) : this._root = root, super.internal(root);

	final TranslationsTg _root; // ignore: unused_field

	// Translations
	@override String get sectionPersonal => 'Шахсӣ';
	@override String get sectionAddress => 'Суроға';
	@override String get sectionProfessional => 'Касбӣ';
	@override String get phoneLabel => 'Телефон';
	@override String get phoneNote => 'Рақам — шиносаи ҳисоб, тағйир намеёбад';
	@override String get joinedLabel => 'Сабти ном';
	@override String get empty => 'Ворид нашудааст';
	@override String get edit => 'Таҳрир';
	@override String get openProfessional => 'Ихтисос, таҷриба ва корҳо';
	@override String get loadFailed => 'Маълумотро бор кардан нашуд';
}

// Path: profile.help
class _TranslationsProfileHelpTg extends TranslationsProfileHelpUz {
	_TranslationsProfileHelpTg._(TranslationsTg root) : this._root = root, super.internal(root);

	final TranslationsTg _root; // ignore: unused_field

	// Translations
	@override String get subtitle => 'Савол ё мушкилӣ бошад — нависед ё занг занед';
	@override String get callLabel => 'Занг задан';
	@override String get emailLabel => 'Почтаи электронӣ';
	@override String get telegramLabel => 'Канали Telegram-и мо';
	@override String get telegramHint => 'Хабарҳо ва эълонҳо';
	@override String get workHours => 'Дшб–шнб, 9:00–19:00';
	@override String get copied => 'Нусха гирифта шуд';
}

// Path: orders.stage
class _TranslationsOrdersStageTg extends TranslationsOrdersStageUz {
	_TranslationsOrdersStageTg._(TranslationsTg root) : this._root = root, super.internal(root);

	final TranslationsTg _root; // ignore: unused_field

	// Translations
	@override String get accepted => 'Пешниҳод қабул шуд';
	@override String get measured => 'Ченкунӣ гирифта шуд';
	@override String get production => 'Истеҳсолот';
	@override String get installation => 'Насб';
	@override String get handover => 'Супоридан ва пардохт';
}

// Path: orders.detail
class _TranslationsOrdersDetailTg extends TranslationsOrdersDetailUz {
	_TranslationsOrdersDetailTg._(TranslationsTg root) : this._root = root, super.internal(root);

	final TranslationsTg _root; // ignore: unused_field

	// Translations
	@override String get stages => 'Марҳилаҳо';
	@override String get spec => 'Мушаххасот';
	@override String get client => 'Муштарӣ';
	@override String get total => 'Ҷамъ';
	@override String get prepaid => 'Пешпардохт';
	@override String get remaining => 'Боқимонда';
	@override String get dueDate => 'Мӯҳлати мувофиқашуда';
	@override String get finishOrder => 'Супоридан ва анҷом';
	@override String get completed => 'Фармоиш анҷом ёфт';
	@override String stageDone({required Object stage}) => '${stage} анҷом ёфт';
	@override String get notFound => 'Фармоиш ёфт нашуд';
	@override String get drawings => 'Нақшаҳо';
	@override String get drawingsHint => 'Бо ду ангушт калон кунед · андозаҳо бо мм';
	@override String get markMeasured => 'Андоза гирифта шуд';
	@override String get markProduction => 'Истеҳсолот оғоз ёфт';
	@override String get markInstallation => 'Ба насб баромадем';
	@override String get stageSaved => 'Қайд шуд — ба мизоҷ хабар рафт';
}

// Path: orders.request
class _TranslationsOrdersRequestTg extends TranslationsOrdersRequestUz {
	_TranslationsOrdersRequestTg._(TranslationsTg root) : this._root = root, super.internal(root);

	final TranslationsTg _root; // ignore: unused_field

	// Translations
	@override String get title => 'Дархост';
	@override String get clientSpec => 'Мушаххасоти аз ҷониби муштарӣ ҳисобшуда';
	@override String get priceOffer => 'Пешниҳоди нарх';
	@override String get serviceFee => 'Насб ва интиқол';
	@override String get yourOffer => 'Пешниҳоди шумо';
	@override String get workDays => 'Мӯҳлат — рӯзи корӣ';
	@override String get note => 'Эзоҳ (ихтиёрӣ)';
	@override String get notePlaceholder => 'Эзоҳи иловагӣ ба муштарӣ…';
	@override String get send => 'Фиристодани пешниҳод';
	@override String get decline => 'Рад кардан';
	@override String get declineTitle => 'Дархостро рад мекунед?';
	@override String get declineMessage => 'Ин дархост аз рӯйхат тамоман нест мешавад.';
	@override String expiresIn({required Object time}) => '${time} мондааст';
	@override String get expired => 'Мӯҳлат гузашт';
	@override String distance({required Object km}) => '${km} км';
	@override String get sent => 'Пешниҳод фиристода шуд';
	@override String get invalidFee => 'Ҳаққи кор манфӣ буда наметавонад';
	@override String get chatNote => 'Нарх ва шартро бо муштарӣ дар чат мувофиқа мекунед.';
	@override String get withdrawOffer => 'Пешниҳодро бозпас гирифтан';
	@override String get declineInviteTitle => 'Пешниҳодро рад мекунед?';
	@override String get declineInviteMessage => 'Муштарӣ фавран хабар мегирад ва устои дигарро интихоб мекунад.';
	@override String get clientPrice => 'Нархи фармоиш';
	@override String get priceInChat => 'Нарх дар чат мувофиқа мешавад';
}

// Path: orders.spec
class _TranslationsOrdersSpecTg extends TranslationsOrdersSpecUz {
	_TranslationsOrdersSpecTg._(TranslationsTg root) : this._root = root, super.internal(root);

	final TranslationsTg _root; // ignore: unused_field

	// Translations
	@override String get size => 'Андоза (мм)';
	@override String get shape => 'Шакл';
	@override String get brand => 'Бренд';
	@override String get color => 'Ранг';
	@override String get material => 'Мавод';
	@override String get glass => 'Шиша';
	@override String get sill => 'Тахтаи тиреза (см)';
	@override String get flower => 'Нақш';
	@override String get address => 'Суроға';
	@override String get product => 'Маҳсулот';
	@override String get phone => 'Телефон';
	@override String get discount => 'Тахфиф';
	@override String get note => 'Эзоҳ';
	@override String itemsValue({required Object kinds, required Object count}) => '${kinds} навъ · ${count} дона';
	@override late final _TranslationsOrdersSpecValuesTg values = _TranslationsOrdersSpecValuesTg._(_root);
	@override String get area => 'Масоҳат';
	@override String get unitPrice => 'Нархи 1 м²';
	@override String get variant => 'Дараҷа';
}

// Path: orders.open
class _TranslationsOrdersOpenTg extends TranslationsOrdersOpenUz {
	_TranslationsOrdersOpenTg._(TranslationsTg root) : this._root = root, super.internal(root);

	final TranslationsTg _root; // ignore: unused_field

	// Translations
	@override String get offerSent => 'Пешниҳод фиристода шуд';
	@override String get waitingClient => 'Дар интизори ҷавоби мизоҷ';
	@override String offersCount({required Object count}) => '${count} пешниҳод';
	@override String get beFirst => 'Аввалин бошед';
	@override String get newBadge => 'Нав';
	@override String get pageTitle => 'Фармоишҳои кушода';
	@override String get tabWaiting => 'Дар интизори ҷавоб';
	@override String get tabSent => 'Пешниҳод фиристода шуд';
	@override String get emptySentTitle => 'Пешниҳоди фиристодашуда нест';
	@override String get emptySentMessage => 'Эълонҳое, ки ҷавоб додаед, дар ин ҷо ҷавоби мизоҷро интизоранд.';
	@override String get tabInvited => 'Ба шумо пешниҳод';
	@override String get invitedBadge => 'Ба шумо пешниҳод';
	@override String get acceptInvite => 'Қабул мекунам';
	@override String get emptyInvitedTitle => 'Пешниҳоди шахсӣ нест';
	@override String get emptyInvitedMessage => 'Фармоишҳое, ки муштарӣ шуморо интихоб кардааст, дар ин ҷо мебароянд.';
	@override String get invitedNote => 'Муштарӣ ин фармоишро маҳз ба шумо фиристод — устоҳои дигар онро намебинанд.';
	@override String get repairBadge => 'Таъмир';
}

// Path: ownOrders.status
class _TranslationsOwnOrdersStatusTg extends TranslationsOwnOrdersStatusUz {
	_TranslationsOwnOrdersStatusTg._(TranslationsTg root) : this._root = root, super.internal(root);

	final TranslationsTg _root; // ignore: unused_field

	// Translations
	@override String get draft => 'Сиёҳнавис';
	@override String get newOrder => 'Нав';
	@override String get inProgress => 'Дар ҷараён';
	@override String get done => 'Анҷомёфта';
	@override String get debt => 'Қарздор';
	@override String get cancelled => 'Бекор шуда';
}

// Path: ownOrders.hint
class _TranslationsOwnOrdersHintTg extends TranslationsOwnOrdersHintUz {
	_TranslationsOwnOrdersHintTg._(TranslationsTg root) : this._root = root, super.internal(root);

	final TranslationsTg _root; // ignore: unused_field

	// Translations
	@override String get newOrder => 'Қабул шуд, ҳанӯз оғоз нашудааст';
	@override String get inProgress => 'Истеҳсол ё насб идома дорад';
	@override String get done => 'Супорида шуд ва пурра ҳисоб шуд';
	@override String get debt => 'Кор анҷом ёфт, аммо пардохт пурра нест';
	@override String get cancelled => 'Фармоиш бекор шуд';
}

// Path: orderFlow.status
class _TranslationsOrderFlowStatusTg extends TranslationsOrderFlowStatusUz {
	_TranslationsOrderFlowStatusTg._(TranslationsTg root) : this._root = root, super.internal(root);

	final TranslationsTg _root; // ignore: unused_field

	// Translations
	@override String get published => 'Нашршуда';
	@override String get assigned => 'Усто интихоб шуд';
	@override String get completed => 'Анҷомёфта';
	@override String get cancelled => 'Бекоршуда';
	@override String get expired => 'Мӯҳлат гузашта';
}

// Path: orderFlow.stage
class _TranslationsOrderFlowStageTg extends TranslationsOrderFlowStageUz {
	_TranslationsOrderFlowStageTg._(TranslationsTg root) : this._root = root, super.internal(root);

	final TranslationsTg _root; // ignore: unused_field

	// Translations
	@override String get accepted => 'Қабул шуд';
	@override String get measured => 'Ченкунӣ шуд';
	@override String get production => 'Истеҳсолот';
	@override String get installation => 'Насб';
	@override String get handover => 'Супорида шуд';
}

// Path: orderFlow.response
class _TranslationsOrderFlowResponseTg extends TranslationsOrderFlowResponseUz {
	_TranslationsOrderFlowResponseTg._(TranslationsTg root) : this._root = root, super.internal(root);

	final TranslationsTg _root; // ignore: unused_field

	// Translations
	@override String get interested => 'Қабул мекунам';
	@override String get withdrawn => 'Даст кашид';
	@override String get chosen => 'Интихоб шуд';
	@override String get rejected => 'Интихоб нашуд';
}

// Path: orders.spec.values
class _TranslationsOrdersSpecValuesTg extends TranslationsOrdersSpecValuesUz {
	_TranslationsOrdersSpecValuesTg._(TranslationsTg root) : this._root = root, super.internal(root);

	final TranslationsTg _root; // ignore: unused_field

	// Translations
	@override String get plastic => 'Пластик';
	@override String get aluminium => 'Алюминий';
	@override String get termo => 'Термо';
	@override String get doubleGlass => 'Дуқабата';
	@override String get singleGlass => 'Якқабата';
	@override String get large => 'Калон';
	@override String get medium => 'Миёна';
	@override String get small => 'Хурд';
}

/// The flat map containing all translations for locale <tg>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on TranslationsTg {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'applicationName' => 'Ustachi',
			'common.ok' => 'OK',
			'common.start' => 'Оғоз',
			'common.cancel' => 'Бекор кардан',
			'common.save' => 'Нигоҳ доштан',
			'common.delete' => 'Нест кардан',
			'common.edit' => 'Таҳрир',
			'common.close' => 'Пӯшидан',
			'common.back' => 'Ба қафо',
			'common.next' => 'Баъдӣ',
			'common.skip' => 'Гузарондан',
			'common.enter' => 'Ворид кунед',
			'common.wentWrong' => 'Хатогӣ рӯй дод. Лутфан баъдтар боз кӯшиш кунед!',
			'common.common' => 'Асосӣ',
			'common.select' => 'Интихоб',
			'common.retry' => 'Такрор',
			'common.refresh' => 'Навсозӣ',
			'common.saved' => 'Нигоҳ дошта шуд',
			'common.saveFailed' => 'Нигоҳ дошта нашуд — боз кӯшиш кунед',
			'common.notFound' => 'Ёфт нашуд',
			'common.empty' => 'Холӣ',
			'common.loading' => 'Боргирӣ…',
			'common.yes' => 'Ҳа',
			'common.no' => 'Не',
			'common.add' => 'Илова кардан',
			'common.copy' => 'Нусха',
			'common.apply' => 'Татбиқ',
			'common.reset' => 'Барқарор',
			'common.done' => 'Тайёр',
			'common.all' => 'Ҳама',
			'common.som' => 'сӯм',
			'common.cm' => 'см',
			'common.mm' => 'мм',
			'common.pcs' => 'дона',
			'common.hoursShort' => 'соат',
			'common.minutesShort' => 'дақ',
			'common.months.0' => 'январ',
			'common.months.1' => 'феврал',
			'common.months.2' => 'март',
			'common.months.3' => 'апрел',
			'common.months.4' => 'май',
			'common.months.5' => 'июн',
			'common.months.6' => 'июл',
			'common.months.7' => 'август',
			'common.months.8' => 'сентябр',
			'common.months.9' => 'октябр',
			'common.months.10' => 'ноябр',
			'common.months.11' => 'декабр',
			'common.weekdays.0' => 'Якшанбе',
			'common.weekdays.1' => 'Душанбе',
			'common.weekdays.2' => 'Сешанбе',
			'common.weekdays.3' => 'Чоршанбе',
			'common.weekdays.4' => 'Панҷшанбе',
			'common.weekdays.5' => 'Ҷумъа',
			'common.weekdays.6' => 'Шанбе',
			'common.today' => 'Имрӯз',
			'common.tomorrow' => 'Пагоҳ',
			'common.comingSoon' => 'Ба зудӣ',
			'onboarding.step1.title' => 'Самти худро интихоб кунед',
			'onboarding.step1.description' => 'Тиреза, бом, хишт, барқкор, сантехник, кошинкор, рангмолӣ… зиёда аз 25 самт. Фармоишҳо аз рӯи самти шумо меоянд.',
			'onboarding.step2.title' => 'Фармоиш худаш меёбад',
			'onboarding.step2.description' => 'Эълонҳои нав аз рӯи вилоят ва самти шумо фавран ҳамчун огоҳинома меоянд — ҷустуҷӯ лозим нест.',
			'onboarding.step3.title' => 'Нархро худатон муайян мекунед',
			'onboarding.step3.description' => 'Нархҳои худро ворид мекунед, бо мизоҷ дар чат мувофиқа мекунед ва марҳилаҳои корро қайд мекунед.',
			'auth.tagline' => 'ФАЗОИ КОРИИ УСТО',
			'auth.common.invalidPhone' => 'Рақами телефонро дуруст ворид кунед',
			'auth.common.cancel' => 'Бекор кардан',
			'auth.phone.title' => 'Ворид шудан ба барнома',
			'auth.phone.subtitle' => 'Рақамро ворид кунед — тавассути SMS рамзи 6-рақама мефиристем. Гузарвожа лозим нест.',
			'auth.phone.label' => 'Рақами телефон',
			'auth.phone.continueBtn' => 'Идома',
			'auth.phone.orOption' => 'ё',
			'auth.phone.telegramBtn' => 'Тавассути Telegram ворид шавед',
			'auth.phone.telegramHint' => 'Бот барои вуруд рақами марбут ба ҳисоби Telegram-и шуморо мепурсад. SMS фиристода намешавад.',
			'auth.phone.telegramOpenError' => 'Боти Telegram кушода нашуд. Аз нав кӯшиш кунед.',
			'auth.phone.agreementPrefix' => 'Бо идома додан шумо бо ',
			'auth.phone.terms' => 'Шартҳои истифода',
			'auth.phone.and' => ' ва ',
			'auth.phone.privacy' => 'Сиёсати махфият',
			'auth.phone.agreementSuffix' => ' розӣ мешавед.',
			'auth.phone.audienceRedirect' => 'Усто ҷустуҷӯ мекунед? «Ustachi»-ро боргирӣ кунед',
			'auth.phone.audienceTitle' => 'Диққат: барнома барои устоҳо',
			'auth.otp.title' => 'Рамзро ворид кунед',
			'auth.otp.sentMessage' => ({required Object phone}) => 'Рамзи 6-рақамаи ба ${phone} фиристодашударо ворид кунед',
			'auth.otp.invalidCode' => 'Ҳар 6 рақамро ворид кунед',
			'auth.otp.resend' => 'Такрор фиристодани рамз',
			'auth.otp.resendIn' => 'Такрор фиристодан',
			'auth.otp.confirmBtn' => 'Тасдиқ',
			'auth.otp.changeNumber' => 'Рақами дигар',
			'auth.profile.title' => 'Дар бораи худ',
			'auth.profile.subtitle' => 'Муштариён шуморо бо ин ном мебинанд. Баъдтар аз профил тағйир дода метавонед.',
			'auth.profile.fullNameLabel' => 'Ном ва насаб',
			'auth.profile.fullNameHint' => 'Ворид кунед',
			'auth.profile.requiredName' => 'Ном ва насабатонро ворид кунед',
			'auth.profile.addPhoto' => 'Илова кардани акс',
			'auth.profile.changePhoto' => 'Иваз кардани акс',
			'auth.profile.saveBtn' => 'Нигоҳ дошта, идома',
			'auth.profile.skip' => 'Баъдтар пур мекунам',
			'auth.profile.regionLabel' => 'Вилоят',
			'auth.profile.regionHint' => 'Вилоятро интихоб кунед',
			'auth.profile.districtLabel' => 'Ноҳия / шаҳр',
			'auth.profile.districtHint' => 'Ноҳияро интихоб кунед',
			'auth.profile.addressLabel' => 'Суроға',
			'auth.profile.addressHint' => 'Кӯча, рақами хона',
			'auth.profile.requiredRegion' => 'Вилоятро интихоб кунед',
			'auth.profile.requiredDistrict' => 'Ноҳияро интихоб кунед',
			'auth.profile.loadFailed' => 'Рӯйхат бор нашуд',
			'auth.telegram.loadingTitle' => 'Вуруд тавассути Telegram',
			'auth.telegram.loadingHint' => 'Пайванди якдафъина тафтиш мешавад…',
			'auth.telegram.invalidLink' => 'Пайванди Telegram нодуруст аст.',
			'auth.telegram.expiredLink' => 'Мӯҳлати пайванд гузаштааст ё қаблан истифода шудааст. Дар бот аз нав оғоз кунед.',
			'auth.telegram.retry' => 'Аз нав кӯшиш кардан',
			'auth.telegram.restartBot' => 'Дар бот аз нав сар кардан',
			'auth.telegram.smsOption' => 'Тавассути SMS ворид шавед',
			'country.title' => 'Кишварро интихоб кунед',
			'country.subtitle' => 'Забони барнома аз рӯи кишвар интихоб мешавад. Баъдтар аз профил тағйир дода метавонед.',
			'country.continueBtn' => 'Идома',
			'country.changeTitle' => 'Кишвар ва забон',
			'home.main' => 'Асосӣ',
			'home.chatting' => 'Чат',
			'home.profile' => 'Профил',
			'home.title' => 'Профил',
			'home.loadError' => 'Профил бор нашуд',
			'home.retry' => 'Такрор',
			'home.phone' => 'Телефон',
			'home.role' => 'Нақш',
			'home.status' => 'Ҳолат',
			'home.active' => 'Фаъол',
			'home.inactive' => 'Ғайрифаъол',
			'home.logout' => 'Баромадан',
			'home.hi' => 'Салом',
			'home.serviceType' => 'Навъҳои хидмат',
			'home.lastOrders' => 'Фармоишҳои охирин',
			'home.all' => 'Ҳама',
			'home.tapRepair' => 'Таъмири крон',
			'home.chandelierInstallation' => 'Насби қандил',
			'home.completed' => 'Иҷро шуд',
			'home.inProgress' => 'Дар ҷараён',
			'home.window' => 'Тиреза',
			'home.furtiniture' => 'Мебел',
			'home.electric' => 'Барқ',
			'home.plumber' => 'Сантехника',
			'calculatePage.window' => 'Тиреза',
			'calculatePage.door' => 'Дар',
			'calculatePage.glass' => 'Тоқҳо',
			'calculatePage.windowConfigurator' => 'Танзими тиреза',
			'calculatePage.windowLayouts' => 'Навъҳои тақсимот',
			'calculatePage.windowPremiumLayouts' => 'Вариантҳои премиум',
			'calculatePage.windowModernLayouts' => 'Вариантҳои муосир',
			'calculatePage.doorConfigurator' => 'Танзими дар',
			'calculatePage.doorModels' => 'Моделҳои дар',
			'calculatePage.doorExtraModels' => 'Моделҳои иловагӣ',
			'calculatePage.material' => 'Мавод',
			'calculatePage.plastic' => 'Пластик',
			'calculatePage.aluminium' => 'Алюминий',
			'calculatePage.termo' => 'Термо',
			'calculatePage.glassShowcase' => 'Вариантҳои тоқ',
			'calculatePage.customTemplateTitleWindow' => 'Тирезаи худро созед',
			'calculatePage.customTemplateTitleDoor' => 'Дари худро созед',
			'calculatePage.customTemplateTitleArch' => 'Тоқи худро созед',
			'calculatePage.customTemplateSubtitle' => 'Шаблони тайёр не — андоза ва тақсимотро худатон мекашед',
			'calculatePage.customTemplateAction' => 'Оғоз',
			'calculatePage.readyTemplates' => 'Шаблонҳои тайёр',
			'profile.personalData' => 'Маълумоти шахсӣ',
			'profile.professional' => 'Маълумоти касбӣ',
			'profile.company' => 'Корхона',
			'profile.myOrders' => 'Фармоишҳои ман',
			'profile.settings' => 'Танзимот',
			'profile.support' => 'Тамос бо мо',
			'profile.logout' => 'Баромадан',
			'profile.logoutTitle' => 'Аз ҳисоб мебароед?',
			'profile.logoutMessage' => 'Нархҳои боршуда ва маълумоти ҳисоб аз дастгоҳ нест мешаванд. Ҳангоми бозгашт онҳо аз нав бор мешаванд.',
			'profile.logoutConfirm' => 'Ҳа, мебароям',
			'profile.loggingOut' => 'Баромада истодааст...',
			'profile.loggingOutHint' => 'Сессия пӯшида, кеши нархҳо тоза мешавад',
			'profile.logoutFailed' => 'Аз сервер баромадан муяссар нашуд, аммо маълумоти дастгоҳ тоза шуд',
			'profile.personal.sectionPersonal' => 'Шахсӣ',
			'profile.personal.sectionAddress' => 'Суроға',
			'profile.personal.sectionProfessional' => 'Касбӣ',
			'profile.personal.phoneLabel' => 'Телефон',
			'profile.personal.phoneNote' => 'Рақам — шиносаи ҳисоб, тағйир намеёбад',
			'profile.personal.joinedLabel' => 'Сабти ном',
			'profile.personal.empty' => 'Ворид нашудааст',
			'profile.personal.edit' => 'Таҳрир',
			'profile.personal.openProfessional' => 'Ихтисос, таҷриба ва корҳо',
			'profile.personal.loadFailed' => 'Маълумотро бор кардан нашуд',
			'profile.help.subtitle' => 'Савол ё мушкилӣ бошад — нависед ё занг занед',
			'profile.help.callLabel' => 'Занг задан',
			'profile.help.emailLabel' => 'Почтаи электронӣ',
			'profile.help.telegramLabel' => 'Канали Telegram-и мо',
			'profile.help.telegramHint' => 'Хабарҳо ва эълонҳо',
			'profile.help.workHours' => 'Дшб–шнб, 9:00–19:00',
			'profile.help.copied' => 'Нусха гирифта шуд',
			'dashboard.title' => 'Мизи корӣ',
			'dashboard.greetingMorning' => 'Субҳ ба хайр,',
			'dashboard.greetingDay' => 'Рӯз ба хайр,',
			'dashboard.greetingEvening' => 'Шом ба хайр,',
			'dashboard.master' => 'усто',
			'dashboard.availableTitle' => 'Фармоиш қабул мекунам',
			'dashboard.availableOn' => 'Дархостҳои нав меоянд',
			'dashboard.availableOff' => 'Дархостҳо қатъ шуданд',
			'dashboard.newRequests' => 'Дархостҳои нав',
			'dashboard.activeOrders' => 'Фармоишҳои фаъол',
			'dashboard.all' => 'Ҳама',
			'dashboard.quickCalculate' => 'Нақшаи тиреза',
			'dashboard.quickCalculateHint' => 'Нақшаи тиреза ва дар',
			'dashboard.quickPortfolio' => 'Намунаи кор',
			'dashboard.quickPortfolioHint' => 'Аз кори анҷомёфта илова кунед',
			'dashboard.emptyRequests' => 'Дархости нав нест',
			'dashboard.emptyRequestsHint' => 'Агар тугмаи қабул фаъол бошад, дархостҳо дар ин ҷо пайдо мешаванд.',
			'dashboard.quickCompany' => 'Корхона',
			'dashboard.quickCompanyHint' => 'Ном ва логотип',
			'dashboard.quickRates' => 'Нархҳои хидмати ман',
			'dashboard.quickRatesHint' => 'Меъёрҳои кор аз рӯи соҳа',
			'dashboard.quickOrdersHeroTitle' => 'Фармоишҳои нав ва Бозор',
			'dashboard.quickOrdersHeroHint' => 'Эълонҳои соҳаи худро бинед ва пешниҳод фиристед',
			'dashboard.quickOpenOrders' => 'Фармоишҳои кушода',
			'dashboard.quickOpenOrdersHint' => 'Эълонҳои бе устод — пешниҳод фиристед',
			'dashboard.calcStep1' => 'Чорчӯба интихоб кунед',
			'dashboard.calcStep2' => 'Танзим кунед',
			'dashboard.calcStep3' => 'Нақша тайёр',
			'dashboard.repairTitle' => 'Фармоишҳои таъмирро қабул мекунам',
			'dashboard.repairOn' => 'Дархостҳои таъмир ҳам меоянд',
			'dashboard.repairOff' => 'Дархостҳои таъмир намеоянд',
			'dashboard.repairHint' => 'Танзими дару тирезаҳои кӯҳна, фурнитура ё иваз кардани шиша',
			'orders.title' => 'Фармоишҳо',
			'orders.segmentNew' => 'Кушода',
			'orders.segmentActive' => 'Дар ҷараён',
			'orders.segmentDone' => 'Анҷомёфта',
			'orders.stepOf' => ({required Object step, required Object total}) => 'Марҳилаи ${step} аз ${total}',
			'orders.lateDays' => ({required Object days}) => '${days} рӯз дер шуд',
			'orders.dueToday' => 'Мӯҳлат — имрӯз',
			'orders.daysLeft' => ({required Object days}) => '${days} рӯз мондааст',
			'orders.offerBtn' => 'Пешниҳод кардан',
			'orders.retry' => 'Такрор',
			'orders.loadFailed' => 'Фармоишҳо бор нашуданд',
			'orders.emptyNewTitle' => 'Фармоиши кушода нест',
			'orders.emptyNewMessage' => 'Ҳамин ки дар минтақаи шумо эълони нав пайдо шавад, дар ин ҷо намоён мешавад.',
			'orders.emptyActiveTitle' => 'Фармоиши фаъол нест',
			'orders.emptyActiveMessage' => 'Вақте дархости навро қабул кунед, он дар ин ҷо пайдо мешавад.',
			'orders.emptyDoneTitle' => 'Кори анҷомёфта нест',
			'orders.emptyDoneMessage' => 'Пас аз супоридани фармоиши аввал он дар ин ҷо пайдо мешавад.',
			'orders.stage.accepted' => 'Пешниҳод қабул шуд',
			'orders.stage.measured' => 'Ченкунӣ гирифта шуд',
			'orders.stage.production' => 'Истеҳсолот',
			'orders.stage.installation' => 'Насб',
			'orders.stage.handover' => 'Супоридан ва пардохт',
			'orders.detail.stages' => 'Марҳилаҳо',
			'orders.detail.spec' => 'Мушаххасот',
			'orders.detail.client' => 'Муштарӣ',
			'orders.detail.total' => 'Ҷамъ',
			'orders.detail.prepaid' => 'Пешпардохт',
			'orders.detail.remaining' => 'Боқимонда',
			'orders.detail.dueDate' => 'Мӯҳлати мувофиқашуда',
			'orders.detail.finishOrder' => 'Супоридан ва анҷом',
			'orders.detail.completed' => 'Фармоиш анҷом ёфт',
			'orders.detail.stageDone' => ({required Object stage}) => '${stage} анҷом ёфт',
			'orders.detail.notFound' => 'Фармоиш ёфт нашуд',
			'orders.detail.drawings' => 'Нақшаҳо',
			'orders.detail.drawingsHint' => 'Бо ду ангушт калон кунед · андозаҳо бо мм',
			'orders.detail.markMeasured' => 'Андоза гирифта шуд',
			'orders.detail.markProduction' => 'Истеҳсолот оғоз ёфт',
			'orders.detail.markInstallation' => 'Ба насб баромадем',
			'orders.detail.stageSaved' => 'Қайд шуд — ба мизоҷ хабар рафт',
			'orders.request.title' => 'Дархост',
			'orders.request.clientSpec' => 'Мушаххасоти аз ҷониби муштарӣ ҳисобшуда',
			'orders.request.priceOffer' => 'Пешниҳоди нарх',
			'orders.request.serviceFee' => 'Насб ва интиқол',
			'orders.request.yourOffer' => 'Пешниҳоди шумо',
			'orders.request.workDays' => 'Мӯҳлат — рӯзи корӣ',
			'orders.request.note' => 'Эзоҳ (ихтиёрӣ)',
			'orders.request.notePlaceholder' => 'Эзоҳи иловагӣ ба муштарӣ…',
			'orders.request.send' => 'Фиристодани пешниҳод',
			'orders.request.decline' => 'Рад кардан',
			'orders.request.declineTitle' => 'Дархостро рад мекунед?',
			'orders.request.declineMessage' => 'Ин дархост аз рӯйхат тамоман нест мешавад.',
			'orders.request.expiresIn' => ({required Object time}) => '${time} мондааст',
			'orders.request.expired' => 'Мӯҳлат гузашт',
			'orders.request.distance' => ({required Object km}) => '${km} км',
			'orders.request.sent' => 'Пешниҳод фиристода шуд',
			'orders.request.invalidFee' => 'Ҳаққи кор манфӣ буда наметавонад',
			'orders.request.chatNote' => 'Нарх ва шартро бо муштарӣ дар чат мувофиқа мекунед.',
			'orders.request.withdrawOffer' => 'Пешниҳодро бозпас гирифтан',
			'orders.request.declineInviteTitle' => 'Пешниҳодро рад мекунед?',
			'orders.request.declineInviteMessage' => 'Муштарӣ фавран хабар мегирад ва устои дигарро интихоб мекунад.',
			'orders.request.clientPrice' => 'Нархи фармоиш',
			'orders.request.priceInChat' => 'Нарх дар чат мувофиқа мешавад',
			'orders.spec.size' => 'Андоза (мм)',
			'orders.spec.shape' => 'Шакл',
			'orders.spec.brand' => 'Бренд',
			'orders.spec.color' => 'Ранг',
			'orders.spec.material' => 'Мавод',
			'orders.spec.glass' => 'Шиша',
			'orders.spec.sill' => 'Тахтаи тиреза (см)',
			'orders.spec.flower' => 'Нақш',
			'orders.spec.address' => 'Суроға',
			'orders.spec.product' => 'Маҳсулот',
			'orders.spec.phone' => 'Телефон',
			'orders.spec.discount' => 'Тахфиф',
			'orders.spec.note' => 'Эзоҳ',
			'orders.spec.itemsValue' => ({required Object kinds, required Object count}) => '${kinds} навъ · ${count} дона',
			'orders.spec.values.plastic' => 'Пластик',
			'orders.spec.values.aluminium' => 'Алюминий',
			'orders.spec.values.termo' => 'Термо',
			'orders.spec.values.doubleGlass' => 'Дуқабата',
			'orders.spec.values.singleGlass' => 'Якқабата',
			'orders.spec.values.large' => 'Калон',
			'orders.spec.values.medium' => 'Миёна',
			'orders.spec.values.small' => 'Хурд',
			'orders.spec.area' => 'Масоҳат',
			'orders.spec.unitPrice' => 'Нархи 1 м²',
			'orders.spec.variant' => 'Дараҷа',
			'orders.invalidId' => 'Рақами фармоиш нодуруст аст.',
			'orders.invalidRequestId' => 'Рақами дархост нодуруст аст.',
			'orders.open.offerSent' => 'Пешниҳод фиристода шуд',
			'orders.open.waitingClient' => 'Дар интизори ҷавоби мизоҷ',
			'orders.open.offersCount' => ({required Object count}) => '${count} пешниҳод',
			'orders.open.beFirst' => 'Аввалин бошед',
			'orders.open.newBadge' => 'Нав',
			'orders.open.pageTitle' => 'Фармоишҳои кушода',
			'orders.open.tabWaiting' => 'Дар интизори ҷавоб',
			'orders.open.tabSent' => 'Пешниҳод фиристода шуд',
			'orders.open.emptySentTitle' => 'Пешниҳоди фиристодашуда нест',
			'orders.open.emptySentMessage' => 'Эълонҳое, ки ҷавоб додаед, дар ин ҷо ҷавоби мизоҷро интизоранд.',
			'orders.open.tabInvited' => 'Ба шумо пешниҳод',
			'orders.open.invitedBadge' => 'Ба шумо пешниҳод',
			'orders.open.acceptInvite' => 'Қабул мекунам',
			'orders.open.emptyInvitedTitle' => 'Пешниҳоди шахсӣ нест',
			'orders.open.emptyInvitedMessage' => 'Фармоишҳое, ки муштарӣ шуморо интихоб кардааст, дар ин ҷо мебароянд.',
			'orders.open.invitedNote' => 'Муштарӣ ин фармоишро маҳз ба шумо фиристод — устоҳои дигар онро намебинанд.',
			'orders.open.repairBadge' => 'Таъмир',
			'orders.personalTitle' => 'Фармоишҳои ман',
			'ownOrders.orderTitle' => 'Фармоиш',
			'ownOrders.itemsCount' => ({required Object count}) => '${count} тиреза',
			'ownOrders.statusTitle' => 'Ҳолати фармоиш',
			'ownOrders.statusRow' => 'Ҳолат',
			'ownOrders.saving' => 'Нигоҳ дошта мешавад…',
			'ownOrders.tapToChange' => 'Барои тағйир зер кунед',
			'ownOrders.alreadyDone' => 'Ин фармоиш аллакай анҷом ёфтааст.',
			'ownOrders.cannotChange' => 'Ҳолати ин фармоишро тағйир додан мумкин нест.',
			'ownOrders.status.draft' => 'Сиёҳнавис',
			'ownOrders.status.newOrder' => 'Нав',
			'ownOrders.status.inProgress' => 'Дар ҷараён',
			'ownOrders.status.done' => 'Анҷомёфта',
			'ownOrders.status.debt' => 'Қарздор',
			'ownOrders.status.cancelled' => 'Бекор шуда',
			'ownOrders.hint.newOrder' => 'Қабул шуд, ҳанӯз оғоз нашудааст',
			'ownOrders.hint.inProgress' => 'Истеҳсол ё насб идома дорад',
			'ownOrders.hint.done' => 'Супорида шуд ва пурра ҳисоб шуд',
			'ownOrders.hint.debt' => 'Кор анҷом ёфт, аммо пардохт пурра нест',
			'ownOrders.hint.cancelled' => 'Фармоиш бекор шуд',
			'orderForm.noProducts' => 'Дар фармоиш маҳсулот нест.',
			'orderForm.queued' => 'Интернет нест — фармоиш ба навбат гузошта шуд ва худаш фиристода мешавад.',
			'orderForm.saved' => 'Фармоиш нигоҳ дошта шуд',
			'orderForm.saveTitle' => 'Нигоҳ доштани фармоиш',
			'orderForm.customer' => 'Фармоишдиҳанда',
			'orderForm.nameLabel' => 'Ном',
			'orderForm.nameHint' => 'Азиз',
			'orderForm.nameRequired' => 'Номро нависед',
			'orderForm.addressHint' => 'Чилонзор, маҳаллаи 9',
			'orderForm.noteLabel' => 'Эзоҳи иловагӣ',
			'orderForm.noteHint' => 'Ошёнаи 2, лифт нест',
			'orderForm.itemsSummary' => ({required Object kinds, required Object count}) => '${kinds} навъ тиреза · ${count} дона',
			'chat.threadsTitle' => 'Гуфтугӯҳо',
			'chat.conversation' => 'Гуфтугӯ',
			'chat.messageHint' => 'Паём нависед...',
			'chat.emptyChat' => 'Нарх ва шартро дар ин ҷо мувофиқа мекунед',
			'chat.emptyThreadsTitle' => 'Ҳоло гуфтугӯ нест',
			'chat.emptyThreadsMessage' => 'Вақте усто ба фармоишатон ҷавоб диҳад, дар ин ҷо менависед.',
			'notifications.title' => 'Огоҳиномаҳо',
			'notifications.markAllRead' => 'Ҳамаро хондашуда кардан',
			'notifications.empty' => 'Огоҳинома нест',
			'notifications.open' => 'Кушодан',
			'masters.title' => 'Дар бораи усто',
			'masters.master' => 'Усто',
			'masters.client' => 'Муштарӣ',
			'masters.write' => 'Навиштан',
			'masters.chooseThis' => 'Интихоби ин усто',
			'masters.choose' => 'Интихоб',
			'masters.chosen' => 'Устои интихобшуда',
			'masters.notFound' => 'Маълумот ёфт нашуд',
			'masters.works' => 'Корҳои иҷрошуда',
			'masters.reviews' => ({required Object count}) => 'Шарҳҳо (${count})',
			'masters.reviewsLabel' => 'Шарҳҳо',
			'masters.noReviews' => 'Ҳоло шарҳ нест — шумо метавонед аввалин бошед.',
			'masters.experienceYears' => ({required Object years}) => '${years} сол таҷриба',
			'masters.rating' => 'Рейтинг',
			'masters.completed' => 'Иҷрошуда',
			'masters.responses' => ({required Object count}) => '${count} ҷавоб',
			'masters.estimate' => 'Ҳисоб',
			'orderFlow.status.published' => 'Нашршуда',
			'orderFlow.status.assigned' => 'Усто интихоб шуд',
			'orderFlow.status.completed' => 'Анҷомёфта',
			'orderFlow.status.cancelled' => 'Бекоршуда',
			'orderFlow.status.expired' => 'Мӯҳлат гузашта',
			'orderFlow.stage.accepted' => 'Қабул шуд',
			'orderFlow.stage.measured' => 'Ченкунӣ шуд',
			'orderFlow.stage.production' => 'Истеҳсолот',
			'orderFlow.stage.installation' => 'Насб',
			'orderFlow.stage.handover' => 'Супорида шуд',
			'orderFlow.response.interested' => 'Қабул мекунам',
			'orderFlow.response.withdrawn' => 'Даст кашид',
			'orderFlow.response.chosen' => 'Интихоб шуд',
			'orderFlow.response.rejected' => 'Интихоб нашуд',
			'company.title' => 'Корхона',
			'company.nameLabel' => 'Номи корхона',
			'company.nameHint' => 'Масалан: Ustachi Servis',
			'company.nameEmpty' => 'Номи корхона ворид нашудааст',
			'company.nameNote' => 'Дар варақаи фармоиш намоён мешавад',
			'company.logoHint' => 'Илова кардани логотип',
			'companyRates.onlyDigits' => 'Танҳо рақам',
			'materials.title' => 'Маводҳо',
			'materials.on' => 'Бо ин мавод кор мекунам — фармоишҳо меоянд',
			'materials.off' => 'Хомӯш — фармоишҳои ин мавод намеоянд',
			'materials.allOff' => 'Ақаллан як мавод бояд фаъол бошад',
			'professional.title' => 'Маълумоти касбӣ',
			'professional.headline' => 'Бигӯед, ки чӣ гуна усто ҳастед',
			'professional.headlineHint' => 'Муштарӣ пеш аз интихоб ин маълумотро мебинад. Баъдтар дар ҳар вақт тағйир дода метавонед.',
			'professional.specialty' => 'Самтҳо',
			'professional.specialtyPick' => 'Самтҳои худро интихоб кунед',
			'professional.specialtyLoadFailed' => 'Рӯйхати ихтисосҳо бор нашуд — интернетро санҷед ва боз ворид шавед.',
			'professional.experienceQuestion' => 'Чанд соли таҷриба доред?',
			'professional.experienceHint' => 'Масалан: 5',
			'professional.experienceRequired' => 'Таҷрибаро ворид кунед',
			'professional.experienceRange' => 'Таҷриба бояд аз 0 то 70 бошад',
			'professional.aboutLabel' => 'Дар бораи худ (ихтиёрӣ)',
			'professional.aboutHint' => 'Кадом корҳоро иҷро мекунед, ба чӣ диққат медиҳед — мухтасар нависед.',
			'professional.works' => 'Корҳои шумо',
			'professional.worksHint' => 'Агар акс илова кунед, муштарӣ кори шуморо мебинад ва эҳтимоли интихоби шумо меафзояд. Ихтиёрӣ — баъдтар ҳам илова кардан мумкин.',
			'professional.deleteSampleTitle' => 'Намунаро нест мекунед?',
			'professional.deleteSampleMessage' => 'Муштариён ин аксро дигар намебинанд.',
			'professional.deleteFailed' => 'Нест карда нашуд',
			'professional.pickSpecialty' => 'Ҳадди ақал як самт интихоб кунед',
			'professional.specialtyHint' => 'Метавонед якчандтоашро интихоб кунед — фармоиш танҳо аз рӯи ин самтҳо меояд.',
			'appUpdate.eyebrow' => 'НАВСОЗӢ',
			'appUpdate.titleOptional' => 'Нусхаи нав тайёр аст',
			'appUpdate.titleRequired' => 'Навсозӣ талаб мешавад',
			'appUpdate.bodyOptional' => 'Нусхаи нави Ustachi Pro баромад. Барои ислоҳот ва имкониятҳои охирин навсозӣ кунед.',
			'appUpdate.bodyRequired' => 'Ин нусха дигар дастгирӣ намешавад. Барои идома додани кор барномаро навсозӣ кунед.',
			'appUpdate.whatsNew' => 'ЧӢ НАВ ШУД',
			'appUpdate.versionFrom' => 'Дар шумо',
			'appUpdate.versionTo' => 'Нав',
			'appUpdate.update' => 'Навсозӣ',
			'appUpdate.later' => 'Баъдтар',
			'appUpdate.openFailed' => 'Пайвандро кушода нашуд. Барномаро аз мағоза дастӣ навсозӣ кунед.',
			_ => null,
		};
	}
}
