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
class TranslationsRu extends Translations with BaseTranslations<AppLocale, Translations> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	TranslationsRu({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.ru,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		super.$meta.setFlatMapFunction($meta.getTranslation); // copy base translations to super.$meta
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <ru>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	@override dynamic operator[](String key) => $meta.getTranslation(key) ?? super.$meta.getTranslation(key);

	late final TranslationsRu _root = this; // ignore: unused_field

	@override 
	TranslationsRu $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => TranslationsRu(meta: meta ?? this.$meta);

	// Translations
	@override String get applicationName => 'Ustachi';
	@override late final _TranslationsCommonRu common = _TranslationsCommonRu._(_root);
	@override late final _TranslationsOnboardingRu onboarding = _TranslationsOnboardingRu._(_root);
	@override late final _TranslationsAuthRu auth = _TranslationsAuthRu._(_root);
	@override late final _TranslationsCountryRu country = _TranslationsCountryRu._(_root);
	@override late final _TranslationsHomeRu home = _TranslationsHomeRu._(_root);
	@override late final _TranslationsCalculatePageRu calculatePage = _TranslationsCalculatePageRu._(_root);
	@override late final _TranslationsProfileRu profile = _TranslationsProfileRu._(_root);
	@override late final _TranslationsDashboardRu dashboard = _TranslationsDashboardRu._(_root);
	@override late final _TranslationsOrdersRu orders = _TranslationsOrdersRu._(_root);
	@override late final _TranslationsOwnOrdersRu ownOrders = _TranslationsOwnOrdersRu._(_root);
	@override late final _TranslationsOrderFormRu orderForm = _TranslationsOrderFormRu._(_root);
	@override late final _TranslationsChatRu chat = _TranslationsChatRu._(_root);
	@override late final _TranslationsNotificationsRu notifications = _TranslationsNotificationsRu._(_root);
	@override late final _TranslationsMastersRu masters = _TranslationsMastersRu._(_root);
	@override late final _TranslationsOrderFlowRu orderFlow = _TranslationsOrderFlowRu._(_root);
	@override late final _TranslationsCompanyRu company = _TranslationsCompanyRu._(_root);
	@override late final _TranslationsCompanyRatesRu companyRates = _TranslationsCompanyRatesRu._(_root);
	@override late final _TranslationsMaterialsRu materials = _TranslationsMaterialsRu._(_root);
	@override late final _TranslationsProfessionalRu professional = _TranslationsProfessionalRu._(_root);
	@override late final _TranslationsAppUpdateRu appUpdate = _TranslationsAppUpdateRu._(_root);
}

// Path: common
class _TranslationsCommonRu extends TranslationsCommonUz {
	_TranslationsCommonRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get ok => 'OK';
	@override String get start => 'Начать';
	@override String get cancel => 'Отмена';
	@override String get save => 'Сохранить';
	@override String get delete => 'Удалить';
	@override String get edit => 'Изменить';
	@override String get close => 'Закрыть';
	@override String get back => 'Назад';
	@override String get next => 'Далее';
	@override String get skip => 'Пропустить';
	@override String get enter => 'Введите';
	@override String get wentWrong => 'Произошла ошибка. Попробуйте ещё раз чуть позже!';
	@override String get common => 'Основное';
	@override String get select => 'Выбрать';
	@override String get retry => 'Повторить';
	@override String get refresh => 'Обновить';
	@override String get saved => 'Сохранено';
	@override String get saveFailed => 'Не сохранилось — попробуйте ещё раз';
	@override String get notFound => 'Не найдено';
	@override String get empty => 'Пусто';
	@override String get loading => 'Загрузка…';
	@override String get yes => 'Да';
	@override String get no => 'Нет';
	@override String get add => 'Добавить';
	@override String get copy => 'Копировать';
	@override String get apply => 'Применить';
	@override String get reset => 'Сбросить';
	@override String get done => 'Готово';
	@override String get all => 'Все';
	@override String get som => 'сум';
	@override String get cm => 'см';
	@override String get mm => 'мм';
	@override String get pcs => 'шт';
	@override String get hoursShort => 'ч';
	@override String get minutesShort => 'мин';
	@override List<String> get months => [
		'января',
		'февраля',
		'марта',
		'апреля',
		'мая',
		'июня',
		'июля',
		'августа',
		'сентября',
		'октября',
		'ноября',
		'декабря',
	];
	@override List<String> get weekdays => [
		'Воскресенье',
		'Понедельник',
		'Вторник',
		'Среда',
		'Четверг',
		'Пятница',
		'Суббота',
	];
	@override String get today => 'Сегодня';
	@override String get tomorrow => 'Завтра';
	@override String get comingSoon => 'Скоро';
}

// Path: onboarding
class _TranslationsOnboardingRu extends TranslationsOnboardingUz {
	_TranslationsOnboardingRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsOnboardingStep1Ru step1 = _TranslationsOnboardingStep1Ru._(_root);
	@override late final _TranslationsOnboardingStep2Ru step2 = _TranslationsOnboardingStep2Ru._(_root);
	@override late final _TranslationsOnboardingStep3Ru step3 = _TranslationsOnboardingStep3Ru._(_root);
}

// Path: auth
class _TranslationsAuthRu extends TranslationsAuthUz {
	_TranslationsAuthRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get tagline => 'РАБОЧЕЕ ПРОСТРАНСТВО МАСТЕРА';
	@override late final _TranslationsAuthCommonRu common = _TranslationsAuthCommonRu._(_root);
	@override late final _TranslationsAuthPhoneRu phone = _TranslationsAuthPhoneRu._(_root);
	@override late final _TranslationsAuthOtpRu otp = _TranslationsAuthOtpRu._(_root);
	@override late final _TranslationsAuthProfileRu profile = _TranslationsAuthProfileRu._(_root);
	@override late final _TranslationsAuthTelegramRu telegram = _TranslationsAuthTelegramRu._(_root);
}

// Path: country
class _TranslationsCountryRu extends TranslationsCountryUz {
	_TranslationsCountryRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get title => 'Выберите страну';
	@override String get subtitle => 'Язык приложения зависит от страны. Позже вы сможете изменить его в профиле.';
	@override String get continueBtn => 'Продолжить';
	@override String get changeTitle => 'Страна и язык';
}

// Path: home
class _TranslationsHomeRu extends TranslationsHomeUz {
	_TranslationsHomeRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get main => 'Главная';
	@override String get chatting => 'Чат';
	@override String get profile => 'Профиль';
	@override String get title => 'Профиль';
	@override String get loadError => 'Профиль не загрузился';
	@override String get retry => 'Повторить';
	@override String get phone => 'Телефон';
	@override String get role => 'Роль';
	@override String get status => 'Статус';
	@override String get active => 'Активен';
	@override String get inactive => 'Неактивен';
	@override String get logout => 'Выйти';
	@override String get hi => 'Привет';
	@override String get serviceType => 'Виды услуг';
	@override String get lastOrders => 'Последние заказы';
	@override String get all => 'Все';
	@override String get tapRepair => 'Ремонт крана';
	@override String get chandelierInstallation => 'Установка люстры';
	@override String get completed => 'Выполнено';
	@override String get inProgress => 'В процессе';
	@override String get window => 'Окна';
	@override String get furtiniture => 'Мебель';
	@override String get electric => 'Электрика';
	@override String get plumber => 'Сантехника';
}

// Path: calculatePage
class _TranslationsCalculatePageRu extends TranslationsCalculatePageUz {
	_TranslationsCalculatePageRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get window => 'Окно';
	@override String get door => 'Дверь';
	@override String get glass => 'Арки';
	@override String get windowConfigurator => 'Конфигурация окна';
	@override String get windowLayouts => 'Типы делений';
	@override String get windowPremiumLayouts => 'Премиум-варианты';
	@override String get windowModernLayouts => 'Современные варианты';
	@override String get doorConfigurator => 'Конфигурация двери';
	@override String get doorModels => 'Модели дверей';
	@override String get doorExtraModels => 'Дополнительные модели';
	@override String get material => 'Материал';
	@override String get plastic => 'Пластик';
	@override String get aluminium => 'Алюминий';
	@override String get termo => 'Термо';
	@override String get glassShowcase => 'Варианты арок';
	@override String get customTemplateTitleWindow => 'Создайте своё окно';
	@override String get customTemplateTitleDoor => 'Создайте свою дверь';
	@override String get customTemplateTitleArch => 'Создайте свою арку';
	@override String get customTemplateSubtitle => 'Не готовый шаблон — размер и деление задаёте сами';
	@override String get customTemplateAction => 'Начать';
	@override String get readyTemplates => 'Готовые шаблоны';
}

// Path: profile
class _TranslationsProfileRu extends TranslationsProfileUz {
	_TranslationsProfileRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get personalData => 'Личные данные';
	@override String get professional => 'Профессиональные данные';
	@override String get company => 'Компания';
	@override String get myOrders => 'Мои заказы';
	@override String get settings => 'Настройки';
	@override String get support => 'Связаться с нами';
	@override String get logout => 'Выйти';
	@override String get logoutTitle => 'Выйти из аккаунта?';
	@override String get logoutMessage => 'Загруженные цены и данные расчётов будут удалены с устройства. При следующем входе они загрузятся заново.';
	@override String get logoutConfirm => 'Да, выйти';
	@override String get loggingOut => 'Выходим...';
	@override String get loggingOutHint => 'Сессия закрывается, кэш цен очищается';
	@override String get logoutFailed => 'Не удалось выйти на сервере, но данные на устройстве очищены';
	@override late final _TranslationsProfilePersonalRu personal = _TranslationsProfilePersonalRu._(_root);
	@override late final _TranslationsProfileHelpRu help = _TranslationsProfileHelpRu._(_root);
}

// Path: dashboard
class _TranslationsDashboardRu extends TranslationsDashboardUz {
	_TranslationsDashboardRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get title => 'Рабочий стол';
	@override String get greetingMorning => 'Доброе утро,';
	@override String get greetingDay => 'Добрый день,';
	@override String get greetingEvening => 'Добрый вечер,';
	@override String get master => 'мастер';
	@override String get availableTitle => 'Принимаю заказы';
	@override String get availableOn => 'Новые заявки будут приходить';
	@override String get availableOff => 'Заявки приостановлены';
	@override String get newRequests => 'Новые заявки';
	@override String get activeOrders => 'Активные заказы';
	@override String get all => 'Все';
	@override String get quickCalculate => 'Чертёж окна';
	@override String get quickCalculateHint => 'Чертёж окон и дверей';
	@override String get quickPortfolio => 'Пример работы';
	@override String get quickPortfolioHint => 'Добавьте из завершённой работы';
	@override String get emptyRequests => 'Новых заявок нет';
	@override String get emptyRequestsHint => 'Если переключатель занятости включён, заявки будут появляться здесь.';
	@override String get quickCompany => 'Компания';
	@override String get quickCompanyHint => 'Название и логотип';
	@override String get quickRates => 'Мои расценки';
	@override String get quickRatesHint => 'Ставки по вашему направлению';
	@override String get quickOrdersHeroTitle => 'Новые заказы и Биржа';
	@override String get quickOrdersHeroHint => 'Смотрите заявки по вашему направлению и отправляйте предложение';
	@override String get quickOpenOrders => 'Открытые заказы';
	@override String get quickOpenOrdersHint => 'Заявки без мастера — отправьте предложение';
	@override String get calcStep1 => 'Выберите раму';
	@override String get calcStep2 => 'Настройте';
	@override String get calcStep3 => 'Чертёж готов';
	@override String get repairTitle => 'Беру заказы на ремонт';
	@override String get repairOn => 'Заявки на ремонт тоже будут поступать';
	@override String get repairOff => 'Заявки на ремонт поступать не будут';
	@override String get repairHint => 'Регулировка старых окон и дверей, фурнитура или замена стекла';
}

// Path: orders
class _TranslationsOrdersRu extends TranslationsOrdersUz {
	_TranslationsOrdersRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get title => 'Заказы';
	@override String get segmentNew => 'Открытые';
	@override String get segmentActive => 'В работе';
	@override String get segmentDone => 'Завершённые';
	@override String stepOf({required Object step, required Object total}) => 'Этап ${step} из ${total}';
	@override String lateDays({required Object days}) => 'Просрочено на ${days} дн.';
	@override String get dueToday => 'Срок — сегодня';
	@override String daysLeft({required Object days}) => 'Осталось ${days} дн.';
	@override String get offerBtn => 'Предложить цену';
	@override String get retry => 'Повторить';
	@override String get loadFailed => 'Не удалось загрузить заказы';
	@override String get emptyNewTitle => 'Открытых заказов нет';
	@override String get emptyNewMessage => 'Как только в вашем регионе появится новая заявка, она появится здесь.';
	@override String get emptyActiveTitle => 'Активных заказов нет';
	@override String get emptyActiveMessage => 'Как только примете новую заявку, она появится здесь.';
	@override String get emptyDoneTitle => 'Завершённых работ нет';
	@override String get emptyDoneMessage => 'После сдачи первого заказа он появится здесь.';
	@override late final _TranslationsOrdersStageRu stage = _TranslationsOrdersStageRu._(_root);
	@override late final _TranslationsOrdersDetailRu detail = _TranslationsOrdersDetailRu._(_root);
	@override late final _TranslationsOrdersRequestRu request = _TranslationsOrdersRequestRu._(_root);
	@override late final _TranslationsOrdersSpecRu spec = _TranslationsOrdersSpecRu._(_root);
	@override String get invalidId => 'Неверный номер заказа.';
	@override String get invalidRequestId => 'Неверный номер заявки.';
	@override late final _TranslationsOrdersOpenRu open = _TranslationsOrdersOpenRu._(_root);
	@override String get personalTitle => 'Мои заказы';
}

// Path: ownOrders
class _TranslationsOwnOrdersRu extends TranslationsOwnOrdersUz {
	_TranslationsOwnOrdersRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get orderTitle => 'Заказ';
	@override String itemsCount({required Object count}) => '${count} окон';
	@override String get statusTitle => 'Статус заказа';
	@override String get statusRow => 'Статус';
	@override String get saving => 'Сохраняется…';
	@override String get tapToChange => 'Нажмите, чтобы изменить';
	@override String get alreadyDone => 'Этот заказ уже завершён.';
	@override String get cannotChange => 'Статус этого заказа изменить нельзя.';
	@override late final _TranslationsOwnOrdersStatusRu status = _TranslationsOwnOrdersStatusRu._(_root);
	@override late final _TranslationsOwnOrdersHintRu hint = _TranslationsOwnOrdersHintRu._(_root);
}

// Path: orderForm
class _TranslationsOrderFormRu extends TranslationsOrderFormUz {
	_TranslationsOrderFormRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get noProducts => 'В заказе нет изделий.';
	@override String get queued => 'Нет интернета — заказ поставлен в очередь и отправится сам.';
	@override String get saved => 'Заказ сохранён';
	@override String get saveTitle => 'Сохранить заказ';
	@override String get customer => 'Заказчик';
	@override String get nameLabel => 'Имя';
	@override String get nameHint => 'Азиз';
	@override String get nameRequired => 'Введите имя';
	@override String get addressHint => 'ул. Чиланзар, 9-квартал';
	@override String get noteLabel => 'Дополнительный комментарий';
	@override String get noteHint => '2-й этаж, лифта нет';
	@override String itemsSummary({required Object kinds, required Object count}) => '${kinds} видов окон · ${count} шт';
}

// Path: chat
class _TranslationsChatRu extends TranslationsChatUz {
	_TranslationsChatRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get threadsTitle => 'Диалоги';
	@override String get conversation => 'Диалог';
	@override String get messageHint => 'Напишите сообщение...';
	@override String get emptyChat => 'Здесь вы договоритесь о цене и условиях';
	@override String get emptyThreadsTitle => 'Диалогов пока нет';
	@override String get emptyThreadsMessage => 'Когда мастер откликнется на заказ, переписка появится здесь.';
}

// Path: notifications
class _TranslationsNotificationsRu extends TranslationsNotificationsUz {
	_TranslationsNotificationsRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get title => 'Уведомления';
	@override String get markAllRead => 'Прочитать все';
	@override String get empty => 'Уведомлений нет';
	@override String get open => 'Открыть';
}

// Path: masters
class _TranslationsMastersRu extends TranslationsMastersUz {
	_TranslationsMastersRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get title => 'О мастере';
	@override String get master => 'Мастер';
	@override String get client => 'Клиент';
	@override String get write => 'Написать';
	@override String get chooseThis => 'Выбрать этого мастера';
	@override String get choose => 'Выбрать';
	@override String get chosen => 'Выбранный мастер';
	@override String get notFound => 'Данные не найдены';
	@override String get works => 'Выполненные работы';
	@override String reviews({required Object count}) => 'Отзывы (${count})';
	@override String get reviewsLabel => 'Отзывы';
	@override String get noReviews => 'Отзывов пока нет — вы можете стать первым.';
	@override String experienceYears({required Object years}) => '${years} лет опыта';
	@override String get rating => 'Рейтинг';
	@override String get completed => 'Выполнено';
	@override String responses({required Object count}) => '${count} откликов';
	@override String get estimate => 'Расчёт';
}

// Path: orderFlow
class _TranslationsOrderFlowRu extends TranslationsOrderFlowUz {
	_TranslationsOrderFlowRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsOrderFlowStatusRu status = _TranslationsOrderFlowStatusRu._(_root);
	@override late final _TranslationsOrderFlowStageRu stage = _TranslationsOrderFlowStageRu._(_root);
	@override late final _TranslationsOrderFlowResponseRu response = _TranslationsOrderFlowResponseRu._(_root);
}

// Path: company
class _TranslationsCompanyRu extends TranslationsCompanyUz {
	_TranslationsCompanyRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get title => 'Компания';
	@override String get nameLabel => 'Название компании';
	@override String get nameHint => 'Например: Ustachi Servis';
	@override String get nameEmpty => 'Название компании не указано';
	@override String get nameNote => 'Отображается в бланке заказа';
	@override String get logoHint => 'Добавить логотип';
}

// Path: companyRates
class _TranslationsCompanyRatesRu extends TranslationsCompanyRatesUz {
	_TranslationsCompanyRatesRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get onlyDigits => 'Только цифры';
}

// Path: materials
class _TranslationsMaterialsRu extends TranslationsMaterialsUz {
	_TranslationsMaterialsRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get title => 'Материалы';
	@override String get on => 'Работаю с этим материалом — заказы будут поступать';
	@override String get off => 'Выключено — заказы по этому материалу поступать не будут';
	@override String get allOff => 'Хотя бы один материал должен оставаться включённым';
}

// Path: professional
class _TranslationsProfessionalRu extends TranslationsProfessionalUz {
	_TranslationsProfessionalRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get title => 'Профессиональные данные';
	@override String get headline => 'Расскажите, какой вы мастер';
	@override String get headlineHint => 'Клиент видит эти данные перед выбором. Позже вы можете изменить их в любой момент.';
	@override String get specialty => 'Направления';
	@override String get specialtyPick => 'Выберите свои направления';
	@override String get specialtyLoadFailed => 'Список направлений не загрузился — проверьте интернет и зайдите снова.';
	@override String get experienceQuestion => 'Сколько лет у вас опыта?';
	@override String get experienceHint => 'Например: 5';
	@override String get experienceRequired => 'Укажите опыт';
	@override String get experienceRange => 'Опыт должен быть от 0 до 70';
	@override String get aboutLabel => 'О себе (необязательно)';
	@override String get aboutHint => 'Какие работы выполняете, на что обращаете внимание — коротко.';
	@override String get works => 'Ваши работы';
	@override String get worksHint => 'С фото клиент увидит вашу работу, и шанс, что выберут вас, вырастет. Необязательно — можно добавить позже.';
	@override String get deleteSampleTitle => 'Удалить пример?';
	@override String get deleteSampleMessage => 'Клиенты больше не увидят это фото.';
	@override String get deleteFailed => 'Не удалось удалить';
	@override String get pickSpecialty => 'Выберите хотя бы одно направление';
	@override String get specialtyHint => 'Можно выбрать несколько — заказы придут только по этим направлениям.';
}

// Path: appUpdate
class _TranslationsAppUpdateRu extends TranslationsAppUpdateUz {
	_TranslationsAppUpdateRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get eyebrow => 'ОБНОВЛЕНИЕ';
	@override String get titleOptional => 'Новая версия готова';
	@override String get titleRequired => 'Требуется обновление';
	@override String get bodyOptional => 'Вышла новая версия Ustachi Pro. Обновите, чтобы получить последние исправления и возможности.';
	@override String get bodyRequired => 'Эта версия больше не поддерживается. Обновите приложение, чтобы продолжить работу.';
	@override String get whatsNew => 'ЧТО НОВОГО';
	@override String get versionFrom => 'У вас';
	@override String get versionTo => 'Новая';
	@override String get update => 'Обновить';
	@override String get later => 'Позже';
	@override String get openFailed => 'Не удалось открыть ссылку. Обновите приложение в магазине вручную.';
}

// Path: onboarding.step1
class _TranslationsOnboardingStep1Ru extends TranslationsOnboardingStep1Uz {
	_TranslationsOnboardingStep1Ru._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get title => 'Выберите своё направление';
	@override String get description => 'Окна, кровля, кирпич, электрика, сантехника, плитка, покраска… более 25 направлений. Заказы приходят по вашему профилю.';
}

// Path: onboarding.step2
class _TranslationsOnboardingStep2Ru extends TranslationsOnboardingStep2Uz {
	_TranslationsOnboardingStep2Ru._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get title => 'Заказы находят вас сами';
	@override String get description => 'Новые заявки по вашему региону и направлению сразу приходят уведомлением — искать не придётся.';
}

// Path: onboarding.step3
class _TranslationsOnboardingStep3Ru extends TranslationsOnboardingStep3Uz {
	_TranslationsOnboardingStep3Ru._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get title => 'Цену назначаете вы';
	@override String get description => 'Вводите свои расценки, договариваетесь с клиентом в чате и отмечаете этапы работы.';
}

// Path: auth.common
class _TranslationsAuthCommonRu extends TranslationsAuthCommonUz {
	_TranslationsAuthCommonRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get invalidPhone => 'Введите корректный номер телефона';
	@override String get cancel => 'Отмена';
}

// Path: auth.phone
class _TranslationsAuthPhoneRu extends TranslationsAuthPhoneUz {
	_TranslationsAuthPhoneRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get title => 'Вход в приложение';
	@override String get subtitle => 'Введите номер — пришлём 6-значный код по SMS. Пароль не нужен.';
	@override String get label => 'Номер телефона';
	@override String get continueBtn => 'Продолжить';
	@override String get orOption => 'или';
	@override String get telegramBtn => 'Войти через Telegram';
	@override String get telegramHint => 'Бот запросит номер вашего Telegram-аккаунта для входа. SMS не отправляется.';
	@override String get telegramOpenError => 'Не удалось открыть Telegram-бота. Попробуйте ещё раз.';
	@override String get agreementPrefix => 'Продолжая, вы соглашаетесь с ';
	@override String get terms => 'Условиями использования';
	@override String get and => ' и ';
	@override String get privacy => 'Политикой конфиденциальности';
	@override String get agreementSuffix => '.';
	@override String get audienceRedirect => 'Ищете мастера? Скачайте «Ustachi»';
	@override String get audienceTitle => 'Внимание: приложение для мастеров';
}

// Path: auth.otp
class _TranslationsAuthOtpRu extends TranslationsAuthOtpUz {
	_TranslationsAuthOtpRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get title => 'Введите код';
	@override String sentMessage({required Object phone}) => 'Введите 6-значный код, отправленный на номер ${phone}';
	@override String get invalidCode => 'Введите все 6 цифр кода';
	@override String get resend => 'Отправить код повторно';
	@override String get resendIn => 'Отправить снова';
	@override String get confirmBtn => 'Подтвердить';
	@override String get changeNumber => 'Ввести другой номер';
}

// Path: auth.profile
class _TranslationsAuthProfileRu extends TranslationsAuthProfileUz {
	_TranslationsAuthProfileRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get title => 'О себе';
	@override String get subtitle => 'Клиенты увидят вас под этим именем. Позже сможете изменить его в профиле.';
	@override String get fullNameLabel => 'Имя и фамилия';
	@override String get fullNameHint => 'Введите';
	@override String get requiredName => 'Введите имя и фамилию';
	@override String get addPhoto => 'Добавить фото';
	@override String get changePhoto => 'Заменить фото';
	@override String get saveBtn => 'Сохранить и продолжить';
	@override String get skip => 'Заполню позже';
	@override String get regionLabel => 'Область';
	@override String get regionHint => 'Выберите область';
	@override String get districtLabel => 'Район / город';
	@override String get districtHint => 'Выберите район';
	@override String get addressLabel => 'Адрес';
	@override String get addressHint => 'Улица, номер дома';
	@override String get requiredRegion => 'Выберите область';
	@override String get requiredDistrict => 'Выберите район';
	@override String get loadFailed => 'Не удалось загрузить список';
}

// Path: auth.telegram
class _TranslationsAuthTelegramRu extends TranslationsAuthTelegramUz {
	_TranslationsAuthTelegramRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get loadingTitle => 'Вход через Telegram';
	@override String get loadingHint => 'Проверка одноразовой ссылки…';
	@override String get invalidLink => 'Недействительная ссылка Telegram.';
	@override String get expiredLink => 'Срок действия ссылки истёк или она уже использована. Начните заново в боте.';
	@override String get retry => 'Повторить';
	@override String get restartBot => 'Начать заново в боте';
	@override String get smsOption => 'Войти через SMS';
}

// Path: profile.personal
class _TranslationsProfilePersonalRu extends TranslationsProfilePersonalUz {
	_TranslationsProfilePersonalRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get sectionPersonal => 'Личное';
	@override String get sectionAddress => 'Адрес';
	@override String get sectionProfessional => 'Профессия';
	@override String get phoneLabel => 'Телефон';
	@override String get phoneNote => 'Номер — идентификатор аккаунта, не меняется';
	@override String get joinedLabel => 'Регистрация';
	@override String get empty => 'Не указано';
	@override String get edit => 'Редактировать';
	@override String get openProfessional => 'Специальность, опыт и работы';
	@override String get loadFailed => 'Не удалось загрузить данные';
}

// Path: profile.help
class _TranslationsProfileHelpRu extends TranslationsProfileHelpUz {
	_TranslationsProfileHelpRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get subtitle => 'Есть вопрос или проблема — напишите или позвоните';
	@override String get callLabel => 'Позвонить';
	@override String get emailLabel => 'Электронная почта';
	@override String get telegramLabel => 'Наш Telegram-канал';
	@override String get telegramHint => 'Новости и объявления';
	@override String get workHours => 'Пн–сб, 9:00–19:00';
	@override String get copied => 'Скопировано';
}

// Path: orders.stage
class _TranslationsOrdersStageRu extends TranslationsOrdersStageUz {
	_TranslationsOrdersStageRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get accepted => 'Предложение принято';
	@override String get measured => 'Замер сделан';
	@override String get production => 'Производство';
	@override String get installation => 'Монтаж';
	@override String get handover => 'Сдача и оплата';
}

// Path: orders.detail
class _TranslationsOrdersDetailRu extends TranslationsOrdersDetailUz {
	_TranslationsOrdersDetailRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get stages => 'Этапы';
	@override String get spec => 'Спецификация';
	@override String get client => 'Клиент';
	@override String get total => 'Итого';
	@override String get prepaid => 'Предоплата';
	@override String get remaining => 'Остаток';
	@override String get dueDate => 'Согласованный срок';
	@override String get finishOrder => 'Сдать и завершить';
	@override String get completed => 'Заказ завершён';
	@override String stageDone({required Object stage}) => '${stage} — завершено';
	@override String get notFound => 'Заказ не найден';
	@override String get drawings => 'Чертежи';
	@override String get drawingsHint => 'Увеличьте двумя пальцами · размеры в мм';
	@override String get markMeasured => 'Замер сделан';
	@override String get markProduction => 'Производство началось';
	@override String get markInstallation => 'Выехали на монтаж';
	@override String get stageSaved => 'Отмечено — клиенту отправлено уведомление';
}

// Path: orders.request
class _TranslationsOrdersRequestRu extends TranslationsOrdersRequestUz {
	_TranslationsOrdersRequestRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get title => 'Заявка';
	@override String get clientSpec => 'Спецификация, рассчитанная клиентом';
	@override String get priceOffer => 'Ценовое предложение';
	@override String get serviceFee => 'Монтаж и доставка';
	@override String get yourOffer => 'Ваше предложение';
	@override String get workDays => 'Срок — рабочих дней';
	@override String get note => 'Комментарий (необязательно)';
	@override String get notePlaceholder => 'Дополнительный комментарий клиенту…';
	@override String get send => 'Отправить предложение';
	@override String get decline => 'Отклонить';
	@override String get declineTitle => 'Отклонить заявку?';
	@override String get declineMessage => 'Заявка будет полностью удалена из списка.';
	@override String expiresIn({required Object time}) => 'Осталось ${time}';
	@override String get expired => 'Срок истёк';
	@override String distance({required Object km}) => '${km} км';
	@override String get sent => 'Предложение отправлено';
	@override String get invalidFee => 'Оплата труда не может быть отрицательной';
	@override String get chatNote => 'Цену и условия вы согласуете с клиентом в чате.';
	@override String get withdrawOffer => 'Отозвать предложение';
	@override String get declineInviteTitle => 'Отклонить предложение?';
	@override String get declineInviteMessage => 'Клиент сразу получит уведомление и выберет другого мастера.';
	@override String get clientPrice => 'Цена заказа';
	@override String get priceInChat => 'Цена согласуется в чате';
}

// Path: orders.spec
class _TranslationsOrdersSpecRu extends TranslationsOrdersSpecUz {
	_TranslationsOrdersSpecRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get size => 'Размер (мм)';
	@override String get shape => 'Форма';
	@override String get brand => 'Бренд';
	@override String get color => 'Цвет';
	@override String get material => 'Материал';
	@override String get glass => 'Стекло';
	@override String get sill => 'Подоконник (см)';
	@override String get flower => 'Раскладка';
	@override String get address => 'Адрес';
	@override String get product => 'Изделия';
	@override String get phone => 'Телефон';
	@override String get discount => 'Скидка';
	@override String get note => 'Комментарий';
	@override String itemsValue({required Object kinds, required Object count}) => '${kinds} видов · ${count} шт';
	@override late final _TranslationsOrdersSpecValuesRu values = _TranslationsOrdersSpecValuesRu._(_root);
	@override String get area => 'Площадь';
	@override String get unitPrice => 'Цена за 1 м²';
	@override String get variant => 'Уровень';
}

// Path: orders.open
class _TranslationsOrdersOpenRu extends TranslationsOrdersOpenUz {
	_TranslationsOrdersOpenRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get offerSent => 'Предложение отправлено';
	@override String get waitingClient => 'Ожидает ответа клиента';
	@override String offersCount({required Object count}) => '${count} предложений';
	@override String get beFirst => 'Будьте первым';
	@override String get newBadge => 'Новая';
	@override String get pageTitle => 'Открытые заказы';
	@override String get tabWaiting => 'Ждут ответа';
	@override String get tabSent => 'Отправлено';
	@override String get emptySentTitle => 'Нет отправленных предложений';
	@override String get emptySentMessage => 'Заявки, на которые вы откликнулись, ждут здесь ответа клиента.';
	@override String get tabInvited => 'Вам предложили';
	@override String get invitedBadge => 'Вам предложили';
	@override String get acceptInvite => 'Принимаю';
	@override String get emptyInvitedTitle => 'Личных предложений нет';
	@override String get emptyInvitedMessage => 'Заказы, где клиент выбрал именно вас, появятся здесь.';
	@override String get invitedNote => 'Клиент отправил этот заказ именно вам — другие мастера его не видят.';
	@override String get repairBadge => 'Ремонт';
}

// Path: ownOrders.status
class _TranslationsOwnOrdersStatusRu extends TranslationsOwnOrdersStatusUz {
	_TranslationsOwnOrdersStatusRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get draft => 'Черновик';
	@override String get newOrder => 'Новый';
	@override String get inProgress => 'В работе';
	@override String get done => 'Завершён';
	@override String get debt => 'Есть долг';
	@override String get cancelled => 'Отменён';
}

// Path: ownOrders.hint
class _TranslationsOwnOrdersHintRu extends TranslationsOwnOrdersHintUz {
	_TranslationsOwnOrdersHintRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get newOrder => 'Принят, ещё не начат';
	@override String get inProgress => 'Идёт производство или монтаж';
	@override String get done => 'Сдан и полностью оплачен';
	@override String get debt => 'Работа закончена, но оплата получена не полностью';
	@override String get cancelled => 'Заказ отменён';
}

// Path: orderFlow.status
class _TranslationsOrderFlowStatusRu extends TranslationsOrderFlowStatusUz {
	_TranslationsOrderFlowStatusRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get published => 'Опубликован';
	@override String get assigned => 'Мастер выбран';
	@override String get completed => 'Завершён';
	@override String get cancelled => 'Отменён';
	@override String get expired => 'Срок истёк';
}

// Path: orderFlow.stage
class _TranslationsOrderFlowStageRu extends TranslationsOrderFlowStageUz {
	_TranslationsOrderFlowStageRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get accepted => 'Принято';
	@override String get measured => 'Замер сделан';
	@override String get production => 'Производство';
	@override String get installation => 'Монтаж';
	@override String get handover => 'Сдано';
}

// Path: orderFlow.response
class _TranslationsOrderFlowResponseRu extends TranslationsOrderFlowResponseUz {
	_TranslationsOrderFlowResponseRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get interested => 'Готов взяться';
	@override String get withdrawn => 'Отказался';
	@override String get chosen => 'Выбран';
	@override String get rejected => 'Не выбран';
}

// Path: orders.spec.values
class _TranslationsOrdersSpecValuesRu extends TranslationsOrdersSpecValuesUz {
	_TranslationsOrdersSpecValuesRu._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get plastic => 'Пластик';
	@override String get aluminium => 'Алюминий';
	@override String get termo => 'Термо';
	@override String get doubleGlass => 'Двухкамерное';
	@override String get singleGlass => 'Однокамерное';
	@override String get large => 'Крупная';
	@override String get medium => 'Средняя';
	@override String get small => 'Мелкая';
}

/// The flat map containing all translations for locale <ru>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on TranslationsRu {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'applicationName' => 'Ustachi',
			'common.ok' => 'OK',
			'common.start' => 'Начать',
			'common.cancel' => 'Отмена',
			'common.save' => 'Сохранить',
			'common.delete' => 'Удалить',
			'common.edit' => 'Изменить',
			'common.close' => 'Закрыть',
			'common.back' => 'Назад',
			'common.next' => 'Далее',
			'common.skip' => 'Пропустить',
			'common.enter' => 'Введите',
			'common.wentWrong' => 'Произошла ошибка. Попробуйте ещё раз чуть позже!',
			'common.common' => 'Основное',
			'common.select' => 'Выбрать',
			'common.retry' => 'Повторить',
			'common.refresh' => 'Обновить',
			'common.saved' => 'Сохранено',
			'common.saveFailed' => 'Не сохранилось — попробуйте ещё раз',
			'common.notFound' => 'Не найдено',
			'common.empty' => 'Пусто',
			'common.loading' => 'Загрузка…',
			'common.yes' => 'Да',
			'common.no' => 'Нет',
			'common.add' => 'Добавить',
			'common.copy' => 'Копировать',
			'common.apply' => 'Применить',
			'common.reset' => 'Сбросить',
			'common.done' => 'Готово',
			'common.all' => 'Все',
			'common.som' => 'сум',
			'common.cm' => 'см',
			'common.mm' => 'мм',
			'common.pcs' => 'шт',
			'common.hoursShort' => 'ч',
			'common.minutesShort' => 'мин',
			'common.months.0' => 'января',
			'common.months.1' => 'февраля',
			'common.months.2' => 'марта',
			'common.months.3' => 'апреля',
			'common.months.4' => 'мая',
			'common.months.5' => 'июня',
			'common.months.6' => 'июля',
			'common.months.7' => 'августа',
			'common.months.8' => 'сентября',
			'common.months.9' => 'октября',
			'common.months.10' => 'ноября',
			'common.months.11' => 'декабря',
			'common.weekdays.0' => 'Воскресенье',
			'common.weekdays.1' => 'Понедельник',
			'common.weekdays.2' => 'Вторник',
			'common.weekdays.3' => 'Среда',
			'common.weekdays.4' => 'Четверг',
			'common.weekdays.5' => 'Пятница',
			'common.weekdays.6' => 'Суббота',
			'common.today' => 'Сегодня',
			'common.tomorrow' => 'Завтра',
			'common.comingSoon' => 'Скоро',
			'onboarding.step1.title' => 'Выберите своё направление',
			'onboarding.step1.description' => 'Окна, кровля, кирпич, электрика, сантехника, плитка, покраска… более 25 направлений. Заказы приходят по вашему профилю.',
			'onboarding.step2.title' => 'Заказы находят вас сами',
			'onboarding.step2.description' => 'Новые заявки по вашему региону и направлению сразу приходят уведомлением — искать не придётся.',
			'onboarding.step3.title' => 'Цену назначаете вы',
			'onboarding.step3.description' => 'Вводите свои расценки, договариваетесь с клиентом в чате и отмечаете этапы работы.',
			'auth.tagline' => 'РАБОЧЕЕ ПРОСТРАНСТВО МАСТЕРА',
			'auth.common.invalidPhone' => 'Введите корректный номер телефона',
			'auth.common.cancel' => 'Отмена',
			'auth.phone.title' => 'Вход в приложение',
			'auth.phone.subtitle' => 'Введите номер — пришлём 6-значный код по SMS. Пароль не нужен.',
			'auth.phone.label' => 'Номер телефона',
			'auth.phone.continueBtn' => 'Продолжить',
			'auth.phone.orOption' => 'или',
			'auth.phone.telegramBtn' => 'Войти через Telegram',
			'auth.phone.telegramHint' => 'Бот запросит номер вашего Telegram-аккаунта для входа. SMS не отправляется.',
			'auth.phone.telegramOpenError' => 'Не удалось открыть Telegram-бота. Попробуйте ещё раз.',
			'auth.phone.agreementPrefix' => 'Продолжая, вы соглашаетесь с ',
			'auth.phone.terms' => 'Условиями использования',
			'auth.phone.and' => ' и ',
			'auth.phone.privacy' => 'Политикой конфиденциальности',
			'auth.phone.agreementSuffix' => '.',
			'auth.phone.audienceRedirect' => 'Ищете мастера? Скачайте «Ustachi»',
			'auth.phone.audienceTitle' => 'Внимание: приложение для мастеров',
			'auth.otp.title' => 'Введите код',
			'auth.otp.sentMessage' => ({required Object phone}) => 'Введите 6-значный код, отправленный на номер ${phone}',
			'auth.otp.invalidCode' => 'Введите все 6 цифр кода',
			'auth.otp.resend' => 'Отправить код повторно',
			'auth.otp.resendIn' => 'Отправить снова',
			'auth.otp.confirmBtn' => 'Подтвердить',
			'auth.otp.changeNumber' => 'Ввести другой номер',
			'auth.profile.title' => 'О себе',
			'auth.profile.subtitle' => 'Клиенты увидят вас под этим именем. Позже сможете изменить его в профиле.',
			'auth.profile.fullNameLabel' => 'Имя и фамилия',
			'auth.profile.fullNameHint' => 'Введите',
			'auth.profile.requiredName' => 'Введите имя и фамилию',
			'auth.profile.addPhoto' => 'Добавить фото',
			'auth.profile.changePhoto' => 'Заменить фото',
			'auth.profile.saveBtn' => 'Сохранить и продолжить',
			'auth.profile.skip' => 'Заполню позже',
			'auth.profile.regionLabel' => 'Область',
			'auth.profile.regionHint' => 'Выберите область',
			'auth.profile.districtLabel' => 'Район / город',
			'auth.profile.districtHint' => 'Выберите район',
			'auth.profile.addressLabel' => 'Адрес',
			'auth.profile.addressHint' => 'Улица, номер дома',
			'auth.profile.requiredRegion' => 'Выберите область',
			'auth.profile.requiredDistrict' => 'Выберите район',
			'auth.profile.loadFailed' => 'Не удалось загрузить список',
			'auth.telegram.loadingTitle' => 'Вход через Telegram',
			'auth.telegram.loadingHint' => 'Проверка одноразовой ссылки…',
			'auth.telegram.invalidLink' => 'Недействительная ссылка Telegram.',
			'auth.telegram.expiredLink' => 'Срок действия ссылки истёк или она уже использована. Начните заново в боте.',
			'auth.telegram.retry' => 'Повторить',
			'auth.telegram.restartBot' => 'Начать заново в боте',
			'auth.telegram.smsOption' => 'Войти через SMS',
			'country.title' => 'Выберите страну',
			'country.subtitle' => 'Язык приложения зависит от страны. Позже вы сможете изменить его в профиле.',
			'country.continueBtn' => 'Продолжить',
			'country.changeTitle' => 'Страна и язык',
			'home.main' => 'Главная',
			'home.chatting' => 'Чат',
			'home.profile' => 'Профиль',
			'home.title' => 'Профиль',
			'home.loadError' => 'Профиль не загрузился',
			'home.retry' => 'Повторить',
			'home.phone' => 'Телефон',
			'home.role' => 'Роль',
			'home.status' => 'Статус',
			'home.active' => 'Активен',
			'home.inactive' => 'Неактивен',
			'home.logout' => 'Выйти',
			'home.hi' => 'Привет',
			'home.serviceType' => 'Виды услуг',
			'home.lastOrders' => 'Последние заказы',
			'home.all' => 'Все',
			'home.tapRepair' => 'Ремонт крана',
			'home.chandelierInstallation' => 'Установка люстры',
			'home.completed' => 'Выполнено',
			'home.inProgress' => 'В процессе',
			'home.window' => 'Окна',
			'home.furtiniture' => 'Мебель',
			'home.electric' => 'Электрика',
			'home.plumber' => 'Сантехника',
			'calculatePage.window' => 'Окно',
			'calculatePage.door' => 'Дверь',
			'calculatePage.glass' => 'Арки',
			'calculatePage.windowConfigurator' => 'Конфигурация окна',
			'calculatePage.windowLayouts' => 'Типы делений',
			'calculatePage.windowPremiumLayouts' => 'Премиум-варианты',
			'calculatePage.windowModernLayouts' => 'Современные варианты',
			'calculatePage.doorConfigurator' => 'Конфигурация двери',
			'calculatePage.doorModels' => 'Модели дверей',
			'calculatePage.doorExtraModels' => 'Дополнительные модели',
			'calculatePage.material' => 'Материал',
			'calculatePage.plastic' => 'Пластик',
			'calculatePage.aluminium' => 'Алюминий',
			'calculatePage.termo' => 'Термо',
			'calculatePage.glassShowcase' => 'Варианты арок',
			'calculatePage.customTemplateTitleWindow' => 'Создайте своё окно',
			'calculatePage.customTemplateTitleDoor' => 'Создайте свою дверь',
			'calculatePage.customTemplateTitleArch' => 'Создайте свою арку',
			'calculatePage.customTemplateSubtitle' => 'Не готовый шаблон — размер и деление задаёте сами',
			'calculatePage.customTemplateAction' => 'Начать',
			'calculatePage.readyTemplates' => 'Готовые шаблоны',
			'profile.personalData' => 'Личные данные',
			'profile.professional' => 'Профессиональные данные',
			'profile.company' => 'Компания',
			'profile.myOrders' => 'Мои заказы',
			'profile.settings' => 'Настройки',
			'profile.support' => 'Связаться с нами',
			'profile.logout' => 'Выйти',
			'profile.logoutTitle' => 'Выйти из аккаунта?',
			'profile.logoutMessage' => 'Загруженные цены и данные расчётов будут удалены с устройства. При следующем входе они загрузятся заново.',
			'profile.logoutConfirm' => 'Да, выйти',
			'profile.loggingOut' => 'Выходим...',
			'profile.loggingOutHint' => 'Сессия закрывается, кэш цен очищается',
			'profile.logoutFailed' => 'Не удалось выйти на сервере, но данные на устройстве очищены',
			'profile.personal.sectionPersonal' => 'Личное',
			'profile.personal.sectionAddress' => 'Адрес',
			'profile.personal.sectionProfessional' => 'Профессия',
			'profile.personal.phoneLabel' => 'Телефон',
			'profile.personal.phoneNote' => 'Номер — идентификатор аккаунта, не меняется',
			'profile.personal.joinedLabel' => 'Регистрация',
			'profile.personal.empty' => 'Не указано',
			'profile.personal.edit' => 'Редактировать',
			'profile.personal.openProfessional' => 'Специальность, опыт и работы',
			'profile.personal.loadFailed' => 'Не удалось загрузить данные',
			'profile.help.subtitle' => 'Есть вопрос или проблема — напишите или позвоните',
			'profile.help.callLabel' => 'Позвонить',
			'profile.help.emailLabel' => 'Электронная почта',
			'profile.help.telegramLabel' => 'Наш Telegram-канал',
			'profile.help.telegramHint' => 'Новости и объявления',
			'profile.help.workHours' => 'Пн–сб, 9:00–19:00',
			'profile.help.copied' => 'Скопировано',
			'dashboard.title' => 'Рабочий стол',
			'dashboard.greetingMorning' => 'Доброе утро,',
			'dashboard.greetingDay' => 'Добрый день,',
			'dashboard.greetingEvening' => 'Добрый вечер,',
			'dashboard.master' => 'мастер',
			'dashboard.availableTitle' => 'Принимаю заказы',
			'dashboard.availableOn' => 'Новые заявки будут приходить',
			'dashboard.availableOff' => 'Заявки приостановлены',
			'dashboard.newRequests' => 'Новые заявки',
			'dashboard.activeOrders' => 'Активные заказы',
			'dashboard.all' => 'Все',
			'dashboard.quickCalculate' => 'Чертёж окна',
			'dashboard.quickCalculateHint' => 'Чертёж окон и дверей',
			'dashboard.quickPortfolio' => 'Пример работы',
			'dashboard.quickPortfolioHint' => 'Добавьте из завершённой работы',
			'dashboard.emptyRequests' => 'Новых заявок нет',
			'dashboard.emptyRequestsHint' => 'Если переключатель занятости включён, заявки будут появляться здесь.',
			'dashboard.quickCompany' => 'Компания',
			'dashboard.quickCompanyHint' => 'Название и логотип',
			'dashboard.quickRates' => 'Мои расценки',
			'dashboard.quickRatesHint' => 'Ставки по вашему направлению',
			'dashboard.quickOrdersHeroTitle' => 'Новые заказы и Биржа',
			'dashboard.quickOrdersHeroHint' => 'Смотрите заявки по вашему направлению и отправляйте предложение',
			'dashboard.quickOpenOrders' => 'Открытые заказы',
			'dashboard.quickOpenOrdersHint' => 'Заявки без мастера — отправьте предложение',
			'dashboard.calcStep1' => 'Выберите раму',
			'dashboard.calcStep2' => 'Настройте',
			'dashboard.calcStep3' => 'Чертёж готов',
			'dashboard.repairTitle' => 'Беру заказы на ремонт',
			'dashboard.repairOn' => 'Заявки на ремонт тоже будут поступать',
			'dashboard.repairOff' => 'Заявки на ремонт поступать не будут',
			'dashboard.repairHint' => 'Регулировка старых окон и дверей, фурнитура или замена стекла',
			'orders.title' => 'Заказы',
			'orders.segmentNew' => 'Открытые',
			'orders.segmentActive' => 'В работе',
			'orders.segmentDone' => 'Завершённые',
			'orders.stepOf' => ({required Object step, required Object total}) => 'Этап ${step} из ${total}',
			'orders.lateDays' => ({required Object days}) => 'Просрочено на ${days} дн.',
			'orders.dueToday' => 'Срок — сегодня',
			'orders.daysLeft' => ({required Object days}) => 'Осталось ${days} дн.',
			'orders.offerBtn' => 'Предложить цену',
			'orders.retry' => 'Повторить',
			'orders.loadFailed' => 'Не удалось загрузить заказы',
			'orders.emptyNewTitle' => 'Открытых заказов нет',
			'orders.emptyNewMessage' => 'Как только в вашем регионе появится новая заявка, она появится здесь.',
			'orders.emptyActiveTitle' => 'Активных заказов нет',
			'orders.emptyActiveMessage' => 'Как только примете новую заявку, она появится здесь.',
			'orders.emptyDoneTitle' => 'Завершённых работ нет',
			'orders.emptyDoneMessage' => 'После сдачи первого заказа он появится здесь.',
			'orders.stage.accepted' => 'Предложение принято',
			'orders.stage.measured' => 'Замер сделан',
			'orders.stage.production' => 'Производство',
			'orders.stage.installation' => 'Монтаж',
			'orders.stage.handover' => 'Сдача и оплата',
			'orders.detail.stages' => 'Этапы',
			'orders.detail.spec' => 'Спецификация',
			'orders.detail.client' => 'Клиент',
			'orders.detail.total' => 'Итого',
			'orders.detail.prepaid' => 'Предоплата',
			'orders.detail.remaining' => 'Остаток',
			'orders.detail.dueDate' => 'Согласованный срок',
			'orders.detail.finishOrder' => 'Сдать и завершить',
			'orders.detail.completed' => 'Заказ завершён',
			'orders.detail.stageDone' => ({required Object stage}) => '${stage} — завершено',
			'orders.detail.notFound' => 'Заказ не найден',
			'orders.detail.drawings' => 'Чертежи',
			'orders.detail.drawingsHint' => 'Увеличьте двумя пальцами · размеры в мм',
			'orders.detail.markMeasured' => 'Замер сделан',
			'orders.detail.markProduction' => 'Производство началось',
			'orders.detail.markInstallation' => 'Выехали на монтаж',
			'orders.detail.stageSaved' => 'Отмечено — клиенту отправлено уведомление',
			'orders.request.title' => 'Заявка',
			'orders.request.clientSpec' => 'Спецификация, рассчитанная клиентом',
			'orders.request.priceOffer' => 'Ценовое предложение',
			'orders.request.serviceFee' => 'Монтаж и доставка',
			'orders.request.yourOffer' => 'Ваше предложение',
			'orders.request.workDays' => 'Срок — рабочих дней',
			'orders.request.note' => 'Комментарий (необязательно)',
			'orders.request.notePlaceholder' => 'Дополнительный комментарий клиенту…',
			'orders.request.send' => 'Отправить предложение',
			'orders.request.decline' => 'Отклонить',
			'orders.request.declineTitle' => 'Отклонить заявку?',
			'orders.request.declineMessage' => 'Заявка будет полностью удалена из списка.',
			'orders.request.expiresIn' => ({required Object time}) => 'Осталось ${time}',
			'orders.request.expired' => 'Срок истёк',
			'orders.request.distance' => ({required Object km}) => '${km} км',
			'orders.request.sent' => 'Предложение отправлено',
			'orders.request.invalidFee' => 'Оплата труда не может быть отрицательной',
			'orders.request.chatNote' => 'Цену и условия вы согласуете с клиентом в чате.',
			'orders.request.withdrawOffer' => 'Отозвать предложение',
			'orders.request.declineInviteTitle' => 'Отклонить предложение?',
			'orders.request.declineInviteMessage' => 'Клиент сразу получит уведомление и выберет другого мастера.',
			'orders.request.clientPrice' => 'Цена заказа',
			'orders.request.priceInChat' => 'Цена согласуется в чате',
			'orders.spec.size' => 'Размер (мм)',
			'orders.spec.shape' => 'Форма',
			'orders.spec.brand' => 'Бренд',
			'orders.spec.color' => 'Цвет',
			'orders.spec.material' => 'Материал',
			'orders.spec.glass' => 'Стекло',
			'orders.spec.sill' => 'Подоконник (см)',
			'orders.spec.flower' => 'Раскладка',
			'orders.spec.address' => 'Адрес',
			'orders.spec.product' => 'Изделия',
			'orders.spec.phone' => 'Телефон',
			'orders.spec.discount' => 'Скидка',
			'orders.spec.note' => 'Комментарий',
			'orders.spec.itemsValue' => ({required Object kinds, required Object count}) => '${kinds} видов · ${count} шт',
			'orders.spec.values.plastic' => 'Пластик',
			'orders.spec.values.aluminium' => 'Алюминий',
			'orders.spec.values.termo' => 'Термо',
			'orders.spec.values.doubleGlass' => 'Двухкамерное',
			'orders.spec.values.singleGlass' => 'Однокамерное',
			'orders.spec.values.large' => 'Крупная',
			'orders.spec.values.medium' => 'Средняя',
			'orders.spec.values.small' => 'Мелкая',
			'orders.spec.area' => 'Площадь',
			'orders.spec.unitPrice' => 'Цена за 1 м²',
			'orders.spec.variant' => 'Уровень',
			'orders.invalidId' => 'Неверный номер заказа.',
			'orders.invalidRequestId' => 'Неверный номер заявки.',
			'orders.open.offerSent' => 'Предложение отправлено',
			'orders.open.waitingClient' => 'Ожидает ответа клиента',
			'orders.open.offersCount' => ({required Object count}) => '${count} предложений',
			'orders.open.beFirst' => 'Будьте первым',
			'orders.open.newBadge' => 'Новая',
			'orders.open.pageTitle' => 'Открытые заказы',
			'orders.open.tabWaiting' => 'Ждут ответа',
			'orders.open.tabSent' => 'Отправлено',
			'orders.open.emptySentTitle' => 'Нет отправленных предложений',
			'orders.open.emptySentMessage' => 'Заявки, на которые вы откликнулись, ждут здесь ответа клиента.',
			'orders.open.tabInvited' => 'Вам предложили',
			'orders.open.invitedBadge' => 'Вам предложили',
			'orders.open.acceptInvite' => 'Принимаю',
			'orders.open.emptyInvitedTitle' => 'Личных предложений нет',
			'orders.open.emptyInvitedMessage' => 'Заказы, где клиент выбрал именно вас, появятся здесь.',
			'orders.open.invitedNote' => 'Клиент отправил этот заказ именно вам — другие мастера его не видят.',
			'orders.open.repairBadge' => 'Ремонт',
			'orders.personalTitle' => 'Мои заказы',
			'ownOrders.orderTitle' => 'Заказ',
			'ownOrders.itemsCount' => ({required Object count}) => '${count} окон',
			'ownOrders.statusTitle' => 'Статус заказа',
			'ownOrders.statusRow' => 'Статус',
			'ownOrders.saving' => 'Сохраняется…',
			'ownOrders.tapToChange' => 'Нажмите, чтобы изменить',
			'ownOrders.alreadyDone' => 'Этот заказ уже завершён.',
			'ownOrders.cannotChange' => 'Статус этого заказа изменить нельзя.',
			'ownOrders.status.draft' => 'Черновик',
			'ownOrders.status.newOrder' => 'Новый',
			'ownOrders.status.inProgress' => 'В работе',
			'ownOrders.status.done' => 'Завершён',
			'ownOrders.status.debt' => 'Есть долг',
			'ownOrders.status.cancelled' => 'Отменён',
			'ownOrders.hint.newOrder' => 'Принят, ещё не начат',
			'ownOrders.hint.inProgress' => 'Идёт производство или монтаж',
			'ownOrders.hint.done' => 'Сдан и полностью оплачен',
			'ownOrders.hint.debt' => 'Работа закончена, но оплата получена не полностью',
			'ownOrders.hint.cancelled' => 'Заказ отменён',
			'orderForm.noProducts' => 'В заказе нет изделий.',
			'orderForm.queued' => 'Нет интернета — заказ поставлен в очередь и отправится сам.',
			'orderForm.saved' => 'Заказ сохранён',
			'orderForm.saveTitle' => 'Сохранить заказ',
			'orderForm.customer' => 'Заказчик',
			'orderForm.nameLabel' => 'Имя',
			'orderForm.nameHint' => 'Азиз',
			'orderForm.nameRequired' => 'Введите имя',
			'orderForm.addressHint' => 'ул. Чиланзар, 9-квартал',
			'orderForm.noteLabel' => 'Дополнительный комментарий',
			'orderForm.noteHint' => '2-й этаж, лифта нет',
			'orderForm.itemsSummary' => ({required Object kinds, required Object count}) => '${kinds} видов окон · ${count} шт',
			'chat.threadsTitle' => 'Диалоги',
			'chat.conversation' => 'Диалог',
			'chat.messageHint' => 'Напишите сообщение...',
			'chat.emptyChat' => 'Здесь вы договоритесь о цене и условиях',
			'chat.emptyThreadsTitle' => 'Диалогов пока нет',
			'chat.emptyThreadsMessage' => 'Когда мастер откликнется на заказ, переписка появится здесь.',
			'notifications.title' => 'Уведомления',
			'notifications.markAllRead' => 'Прочитать все',
			'notifications.empty' => 'Уведомлений нет',
			'notifications.open' => 'Открыть',
			'masters.title' => 'О мастере',
			'masters.master' => 'Мастер',
			'masters.client' => 'Клиент',
			'masters.write' => 'Написать',
			'masters.chooseThis' => 'Выбрать этого мастера',
			'masters.choose' => 'Выбрать',
			'masters.chosen' => 'Выбранный мастер',
			'masters.notFound' => 'Данные не найдены',
			'masters.works' => 'Выполненные работы',
			'masters.reviews' => ({required Object count}) => 'Отзывы (${count})',
			'masters.reviewsLabel' => 'Отзывы',
			'masters.noReviews' => 'Отзывов пока нет — вы можете стать первым.',
			'masters.experienceYears' => ({required Object years}) => '${years} лет опыта',
			'masters.rating' => 'Рейтинг',
			'masters.completed' => 'Выполнено',
			'masters.responses' => ({required Object count}) => '${count} откликов',
			'masters.estimate' => 'Расчёт',
			'orderFlow.status.published' => 'Опубликован',
			'orderFlow.status.assigned' => 'Мастер выбран',
			'orderFlow.status.completed' => 'Завершён',
			'orderFlow.status.cancelled' => 'Отменён',
			'orderFlow.status.expired' => 'Срок истёк',
			'orderFlow.stage.accepted' => 'Принято',
			'orderFlow.stage.measured' => 'Замер сделан',
			'orderFlow.stage.production' => 'Производство',
			'orderFlow.stage.installation' => 'Монтаж',
			'orderFlow.stage.handover' => 'Сдано',
			'orderFlow.response.interested' => 'Готов взяться',
			'orderFlow.response.withdrawn' => 'Отказался',
			'orderFlow.response.chosen' => 'Выбран',
			'orderFlow.response.rejected' => 'Не выбран',
			'company.title' => 'Компания',
			'company.nameLabel' => 'Название компании',
			'company.nameHint' => 'Например: Ustachi Servis',
			'company.nameEmpty' => 'Название компании не указано',
			'company.nameNote' => 'Отображается в бланке заказа',
			'company.logoHint' => 'Добавить логотип',
			'companyRates.onlyDigits' => 'Только цифры',
			'materials.title' => 'Материалы',
			'materials.on' => 'Работаю с этим материалом — заказы будут поступать',
			'materials.off' => 'Выключено — заказы по этому материалу поступать не будут',
			'materials.allOff' => 'Хотя бы один материал должен оставаться включённым',
			'professional.title' => 'Профессиональные данные',
			'professional.headline' => 'Расскажите, какой вы мастер',
			'professional.headlineHint' => 'Клиент видит эти данные перед выбором. Позже вы можете изменить их в любой момент.',
			'professional.specialty' => 'Направления',
			'professional.specialtyPick' => 'Выберите свои направления',
			'professional.specialtyLoadFailed' => 'Список направлений не загрузился — проверьте интернет и зайдите снова.',
			'professional.experienceQuestion' => 'Сколько лет у вас опыта?',
			'professional.experienceHint' => 'Например: 5',
			'professional.experienceRequired' => 'Укажите опыт',
			'professional.experienceRange' => 'Опыт должен быть от 0 до 70',
			'professional.aboutLabel' => 'О себе (необязательно)',
			'professional.aboutHint' => 'Какие работы выполняете, на что обращаете внимание — коротко.',
			'professional.works' => 'Ваши работы',
			'professional.worksHint' => 'С фото клиент увидит вашу работу, и шанс, что выберут вас, вырастет. Необязательно — можно добавить позже.',
			'professional.deleteSampleTitle' => 'Удалить пример?',
			'professional.deleteSampleMessage' => 'Клиенты больше не увидят это фото.',
			'professional.deleteFailed' => 'Не удалось удалить',
			'professional.pickSpecialty' => 'Выберите хотя бы одно направление',
			'professional.specialtyHint' => 'Можно выбрать несколько — заказы придут только по этим направлениям.',
			'appUpdate.eyebrow' => 'ОБНОВЛЕНИЕ',
			'appUpdate.titleOptional' => 'Новая версия готова',
			'appUpdate.titleRequired' => 'Требуется обновление',
			'appUpdate.bodyOptional' => 'Вышла новая версия Ustachi Pro. Обновите, чтобы получить последние исправления и возможности.',
			'appUpdate.bodyRequired' => 'Эта версия больше не поддерживается. Обновите приложение, чтобы продолжить работу.',
			'appUpdate.whatsNew' => 'ЧТО НОВОГО',
			'appUpdate.versionFrom' => 'У вас',
			'appUpdate.versionTo' => 'Новая',
			'appUpdate.update' => 'Обновить',
			'appUpdate.later' => 'Позже',
			'appUpdate.openFailed' => 'Не удалось открыть ссылку. Обновите приложение в магазине вручную.',
			_ => null,
		};
	}
}
