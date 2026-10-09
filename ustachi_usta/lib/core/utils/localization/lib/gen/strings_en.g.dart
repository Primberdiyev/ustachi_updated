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
class TranslationsEn extends Translations with BaseTranslations<AppLocale, Translations> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	TranslationsEn({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.en,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		super.$meta.setFlatMapFunction($meta.getTranslation); // copy base translations to super.$meta
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <en>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	@override dynamic operator[](String key) => $meta.getTranslation(key) ?? super.$meta.getTranslation(key);

	late final TranslationsEn _root = this; // ignore: unused_field

	@override 
	TranslationsEn $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => TranslationsEn(meta: meta ?? this.$meta);

	// Translations
	@override String get applicationName => 'Ustachi';
	@override late final _TranslationsCommonEn common = _TranslationsCommonEn._(_root);
	@override late final _TranslationsOnboardingEn onboarding = _TranslationsOnboardingEn._(_root);
	@override late final _TranslationsAuthEn auth = _TranslationsAuthEn._(_root);
	@override late final _TranslationsCountryEn country = _TranslationsCountryEn._(_root);
	@override late final _TranslationsHomeEn home = _TranslationsHomeEn._(_root);
	@override late final _TranslationsCalculatePageEn calculatePage = _TranslationsCalculatePageEn._(_root);
	@override late final _TranslationsProfileEn profile = _TranslationsProfileEn._(_root);
	@override late final _TranslationsDashboardEn dashboard = _TranslationsDashboardEn._(_root);
	@override late final _TranslationsOrdersEn orders = _TranslationsOrdersEn._(_root);
	@override late final _TranslationsOwnOrdersEn ownOrders = _TranslationsOwnOrdersEn._(_root);
	@override late final _TranslationsOrderFormEn orderForm = _TranslationsOrderFormEn._(_root);
	@override late final _TranslationsChatEn chat = _TranslationsChatEn._(_root);
	@override late final _TranslationsNotificationsEn notifications = _TranslationsNotificationsEn._(_root);
	@override late final _TranslationsMastersEn masters = _TranslationsMastersEn._(_root);
	@override late final _TranslationsOrderFlowEn orderFlow = _TranslationsOrderFlowEn._(_root);
	@override late final _TranslationsCompanyEn company = _TranslationsCompanyEn._(_root);
	@override late final _TranslationsCompanyRatesEn companyRates = _TranslationsCompanyRatesEn._(_root);
	@override late final _TranslationsMaterialsEn materials = _TranslationsMaterialsEn._(_root);
	@override late final _TranslationsProfessionalEn professional = _TranslationsProfessionalEn._(_root);
	@override late final _TranslationsAppUpdateEn appUpdate = _TranslationsAppUpdateEn._(_root);
}

// Path: common
class _TranslationsCommonEn extends TranslationsCommonUz {
	_TranslationsCommonEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get ok => 'OK';
	@override String get start => 'Start';
	@override String get cancel => 'Cancel';
	@override String get save => 'Save';
	@override String get delete => 'Delete';
	@override String get edit => 'Edit';
	@override String get close => 'Close';
	@override String get back => 'Back';
	@override String get next => 'Next';
	@override String get skip => 'Skip';
	@override String get enter => 'Enter';
	@override String get wentWrong => 'Something went wrong. Please try again in a moment!';
	@override String get common => 'General';
	@override String get select => 'Select';
	@override String get retry => 'Try again';
	@override String get refresh => 'Refresh';
	@override String get saved => 'Saved';
	@override String get saveFailed => 'Not saved — please try again';
	@override String get notFound => 'Not found';
	@override String get empty => 'Empty';
	@override String get loading => 'Loading…';
	@override String get yes => 'Yes';
	@override String get no => 'No';
	@override String get add => 'Add';
	@override String get copy => 'Duplicate';
	@override String get apply => 'Apply';
	@override String get reset => 'Reset';
	@override String get done => 'Done';
	@override String get all => 'All';
	@override String get som => 'soum';
	@override String get cm => 'cm';
	@override String get mm => 'mm';
	@override String get pcs => 'pcs';
	@override String get hoursShort => 'h';
	@override String get minutesShort => 'min';
	@override List<String> get months => [
		'January',
		'February',
		'March',
		'April',
		'May',
		'June',
		'July',
		'August',
		'September',
		'October',
		'November',
		'December',
	];
	@override List<String> get weekdays => [
		'Sunday',
		'Monday',
		'Tuesday',
		'Wednesday',
		'Thursday',
		'Friday',
		'Saturday',
	];
	@override String get today => 'Today';
	@override String get tomorrow => 'Tomorrow';
	@override String get comingSoon => 'Coming soon';
}

// Path: onboarding
class _TranslationsOnboardingEn extends TranslationsOnboardingUz {
	_TranslationsOnboardingEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsOnboardingStep1En step1 = _TranslationsOnboardingStep1En._(_root);
	@override late final _TranslationsOnboardingStep2En step2 = _TranslationsOnboardingStep2En._(_root);
	@override late final _TranslationsOnboardingStep3En step3 = _TranslationsOnboardingStep3En._(_root);
}

// Path: auth
class _TranslationsAuthEn extends TranslationsAuthUz {
	_TranslationsAuthEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get tagline => 'THE CRAFTSMAN’S WORKSPACE';
	@override late final _TranslationsAuthCommonEn common = _TranslationsAuthCommonEn._(_root);
	@override late final _TranslationsAuthPhoneEn phone = _TranslationsAuthPhoneEn._(_root);
	@override late final _TranslationsAuthOtpEn otp = _TranslationsAuthOtpEn._(_root);
	@override late final _TranslationsAuthProfileEn profile = _TranslationsAuthProfileEn._(_root);
	@override late final _TranslationsAuthTelegramEn telegram = _TranslationsAuthTelegramEn._(_root);
}

// Path: country
class _TranslationsCountryEn extends TranslationsCountryUz {
	_TranslationsCountryEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Choose your country';
	@override String get subtitle => 'The app language follows your country. You can change it later in your profile.';
	@override String get continueBtn => 'Continue';
	@override String get changeTitle => 'Country and language';
}

// Path: home
class _TranslationsHomeEn extends TranslationsHomeUz {
	_TranslationsHomeEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get main => 'Home';
	@override String get chatting => 'Chat';
	@override String get profile => 'Profile';
	@override String get title => 'Profile';
	@override String get loadError => 'Profile did not load';
	@override String get retry => 'Try again';
	@override String get phone => 'Phone';
	@override String get role => 'Role';
	@override String get status => 'Status';
	@override String get active => 'Active';
	@override String get inactive => 'Inactive';
	@override String get logout => 'Log out';
	@override String get hi => 'Hi';
	@override String get serviceType => 'Service types';
	@override String get lastOrders => 'Recent orders';
	@override String get all => 'All';
	@override String get tapRepair => 'Faucet repair';
	@override String get chandelierInstallation => 'Chandelier installation';
	@override String get completed => 'Completed';
	@override String get inProgress => 'In progress';
	@override String get window => 'Windows';
	@override String get furtiniture => 'Furniture';
	@override String get electric => 'Electrics';
	@override String get plumber => 'Plumbing';
}

// Path: calculatePage
class _TranslationsCalculatePageEn extends TranslationsCalculatePageUz {
	_TranslationsCalculatePageEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get window => 'Window';
	@override String get door => 'Door';
	@override String get glass => 'Arches';
	@override String get windowConfigurator => 'Window configuration';
	@override String get windowLayouts => 'Layout types';
	@override String get windowPremiumLayouts => 'Premium options';
	@override String get windowModernLayouts => 'Modern options';
	@override String get doorConfigurator => 'Door configuration';
	@override String get doorModels => 'Door models';
	@override String get doorExtraModels => 'Additional models';
	@override String get material => 'Material';
	@override String get plastic => 'Plastic';
	@override String get aluminium => 'Aluminium';
	@override String get termo => 'Thermo';
	@override String get glassShowcase => 'Arch options';
	@override String get customTemplateTitleWindow => 'Create your own window';
	@override String get customTemplateTitleDoor => 'Create your own door';
	@override String get customTemplateTitleArch => 'Create your own arch';
	@override String get customTemplateSubtitle => 'Not a ready template — you draw the size and layout yourself';
	@override String get customTemplateAction => 'Start';
	@override String get readyTemplates => 'Ready templates';
}

// Path: profile
class _TranslationsProfileEn extends TranslationsProfileUz {
	_TranslationsProfileEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get personalData => 'Personal details';
	@override String get professional => 'Professional details';
	@override String get company => 'Company';
	@override String get myOrders => 'My orders';
	@override String get settings => 'Settings';
	@override String get support => 'Contact us';
	@override String get logout => 'Log out';
	@override String get logoutTitle => 'Log out of your account?';
	@override String get logoutMessage => 'Downloaded prices and calculation data will be removed from this device. They will be downloaded again next time you sign in.';
	@override String get logoutConfirm => 'Yes, log out';
	@override String get loggingOut => 'Logging out...';
	@override String get loggingOutHint => 'Closing the session and clearing the price cache';
	@override String get logoutFailed => 'Could not sign out on the server, but local data was cleared';
	@override late final _TranslationsProfilePersonalEn personal = _TranslationsProfilePersonalEn._(_root);
	@override late final _TranslationsProfileHelpEn help = _TranslationsProfileHelpEn._(_root);
}

// Path: dashboard
class _TranslationsDashboardEn extends TranslationsDashboardUz {
	_TranslationsDashboardEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Dashboard';
	@override String get greetingMorning => 'Good morning,';
	@override String get greetingDay => 'Good afternoon,';
	@override String get greetingEvening => 'Good evening,';
	@override String get master => 'craftsman';
	@override String get availableTitle => 'Accepting orders';
	@override String get availableOn => 'New requests will keep coming';
	@override String get availableOff => 'Requests are paused';
	@override String get repairTitle => 'I take repair jobs';
	@override String get repairOn => 'Repair requests will also arrive';
	@override String get repairOff => 'Repair requests will not arrive';
	@override String get repairHint => 'Adjusting old windows/doors, fittings or glass replacement';
	@override String get newRequests => 'New requests';
	@override String get activeOrders => 'Active orders';
	@override String get all => 'All';
	@override String get quickCalculate => 'Frame drawing';
	@override String get quickCalculateHint => 'Window and door drawings';
	@override String get quickPortfolio => 'Work sample';
	@override String get quickPortfolioHint => 'Add one from a finished job';
	@override String get emptyRequests => 'No new requests';
	@override String get emptyRequestsHint => 'When the availability switch is on, requests land here.';
	@override String get quickCompany => 'Company';
	@override String get quickCompanyHint => 'Name and logo';
	@override String get quickRates => 'My service rates';
	@override String get quickRatesHint => 'Your work rates by trade';
	@override String get quickOrdersHeroTitle => 'New orders & Marketplace';
	@override String get quickOrdersHeroHint => 'See listings in your trade and send an offer';
	@override String get quickOpenOrders => 'Open orders';
	@override String get quickOpenOrdersHint => 'Listings without a master — send an offer';
	@override String get calcStep1 => 'Pick a frame';
	@override String get calcStep2 => 'Configure';
	@override String get calcStep3 => 'Drawing ready';
}

// Path: orders
class _TranslationsOrdersEn extends TranslationsOrdersUz {
	_TranslationsOrdersEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Orders';
	@override String get segmentNew => 'Open';
	@override String get segmentActive => 'In progress';
	@override String get segmentDone => 'Completed';
	@override String stepOf({required Object step, required Object total}) => 'Stage ${step} of ${total}';
	@override String lateDays({required Object days}) => '${days} days late';
	@override String get dueToday => 'Due today';
	@override String daysLeft({required Object days}) => '${days} days left';
	@override String get offerBtn => 'Make an offer';
	@override String get retry => 'Try again';
	@override String get loadFailed => 'Could not load orders';
	@override String get emptyNewTitle => 'No open orders';
	@override String get emptyNewMessage => 'As soon as a new listing appears in your area, it will show up here.';
	@override String get emptyActiveTitle => 'No active orders';
	@override String get emptyActiveMessage => 'Once you accept a new request, it will show up here.';
	@override String get emptyDoneTitle => 'No completed jobs';
	@override String get emptyDoneMessage => 'Your first delivered order will appear here.';
	@override late final _TranslationsOrdersStageEn stage = _TranslationsOrdersStageEn._(_root);
	@override late final _TranslationsOrdersDetailEn detail = _TranslationsOrdersDetailEn._(_root);
	@override late final _TranslationsOrdersRequestEn request = _TranslationsOrdersRequestEn._(_root);
	@override late final _TranslationsOrdersSpecEn spec = _TranslationsOrdersSpecEn._(_root);
	@override String get invalidId => 'Invalid order number.';
	@override String get invalidRequestId => 'Invalid request number.';
	@override late final _TranslationsOrdersOpenEn open = _TranslationsOrdersOpenEn._(_root);
	@override String get personalTitle => 'My orders';
}

// Path: ownOrders
class _TranslationsOwnOrdersEn extends TranslationsOwnOrdersUz {
	_TranslationsOwnOrdersEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get orderTitle => 'Order';
	@override String itemsCount({required Object count}) => '${count} windows';
	@override String get statusTitle => 'Order status';
	@override String get statusRow => 'Status';
	@override String get saving => 'Saving…';
	@override String get tapToChange => 'Tap to change';
	@override String get alreadyDone => 'This order is already completed.';
	@override String get cannotChange => 'This order’s status cannot be changed.';
	@override late final _TranslationsOwnOrdersStatusEn status = _TranslationsOwnOrdersStatusEn._(_root);
	@override late final _TranslationsOwnOrdersHintEn hint = _TranslationsOwnOrdersHintEn._(_root);
}

// Path: orderForm
class _TranslationsOrderFormEn extends TranslationsOrderFormUz {
	_TranslationsOrderFormEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get noProducts => 'The order has no items.';
	@override String get queued => 'No internet — the order is queued and will be sent automatically.';
	@override String get saved => 'Order saved';
	@override String get saveTitle => 'Save order';
	@override String get customer => 'Customer';
	@override String get nameLabel => 'Name';
	@override String get nameHint => 'Alex';
	@override String get nameRequired => 'Enter a name';
	@override String get addressHint => '9th block, Chilanzar';
	@override String get noteLabel => 'Extra note';
	@override String get noteHint => '2nd floor, no lift';
	@override String itemsSummary({required Object kinds, required Object count}) => '${kinds} window types · ${count} pcs';
}

// Path: chat
class _TranslationsChatEn extends TranslationsChatUz {
	_TranslationsChatEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get threadsTitle => 'Chats';
	@override String get conversation => 'Chat';
	@override String get messageHint => 'Write a message...';
	@override String get emptyChat => 'Agree on price and terms right here';
	@override String get emptyThreadsTitle => 'No chats yet';
	@override String get emptyThreadsMessage => 'When a craftsman replies to your order, you’ll chat here.';
}

// Path: notifications
class _TranslationsNotificationsEn extends TranslationsNotificationsUz {
	_TranslationsNotificationsEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Notifications';
	@override String get markAllRead => 'Mark all as read';
	@override String get empty => 'No notifications';
	@override String get open => 'Open';
}

// Path: masters
class _TranslationsMastersEn extends TranslationsMastersUz {
	_TranslationsMastersEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'About the craftsman';
	@override String get master => 'Craftsman';
	@override String get client => 'Client';
	@override String get write => 'Message';
	@override String get chooseThis => 'Choose this craftsman';
	@override String get choose => 'Choose';
	@override String get chosen => 'Chosen craftsman';
	@override String get notFound => 'No details found';
	@override String get works => 'Past work';
	@override String reviews({required Object count}) => 'Reviews (${count})';
	@override String get reviewsLabel => 'Reviews';
	@override String get noReviews => 'No reviews yet — you could be the first.';
	@override String experienceYears({required Object years}) => '${years} years of experience';
	@override String get rating => 'Rating';
	@override String get completed => 'Completed';
	@override String responses({required Object count}) => '${count} responses';
	@override String get estimate => 'Estimate';
}

// Path: orderFlow
class _TranslationsOrderFlowEn extends TranslationsOrderFlowUz {
	_TranslationsOrderFlowEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsOrderFlowStatusEn status = _TranslationsOrderFlowStatusEn._(_root);
	@override late final _TranslationsOrderFlowStageEn stage = _TranslationsOrderFlowStageEn._(_root);
	@override late final _TranslationsOrderFlowResponseEn response = _TranslationsOrderFlowResponseEn._(_root);
}

// Path: company
class _TranslationsCompanyEn extends TranslationsCompanyUz {
	_TranslationsCompanyEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Company';
	@override String get nameLabel => 'Company name';
	@override String get nameHint => 'For example: Ustachi Service';
	@override String get nameEmpty => 'Company name not set';
	@override String get nameNote => 'Shown on the order sheet';
	@override String get logoHint => 'Add a logo';
}

// Path: companyRates
class _TranslationsCompanyRatesEn extends TranslationsCompanyRatesUz {
	_TranslationsCompanyRatesEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get onlyDigits => 'Digits only';
}

// Path: materials
class _TranslationsMaterialsEn extends TranslationsMaterialsUz {
	_TranslationsMaterialsEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Materials';
	@override String get on => 'I work with this material — orders will arrive';
	@override String get off => 'Turned off — orders for this material will not arrive';
	@override String get allOff => 'At least one material must stay on';
}

// Path: professional
class _TranslationsProfessionalEn extends TranslationsProfessionalUz {
	_TranslationsProfessionalEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Professional details';
	@override String get headline => 'Tell clients what kind of craftsman you are';
	@override String get headlineHint => 'Clients see this before choosing you. You can change it at any time later.';
	@override String get specialty => 'Trades';
	@override String get specialtyPick => 'Choose your trades';
	@override String get specialtyLoadFailed => 'The specialty list did not load — check your connection and come back.';
	@override String get experienceQuestion => 'How many years of experience do you have?';
	@override String get experienceHint => 'For example: 5';
	@override String get experienceRequired => 'Enter your experience';
	@override String get experienceRange => 'Experience must be between 0 and 70';
	@override String get aboutLabel => 'About you (optional)';
	@override String get aboutHint => 'What jobs you take on and what you pay attention to — keep it short.';
	@override String get works => 'Your work';
	@override String get worksHint => 'Photos let clients see your work and make them more likely to pick you. Optional — you can add them later.';
	@override String get deleteSampleTitle => 'Delete this sample?';
	@override String get deleteSampleMessage => 'Clients will no longer see this photo.';
	@override String get deleteFailed => 'Could not delete';
	@override String get pickSpecialty => 'Choose at least one trade';
	@override String get specialtyHint => 'You can pick several — orders will come only for these trades.';
}

// Path: appUpdate
class _TranslationsAppUpdateEn extends TranslationsAppUpdateUz {
	_TranslationsAppUpdateEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get eyebrow => 'UPDATE';
	@override String get titleOptional => 'A new version is ready';
	@override String get titleRequired => 'Update required';
	@override String get bodyOptional => 'A new version of Ustachi Pro is out. Update to get the latest fixes and features.';
	@override String get bodyRequired => 'This version is no longer supported. Please update to keep using the app.';
	@override String get whatsNew => 'WHAT\'S NEW';
	@override String get versionFrom => 'Yours';
	@override String get versionTo => 'New';
	@override String get update => 'Update';
	@override String get later => 'Later';
	@override String get openFailed => 'Could not open the link. Please update from the store manually.';
}

// Path: onboarding.step1
class _TranslationsOnboardingStep1En extends TranslationsOnboardingStep1Uz {
	_TranslationsOnboardingStep1En._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Choose your trade';
	@override String get description => 'Windows, roofing, bricklaying, wiring, plumbing, tiling, painting… over 25 trades. You get the orders that match your profile.';
}

// Path: onboarding.step2
class _TranslationsOnboardingStep2En extends TranslationsOnboardingStep2Uz {
	_TranslationsOnboardingStep2En._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Jobs find you';
	@override String get description => 'New requests in your region and trade arrive as a notification right away — no searching needed.';
}

// Path: onboarding.step3
class _TranslationsOnboardingStep3En extends TranslationsOnboardingStep3Uz {
	_TranslationsOnboardingStep3En._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'You set the price';
	@override String get description => 'Enter your own rates, agree with the client in chat and mark each stage of the work.';
}

// Path: auth.common
class _TranslationsAuthCommonEn extends TranslationsAuthCommonUz {
	_TranslationsAuthCommonEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get invalidPhone => 'Enter a valid phone number';
	@override String get cancel => 'Cancel';
}

// Path: auth.phone
class _TranslationsAuthPhoneEn extends TranslationsAuthPhoneUz {
	_TranslationsAuthPhoneEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Sign in';
	@override String get subtitle => 'Enter your number — we’ll text you a 6-digit code. No password needed.';
	@override String get label => 'Phone number';
	@override String get continueBtn => 'Continue';
	@override String get orOption => 'or';
	@override String get telegramBtn => 'Log in via Telegram';
	@override String get telegramHint => 'The bot will ask for the phone number linked to your Telegram account to sign in. No SMS is sent.';
	@override String get telegramOpenError => 'Couldn\'t open the Telegram bot. Please try again.';
	@override String get agreementPrefix => 'By continuing you agree to the ';
	@override String get terms => 'Terms of use';
	@override String get and => ' and ';
	@override String get privacy => 'Privacy policy';
	@override String get agreementSuffix => '.';
	@override String get audienceRedirect => 'Looking for one? Download “Ustachi”';
	@override String get audienceTitle => 'Note: this app is for craftsmen';
}

// Path: auth.otp
class _TranslationsAuthOtpEn extends TranslationsAuthOtpUz {
	_TranslationsAuthOtpEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Enter the code';
	@override String sentMessage({required Object phone}) => 'Enter the 6-digit code sent to ${phone}';
	@override String get invalidCode => 'Enter all 6 digits';
	@override String get resend => 'Resend code';
	@override String get resendIn => 'Resend';
	@override String get confirmBtn => 'Confirm';
	@override String get changeNumber => 'Use another number';
}

// Path: auth.profile
class _TranslationsAuthProfileEn extends TranslationsAuthProfileUz {
	_TranslationsAuthProfileEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'About you';
	@override String get subtitle => 'Clients will see you under this name. You can change it later in your profile.';
	@override String get fullNameLabel => 'Full name';
	@override String get fullNameHint => 'Enter';
	@override String get requiredName => 'Enter your full name';
	@override String get addPhoto => 'Add photo';
	@override String get changePhoto => 'Change photo';
	@override String get saveBtn => 'Save and continue';
	@override String get skip => 'I’ll fill this in later';
	@override String get regionLabel => 'Region';
	@override String get regionHint => 'Select a region';
	@override String get districtLabel => 'District / city';
	@override String get districtHint => 'Select a district';
	@override String get addressLabel => 'Address';
	@override String get addressHint => 'Street, house number';
	@override String get requiredRegion => 'Select a region';
	@override String get requiredDistrict => 'Select a district';
	@override String get loadFailed => 'Could not load the list';
}

// Path: auth.telegram
class _TranslationsAuthTelegramEn extends TranslationsAuthTelegramUz {
	_TranslationsAuthTelegramEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get loadingTitle => 'Signing in via Telegram';
	@override String get loadingHint => 'Verifying one-time link…';
	@override String get invalidLink => 'This Telegram link is invalid.';
	@override String get expiredLink => 'The link has expired or was already used. Start again in the bot.';
	@override String get retry => 'Retry';
	@override String get restartBot => 'Restart in bot';
	@override String get smsOption => 'Sign in via SMS';
}

// Path: profile.personal
class _TranslationsProfilePersonalEn extends TranslationsProfilePersonalUz {
	_TranslationsProfilePersonalEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get sectionPersonal => 'Personal';
	@override String get sectionAddress => 'Address';
	@override String get sectionProfessional => 'Professional';
	@override String get phoneLabel => 'Phone';
	@override String get phoneNote => 'The number identifies the account and cannot be changed';
	@override String get joinedLabel => 'Joined';
	@override String get empty => 'Not set';
	@override String get edit => 'Edit';
	@override String get openProfessional => 'Specialty, experience and work samples';
	@override String get loadFailed => 'Could not load your details';
}

// Path: profile.help
class _TranslationsProfileHelpEn extends TranslationsProfileHelpUz {
	_TranslationsProfileHelpEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get subtitle => 'Have a question or a problem — write or call us';
	@override String get callLabel => 'Call';
	@override String get emailLabel => 'Email';
	@override String get telegramLabel => 'Our Telegram channel';
	@override String get telegramHint => 'News and announcements';
	@override String get workHours => 'Mon–Sat, 9:00–19:00';
	@override String get copied => 'Copied';
}

// Path: orders.stage
class _TranslationsOrdersStageEn extends TranslationsOrdersStageUz {
	_TranslationsOrdersStageEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get accepted => 'Offer accepted';
	@override String get measured => 'Measured';
	@override String get production => 'Production';
	@override String get installation => 'Installation';
	@override String get handover => 'Handover and payment';
}

// Path: orders.detail
class _TranslationsOrdersDetailEn extends TranslationsOrdersDetailUz {
	_TranslationsOrdersDetailEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get stages => 'Stages';
	@override String get spec => 'Specification';
	@override String get client => 'Client';
	@override String get total => 'Total';
	@override String get prepaid => 'Prepayment';
	@override String get remaining => 'Remaining';
	@override String get dueDate => 'Agreed deadline';
	@override String get finishOrder => 'Hand over and finish';
	@override String get completed => 'Order completed';
	@override String stageDone({required Object stage}) => '${stage} completed';
	@override String get notFound => 'Order not found';
	@override String get drawings => 'Drawings';
	@override String get drawingsHint => 'Pinch to zoom · dimensions in mm';
	@override String get markMeasured => 'Measurement taken';
	@override String get markProduction => 'Production started';
	@override String get markInstallation => 'Out for installation';
	@override String get stageSaved => 'Marked — the client has been notified';
}

// Path: orders.request
class _TranslationsOrdersRequestEn extends TranslationsOrdersRequestUz {
	_TranslationsOrdersRequestEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Request';
	@override String get clientSpec => 'Specification calculated by the client';
	@override String get priceOffer => 'Price offer';
	@override String get serviceFee => 'Installation and delivery';
	@override String get yourOffer => 'Your offer';
	@override String get workDays => 'Deadline — working days';
	@override String get note => 'Note (optional)';
	@override String get notePlaceholder => 'Extra note for the client…';
	@override String get send => 'Send offer';
	@override String get decline => 'Decline';
	@override String get declineTitle => 'Decline this request?';
	@override String get declineMessage => 'The request will disappear from your list for good.';
	@override String expiresIn({required Object time}) => '${time} left';
	@override String get expired => 'Expired';
	@override String distance({required Object km}) => '${km} km';
	@override String get sent => 'Offer sent';
	@override String get invalidFee => 'Your fee cannot be negative';
	@override String get chatNote => 'You agree on price and terms with the client in chat.';
	@override String get withdrawOffer => 'Withdraw offer';
	@override String get declineInviteTitle => 'Decline the invite?';
	@override String get declineInviteMessage => 'The client is notified right away and can pick another master.';
	@override String get clientPrice => 'Order price';
	@override String get priceInChat => 'Price is agreed in chat';
}

// Path: orders.spec
class _TranslationsOrdersSpecEn extends TranslationsOrdersSpecUz {
	_TranslationsOrdersSpecEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get size => 'Size (mm)';
	@override String get shape => 'Shape';
	@override String get brand => 'Brand';
	@override String get color => 'Color';
	@override String get material => 'Material';
	@override String get glass => 'Glass';
	@override String get sill => 'Sill (cm)';
	@override String get flower => 'Grille';
	@override String get address => 'Address';
	@override String get product => 'Items';
	@override String get phone => 'Phone';
	@override String get discount => 'Discount';
	@override String get note => 'Note';
	@override String itemsValue({required Object kinds, required Object count}) => '${kinds} kinds · ${count} pcs';
	@override late final _TranslationsOrdersSpecValuesEn values = _TranslationsOrdersSpecValuesEn._(_root);
	@override String get area => 'Area';
	@override String get unitPrice => 'Price per m²';
	@override String get variant => 'Grade';
}

// Path: orders.open
class _TranslationsOrdersOpenEn extends TranslationsOrdersOpenUz {
	_TranslationsOrdersOpenEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get offerSent => 'Offer sent';
	@override String get waitingClient => 'Waiting for the client\'s reply';
	@override String offersCount({required Object count}) => '${count} offers';
	@override String get beFirst => 'Be the first';
	@override String get newBadge => 'New';
	@override String get pageTitle => 'Open orders';
	@override String get tabWaiting => 'Awaiting reply';
	@override String get tabSent => 'Offer sent';
	@override String get emptySentTitle => 'No offers sent';
	@override String get emptySentMessage => 'Listings you responded to wait here for the client\'s reply.';
	@override String get tabInvited => 'Invited';
	@override String get invitedBadge => 'Invited to you';
	@override String get repairBadge => 'Repair';
	@override String get acceptInvite => 'Accept';
	@override String get emptyInvitedTitle => 'No personal invites';
	@override String get emptyInvitedMessage => 'Orders where the client picked you will show up here.';
	@override String get invitedNote => 'The client sent this order to you specifically — other masters can\'t see it.';
}

// Path: ownOrders.status
class _TranslationsOwnOrdersStatusEn extends TranslationsOwnOrdersStatusUz {
	_TranslationsOwnOrdersStatusEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get draft => 'Draft';
	@override String get newOrder => 'New';
	@override String get inProgress => 'In progress';
	@override String get done => 'Completed';
	@override String get debt => 'Unpaid balance';
	@override String get cancelled => 'Cancelled';
}

// Path: ownOrders.hint
class _TranslationsOwnOrdersHintEn extends TranslationsOwnOrdersHintUz {
	_TranslationsOwnOrdersHintEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get newOrder => 'Accepted, not started yet';
	@override String get inProgress => 'Production or installation is underway';
	@override String get done => 'Handed over and fully settled';
	@override String get debt => 'Work is done but payment is incomplete';
	@override String get cancelled => 'The order was cancelled';
}

// Path: orderFlow.status
class _TranslationsOrderFlowStatusEn extends TranslationsOrderFlowStatusUz {
	_TranslationsOrderFlowStatusEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get published => 'Published';
	@override String get assigned => 'Craftsman chosen';
	@override String get completed => 'Completed';
	@override String get cancelled => 'Cancelled';
	@override String get expired => 'Expired';
}

// Path: orderFlow.stage
class _TranslationsOrderFlowStageEn extends TranslationsOrderFlowStageUz {
	_TranslationsOrderFlowStageEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get accepted => 'Accepted';
	@override String get measured => 'Measured';
	@override String get production => 'Production';
	@override String get installation => 'Installation';
	@override String get handover => 'Handed over';
}

// Path: orderFlow.response
class _TranslationsOrderFlowResponseEn extends TranslationsOrderFlowResponseUz {
	_TranslationsOrderFlowResponseEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get interested => 'Interested';
	@override String get withdrawn => 'Withdrawn';
	@override String get chosen => 'Chosen';
	@override String get rejected => 'Not chosen';
}

// Path: orders.spec.values
class _TranslationsOrdersSpecValuesEn extends TranslationsOrdersSpecValuesUz {
	_TranslationsOrdersSpecValuesEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get plastic => 'Plastic';
	@override String get aluminium => 'Aluminium';
	@override String get termo => 'Thermo';
	@override String get doubleGlass => 'Double glazing';
	@override String get singleGlass => 'Single glazing';
	@override String get large => 'Large';
	@override String get medium => 'Medium';
	@override String get small => 'Small';
}

/// The flat map containing all translations for locale <en>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on TranslationsEn {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'applicationName' => 'Ustachi',
			'common.ok' => 'OK',
			'common.start' => 'Start',
			'common.cancel' => 'Cancel',
			'common.save' => 'Save',
			'common.delete' => 'Delete',
			'common.edit' => 'Edit',
			'common.close' => 'Close',
			'common.back' => 'Back',
			'common.next' => 'Next',
			'common.skip' => 'Skip',
			'common.enter' => 'Enter',
			'common.wentWrong' => 'Something went wrong. Please try again in a moment!',
			'common.common' => 'General',
			'common.select' => 'Select',
			'common.retry' => 'Try again',
			'common.refresh' => 'Refresh',
			'common.saved' => 'Saved',
			'common.saveFailed' => 'Not saved — please try again',
			'common.notFound' => 'Not found',
			'common.empty' => 'Empty',
			'common.loading' => 'Loading…',
			'common.yes' => 'Yes',
			'common.no' => 'No',
			'common.add' => 'Add',
			'common.copy' => 'Duplicate',
			'common.apply' => 'Apply',
			'common.reset' => 'Reset',
			'common.done' => 'Done',
			'common.all' => 'All',
			'common.som' => 'soum',
			'common.cm' => 'cm',
			'common.mm' => 'mm',
			'common.pcs' => 'pcs',
			'common.hoursShort' => 'h',
			'common.minutesShort' => 'min',
			'common.months.0' => 'January',
			'common.months.1' => 'February',
			'common.months.2' => 'March',
			'common.months.3' => 'April',
			'common.months.4' => 'May',
			'common.months.5' => 'June',
			'common.months.6' => 'July',
			'common.months.7' => 'August',
			'common.months.8' => 'September',
			'common.months.9' => 'October',
			'common.months.10' => 'November',
			'common.months.11' => 'December',
			'common.weekdays.0' => 'Sunday',
			'common.weekdays.1' => 'Monday',
			'common.weekdays.2' => 'Tuesday',
			'common.weekdays.3' => 'Wednesday',
			'common.weekdays.4' => 'Thursday',
			'common.weekdays.5' => 'Friday',
			'common.weekdays.6' => 'Saturday',
			'common.today' => 'Today',
			'common.tomorrow' => 'Tomorrow',
			'common.comingSoon' => 'Coming soon',
			'onboarding.step1.title' => 'Choose your trade',
			'onboarding.step1.description' => 'Windows, roofing, bricklaying, wiring, plumbing, tiling, painting… over 25 trades. You get the orders that match your profile.',
			'onboarding.step2.title' => 'Jobs find you',
			'onboarding.step2.description' => 'New requests in your region and trade arrive as a notification right away — no searching needed.',
			'onboarding.step3.title' => 'You set the price',
			'onboarding.step3.description' => 'Enter your own rates, agree with the client in chat and mark each stage of the work.',
			'auth.tagline' => 'THE CRAFTSMAN’S WORKSPACE',
			'auth.common.invalidPhone' => 'Enter a valid phone number',
			'auth.common.cancel' => 'Cancel',
			'auth.phone.title' => 'Sign in',
			'auth.phone.subtitle' => 'Enter your number — we’ll text you a 6-digit code. No password needed.',
			'auth.phone.label' => 'Phone number',
			'auth.phone.continueBtn' => 'Continue',
			'auth.phone.orOption' => 'or',
			'auth.phone.telegramBtn' => 'Log in via Telegram',
			'auth.phone.telegramHint' => 'The bot will ask for the phone number linked to your Telegram account to sign in. No SMS is sent.',
			'auth.phone.telegramOpenError' => 'Couldn\'t open the Telegram bot. Please try again.',
			'auth.phone.agreementPrefix' => 'By continuing you agree to the ',
			'auth.phone.terms' => 'Terms of use',
			'auth.phone.and' => ' and ',
			'auth.phone.privacy' => 'Privacy policy',
			'auth.phone.agreementSuffix' => '.',
			'auth.phone.audienceRedirect' => 'Looking for one? Download “Ustachi”',
			'auth.phone.audienceTitle' => 'Note: this app is for craftsmen',
			'auth.otp.title' => 'Enter the code',
			'auth.otp.sentMessage' => ({required Object phone}) => 'Enter the 6-digit code sent to ${phone}',
			'auth.otp.invalidCode' => 'Enter all 6 digits',
			'auth.otp.resend' => 'Resend code',
			'auth.otp.resendIn' => 'Resend',
			'auth.otp.confirmBtn' => 'Confirm',
			'auth.otp.changeNumber' => 'Use another number',
			'auth.profile.title' => 'About you',
			'auth.profile.subtitle' => 'Clients will see you under this name. You can change it later in your profile.',
			'auth.profile.fullNameLabel' => 'Full name',
			'auth.profile.fullNameHint' => 'Enter',
			'auth.profile.requiredName' => 'Enter your full name',
			'auth.profile.addPhoto' => 'Add photo',
			'auth.profile.changePhoto' => 'Change photo',
			'auth.profile.saveBtn' => 'Save and continue',
			'auth.profile.skip' => 'I’ll fill this in later',
			'auth.profile.regionLabel' => 'Region',
			'auth.profile.regionHint' => 'Select a region',
			'auth.profile.districtLabel' => 'District / city',
			'auth.profile.districtHint' => 'Select a district',
			'auth.profile.addressLabel' => 'Address',
			'auth.profile.addressHint' => 'Street, house number',
			'auth.profile.requiredRegion' => 'Select a region',
			'auth.profile.requiredDistrict' => 'Select a district',
			'auth.profile.loadFailed' => 'Could not load the list',
			'auth.telegram.loadingTitle' => 'Signing in via Telegram',
			'auth.telegram.loadingHint' => 'Verifying one-time link…',
			'auth.telegram.invalidLink' => 'This Telegram link is invalid.',
			'auth.telegram.expiredLink' => 'The link has expired or was already used. Start again in the bot.',
			'auth.telegram.retry' => 'Retry',
			'auth.telegram.restartBot' => 'Restart in bot',
			'auth.telegram.smsOption' => 'Sign in via SMS',
			'country.title' => 'Choose your country',
			'country.subtitle' => 'The app language follows your country. You can change it later in your profile.',
			'country.continueBtn' => 'Continue',
			'country.changeTitle' => 'Country and language',
			'home.main' => 'Home',
			'home.chatting' => 'Chat',
			'home.profile' => 'Profile',
			'home.title' => 'Profile',
			'home.loadError' => 'Profile did not load',
			'home.retry' => 'Try again',
			'home.phone' => 'Phone',
			'home.role' => 'Role',
			'home.status' => 'Status',
			'home.active' => 'Active',
			'home.inactive' => 'Inactive',
			'home.logout' => 'Log out',
			'home.hi' => 'Hi',
			'home.serviceType' => 'Service types',
			'home.lastOrders' => 'Recent orders',
			'home.all' => 'All',
			'home.tapRepair' => 'Faucet repair',
			'home.chandelierInstallation' => 'Chandelier installation',
			'home.completed' => 'Completed',
			'home.inProgress' => 'In progress',
			'home.window' => 'Windows',
			'home.furtiniture' => 'Furniture',
			'home.electric' => 'Electrics',
			'home.plumber' => 'Plumbing',
			'calculatePage.window' => 'Window',
			'calculatePage.door' => 'Door',
			'calculatePage.glass' => 'Arches',
			'calculatePage.windowConfigurator' => 'Window configuration',
			'calculatePage.windowLayouts' => 'Layout types',
			'calculatePage.windowPremiumLayouts' => 'Premium options',
			'calculatePage.windowModernLayouts' => 'Modern options',
			'calculatePage.doorConfigurator' => 'Door configuration',
			'calculatePage.doorModels' => 'Door models',
			'calculatePage.doorExtraModels' => 'Additional models',
			'calculatePage.material' => 'Material',
			'calculatePage.plastic' => 'Plastic',
			'calculatePage.aluminium' => 'Aluminium',
			'calculatePage.termo' => 'Thermo',
			'calculatePage.glassShowcase' => 'Arch options',
			'calculatePage.customTemplateTitleWindow' => 'Create your own window',
			'calculatePage.customTemplateTitleDoor' => 'Create your own door',
			'calculatePage.customTemplateTitleArch' => 'Create your own arch',
			'calculatePage.customTemplateSubtitle' => 'Not a ready template — you draw the size and layout yourself',
			'calculatePage.customTemplateAction' => 'Start',
			'calculatePage.readyTemplates' => 'Ready templates',
			'profile.personalData' => 'Personal details',
			'profile.professional' => 'Professional details',
			'profile.company' => 'Company',
			'profile.myOrders' => 'My orders',
			'profile.settings' => 'Settings',
			'profile.support' => 'Contact us',
			'profile.logout' => 'Log out',
			'profile.logoutTitle' => 'Log out of your account?',
			'profile.logoutMessage' => 'Downloaded prices and calculation data will be removed from this device. They will be downloaded again next time you sign in.',
			'profile.logoutConfirm' => 'Yes, log out',
			'profile.loggingOut' => 'Logging out...',
			'profile.loggingOutHint' => 'Closing the session and clearing the price cache',
			'profile.logoutFailed' => 'Could not sign out on the server, but local data was cleared',
			'profile.personal.sectionPersonal' => 'Personal',
			'profile.personal.sectionAddress' => 'Address',
			'profile.personal.sectionProfessional' => 'Professional',
			'profile.personal.phoneLabel' => 'Phone',
			'profile.personal.phoneNote' => 'The number identifies the account and cannot be changed',
			'profile.personal.joinedLabel' => 'Joined',
			'profile.personal.empty' => 'Not set',
			'profile.personal.edit' => 'Edit',
			'profile.personal.openProfessional' => 'Specialty, experience and work samples',
			'profile.personal.loadFailed' => 'Could not load your details',
			'profile.help.subtitle' => 'Have a question or a problem — write or call us',
			'profile.help.callLabel' => 'Call',
			'profile.help.emailLabel' => 'Email',
			'profile.help.telegramLabel' => 'Our Telegram channel',
			'profile.help.telegramHint' => 'News and announcements',
			'profile.help.workHours' => 'Mon–Sat, 9:00–19:00',
			'profile.help.copied' => 'Copied',
			'dashboard.title' => 'Dashboard',
			'dashboard.greetingMorning' => 'Good morning,',
			'dashboard.greetingDay' => 'Good afternoon,',
			'dashboard.greetingEvening' => 'Good evening,',
			'dashboard.master' => 'craftsman',
			'dashboard.availableTitle' => 'Accepting orders',
			'dashboard.availableOn' => 'New requests will keep coming',
			'dashboard.availableOff' => 'Requests are paused',
			'dashboard.repairTitle' => 'I take repair jobs',
			'dashboard.repairOn' => 'Repair requests will also arrive',
			'dashboard.repairOff' => 'Repair requests will not arrive',
			'dashboard.repairHint' => 'Adjusting old windows/doors, fittings or glass replacement',
			'dashboard.newRequests' => 'New requests',
			'dashboard.activeOrders' => 'Active orders',
			'dashboard.all' => 'All',
			'dashboard.quickCalculate' => 'Frame drawing',
			'dashboard.quickCalculateHint' => 'Window and door drawings',
			'dashboard.quickPortfolio' => 'Work sample',
			'dashboard.quickPortfolioHint' => 'Add one from a finished job',
			'dashboard.emptyRequests' => 'No new requests',
			'dashboard.emptyRequestsHint' => 'When the availability switch is on, requests land here.',
			'dashboard.quickCompany' => 'Company',
			'dashboard.quickCompanyHint' => 'Name and logo',
			'dashboard.quickRates' => 'My service rates',
			'dashboard.quickRatesHint' => 'Your work rates by trade',
			'dashboard.quickOrdersHeroTitle' => 'New orders & Marketplace',
			'dashboard.quickOrdersHeroHint' => 'See listings in your trade and send an offer',
			'dashboard.quickOpenOrders' => 'Open orders',
			'dashboard.quickOpenOrdersHint' => 'Listings without a master — send an offer',
			'dashboard.calcStep1' => 'Pick a frame',
			'dashboard.calcStep2' => 'Configure',
			'dashboard.calcStep3' => 'Drawing ready',
			'orders.title' => 'Orders',
			'orders.segmentNew' => 'Open',
			'orders.segmentActive' => 'In progress',
			'orders.segmentDone' => 'Completed',
			'orders.stepOf' => ({required Object step, required Object total}) => 'Stage ${step} of ${total}',
			'orders.lateDays' => ({required Object days}) => '${days} days late',
			'orders.dueToday' => 'Due today',
			'orders.daysLeft' => ({required Object days}) => '${days} days left',
			'orders.offerBtn' => 'Make an offer',
			'orders.retry' => 'Try again',
			'orders.loadFailed' => 'Could not load orders',
			'orders.emptyNewTitle' => 'No open orders',
			'orders.emptyNewMessage' => 'As soon as a new listing appears in your area, it will show up here.',
			'orders.emptyActiveTitle' => 'No active orders',
			'orders.emptyActiveMessage' => 'Once you accept a new request, it will show up here.',
			'orders.emptyDoneTitle' => 'No completed jobs',
			'orders.emptyDoneMessage' => 'Your first delivered order will appear here.',
			'orders.stage.accepted' => 'Offer accepted',
			'orders.stage.measured' => 'Measured',
			'orders.stage.production' => 'Production',
			'orders.stage.installation' => 'Installation',
			'orders.stage.handover' => 'Handover and payment',
			'orders.detail.stages' => 'Stages',
			'orders.detail.spec' => 'Specification',
			'orders.detail.client' => 'Client',
			'orders.detail.total' => 'Total',
			'orders.detail.prepaid' => 'Prepayment',
			'orders.detail.remaining' => 'Remaining',
			'orders.detail.dueDate' => 'Agreed deadline',
			'orders.detail.finishOrder' => 'Hand over and finish',
			'orders.detail.completed' => 'Order completed',
			'orders.detail.stageDone' => ({required Object stage}) => '${stage} completed',
			'orders.detail.notFound' => 'Order not found',
			'orders.detail.drawings' => 'Drawings',
			'orders.detail.drawingsHint' => 'Pinch to zoom · dimensions in mm',
			'orders.detail.markMeasured' => 'Measurement taken',
			'orders.detail.markProduction' => 'Production started',
			'orders.detail.markInstallation' => 'Out for installation',
			'orders.detail.stageSaved' => 'Marked — the client has been notified',
			'orders.request.title' => 'Request',
			'orders.request.clientSpec' => 'Specification calculated by the client',
			'orders.request.priceOffer' => 'Price offer',
			'orders.request.serviceFee' => 'Installation and delivery',
			'orders.request.yourOffer' => 'Your offer',
			'orders.request.workDays' => 'Deadline — working days',
			'orders.request.note' => 'Note (optional)',
			'orders.request.notePlaceholder' => 'Extra note for the client…',
			'orders.request.send' => 'Send offer',
			'orders.request.decline' => 'Decline',
			'orders.request.declineTitle' => 'Decline this request?',
			'orders.request.declineMessage' => 'The request will disappear from your list for good.',
			'orders.request.expiresIn' => ({required Object time}) => '${time} left',
			'orders.request.expired' => 'Expired',
			'orders.request.distance' => ({required Object km}) => '${km} km',
			'orders.request.sent' => 'Offer sent',
			'orders.request.invalidFee' => 'Your fee cannot be negative',
			'orders.request.chatNote' => 'You agree on price and terms with the client in chat.',
			'orders.request.withdrawOffer' => 'Withdraw offer',
			'orders.request.declineInviteTitle' => 'Decline the invite?',
			'orders.request.declineInviteMessage' => 'The client is notified right away and can pick another master.',
			'orders.request.clientPrice' => 'Order price',
			'orders.request.priceInChat' => 'Price is agreed in chat',
			'orders.spec.size' => 'Size (mm)',
			'orders.spec.shape' => 'Shape',
			'orders.spec.brand' => 'Brand',
			'orders.spec.color' => 'Color',
			'orders.spec.material' => 'Material',
			'orders.spec.glass' => 'Glass',
			'orders.spec.sill' => 'Sill (cm)',
			'orders.spec.flower' => 'Grille',
			'orders.spec.address' => 'Address',
			'orders.spec.product' => 'Items',
			'orders.spec.phone' => 'Phone',
			'orders.spec.discount' => 'Discount',
			'orders.spec.note' => 'Note',
			'orders.spec.itemsValue' => ({required Object kinds, required Object count}) => '${kinds} kinds · ${count} pcs',
			'orders.spec.values.plastic' => 'Plastic',
			'orders.spec.values.aluminium' => 'Aluminium',
			'orders.spec.values.termo' => 'Thermo',
			'orders.spec.values.doubleGlass' => 'Double glazing',
			'orders.spec.values.singleGlass' => 'Single glazing',
			'orders.spec.values.large' => 'Large',
			'orders.spec.values.medium' => 'Medium',
			'orders.spec.values.small' => 'Small',
			'orders.spec.area' => 'Area',
			'orders.spec.unitPrice' => 'Price per m²',
			'orders.spec.variant' => 'Grade',
			'orders.invalidId' => 'Invalid order number.',
			'orders.invalidRequestId' => 'Invalid request number.',
			'orders.open.offerSent' => 'Offer sent',
			'orders.open.waitingClient' => 'Waiting for the client\'s reply',
			'orders.open.offersCount' => ({required Object count}) => '${count} offers',
			'orders.open.beFirst' => 'Be the first',
			'orders.open.newBadge' => 'New',
			'orders.open.pageTitle' => 'Open orders',
			'orders.open.tabWaiting' => 'Awaiting reply',
			'orders.open.tabSent' => 'Offer sent',
			'orders.open.emptySentTitle' => 'No offers sent',
			'orders.open.emptySentMessage' => 'Listings you responded to wait here for the client\'s reply.',
			'orders.open.tabInvited' => 'Invited',
			'orders.open.invitedBadge' => 'Invited to you',
			'orders.open.repairBadge' => 'Repair',
			'orders.open.acceptInvite' => 'Accept',
			'orders.open.emptyInvitedTitle' => 'No personal invites',
			'orders.open.emptyInvitedMessage' => 'Orders where the client picked you will show up here.',
			'orders.open.invitedNote' => 'The client sent this order to you specifically — other masters can\'t see it.',
			'orders.personalTitle' => 'My orders',
			'ownOrders.orderTitle' => 'Order',
			'ownOrders.itemsCount' => ({required Object count}) => '${count} windows',
			'ownOrders.statusTitle' => 'Order status',
			'ownOrders.statusRow' => 'Status',
			'ownOrders.saving' => 'Saving…',
			'ownOrders.tapToChange' => 'Tap to change',
			'ownOrders.alreadyDone' => 'This order is already completed.',
			'ownOrders.cannotChange' => 'This order’s status cannot be changed.',
			'ownOrders.status.draft' => 'Draft',
			'ownOrders.status.newOrder' => 'New',
			'ownOrders.status.inProgress' => 'In progress',
			'ownOrders.status.done' => 'Completed',
			'ownOrders.status.debt' => 'Unpaid balance',
			'ownOrders.status.cancelled' => 'Cancelled',
			'ownOrders.hint.newOrder' => 'Accepted, not started yet',
			'ownOrders.hint.inProgress' => 'Production or installation is underway',
			'ownOrders.hint.done' => 'Handed over and fully settled',
			'ownOrders.hint.debt' => 'Work is done but payment is incomplete',
			'ownOrders.hint.cancelled' => 'The order was cancelled',
			'orderForm.noProducts' => 'The order has no items.',
			'orderForm.queued' => 'No internet — the order is queued and will be sent automatically.',
			'orderForm.saved' => 'Order saved',
			'orderForm.saveTitle' => 'Save order',
			'orderForm.customer' => 'Customer',
			'orderForm.nameLabel' => 'Name',
			'orderForm.nameHint' => 'Alex',
			'orderForm.nameRequired' => 'Enter a name',
			'orderForm.addressHint' => '9th block, Chilanzar',
			'orderForm.noteLabel' => 'Extra note',
			'orderForm.noteHint' => '2nd floor, no lift',
			'orderForm.itemsSummary' => ({required Object kinds, required Object count}) => '${kinds} window types · ${count} pcs',
			'chat.threadsTitle' => 'Chats',
			'chat.conversation' => 'Chat',
			'chat.messageHint' => 'Write a message...',
			'chat.emptyChat' => 'Agree on price and terms right here',
			'chat.emptyThreadsTitle' => 'No chats yet',
			'chat.emptyThreadsMessage' => 'When a craftsman replies to your order, you’ll chat here.',
			'notifications.title' => 'Notifications',
			'notifications.markAllRead' => 'Mark all as read',
			'notifications.empty' => 'No notifications',
			'notifications.open' => 'Open',
			'masters.title' => 'About the craftsman',
			'masters.master' => 'Craftsman',
			'masters.client' => 'Client',
			'masters.write' => 'Message',
			'masters.chooseThis' => 'Choose this craftsman',
			'masters.choose' => 'Choose',
			'masters.chosen' => 'Chosen craftsman',
			'masters.notFound' => 'No details found',
			'masters.works' => 'Past work',
			'masters.reviews' => ({required Object count}) => 'Reviews (${count})',
			'masters.reviewsLabel' => 'Reviews',
			'masters.noReviews' => 'No reviews yet — you could be the first.',
			'masters.experienceYears' => ({required Object years}) => '${years} years of experience',
			'masters.rating' => 'Rating',
			'masters.completed' => 'Completed',
			'masters.responses' => ({required Object count}) => '${count} responses',
			'masters.estimate' => 'Estimate',
			'orderFlow.status.published' => 'Published',
			'orderFlow.status.assigned' => 'Craftsman chosen',
			'orderFlow.status.completed' => 'Completed',
			'orderFlow.status.cancelled' => 'Cancelled',
			'orderFlow.status.expired' => 'Expired',
			'orderFlow.stage.accepted' => 'Accepted',
			'orderFlow.stage.measured' => 'Measured',
			'orderFlow.stage.production' => 'Production',
			'orderFlow.stage.installation' => 'Installation',
			'orderFlow.stage.handover' => 'Handed over',
			'orderFlow.response.interested' => 'Interested',
			'orderFlow.response.withdrawn' => 'Withdrawn',
			'orderFlow.response.chosen' => 'Chosen',
			'orderFlow.response.rejected' => 'Not chosen',
			'company.title' => 'Company',
			'company.nameLabel' => 'Company name',
			'company.nameHint' => 'For example: Ustachi Service',
			'company.nameEmpty' => 'Company name not set',
			'company.nameNote' => 'Shown on the order sheet',
			'company.logoHint' => 'Add a logo',
			'companyRates.onlyDigits' => 'Digits only',
			'materials.title' => 'Materials',
			'materials.on' => 'I work with this material — orders will arrive',
			'materials.off' => 'Turned off — orders for this material will not arrive',
			'materials.allOff' => 'At least one material must stay on',
			'professional.title' => 'Professional details',
			'professional.headline' => 'Tell clients what kind of craftsman you are',
			'professional.headlineHint' => 'Clients see this before choosing you. You can change it at any time later.',
			'professional.specialty' => 'Trades',
			'professional.specialtyPick' => 'Choose your trades',
			'professional.specialtyLoadFailed' => 'The specialty list did not load — check your connection and come back.',
			'professional.experienceQuestion' => 'How many years of experience do you have?',
			'professional.experienceHint' => 'For example: 5',
			'professional.experienceRequired' => 'Enter your experience',
			'professional.experienceRange' => 'Experience must be between 0 and 70',
			'professional.aboutLabel' => 'About you (optional)',
			'professional.aboutHint' => 'What jobs you take on and what you pay attention to — keep it short.',
			'professional.works' => 'Your work',
			'professional.worksHint' => 'Photos let clients see your work and make them more likely to pick you. Optional — you can add them later.',
			'professional.deleteSampleTitle' => 'Delete this sample?',
			'professional.deleteSampleMessage' => 'Clients will no longer see this photo.',
			'professional.deleteFailed' => 'Could not delete',
			'professional.pickSpecialty' => 'Choose at least one trade',
			'professional.specialtyHint' => 'You can pick several — orders will come only for these trades.',
			'appUpdate.eyebrow' => 'UPDATE',
			'appUpdate.titleOptional' => 'A new version is ready',
			'appUpdate.titleRequired' => 'Update required',
			'appUpdate.bodyOptional' => 'A new version of Ustachi Pro is out. Update to get the latest fixes and features.',
			'appUpdate.bodyRequired' => 'This version is no longer supported. Please update to keep using the app.',
			'appUpdate.whatsNew' => 'WHAT\'S NEW',
			'appUpdate.versionFrom' => 'Yours',
			'appUpdate.versionTo' => 'New',
			'appUpdate.update' => 'Update',
			'appUpdate.later' => 'Later',
			'appUpdate.openFailed' => 'Could not open the link. Please update from the store manually.',
			_ => null,
		};
	}
}
