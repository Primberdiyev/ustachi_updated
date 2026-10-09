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
class TranslationsTk extends Translations with BaseTranslations<AppLocale, Translations> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	TranslationsTk({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.tk,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		super.$meta.setFlatMapFunction($meta.getTranslation); // copy base translations to super.$meta
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <tk>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	@override dynamic operator[](String key) => $meta.getTranslation(key) ?? super.$meta.getTranslation(key);

	late final TranslationsTk _root = this; // ignore: unused_field

	@override 
	TranslationsTk $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => TranslationsTk(meta: meta ?? this.$meta);

	// Translations
	@override String get applicationName => 'Ustachi';
	@override late final _TranslationsCommonTk common = _TranslationsCommonTk._(_root);
	@override late final _TranslationsOnboardingTk onboarding = _TranslationsOnboardingTk._(_root);
	@override late final _TranslationsAuthTk auth = _TranslationsAuthTk._(_root);
	@override late final _TranslationsCountryTk country = _TranslationsCountryTk._(_root);
	@override late final _TranslationsHomeTk home = _TranslationsHomeTk._(_root);
	@override late final _TranslationsCalculatePageTk calculatePage = _TranslationsCalculatePageTk._(_root);
	@override late final _TranslationsProfileTk profile = _TranslationsProfileTk._(_root);
	@override late final _TranslationsDashboardTk dashboard = _TranslationsDashboardTk._(_root);
	@override late final _TranslationsOrdersTk orders = _TranslationsOrdersTk._(_root);
	@override late final _TranslationsOwnOrdersTk ownOrders = _TranslationsOwnOrdersTk._(_root);
	@override late final _TranslationsOrderFormTk orderForm = _TranslationsOrderFormTk._(_root);
	@override late final _TranslationsChatTk chat = _TranslationsChatTk._(_root);
	@override late final _TranslationsNotificationsTk notifications = _TranslationsNotificationsTk._(_root);
	@override late final _TranslationsMastersTk masters = _TranslationsMastersTk._(_root);
	@override late final _TranslationsOrderFlowTk orderFlow = _TranslationsOrderFlowTk._(_root);
	@override late final _TranslationsCompanyTk company = _TranslationsCompanyTk._(_root);
	@override late final _TranslationsCompanyRatesTk companyRates = _TranslationsCompanyRatesTk._(_root);
	@override late final _TranslationsMaterialsTk materials = _TranslationsMaterialsTk._(_root);
	@override late final _TranslationsProfessionalTk professional = _TranslationsProfessionalTk._(_root);
	@override late final _TranslationsAppUpdateTk appUpdate = _TranslationsAppUpdateTk._(_root);
}

// Path: common
class _TranslationsCommonTk extends TranslationsCommonUz {
	_TranslationsCommonTk._(TranslationsTk root) : this._root = root, super.internal(root);

	final TranslationsTk _root; // ignore: unused_field

	// Translations
	@override String get ok => 'Bolýar';
	@override String get start => 'Başla';
	@override String get cancel => 'Ýatyr';
	@override String get save => 'Ýatda sakla';
	@override String get delete => 'Poz';
	@override String get edit => 'Üýtget';
	@override String get close => 'Ýap';
	@override String get back => 'Yza';
	@override String get next => 'Indiki';
	@override String get skip => 'Geç';
	@override String get enter => 'Giriziň';
	@override String get wentWrong => 'Ýalňyşlyk ýüze çykdy. Biraz soň gaýtadan synanyşyň!';
	@override String get common => 'Esasy';
	@override String get select => 'Saýla';
	@override String get retry => 'Gaýtadan synanyş';
	@override String get refresh => 'Täzele';
	@override String get saved => 'Ýatda saklandy';
	@override String get saveFailed => 'Ýatda saklanmady — gaýtadan synanyşyň';
	@override String get notFound => 'Tapylmady';
	@override String get empty => 'Boş';
	@override String get loading => 'Ýüklenýär…';
	@override String get yes => 'Hawa';
	@override String get no => 'Ýok';
	@override String get add => 'Goş';
	@override String get copy => 'Nusgala';
	@override String get apply => 'Ulan';
	@override String get reset => 'Dikelt';
	@override String get done => 'Taýýar';
	@override String get all => 'Ählisi';
	@override String get som => 'som';
	@override String get cm => 'sm';
	@override String get mm => 'mm';
	@override String get pcs => 'sany';
	@override String get hoursShort => 'sag';
	@override String get minutesShort => 'min';
	@override List<String> get months => [
		'ýanwar',
		'fewral',
		'mart',
		'aprel',
		'maý',
		'iýun',
		'iýul',
		'awgust',
		'sentýabr',
		'oktýabr',
		'noýabr',
		'dekabr',
	];
	@override List<String> get weekdays => [
		'Ýekşenbe',
		'Duşenbe',
		'Sişenbe',
		'Çarşenbe',
		'Penşenbe',
		'Anna',
		'Şenbe',
	];
	@override String get today => 'Şu gün';
	@override String get tomorrow => 'Ertir';
	@override String get comingSoon => 'Basym';
}

// Path: onboarding
class _TranslationsOnboardingTk extends TranslationsOnboardingUz {
	_TranslationsOnboardingTk._(TranslationsTk root) : this._root = root, super.internal(root);

	final TranslationsTk _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsOnboardingStep1Tk step1 = _TranslationsOnboardingStep1Tk._(_root);
	@override late final _TranslationsOnboardingStep2Tk step2 = _TranslationsOnboardingStep2Tk._(_root);
	@override late final _TranslationsOnboardingStep3Tk step3 = _TranslationsOnboardingStep3Tk._(_root);
}

// Path: auth
class _TranslationsAuthTk extends TranslationsAuthUz {
	_TranslationsAuthTk._(TranslationsTk root) : this._root = root, super.internal(root);

	final TranslationsTk _root; // ignore: unused_field

	// Translations
	@override String get tagline => 'USSANYŇ IŞ GIŇIŞLIGI';
	@override late final _TranslationsAuthCommonTk common = _TranslationsAuthCommonTk._(_root);
	@override late final _TranslationsAuthPhoneTk phone = _TranslationsAuthPhoneTk._(_root);
	@override late final _TranslationsAuthOtpTk otp = _TranslationsAuthOtpTk._(_root);
	@override late final _TranslationsAuthProfileTk profile = _TranslationsAuthProfileTk._(_root);
	@override late final _TranslationsAuthTelegramTk telegram = _TranslationsAuthTelegramTk._(_root);
}

// Path: country
class _TranslationsCountryTk extends TranslationsCountryUz {
	_TranslationsCountryTk._(TranslationsTk root) : this._root = root, super.internal(root);

	final TranslationsTk _root; // ignore: unused_field

	// Translations
	@override String get title => 'Ýurdy saýlaň';
	@override String get subtitle => 'Programmanyň dili ýurda görä saýlanýar. Soňra profiliňizden üýtgedip bilersiňiz.';
	@override String get continueBtn => 'Dowam et';
	@override String get changeTitle => 'Ýurt we dil';
}

// Path: home
class _TranslationsHomeTk extends TranslationsHomeUz {
	_TranslationsHomeTk._(TranslationsTk root) : this._root = root, super.internal(root);

	final TranslationsTk _root; // ignore: unused_field

	// Translations
	@override String get main => 'Esasy';
	@override String get chatting => 'Çat';
	@override String get profile => 'Profil';
	@override String get title => 'Profil';
	@override String get loadError => 'Profil ýüklenmedi';
	@override String get retry => 'Gaýtadan synanyş';
	@override String get phone => 'Telefon';
	@override String get role => 'Rol';
	@override String get status => 'Ýagdaý';
	@override String get active => 'Işjeň';
	@override String get inactive => 'Işjeň däl';
	@override String get logout => 'Çyk';
	@override String get hi => 'Salam';
	@override String get serviceType => 'Hyzmat görnüşleri';
	@override String get lastOrders => 'Soňky sargytlar';
	@override String get all => 'Ählisi';
	@override String get tapRepair => 'Kran abatlaýyş';
	@override String get chandelierInstallation => 'Lýustra oturtmak';
	@override String get completed => 'Ýerine ýetirildi';
	@override String get inProgress => 'Dowam edýär';
	@override String get window => 'Penjire';
	@override String get furtiniture => 'Mebel';
	@override String get electric => 'Elektrik';
	@override String get plumber => 'Santehnika';
}

// Path: calculatePage
class _TranslationsCalculatePageTk extends TranslationsCalculatePageUz {
	_TranslationsCalculatePageTk._(TranslationsTk root) : this._root = root, super.internal(root);

	final TranslationsTk _root; // ignore: unused_field

	// Translations
	@override String get window => 'Penjire';
	@override String get door => 'Gapy';
	@override String get glass => 'Arkalar';
	@override String get windowConfigurator => 'Penjire konfigurasiýasy';
	@override String get windowLayouts => 'Bölüm görnüşleri';
	@override String get windowPremiumLayouts => 'Premium warýantlar';
	@override String get windowModernLayouts => 'Döwrebap warýantlar';
	@override String get doorConfigurator => 'Gapy konfigurasiýasy';
	@override String get doorModels => 'Gapy modelleri';
	@override String get doorExtraModels => 'Goşmaça modeller';
	@override String get material => 'Material';
	@override String get plastic => 'Plastik';
	@override String get aluminium => 'Alýuminiý';
	@override String get termo => 'Termo';
	@override String get glassShowcase => 'Arka warýantlary';
	@override String get customTemplateTitleWindow => 'Öz penjiräňizi dörediň';
	@override String get customTemplateTitleDoor => 'Öz gapyňyzy dörediň';
	@override String get customTemplateTitleArch => 'Öz arkaňyzy dörediň';
	@override String get customTemplateSubtitle => 'Taýýar şablon däl — ölçegi we bölünişi özüňiz çyzýarsyňyz';
	@override String get customTemplateAction => 'Başla';
	@override String get readyTemplates => 'Taýýar şablonlar';
}

// Path: profile
class _TranslationsProfileTk extends TranslationsProfileUz {
	_TranslationsProfileTk._(TranslationsTk root) : this._root = root, super.internal(root);

	final TranslationsTk _root; // ignore: unused_field

	// Translations
	@override String get personalData => 'Şahsy maglumatlar';
	@override String get professional => 'Hünär maglumaty';
	@override String get company => 'Kärhana';
	@override String get myOrders => 'Sargytlarym';
	@override String get settings => 'Sazlamalar';
	@override String get support => 'Biz bilen habarlaşyň';
	@override String get logout => 'Çyk';
	@override String get logoutTitle => 'Hasapdan çykylsynmy?';
	@override String get logoutMessage => 'Ýüklenen bahalar we hasaplama maglumatlary enjamdan pozular. Gaýtadan gireniňizde olar täzeden ýüklener.';
	@override String get logoutConfirm => 'Hawa, çykaryn';
	@override String get loggingOut => 'Çykylýar...';
	@override String get loggingOutHint => 'Sessiýa ýapylyp, baha keşi arassalanýar';
	@override String get logoutFailed => 'Serwerden çykyp bolmady, ýöne enjamdaky maglumatlar arassalandy';
	@override late final _TranslationsProfilePersonalTk personal = _TranslationsProfilePersonalTk._(_root);
	@override late final _TranslationsProfileHelpTk help = _TranslationsProfileHelpTk._(_root);
}

// Path: dashboard
class _TranslationsDashboardTk extends TranslationsDashboardUz {
	_TranslationsDashboardTk._(TranslationsTk root) : this._root = root, super.internal(root);

	final TranslationsTk _root; // ignore: unused_field

	// Translations
	@override String get title => 'Iş stoly';
	@override String get greetingMorning => 'Ertiriňiz haýyrly,';
	@override String get greetingDay => 'Gowy gün,';
	@override String get greetingEvening => 'Agşamyňyz haýyrly,';
	@override String get master => 'ussa';
	@override String get availableTitle => 'Sargyt kabul edýärin';
	@override String get availableOn => 'Täze haýyşlar gelip durar';
	@override String get availableOff => 'Haýyşlar togtadyldy';
	@override String get newRequests => 'Täze haýyşlar';
	@override String get activeOrders => 'Işjeň sargytlar';
	@override String get all => 'Ählisi';
	@override String get quickCalculate => 'Penjire çyzgysy';
	@override String get quickCalculateHint => 'Penjire we gapy çyzgysy';
	@override String get quickPortfolio => 'Iş nusgasy';
	@override String get quickPortfolioHint => 'Tamamlanan işden goşuň';
	@override String get emptyRequests => 'Täze haýyş ýok';
	@override String get emptyRequestsHint => 'Elýeterlilik açary açyk bolsa, haýyşlar şu ýere düşer.';
	@override String get quickCompany => 'Kärhana';
	@override String get quickCompanyHint => 'At we logotip';
	@override String get quickRates => 'Hyzmat bahalarym';
	@override String get quickRatesHint => 'Ugruňyz boýunça iş nyrhlary';
	@override String get quickOrdersHeroTitle => 'Täze sargytlar we Bazar';
	@override String get quickOrdersHeroHint => 'Ugruňyzdaky bildirişleri görüň we teklip iberiň';
	@override String get quickOpenOrders => 'Açyk sargytlar';
	@override String get quickOpenOrdersHint => 'Ussa saýlanmadyk bildirişler — teklip iberiň';
	@override String get calcStep1 => 'Çarçuwa saýlaň';
	@override String get calcStep2 => 'Sazlaň';
	@override String get calcStep3 => 'Çyzgy taýýar';
	@override String get repairTitle => 'Bejeriş işlerini kabul edýärin';
	@override String get repairOn => 'Bejeriş islegleri hem geler';
	@override String get repairOff => 'Bejeriş islegleri gelmez';
	@override String get repairHint => 'Köne penjire-gapylary sazlamak, esbaplary ýa-da aýnany çalyşmak';
}

// Path: orders
class _TranslationsOrdersTk extends TranslationsOrdersUz {
	_TranslationsOrdersTk._(TranslationsTk root) : this._root = root, super.internal(root);

	final TranslationsTk _root; // ignore: unused_field

	// Translations
	@override String get title => 'Sargytlar';
	@override String get segmentNew => 'Açyk';
	@override String get segmentActive => 'Dowam edýän';
	@override String get segmentDone => 'Tamamlanan';
	@override String stepOf({required Object total, required Object step}) => '${total} tapgyrdan ${step}.';
	@override String lateDays({required Object days}) => '${days} gün gijikdi';
	@override String get dueToday => 'Möhleti — şu gün';
	@override String daysLeft({required Object days}) => '${days} gün galdy';
	@override String get offerBtn => 'Teklip ber';
	@override String get retry => 'Gaýtadan synanyş';
	@override String get loadFailed => 'Sargytlar ýüklenip bilmedi';
	@override String get emptyNewTitle => 'Açyk sargyt ýok';
	@override String get emptyNewMessage => 'Sebitiňizde täze bildiriş peýda bolan badyna şu ýerde görner.';
	@override String get emptyActiveTitle => 'Işjeň sargyt ýok';
	@override String get emptyActiveMessage => 'Täze haýyşy kabul edeniňizde ol şu ýerde peýda bolar.';
	@override String get emptyDoneTitle => 'Tamamlanan iş ýok';
	@override String get emptyDoneMessage => 'Ilkinji sargydy tabşyranyňyzdan soň ol şu ýerde görüner.';
	@override late final _TranslationsOrdersStageTk stage = _TranslationsOrdersStageTk._(_root);
	@override late final _TranslationsOrdersDetailTk detail = _TranslationsOrdersDetailTk._(_root);
	@override late final _TranslationsOrdersRequestTk request = _TranslationsOrdersRequestTk._(_root);
	@override late final _TranslationsOrdersSpecTk spec = _TranslationsOrdersSpecTk._(_root);
	@override String get invalidId => 'Sargyt belgisi nädogry.';
	@override String get invalidRequestId => 'Haýyş belgisi nädogry.';
	@override late final _TranslationsOrdersOpenTk open = _TranslationsOrdersOpenTk._(_root);
	@override String get personalTitle => 'Meniň sargytlarym';
}

// Path: ownOrders
class _TranslationsOwnOrdersTk extends TranslationsOwnOrdersUz {
	_TranslationsOwnOrdersTk._(TranslationsTk root) : this._root = root, super.internal(root);

	final TranslationsTk _root; // ignore: unused_field

	// Translations
	@override String get orderTitle => 'Sargyt';
	@override String itemsCount({required Object count}) => '${count} penjire';
	@override String get statusTitle => 'Sargyt ýagdaýy';
	@override String get statusRow => 'Ýagdaý';
	@override String get saving => 'Ýatda saklanýar…';
	@override String get tapToChange => 'Üýtgetmek üçin basyň';
	@override String get alreadyDone => 'Bu sargyt eýýäm tamamlandy.';
	@override String get cannotChange => 'Bu sargydyň ýagdaýyny üýtgetmek bolmaýar.';
	@override late final _TranslationsOwnOrdersStatusTk status = _TranslationsOwnOrdersStatusTk._(_root);
	@override late final _TranslationsOwnOrdersHintTk hint = _TranslationsOwnOrdersHintTk._(_root);
}

// Path: orderForm
class _TranslationsOrderFormTk extends TranslationsOrderFormUz {
	_TranslationsOrderFormTk._(TranslationsTk root) : this._root = root, super.internal(root);

	final TranslationsTk _root; // ignore: unused_field

	// Translations
	@override String get noProducts => 'Sargytda haryt ýok.';
	@override String get queued => 'Internet ýok — sargyt nobata goýuldy, özi iberiler.';
	@override String get saved => 'Sargyt ýatda saklandy';
	@override String get saveTitle => 'Sargydy ýatda sakla';
	@override String get customer => 'Sargyt beriji';
	@override String get nameLabel => 'Ady';
	@override String get nameHint => 'Aziz';
	@override String get nameRequired => 'Ady ýazyň';
	@override String get addressHint => 'Çilanzar 9-nji kwartal';
	@override String get noteLabel => 'Goşmaça bellik';
	@override String get noteHint => '2-nji gat, lift ýok';
	@override String itemsSummary({required Object kinds, required Object count}) => '${kinds} görnüş penjire · ${count} sany';
}

// Path: chat
class _TranslationsChatTk extends TranslationsChatUz {
	_TranslationsChatTk._(TranslationsTk root) : this._root = root, super.internal(root);

	final TranslationsTk _root; // ignore: unused_field

	// Translations
	@override String get threadsTitle => 'Söhbetler';
	@override String get conversation => 'Söhbet';
	@override String get messageHint => 'Habar ýazyň...';
	@override String get emptyChat => 'Bahany we şertleri şu ýerde ylalaşarsyňyz';
	@override String get emptyThreadsTitle => 'Heniz söhbet ýok';
	@override String get emptyThreadsMessage => 'Ussa sargydyňyza jogap berende şu ýerde ýazyşarsyňyz.';
}

// Path: notifications
class _TranslationsNotificationsTk extends TranslationsNotificationsUz {
	_TranslationsNotificationsTk._(TranslationsTk root) : this._root = root, super.internal(root);

	final TranslationsTk _root; // ignore: unused_field

	// Translations
	@override String get title => 'Habarnamalar';
	@override String get markAllRead => 'Ählisini okaldy diý';
	@override String get empty => 'Habarnama ýok';
	@override String get open => 'Aç';
}

// Path: masters
class _TranslationsMastersTk extends TranslationsMastersUz {
	_TranslationsMastersTk._(TranslationsTk root) : this._root = root, super.internal(root);

	final TranslationsTk _root; // ignore: unused_field

	// Translations
	@override String get title => 'Ussa barada';
	@override String get master => 'Ussa';
	@override String get client => 'Müşderi';
	@override String get write => 'Ýaz';
	@override String get chooseThis => 'Şu ussany saýla';
	@override String get choose => 'Saýla';
	@override String get chosen => 'Saýlanan ussa';
	@override String get notFound => 'Maglumat tapylmady';
	@override String get works => 'Ýerine ýetiren işleri';
	@override String reviews({required Object count}) => 'Synlar (${count})';
	@override String get reviewsLabel => 'Synlar';
	@override String get noReviews => 'Heniz syn ýok — ilkinji siz bolup bilersiňiz.';
	@override String experienceYears({required Object years}) => '${years} ýyl tejribe';
	@override String get rating => 'Reýting';
	@override String get completed => 'Ýerine ýetirilen';
	@override String responses({required Object count}) => '${count} jogap';
	@override String get estimate => 'Hasap';
}

// Path: orderFlow
class _TranslationsOrderFlowTk extends TranslationsOrderFlowUz {
	_TranslationsOrderFlowTk._(TranslationsTk root) : this._root = root, super.internal(root);

	final TranslationsTk _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsOrderFlowStatusTk status = _TranslationsOrderFlowStatusTk._(_root);
	@override late final _TranslationsOrderFlowStageTk stage = _TranslationsOrderFlowStageTk._(_root);
	@override late final _TranslationsOrderFlowResponseTk response = _TranslationsOrderFlowResponseTk._(_root);
}

// Path: company
class _TranslationsCompanyTk extends TranslationsCompanyUz {
	_TranslationsCompanyTk._(TranslationsTk root) : this._root = root, super.internal(root);

	final TranslationsTk _root; // ignore: unused_field

	// Translations
	@override String get title => 'Kärhana';
	@override String get nameLabel => 'Kärhananyň ady';
	@override String get nameHint => 'Meselem: Ustachi Servis';
	@override String get nameEmpty => 'Kärhananyň ady girizilmedi';
	@override String get nameNote => 'Sargyt kagyzynda görünýär';
	@override String get logoHint => 'Logotip goş';
}

// Path: companyRates
class _TranslationsCompanyRatesTk extends TranslationsCompanyRatesUz {
	_TranslationsCompanyRatesTk._(TranslationsTk root) : this._root = root, super.internal(root);

	final TranslationsTk _root; // ignore: unused_field

	// Translations
	@override String get onlyDigits => 'Diňe san';
}

// Path: materials
class _TranslationsMaterialsTk extends TranslationsMaterialsUz {
	_TranslationsMaterialsTk._(TranslationsTk root) : this._root = root, super.internal(root);

	final TranslationsTk _root; // ignore: unused_field

	// Translations
	@override String get title => 'Materiallar';
	@override String get on => 'Bu material bilen işleýärin — sargytlar geler';
	@override String get off => 'Öçük — bu material boýunça sargytlar gelmez';
	@override String get allOff => 'Iň bolmanda bir material açyk bolmaly';
}

// Path: professional
class _TranslationsProfessionalTk extends TranslationsProfessionalUz {
	_TranslationsProfessionalTk._(TranslationsTk root) : this._root = root, super.internal(root);

	final TranslationsTk _root; // ignore: unused_field

	// Translations
	@override String get title => 'Hünär maglumaty';
	@override String get headline => 'Nähili ussadygyňyzy aýdyň';
	@override String get headlineHint => 'Müşderi sizi saýlamazdan öň şu maglumaty görýär. Soň islendik wagt üýtgedip bilersiňiz.';
	@override String get specialty => 'Ugurlar';
	@override String get specialtyPick => 'Ugurlaryňyzy saýlaň';
	@override String get specialtyLoadFailed => 'Ugurlaryň sanawy ýüklenmedi — interneti barlaň we gaýtadan giriň.';
	@override String get experienceQuestion => 'Näçe ýyl tejribäňiz bar?';
	@override String get experienceHint => 'Meselem: 5';
	@override String get experienceRequired => 'Tejribäni giriziň';
	@override String get experienceRange => 'Tejribe 0 bilen 70 aralygynda bolmaly';
	@override String get aboutLabel => 'Özüňiz barada (islege bagly)';
	@override String get aboutHint => 'Haýsy işleri edýärsiňiz, nämä üns berýärsiňiz — gysgaça ýazyň.';
	@override String get works => 'Işleriňiz';
	@override String get worksHint => 'Surat goşsaňyz, müşderi işiňizi görer we sizi saýlamak ähtimallygy artar. Islege bagly — soň hem goşup bolýar.';
	@override String get deleteSampleTitle => 'Nusga pozulsynmy?';
	@override String get deleteSampleMessage => 'Müşderiler bu suraty indi görmez.';
	@override String get deleteFailed => 'Pozulmady';
	@override String get pickSpecialty => 'Iň bolmanda bir ugur saýlaň';
	@override String get specialtyHint => 'Birnäçesini saýlap bilersiňiz — sargyt diňe şu ugurlar boýunça geler.';
}

// Path: appUpdate
class _TranslationsAppUpdateTk extends TranslationsAppUpdateUz {
	_TranslationsAppUpdateTk._(TranslationsTk root) : this._root = root, super.internal(root);

	final TranslationsTk _root; // ignore: unused_field

	// Translations
	@override String get eyebrow => 'TÄZELEME';
	@override String get titleOptional => 'Täze wersiýa taýýar';
	@override String get titleRequired => 'Täzelemek talap edilýär';
	@override String get bodyOptional => 'Ustachi Pro-nyň täze wersiýasy çykdy. Soňky düzedişler we mümkinçilikler üçin täzeläň.';
	@override String get bodyRequired => 'Bu wersiýa indi goldanylmaýar. Programmadan peýdalanmagy dowam etdirmek üçin täzeläň.';
	@override String get whatsNew => 'NÄME TÄZELENDI';
	@override String get versionFrom => 'Sizde';
	@override String get versionTo => 'Täze';
	@override String get update => 'Täzelemek';
	@override String get later => 'Soňra';
	@override String get openFailed => 'Salgylanmany açyp bolmady. Programmany dükandan elde täzeläň.';
}

// Path: onboarding.step1
class _TranslationsOnboardingStep1Tk extends TranslationsOnboardingStep1Uz {
	_TranslationsOnboardingStep1Tk._(TranslationsTk root) : this._root = root, super.internal(root);

	final TranslationsTk _root; // ignore: unused_field

	// Translations
	@override String get title => 'Öz ugruňyzy saýlaň';
	@override String get description => 'Penjire, üçek, kerpiç, elektrik, santehnik, kafel, boýag… 25-den gowrak ugur. Sargytlar siziň ugruňyz boýunça gelýär.';
}

// Path: onboarding.step2
class _TranslationsOnboardingStep2Tk extends TranslationsOnboardingStep2Uz {
	_TranslationsOnboardingStep2Tk._(TranslationsTk root) : this._root = root, super.internal(root);

	final TranslationsTk _root; // ignore: unused_field

	// Translations
	@override String get title => 'Sargyt özi tapýar';
	@override String get description => 'Sebitiňize we ugruňyza laýyk täze bildirişler derrew habarnama bolup gelýär — gözlemeli däl.';
}

// Path: onboarding.step3
class _TranslationsOnboardingStep3Tk extends TranslationsOnboardingStep3Uz {
	_TranslationsOnboardingStep3Tk._(TranslationsTk root) : this._root = root, super.internal(root);

	final TranslationsTk _root; // ignore: unused_field

	// Translations
	@override String get title => 'Bahany özüňiz kesgitleýärsiňiz';
	@override String get description => 'Öz bahalaryňyzy girizýärsiňiz, müşderi bilen çatda ylalaşýarsyňyz we işiň tapgyrlaryny bellemek siziň eliňizde.';
}

// Path: auth.common
class _TranslationsAuthCommonTk extends TranslationsAuthCommonUz {
	_TranslationsAuthCommonTk._(TranslationsTk root) : this._root = root, super.internal(root);

	final TranslationsTk _root; // ignore: unused_field

	// Translations
	@override String get invalidPhone => 'Telefon belgiňizi dogry giriziň';
	@override String get cancel => 'Ýatyr';
}

// Path: auth.phone
class _TranslationsAuthPhoneTk extends TranslationsAuthPhoneUz {
	_TranslationsAuthPhoneTk._(TranslationsTk root) : this._root = root, super.internal(root);

	final TranslationsTk _root; // ignore: unused_field

	// Translations
	@override String get title => 'Programma girmek';
	@override String get subtitle => 'Belgiňizi giriziň — SMS arkaly 6 belgili kod ibereris. Parol gerek däl.';
	@override String get label => 'Telefon belgisi';
	@override String get continueBtn => 'Dowam et';
	@override String get orOption => 'ýa-da';
	@override String get telegramBtn => 'Telegram arkaly gir';
	@override String get telegramHint => 'Bot girmek üçin Telegram hasabyňyza baglanyşykly belgini sorar. SMS iberilmeýär.';
	@override String get telegramOpenError => 'Telegram botuny açyp bolmady. Gaýtadan synanyşyň.';
	@override String get agreementPrefix => 'Dowam etmek bilen siz ';
	@override String get terms => 'Ulanyş şertleri';
	@override String get and => ' we ';
	@override String get privacy => 'Gizlinlik syýasaty';
	@override String get agreementSuffix => ' bilen ylalaşýarsyňyz.';
	@override String get audienceRedirect => 'Ussa gözleýärsiňizmi? «Ustachi» ýükläň';
	@override String get audienceTitle => 'Üns beriň: programma ussalar üçin';
}

// Path: auth.otp
class _TranslationsAuthOtpTk extends TranslationsAuthOtpUz {
	_TranslationsAuthOtpTk._(TranslationsTk root) : this._root = root, super.internal(root);

	final TranslationsTk _root; // ignore: unused_field

	// Translations
	@override String get title => 'Kody giriziň';
	@override String sentMessage({required Object phone}) => '${phone} belgä iberilen 6 belgili kody giriziň';
	@override String get invalidCode => '6 belginiň hemmesini giriziň';
	@override String get resend => 'Kody gaýtadan iber';
	@override String get resendIn => 'Gaýtadan iber';
	@override String get confirmBtn => 'Tassykla';
	@override String get changeNumber => 'Başga belgi giriz';
}

// Path: auth.profile
class _TranslationsAuthProfileTk extends TranslationsAuthProfileUz {
	_TranslationsAuthProfileTk._(TranslationsTk root) : this._root = root, super.internal(root);

	final TranslationsTk _root; // ignore: unused_field

	// Translations
	@override String get title => 'Özüňiz barada';
	@override String get subtitle => 'Müşderiler sizi şu at bilen görer. Soňra profiliňizden üýtgedip bilersiňiz.';
	@override String get fullNameLabel => 'Ady we familiýasy';
	@override String get fullNameHint => 'Giriziň';
	@override String get requiredName => 'Adyňyzy we familiýaňyzy giriziň';
	@override String get addPhoto => 'Surat goş';
	@override String get changePhoto => 'Suraty çalyş';
	@override String get saveBtn => 'Ýatda sakla we dowam et';
	@override String get skip => 'Soň dolduraryn';
	@override String get regionLabel => 'Welaýat';
	@override String get regionHint => 'Welaýaty saýlaň';
	@override String get districtLabel => 'Etrap / şäher';
	@override String get districtHint => 'Etraby saýlaň';
	@override String get addressLabel => 'Salgy';
	@override String get addressHint => 'Köçe, jaý belgisi';
	@override String get requiredRegion => 'Welaýaty saýlaň';
	@override String get requiredDistrict => 'Etraby saýlaň';
	@override String get loadFailed => 'Sanaw ýüklenip bilmedi';
}

// Path: auth.telegram
class _TranslationsAuthTelegramTk extends TranslationsAuthTelegramUz {
	_TranslationsAuthTelegramTk._(TranslationsTk root) : this._root = root, super.internal(root);

	final TranslationsTk _root; // ignore: unused_field

	// Translations
	@override String get loadingTitle => 'Telegram arkaly girilýär';
	@override String get loadingHint => 'Bir gezeklik salgy barlanýar…';
	@override String get invalidLink => 'Telegram salgysy nädogry.';
	@override String get expiredLink => 'Salgynyň möhleti gutardy ýa-da öň ulanyldy. Botda täzeden başlaň.';
	@override String get retry => 'Gaýtadan synanyş';
	@override String get restartBot => 'Botda täzeden başla';
	@override String get smsOption => 'SMS arkaly gir';
}

// Path: profile.personal
class _TranslationsProfilePersonalTk extends TranslationsProfilePersonalUz {
	_TranslationsProfilePersonalTk._(TranslationsTk root) : this._root = root, super.internal(root);

	final TranslationsTk _root; // ignore: unused_field

	// Translations
	@override String get sectionPersonal => 'Şahsy';
	@override String get sectionAddress => 'Salgy';
	@override String get sectionProfessional => 'Hünär';
	@override String get phoneLabel => 'Telefon';
	@override String get phoneNote => 'Belgi — hasabyň kesgitleýjisi, üýtgedilmeýär';
	@override String get joinedLabel => 'Bellige alnan';
	@override String get empty => 'Girizilmedik';
	@override String get edit => 'Düzetmek';
	@override String get openProfessional => 'Hünär, tejribe we işler';
	@override String get loadFailed => 'Maglumaty ýükläp bolmady';
}

// Path: profile.help
class _TranslationsProfileHelpTk extends TranslationsProfileHelpUz {
	_TranslationsProfileHelpTk._(TranslationsTk root) : this._root = root, super.internal(root);

	final TranslationsTk _root; // ignore: unused_field

	// Translations
	@override String get subtitle => 'Sorag ýa-da mesele bolsa — ýazyň ýa-da jaň ediň';
	@override String get callLabel => 'Jaň etmek';
	@override String get emailLabel => 'Elektron poçta';
	@override String get telegramLabel => 'Telegram kanalymyz';
	@override String get telegramHint => 'Täzelikler we bildirişler';
	@override String get workHours => 'Duş–şen, 9:00–19:00';
	@override String get copied => 'Göçürildi';
}

// Path: orders.stage
class _TranslationsOrdersStageTk extends TranslationsOrdersStageUz {
	_TranslationsOrdersStageTk._(TranslationsTk root) : this._root = root, super.internal(root);

	final TranslationsTk _root; // ignore: unused_field

	// Translations
	@override String get accepted => 'Teklip kabul edildi';
	@override String get measured => 'Ölçeg alyndy';
	@override String get production => 'Önümçilik';
	@override String get installation => 'Gurnama';
	@override String get handover => 'Tabşyryş we töleg';
}

// Path: orders.detail
class _TranslationsOrdersDetailTk extends TranslationsOrdersDetailUz {
	_TranslationsOrdersDetailTk._(TranslationsTk root) : this._root = root, super.internal(root);

	final TranslationsTk _root; // ignore: unused_field

	// Translations
	@override String get stages => 'Tapgyrlar';
	@override String get spec => 'Spesifikasiýa';
	@override String get client => 'Müşderi';
	@override String get total => 'Jemi';
	@override String get prepaid => 'Öňünden töleg';
	@override String get remaining => 'Galyndy';
	@override String get dueDate => 'Ylalaşylan möhlet';
	@override String get finishOrder => 'Tabşyr we tamamla';
	@override String get completed => 'Sargyt tamamlandy';
	@override String stageDone({required Object stage}) => '${stage} tamamlandy';
	@override String get notFound => 'Sargyt tapylmady';
	@override String get drawings => 'Çyzgylar';
	@override String get drawingsHint => 'Iki barmak bilen ulaldyň · ölçegler mm-de';
	@override String get markMeasured => 'Ölçeg alyndy';
	@override String get markProduction => 'Önümçilik başlandy';
	@override String get markInstallation => 'Gurnama çykdyk';
	@override String get stageSaved => 'Bellendi — müşderä habar gitdi';
}

// Path: orders.request
class _TranslationsOrdersRequestTk extends TranslationsOrdersRequestUz {
	_TranslationsOrdersRequestTk._(TranslationsTk root) : this._root = root, super.internal(root);

	final TranslationsTk _root; // ignore: unused_field

	// Translations
	@override String get title => 'Haýyş';
	@override String get clientSpec => 'Müşderiniň hasaplan spesifikasiýasy';
	@override String get priceOffer => 'Baha teklibi';
	@override String get serviceFee => 'Gurnama we eltip bermek';
	@override String get yourOffer => 'Siziň teklibiňiz';
	@override String get workDays => 'Möhlet — iş güni';
	@override String get note => 'Bellik (islege bagly)';
	@override String get notePlaceholder => 'Müşderä goşmaça bellik…';
	@override String get send => 'Teklibi iber';
	@override String get decline => 'Ret et';
	@override String get declineTitle => 'Haýyş ret edilsinmi?';
	@override String get declineMessage => 'Bu haýyş sanawdan doly pozular.';
	@override String expiresIn({required Object time}) => '${time} galdy';
	@override String get expired => 'Möhleti geçdi';
	@override String distance({required Object km}) => '${km} km';
	@override String get sent => 'Teklip iberildi';
	@override String get invalidFee => 'Iş haky otrisatel bolup bilmez';
	@override String get chatNote => 'Bahany we şertleri müşderi bilen çatda ylalaşarsyňyz.';
	@override String get withdrawOffer => 'Teklibi yzyna almak';
	@override String get declineInviteTitle => 'Teklibi ret edýärsiňizmi?';
	@override String get declineInviteMessage => 'Müşderä derrew habar barýar we ol başga ussa saýlaýar.';
	@override String get clientPrice => 'Sargydyň bahasy';
	@override String get priceInChat => 'Baha çatda ylalaşylýar';
}

// Path: orders.spec
class _TranslationsOrdersSpecTk extends TranslationsOrdersSpecUz {
	_TranslationsOrdersSpecTk._(TranslationsTk root) : this._root = root, super.internal(root);

	final TranslationsTk _root; // ignore: unused_field

	// Translations
	@override String get size => 'Ölçeg (mm)';
	@override String get shape => 'Şekil';
	@override String get brand => 'Brend';
	@override String get color => 'Reňk';
	@override String get material => 'Material';
	@override String get glass => 'Aýna';
	@override String get sill => 'Penjire tagtasy (sm)';
	@override String get flower => 'Nagyş';
	@override String get address => 'Salgy';
	@override String get product => 'Önümler';
	@override String get phone => 'Telefon';
	@override String get discount => 'Arzanladyş';
	@override String get note => 'Bellik';
	@override String itemsValue({required Object kinds, required Object count}) => '${kinds} görnüş · ${count} sany';
	@override late final _TranslationsOrdersSpecValuesTk values = _TranslationsOrdersSpecValuesTk._(_root);
	@override String get area => 'Meýdany';
	@override String get unitPrice => '1 m² bahasy';
	@override String get variant => 'Derejesi';
}

// Path: orders.open
class _TranslationsOrdersOpenTk extends TranslationsOrdersOpenUz {
	_TranslationsOrdersOpenTk._(TranslationsTk root) : this._root = root, super.internal(root);

	final TranslationsTk _root; // ignore: unused_field

	// Translations
	@override String get offerSent => 'Teklip iberildi';
	@override String get waitingClient => 'Müşderiniň jogabyna garaşylýar';
	@override String offersCount({required Object count}) => '${count} teklip';
	@override String get beFirst => 'Ilkinji boluň';
	@override String get newBadge => 'Täze';
	@override String get pageTitle => 'Açyk sargytlar';
	@override String get tabWaiting => 'Jogaba garaşylýar';
	@override String get tabSent => 'Teklip iberildi';
	@override String get emptySentTitle => 'Iberilen teklip ýok';
	@override String get emptySentMessage => 'Jogap beren bildirişleriňiz şu ýerde müşderiniň jogabyna garaşýar.';
	@override String get tabInvited => 'Size teklip';
	@override String get invitedBadge => 'Size teklip';
	@override String get acceptInvite => 'Kabul edýärin';
	@override String get emptyInvitedTitle => 'Şahsy teklip ýok';
	@override String get emptyInvitedMessage => 'Müşderiniň sizi saýlan sargytlary şu ýerde görüner.';
	@override String get invitedNote => 'Müşderi bu sargydy gönüden-göni size iberdi — beýleki ussalar görmeýär.';
	@override String get repairBadge => 'Bejeriş';
}

// Path: ownOrders.status
class _TranslationsOwnOrdersStatusTk extends TranslationsOwnOrdersStatusUz {
	_TranslationsOwnOrdersStatusTk._(TranslationsTk root) : this._root = root, super.internal(root);

	final TranslationsTk _root; // ignore: unused_field

	// Translations
	@override String get draft => 'Taslama';
	@override String get newOrder => 'Täze';
	@override String get inProgress => 'Dowam edýär';
	@override String get done => 'Tamamlandy';
	@override String get debt => 'Bergili';
	@override String get cancelled => 'Ýatyryldy';
}

// Path: ownOrders.hint
class _TranslationsOwnOrdersHintTk extends TranslationsOwnOrdersHintUz {
	_TranslationsOwnOrdersHintTk._(TranslationsTk root) : this._root = root, super.internal(root);

	final TranslationsTk _root; // ignore: unused_field

	// Translations
	@override String get newOrder => 'Kabul edildi, entek başlanmady';
	@override String get inProgress => 'Önümçilik ýa-da gurnama dowam edýär';
	@override String get done => 'Tabşyryldy we doly hasaplaşyldy';
	@override String get debt => 'Iş gutardy, ýöne töleg doly däl';
	@override String get cancelled => 'Sargyt ýatyryldy';
}

// Path: orderFlow.status
class _TranslationsOrderFlowStatusTk extends TranslationsOrderFlowStatusUz {
	_TranslationsOrderFlowStatusTk._(TranslationsTk root) : this._root = root, super.internal(root);

	final TranslationsTk _root; // ignore: unused_field

	// Translations
	@override String get published => 'Çap edildi';
	@override String get assigned => 'Ussa saýlandy';
	@override String get completed => 'Tamamlandy';
	@override String get cancelled => 'Ýatyryldy';
	@override String get expired => 'Möhleti geçdi';
}

// Path: orderFlow.stage
class _TranslationsOrderFlowStageTk extends TranslationsOrderFlowStageUz {
	_TranslationsOrderFlowStageTk._(TranslationsTk root) : this._root = root, super.internal(root);

	final TranslationsTk _root; // ignore: unused_field

	// Translations
	@override String get accepted => 'Kabul edildi';
	@override String get measured => 'Ölçeg alyndy';
	@override String get production => 'Önümçilik';
	@override String get installation => 'Gurnama';
	@override String get handover => 'Tabşyryldy';
}

// Path: orderFlow.response
class _TranslationsOrderFlowResponseTk extends TranslationsOrderFlowResponseUz {
	_TranslationsOrderFlowResponseTk._(TranslationsTk root) : this._root = root, super.internal(root);

	final TranslationsTk _root; // ignore: unused_field

	// Translations
	@override String get interested => 'Kabul edýärin';
	@override String get withdrawn => 'Ýüz öwürdi';
	@override String get chosen => 'Saýlandy';
	@override String get rejected => 'Saýlanmady';
}

// Path: orders.spec.values
class _TranslationsOrdersSpecValuesTk extends TranslationsOrdersSpecValuesUz {
	_TranslationsOrdersSpecValuesTk._(TranslationsTk root) : this._root = root, super.internal(root);

	final TranslationsTk _root; // ignore: unused_field

	// Translations
	@override String get plastic => 'Plastik';
	@override String get aluminium => 'Alýuminiý';
	@override String get termo => 'Termo';
	@override String get doubleGlass => 'Iki gatly';
	@override String get singleGlass => 'Bir gatly';
	@override String get large => 'Uly';
	@override String get medium => 'Orta';
	@override String get small => 'Kiçi';
}

/// The flat map containing all translations for locale <tk>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on TranslationsTk {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'applicationName' => 'Ustachi',
			'common.ok' => 'Bolýar',
			'common.start' => 'Başla',
			'common.cancel' => 'Ýatyr',
			'common.save' => 'Ýatda sakla',
			'common.delete' => 'Poz',
			'common.edit' => 'Üýtget',
			'common.close' => 'Ýap',
			'common.back' => 'Yza',
			'common.next' => 'Indiki',
			'common.skip' => 'Geç',
			'common.enter' => 'Giriziň',
			'common.wentWrong' => 'Ýalňyşlyk ýüze çykdy. Biraz soň gaýtadan synanyşyň!',
			'common.common' => 'Esasy',
			'common.select' => 'Saýla',
			'common.retry' => 'Gaýtadan synanyş',
			'common.refresh' => 'Täzele',
			'common.saved' => 'Ýatda saklandy',
			'common.saveFailed' => 'Ýatda saklanmady — gaýtadan synanyşyň',
			'common.notFound' => 'Tapylmady',
			'common.empty' => 'Boş',
			'common.loading' => 'Ýüklenýär…',
			'common.yes' => 'Hawa',
			'common.no' => 'Ýok',
			'common.add' => 'Goş',
			'common.copy' => 'Nusgala',
			'common.apply' => 'Ulan',
			'common.reset' => 'Dikelt',
			'common.done' => 'Taýýar',
			'common.all' => 'Ählisi',
			'common.som' => 'som',
			'common.cm' => 'sm',
			'common.mm' => 'mm',
			'common.pcs' => 'sany',
			'common.hoursShort' => 'sag',
			'common.minutesShort' => 'min',
			'common.months.0' => 'ýanwar',
			'common.months.1' => 'fewral',
			'common.months.2' => 'mart',
			'common.months.3' => 'aprel',
			'common.months.4' => 'maý',
			'common.months.5' => 'iýun',
			'common.months.6' => 'iýul',
			'common.months.7' => 'awgust',
			'common.months.8' => 'sentýabr',
			'common.months.9' => 'oktýabr',
			'common.months.10' => 'noýabr',
			'common.months.11' => 'dekabr',
			'common.weekdays.0' => 'Ýekşenbe',
			'common.weekdays.1' => 'Duşenbe',
			'common.weekdays.2' => 'Sişenbe',
			'common.weekdays.3' => 'Çarşenbe',
			'common.weekdays.4' => 'Penşenbe',
			'common.weekdays.5' => 'Anna',
			'common.weekdays.6' => 'Şenbe',
			'common.today' => 'Şu gün',
			'common.tomorrow' => 'Ertir',
			'common.comingSoon' => 'Basym',
			'onboarding.step1.title' => 'Öz ugruňyzy saýlaň',
			'onboarding.step1.description' => 'Penjire, üçek, kerpiç, elektrik, santehnik, kafel, boýag… 25-den gowrak ugur. Sargytlar siziň ugruňyz boýunça gelýär.',
			'onboarding.step2.title' => 'Sargyt özi tapýar',
			'onboarding.step2.description' => 'Sebitiňize we ugruňyza laýyk täze bildirişler derrew habarnama bolup gelýär — gözlemeli däl.',
			'onboarding.step3.title' => 'Bahany özüňiz kesgitleýärsiňiz',
			'onboarding.step3.description' => 'Öz bahalaryňyzy girizýärsiňiz, müşderi bilen çatda ylalaşýarsyňyz we işiň tapgyrlaryny bellemek siziň eliňizde.',
			'auth.tagline' => 'USSANYŇ IŞ GIŇIŞLIGI',
			'auth.common.invalidPhone' => 'Telefon belgiňizi dogry giriziň',
			'auth.common.cancel' => 'Ýatyr',
			'auth.phone.title' => 'Programma girmek',
			'auth.phone.subtitle' => 'Belgiňizi giriziň — SMS arkaly 6 belgili kod ibereris. Parol gerek däl.',
			'auth.phone.label' => 'Telefon belgisi',
			'auth.phone.continueBtn' => 'Dowam et',
			'auth.phone.orOption' => 'ýa-da',
			'auth.phone.telegramBtn' => 'Telegram arkaly gir',
			'auth.phone.telegramHint' => 'Bot girmek üçin Telegram hasabyňyza baglanyşykly belgini sorar. SMS iberilmeýär.',
			'auth.phone.telegramOpenError' => 'Telegram botuny açyp bolmady. Gaýtadan synanyşyň.',
			'auth.phone.agreementPrefix' => 'Dowam etmek bilen siz ',
			'auth.phone.terms' => 'Ulanyş şertleri',
			'auth.phone.and' => ' we ',
			'auth.phone.privacy' => 'Gizlinlik syýasaty',
			'auth.phone.agreementSuffix' => ' bilen ylalaşýarsyňyz.',
			'auth.phone.audienceRedirect' => 'Ussa gözleýärsiňizmi? «Ustachi» ýükläň',
			'auth.phone.audienceTitle' => 'Üns beriň: programma ussalar üçin',
			'auth.otp.title' => 'Kody giriziň',
			'auth.otp.sentMessage' => ({required Object phone}) => '${phone} belgä iberilen 6 belgili kody giriziň',
			'auth.otp.invalidCode' => '6 belginiň hemmesini giriziň',
			'auth.otp.resend' => 'Kody gaýtadan iber',
			'auth.otp.resendIn' => 'Gaýtadan iber',
			'auth.otp.confirmBtn' => 'Tassykla',
			'auth.otp.changeNumber' => 'Başga belgi giriz',
			'auth.profile.title' => 'Özüňiz barada',
			'auth.profile.subtitle' => 'Müşderiler sizi şu at bilen görer. Soňra profiliňizden üýtgedip bilersiňiz.',
			'auth.profile.fullNameLabel' => 'Ady we familiýasy',
			'auth.profile.fullNameHint' => 'Giriziň',
			'auth.profile.requiredName' => 'Adyňyzy we familiýaňyzy giriziň',
			'auth.profile.addPhoto' => 'Surat goş',
			'auth.profile.changePhoto' => 'Suraty çalyş',
			'auth.profile.saveBtn' => 'Ýatda sakla we dowam et',
			'auth.profile.skip' => 'Soň dolduraryn',
			'auth.profile.regionLabel' => 'Welaýat',
			'auth.profile.regionHint' => 'Welaýaty saýlaň',
			'auth.profile.districtLabel' => 'Etrap / şäher',
			'auth.profile.districtHint' => 'Etraby saýlaň',
			'auth.profile.addressLabel' => 'Salgy',
			'auth.profile.addressHint' => 'Köçe, jaý belgisi',
			'auth.profile.requiredRegion' => 'Welaýaty saýlaň',
			'auth.profile.requiredDistrict' => 'Etraby saýlaň',
			'auth.profile.loadFailed' => 'Sanaw ýüklenip bilmedi',
			'auth.telegram.loadingTitle' => 'Telegram arkaly girilýär',
			'auth.telegram.loadingHint' => 'Bir gezeklik salgy barlanýar…',
			'auth.telegram.invalidLink' => 'Telegram salgysy nädogry.',
			'auth.telegram.expiredLink' => 'Salgynyň möhleti gutardy ýa-da öň ulanyldy. Botda täzeden başlaň.',
			'auth.telegram.retry' => 'Gaýtadan synanyş',
			'auth.telegram.restartBot' => 'Botda täzeden başla',
			'auth.telegram.smsOption' => 'SMS arkaly gir',
			'country.title' => 'Ýurdy saýlaň',
			'country.subtitle' => 'Programmanyň dili ýurda görä saýlanýar. Soňra profiliňizden üýtgedip bilersiňiz.',
			'country.continueBtn' => 'Dowam et',
			'country.changeTitle' => 'Ýurt we dil',
			'home.main' => 'Esasy',
			'home.chatting' => 'Çat',
			'home.profile' => 'Profil',
			'home.title' => 'Profil',
			'home.loadError' => 'Profil ýüklenmedi',
			'home.retry' => 'Gaýtadan synanyş',
			'home.phone' => 'Telefon',
			'home.role' => 'Rol',
			'home.status' => 'Ýagdaý',
			'home.active' => 'Işjeň',
			'home.inactive' => 'Işjeň däl',
			'home.logout' => 'Çyk',
			'home.hi' => 'Salam',
			'home.serviceType' => 'Hyzmat görnüşleri',
			'home.lastOrders' => 'Soňky sargytlar',
			'home.all' => 'Ählisi',
			'home.tapRepair' => 'Kran abatlaýyş',
			'home.chandelierInstallation' => 'Lýustra oturtmak',
			'home.completed' => 'Ýerine ýetirildi',
			'home.inProgress' => 'Dowam edýär',
			'home.window' => 'Penjire',
			'home.furtiniture' => 'Mebel',
			'home.electric' => 'Elektrik',
			'home.plumber' => 'Santehnika',
			'calculatePage.window' => 'Penjire',
			'calculatePage.door' => 'Gapy',
			'calculatePage.glass' => 'Arkalar',
			'calculatePage.windowConfigurator' => 'Penjire konfigurasiýasy',
			'calculatePage.windowLayouts' => 'Bölüm görnüşleri',
			'calculatePage.windowPremiumLayouts' => 'Premium warýantlar',
			'calculatePage.windowModernLayouts' => 'Döwrebap warýantlar',
			'calculatePage.doorConfigurator' => 'Gapy konfigurasiýasy',
			'calculatePage.doorModels' => 'Gapy modelleri',
			'calculatePage.doorExtraModels' => 'Goşmaça modeller',
			'calculatePage.material' => 'Material',
			'calculatePage.plastic' => 'Plastik',
			'calculatePage.aluminium' => 'Alýuminiý',
			'calculatePage.termo' => 'Termo',
			'calculatePage.glassShowcase' => 'Arka warýantlary',
			'calculatePage.customTemplateTitleWindow' => 'Öz penjiräňizi dörediň',
			'calculatePage.customTemplateTitleDoor' => 'Öz gapyňyzy dörediň',
			'calculatePage.customTemplateTitleArch' => 'Öz arkaňyzy dörediň',
			'calculatePage.customTemplateSubtitle' => 'Taýýar şablon däl — ölçegi we bölünişi özüňiz çyzýarsyňyz',
			'calculatePage.customTemplateAction' => 'Başla',
			'calculatePage.readyTemplates' => 'Taýýar şablonlar',
			'profile.personalData' => 'Şahsy maglumatlar',
			'profile.professional' => 'Hünär maglumaty',
			'profile.company' => 'Kärhana',
			'profile.myOrders' => 'Sargytlarym',
			'profile.settings' => 'Sazlamalar',
			'profile.support' => 'Biz bilen habarlaşyň',
			'profile.logout' => 'Çyk',
			'profile.logoutTitle' => 'Hasapdan çykylsynmy?',
			'profile.logoutMessage' => 'Ýüklenen bahalar we hasaplama maglumatlary enjamdan pozular. Gaýtadan gireniňizde olar täzeden ýüklener.',
			'profile.logoutConfirm' => 'Hawa, çykaryn',
			'profile.loggingOut' => 'Çykylýar...',
			'profile.loggingOutHint' => 'Sessiýa ýapylyp, baha keşi arassalanýar',
			'profile.logoutFailed' => 'Serwerden çykyp bolmady, ýöne enjamdaky maglumatlar arassalandy',
			'profile.personal.sectionPersonal' => 'Şahsy',
			'profile.personal.sectionAddress' => 'Salgy',
			'profile.personal.sectionProfessional' => 'Hünär',
			'profile.personal.phoneLabel' => 'Telefon',
			'profile.personal.phoneNote' => 'Belgi — hasabyň kesgitleýjisi, üýtgedilmeýär',
			'profile.personal.joinedLabel' => 'Bellige alnan',
			'profile.personal.empty' => 'Girizilmedik',
			'profile.personal.edit' => 'Düzetmek',
			'profile.personal.openProfessional' => 'Hünär, tejribe we işler',
			'profile.personal.loadFailed' => 'Maglumaty ýükläp bolmady',
			'profile.help.subtitle' => 'Sorag ýa-da mesele bolsa — ýazyň ýa-da jaň ediň',
			'profile.help.callLabel' => 'Jaň etmek',
			'profile.help.emailLabel' => 'Elektron poçta',
			'profile.help.telegramLabel' => 'Telegram kanalymyz',
			'profile.help.telegramHint' => 'Täzelikler we bildirişler',
			'profile.help.workHours' => 'Duş–şen, 9:00–19:00',
			'profile.help.copied' => 'Göçürildi',
			'dashboard.title' => 'Iş stoly',
			'dashboard.greetingMorning' => 'Ertiriňiz haýyrly,',
			'dashboard.greetingDay' => 'Gowy gün,',
			'dashboard.greetingEvening' => 'Agşamyňyz haýyrly,',
			'dashboard.master' => 'ussa',
			'dashboard.availableTitle' => 'Sargyt kabul edýärin',
			'dashboard.availableOn' => 'Täze haýyşlar gelip durar',
			'dashboard.availableOff' => 'Haýyşlar togtadyldy',
			'dashboard.newRequests' => 'Täze haýyşlar',
			'dashboard.activeOrders' => 'Işjeň sargytlar',
			'dashboard.all' => 'Ählisi',
			'dashboard.quickCalculate' => 'Penjire çyzgysy',
			'dashboard.quickCalculateHint' => 'Penjire we gapy çyzgysy',
			'dashboard.quickPortfolio' => 'Iş nusgasy',
			'dashboard.quickPortfolioHint' => 'Tamamlanan işden goşuň',
			'dashboard.emptyRequests' => 'Täze haýyş ýok',
			'dashboard.emptyRequestsHint' => 'Elýeterlilik açary açyk bolsa, haýyşlar şu ýere düşer.',
			'dashboard.quickCompany' => 'Kärhana',
			'dashboard.quickCompanyHint' => 'At we logotip',
			'dashboard.quickRates' => 'Hyzmat bahalarym',
			'dashboard.quickRatesHint' => 'Ugruňyz boýunça iş nyrhlary',
			'dashboard.quickOrdersHeroTitle' => 'Täze sargytlar we Bazar',
			'dashboard.quickOrdersHeroHint' => 'Ugruňyzdaky bildirişleri görüň we teklip iberiň',
			'dashboard.quickOpenOrders' => 'Açyk sargytlar',
			'dashboard.quickOpenOrdersHint' => 'Ussa saýlanmadyk bildirişler — teklip iberiň',
			'dashboard.calcStep1' => 'Çarçuwa saýlaň',
			'dashboard.calcStep2' => 'Sazlaň',
			'dashboard.calcStep3' => 'Çyzgy taýýar',
			'dashboard.repairTitle' => 'Bejeriş işlerini kabul edýärin',
			'dashboard.repairOn' => 'Bejeriş islegleri hem geler',
			'dashboard.repairOff' => 'Bejeriş islegleri gelmez',
			'dashboard.repairHint' => 'Köne penjire-gapylary sazlamak, esbaplary ýa-da aýnany çalyşmak',
			'orders.title' => 'Sargytlar',
			'orders.segmentNew' => 'Açyk',
			'orders.segmentActive' => 'Dowam edýän',
			'orders.segmentDone' => 'Tamamlanan',
			'orders.stepOf' => ({required Object total, required Object step}) => '${total} tapgyrdan ${step}.',
			'orders.lateDays' => ({required Object days}) => '${days} gün gijikdi',
			'orders.dueToday' => 'Möhleti — şu gün',
			'orders.daysLeft' => ({required Object days}) => '${days} gün galdy',
			'orders.offerBtn' => 'Teklip ber',
			'orders.retry' => 'Gaýtadan synanyş',
			'orders.loadFailed' => 'Sargytlar ýüklenip bilmedi',
			'orders.emptyNewTitle' => 'Açyk sargyt ýok',
			'orders.emptyNewMessage' => 'Sebitiňizde täze bildiriş peýda bolan badyna şu ýerde görner.',
			'orders.emptyActiveTitle' => 'Işjeň sargyt ýok',
			'orders.emptyActiveMessage' => 'Täze haýyşy kabul edeniňizde ol şu ýerde peýda bolar.',
			'orders.emptyDoneTitle' => 'Tamamlanan iş ýok',
			'orders.emptyDoneMessage' => 'Ilkinji sargydy tabşyranyňyzdan soň ol şu ýerde görüner.',
			'orders.stage.accepted' => 'Teklip kabul edildi',
			'orders.stage.measured' => 'Ölçeg alyndy',
			'orders.stage.production' => 'Önümçilik',
			'orders.stage.installation' => 'Gurnama',
			'orders.stage.handover' => 'Tabşyryş we töleg',
			'orders.detail.stages' => 'Tapgyrlar',
			'orders.detail.spec' => 'Spesifikasiýa',
			'orders.detail.client' => 'Müşderi',
			'orders.detail.total' => 'Jemi',
			'orders.detail.prepaid' => 'Öňünden töleg',
			'orders.detail.remaining' => 'Galyndy',
			'orders.detail.dueDate' => 'Ylalaşylan möhlet',
			'orders.detail.finishOrder' => 'Tabşyr we tamamla',
			'orders.detail.completed' => 'Sargyt tamamlandy',
			'orders.detail.stageDone' => ({required Object stage}) => '${stage} tamamlandy',
			'orders.detail.notFound' => 'Sargyt tapylmady',
			'orders.detail.drawings' => 'Çyzgylar',
			'orders.detail.drawingsHint' => 'Iki barmak bilen ulaldyň · ölçegler mm-de',
			'orders.detail.markMeasured' => 'Ölçeg alyndy',
			'orders.detail.markProduction' => 'Önümçilik başlandy',
			'orders.detail.markInstallation' => 'Gurnama çykdyk',
			'orders.detail.stageSaved' => 'Bellendi — müşderä habar gitdi',
			'orders.request.title' => 'Haýyş',
			'orders.request.clientSpec' => 'Müşderiniň hasaplan spesifikasiýasy',
			'orders.request.priceOffer' => 'Baha teklibi',
			'orders.request.serviceFee' => 'Gurnama we eltip bermek',
			'orders.request.yourOffer' => 'Siziň teklibiňiz',
			'orders.request.workDays' => 'Möhlet — iş güni',
			'orders.request.note' => 'Bellik (islege bagly)',
			'orders.request.notePlaceholder' => 'Müşderä goşmaça bellik…',
			'orders.request.send' => 'Teklibi iber',
			'orders.request.decline' => 'Ret et',
			'orders.request.declineTitle' => 'Haýyş ret edilsinmi?',
			'orders.request.declineMessage' => 'Bu haýyş sanawdan doly pozular.',
			'orders.request.expiresIn' => ({required Object time}) => '${time} galdy',
			'orders.request.expired' => 'Möhleti geçdi',
			'orders.request.distance' => ({required Object km}) => '${km} km',
			'orders.request.sent' => 'Teklip iberildi',
			'orders.request.invalidFee' => 'Iş haky otrisatel bolup bilmez',
			'orders.request.chatNote' => 'Bahany we şertleri müşderi bilen çatda ylalaşarsyňyz.',
			'orders.request.withdrawOffer' => 'Teklibi yzyna almak',
			'orders.request.declineInviteTitle' => 'Teklibi ret edýärsiňizmi?',
			'orders.request.declineInviteMessage' => 'Müşderä derrew habar barýar we ol başga ussa saýlaýar.',
			'orders.request.clientPrice' => 'Sargydyň bahasy',
			'orders.request.priceInChat' => 'Baha çatda ylalaşylýar',
			'orders.spec.size' => 'Ölçeg (mm)',
			'orders.spec.shape' => 'Şekil',
			'orders.spec.brand' => 'Brend',
			'orders.spec.color' => 'Reňk',
			'orders.spec.material' => 'Material',
			'orders.spec.glass' => 'Aýna',
			'orders.spec.sill' => 'Penjire tagtasy (sm)',
			'orders.spec.flower' => 'Nagyş',
			'orders.spec.address' => 'Salgy',
			'orders.spec.product' => 'Önümler',
			'orders.spec.phone' => 'Telefon',
			'orders.spec.discount' => 'Arzanladyş',
			'orders.spec.note' => 'Bellik',
			'orders.spec.itemsValue' => ({required Object kinds, required Object count}) => '${kinds} görnüş · ${count} sany',
			'orders.spec.values.plastic' => 'Plastik',
			'orders.spec.values.aluminium' => 'Alýuminiý',
			'orders.spec.values.termo' => 'Termo',
			'orders.spec.values.doubleGlass' => 'Iki gatly',
			'orders.spec.values.singleGlass' => 'Bir gatly',
			'orders.spec.values.large' => 'Uly',
			'orders.spec.values.medium' => 'Orta',
			'orders.spec.values.small' => 'Kiçi',
			'orders.spec.area' => 'Meýdany',
			'orders.spec.unitPrice' => '1 m² bahasy',
			'orders.spec.variant' => 'Derejesi',
			'orders.invalidId' => 'Sargyt belgisi nädogry.',
			'orders.invalidRequestId' => 'Haýyş belgisi nädogry.',
			'orders.open.offerSent' => 'Teklip iberildi',
			'orders.open.waitingClient' => 'Müşderiniň jogabyna garaşylýar',
			'orders.open.offersCount' => ({required Object count}) => '${count} teklip',
			'orders.open.beFirst' => 'Ilkinji boluň',
			'orders.open.newBadge' => 'Täze',
			'orders.open.pageTitle' => 'Açyk sargytlar',
			'orders.open.tabWaiting' => 'Jogaba garaşylýar',
			'orders.open.tabSent' => 'Teklip iberildi',
			'orders.open.emptySentTitle' => 'Iberilen teklip ýok',
			'orders.open.emptySentMessage' => 'Jogap beren bildirişleriňiz şu ýerde müşderiniň jogabyna garaşýar.',
			'orders.open.tabInvited' => 'Size teklip',
			'orders.open.invitedBadge' => 'Size teklip',
			'orders.open.acceptInvite' => 'Kabul edýärin',
			'orders.open.emptyInvitedTitle' => 'Şahsy teklip ýok',
			'orders.open.emptyInvitedMessage' => 'Müşderiniň sizi saýlan sargytlary şu ýerde görüner.',
			'orders.open.invitedNote' => 'Müşderi bu sargydy gönüden-göni size iberdi — beýleki ussalar görmeýär.',
			'orders.open.repairBadge' => 'Bejeriş',
			'orders.personalTitle' => 'Meniň sargytlarym',
			'ownOrders.orderTitle' => 'Sargyt',
			'ownOrders.itemsCount' => ({required Object count}) => '${count} penjire',
			'ownOrders.statusTitle' => 'Sargyt ýagdaýy',
			'ownOrders.statusRow' => 'Ýagdaý',
			'ownOrders.saving' => 'Ýatda saklanýar…',
			'ownOrders.tapToChange' => 'Üýtgetmek üçin basyň',
			'ownOrders.alreadyDone' => 'Bu sargyt eýýäm tamamlandy.',
			'ownOrders.cannotChange' => 'Bu sargydyň ýagdaýyny üýtgetmek bolmaýar.',
			'ownOrders.status.draft' => 'Taslama',
			'ownOrders.status.newOrder' => 'Täze',
			'ownOrders.status.inProgress' => 'Dowam edýär',
			'ownOrders.status.done' => 'Tamamlandy',
			'ownOrders.status.debt' => 'Bergili',
			'ownOrders.status.cancelled' => 'Ýatyryldy',
			'ownOrders.hint.newOrder' => 'Kabul edildi, entek başlanmady',
			'ownOrders.hint.inProgress' => 'Önümçilik ýa-da gurnama dowam edýär',
			'ownOrders.hint.done' => 'Tabşyryldy we doly hasaplaşyldy',
			'ownOrders.hint.debt' => 'Iş gutardy, ýöne töleg doly däl',
			'ownOrders.hint.cancelled' => 'Sargyt ýatyryldy',
			'orderForm.noProducts' => 'Sargytda haryt ýok.',
			'orderForm.queued' => 'Internet ýok — sargyt nobata goýuldy, özi iberiler.',
			'orderForm.saved' => 'Sargyt ýatda saklandy',
			'orderForm.saveTitle' => 'Sargydy ýatda sakla',
			'orderForm.customer' => 'Sargyt beriji',
			'orderForm.nameLabel' => 'Ady',
			'orderForm.nameHint' => 'Aziz',
			'orderForm.nameRequired' => 'Ady ýazyň',
			'orderForm.addressHint' => 'Çilanzar 9-nji kwartal',
			'orderForm.noteLabel' => 'Goşmaça bellik',
			'orderForm.noteHint' => '2-nji gat, lift ýok',
			'orderForm.itemsSummary' => ({required Object kinds, required Object count}) => '${kinds} görnüş penjire · ${count} sany',
			'chat.threadsTitle' => 'Söhbetler',
			'chat.conversation' => 'Söhbet',
			'chat.messageHint' => 'Habar ýazyň...',
			'chat.emptyChat' => 'Bahany we şertleri şu ýerde ylalaşarsyňyz',
			'chat.emptyThreadsTitle' => 'Heniz söhbet ýok',
			'chat.emptyThreadsMessage' => 'Ussa sargydyňyza jogap berende şu ýerde ýazyşarsyňyz.',
			'notifications.title' => 'Habarnamalar',
			'notifications.markAllRead' => 'Ählisini okaldy diý',
			'notifications.empty' => 'Habarnama ýok',
			'notifications.open' => 'Aç',
			'masters.title' => 'Ussa barada',
			'masters.master' => 'Ussa',
			'masters.client' => 'Müşderi',
			'masters.write' => 'Ýaz',
			'masters.chooseThis' => 'Şu ussany saýla',
			'masters.choose' => 'Saýla',
			'masters.chosen' => 'Saýlanan ussa',
			'masters.notFound' => 'Maglumat tapylmady',
			'masters.works' => 'Ýerine ýetiren işleri',
			'masters.reviews' => ({required Object count}) => 'Synlar (${count})',
			'masters.reviewsLabel' => 'Synlar',
			'masters.noReviews' => 'Heniz syn ýok — ilkinji siz bolup bilersiňiz.',
			'masters.experienceYears' => ({required Object years}) => '${years} ýyl tejribe',
			'masters.rating' => 'Reýting',
			'masters.completed' => 'Ýerine ýetirilen',
			'masters.responses' => ({required Object count}) => '${count} jogap',
			'masters.estimate' => 'Hasap',
			'orderFlow.status.published' => 'Çap edildi',
			'orderFlow.status.assigned' => 'Ussa saýlandy',
			'orderFlow.status.completed' => 'Tamamlandy',
			'orderFlow.status.cancelled' => 'Ýatyryldy',
			'orderFlow.status.expired' => 'Möhleti geçdi',
			'orderFlow.stage.accepted' => 'Kabul edildi',
			'orderFlow.stage.measured' => 'Ölçeg alyndy',
			'orderFlow.stage.production' => 'Önümçilik',
			'orderFlow.stage.installation' => 'Gurnama',
			'orderFlow.stage.handover' => 'Tabşyryldy',
			'orderFlow.response.interested' => 'Kabul edýärin',
			'orderFlow.response.withdrawn' => 'Ýüz öwürdi',
			'orderFlow.response.chosen' => 'Saýlandy',
			'orderFlow.response.rejected' => 'Saýlanmady',
			'company.title' => 'Kärhana',
			'company.nameLabel' => 'Kärhananyň ady',
			'company.nameHint' => 'Meselem: Ustachi Servis',
			'company.nameEmpty' => 'Kärhananyň ady girizilmedi',
			'company.nameNote' => 'Sargyt kagyzynda görünýär',
			'company.logoHint' => 'Logotip goş',
			'companyRates.onlyDigits' => 'Diňe san',
			'materials.title' => 'Materiallar',
			'materials.on' => 'Bu material bilen işleýärin — sargytlar geler',
			'materials.off' => 'Öçük — bu material boýunça sargytlar gelmez',
			'materials.allOff' => 'Iň bolmanda bir material açyk bolmaly',
			'professional.title' => 'Hünär maglumaty',
			'professional.headline' => 'Nähili ussadygyňyzy aýdyň',
			'professional.headlineHint' => 'Müşderi sizi saýlamazdan öň şu maglumaty görýär. Soň islendik wagt üýtgedip bilersiňiz.',
			'professional.specialty' => 'Ugurlar',
			'professional.specialtyPick' => 'Ugurlaryňyzy saýlaň',
			'professional.specialtyLoadFailed' => 'Ugurlaryň sanawy ýüklenmedi — interneti barlaň we gaýtadan giriň.',
			'professional.experienceQuestion' => 'Näçe ýyl tejribäňiz bar?',
			'professional.experienceHint' => 'Meselem: 5',
			'professional.experienceRequired' => 'Tejribäni giriziň',
			'professional.experienceRange' => 'Tejribe 0 bilen 70 aralygynda bolmaly',
			'professional.aboutLabel' => 'Özüňiz barada (islege bagly)',
			'professional.aboutHint' => 'Haýsy işleri edýärsiňiz, nämä üns berýärsiňiz — gysgaça ýazyň.',
			'professional.works' => 'Işleriňiz',
			'professional.worksHint' => 'Surat goşsaňyz, müşderi işiňizi görer we sizi saýlamak ähtimallygy artar. Islege bagly — soň hem goşup bolýar.',
			'professional.deleteSampleTitle' => 'Nusga pozulsynmy?',
			'professional.deleteSampleMessage' => 'Müşderiler bu suraty indi görmez.',
			'professional.deleteFailed' => 'Pozulmady',
			'professional.pickSpecialty' => 'Iň bolmanda bir ugur saýlaň',
			'professional.specialtyHint' => 'Birnäçesini saýlap bilersiňiz — sargyt diňe şu ugurlar boýunça geler.',
			'appUpdate.eyebrow' => 'TÄZELEME',
			'appUpdate.titleOptional' => 'Täze wersiýa taýýar',
			'appUpdate.titleRequired' => 'Täzelemek talap edilýär',
			'appUpdate.bodyOptional' => 'Ustachi Pro-nyň täze wersiýasy çykdy. Soňky düzedişler we mümkinçilikler üçin täzeläň.',
			'appUpdate.bodyRequired' => 'Bu wersiýa indi goldanylmaýar. Programmadan peýdalanmagy dowam etdirmek üçin täzeläň.',
			'appUpdate.whatsNew' => 'NÄME TÄZELENDI',
			'appUpdate.versionFrom' => 'Sizde',
			'appUpdate.versionTo' => 'Täze',
			'appUpdate.update' => 'Täzelemek',
			'appUpdate.later' => 'Soňra',
			'appUpdate.openFailed' => 'Salgylanmany açyp bolmady. Programmany dükandan elde täzeläň.',
			_ => null,
		};
	}
}
