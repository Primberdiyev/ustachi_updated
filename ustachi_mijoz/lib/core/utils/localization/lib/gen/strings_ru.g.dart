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
		  _meta = meta ?? TranslationMetadata(
		    locale: AppLocale.ru,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		_meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <ru>.
	final TranslationMetadata<AppLocale, Translations> _meta;
	@override TranslationMetadata<AppLocale, Translations> get $meta => _meta;

	/// Access flat map
	@override dynamic operator[](String key) => _meta.getTranslation(key) ?? super[key];

	late final TranslationsRu _root = this; // ignore: unused_field

	@override 
	TranslationsRu $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => TranslationsRu(meta: meta ?? this.$meta);

	// Translations
	@override String get applicationName => 'Ustachi';
	@override late final _Translations$common$ru common = _Translations$common$ru._(_root);
	@override late final _Translations$onboarding$ru onboarding = _Translations$onboarding$ru._(_root);
	@override late final _Translations$auth$ru auth = _Translations$auth$ru._(_root);
	@override late final _Translations$home$ru home = _Translations$home$ru._(_root);
	@override late final _Translations$calculatePage$ru calculatePage = _Translations$calculatePage$ru._(_root);
	@override late final _Translations$marketplace$ru marketplace = _Translations$marketplace$ru._(_root);
	@override late final _Translations$profile$ru profile = _Translations$profile$ru._(_root);
	@override late final _Translations$masters$ru masters = _Translations$masters$ru._(_root);
	@override late final _Translations$appUpdate$ru appUpdate = _Translations$appUpdate$ru._(_root);
}

// Path: common
class _Translations$common$ru extends Translations$common$uz {
	_Translations$common$ru._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get loading => 'Загрузка…';
	@override String get loadingTimeout => 'Загрузка затянулась. Проверьте интернет и повторите попытку.';
	@override String get ok => 'ОК';
	@override String get start => 'Начать';
	@override String get cancel => 'Отмена';
	@override String get save => 'Сохранить';
	@override String get delete => 'Удалить';
	@override String get edit => 'Редактировать';
	@override String get close => 'Закрыть';
	@override String get back => 'Назад';
	@override String get next => 'Далее';
	@override String get skip => 'Пропустить';
	@override String get enter => 'Введите';
	@override String get wentWrong => 'Произошла ошибка. Пожалуйста, попробуйте позже!';
	@override String get common => 'Основное';
	@override String get select => 'Выбрать';
	@override String get copy => 'Копировать';
	@override String get saved => 'Сохранено';
	@override String get retry => 'Повторить';
	@override String get notFound => 'Ничего не найдено';
}

// Path: onboarding
class _Translations$onboarding$ru extends Translations$onboarding$uz {
	_Translations$onboarding$ru._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override late final _Translations$onboarding$step1$ru step1 = _Translations$onboarding$step1$ru._(_root);
	@override late final _Translations$onboarding$step2$ru step2 = _Translations$onboarding$step2$ru._(_root);
	@override late final _Translations$onboarding$step3$ru step3 = _Translations$onboarding$step3$ru._(_root);
}

// Path: auth
class _Translations$auth$ru extends Translations$auth$uz {
	_Translations$auth$ru._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override late final _Translations$auth$common$ru common = _Translations$auth$common$ru._(_root);
	@override late final _Translations$auth$selection$ru selection = _Translations$auth$selection$ru._(_root);
	@override late final _Translations$auth$login$ru login = _Translations$auth$login$ru._(_root);
	@override late final _Translations$auth$register$ru register = _Translations$auth$register$ru._(_root);
	@override late final _Translations$auth$otp$ru otp = _Translations$auth$otp$ru._(_root);
	@override late final _Translations$auth$forgot$ru forgot = _Translations$auth$forgot$ru._(_root);
	@override late final _Translations$auth$reset$ru reset = _Translations$auth$reset$ru._(_root);
	@override late final _Translations$auth$phone$ru phone = _Translations$auth$phone$ru._(_root);
	@override late final _Translations$auth$telegram$ru telegram = _Translations$auth$telegram$ru._(_root);
	@override late final _Translations$auth$profile$ru profile = _Translations$auth$profile$ru._(_root);
}

// Path: home
class _Translations$home$ru extends Translations$home$uz {
	_Translations$home$ru._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get main => 'Главная';
	@override String get calculate => 'Расчет';
	@override String get chatting => 'Чат';
	@override String get profile => 'Профиль';
	@override String get title => 'Профиль';
	@override String get loadError => 'Профиль не загружен';
	@override String get retry => 'Повторить';
	@override String get phone => 'Телефон';
	@override String get role => 'Роль';
	@override String get status => 'Статус';
	@override String get active => 'Активен';
	@override String get inactive => 'Неактивен';
	@override String get logout => 'Выйти';
	@override String get hi => 'Привет';
	@override String get todayQuestion => 'Что рассчитаем сегодня?';
	@override String get calculatePrice => 'Расчет стоимости';
	@override String get findMaster => 'Найти мастера';
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
	@override String get roof => 'Крыша';
	@override String get concrete => 'Бетон';
	@override String get gate => 'Ворота';
	@override String get brick => 'Кирпич';
	@override String get masters => 'Мастера';
	@override String get ordersSubtitle => 'Следите за объявлениями и выполнением работ';
	@override String get calculateHeroSubtitle => 'Несколько вопросов — и точный расчет';
	@override String get step1 => 'Укажите размер';
	@override String get step2 => 'Предложение и цена';
	@override String get step3 => 'Вызовите мастера';
	@override String get searchHint => 'Поиск: крыша, кирпич, электрик…';
	@override String get notFoundEmpty => 'Не удалось загрузить список направлений.';
	@override String notFoundQuery({required Object query}) => 'По запросу «${query}» ничего не найдено.';
}

// Path: calculatePage
class _Translations$calculatePage$ru extends Translations$calculatePage$uz {
	_Translations$calculatePage$ru._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get som => 'сум';
}

// Path: marketplace
class _Translations$marketplace$ru extends Translations$marketplace$uz {
	_Translations$marketplace$ru._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get chats => 'Чаты';
	@override String get contactMaster => 'Связаться с мастером';
	@override String get addMoreWindow => 'Добавить еще окно';
	@override String get selectMaster => 'Выбор мастера';
	@override String get write => 'Написать';
	@override String get selectThisMaster => 'Выбрать этого мастера';
	@override String get notifications => 'Уведомления';
	@override String get readAll => 'Прочитать все';
}

// Path: profile
class _Translations$profile$ru extends Translations$profile$uz {
	_Translations$profile$ru._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get personalData => 'Личные данные';
	@override String get myOrders => 'Мои заказы';
	@override String get settings => 'Настройки';
	@override String get language => 'Язык приложения';
	@override String get theme => 'Оформление приложения';
	@override String get themeLight => 'Светлая';
	@override String get themeDark => 'Темная';
	@override String get themeSystem => 'Как в системе';
	@override String get themeSystemHint => 'Меняется в зависимости от настроек телефона';
	@override String get support => 'Связаться с нами';
	@override String get logout => 'Выйти';
	@override late final _Translations$profile$help$ru help = _Translations$profile$help$ru._(_root);
	@override String get logoutTitle => 'Выйти из аккаунта?';
	@override String get logoutMessage => 'Сессия будет закрыта, данные аккаунта удалены с устройства. При повторном входе они загрузятся заново.';
	@override String get logoutConfirm => 'Да, выйти';
	@override String get loggingOut => 'Выход...';
	@override String get loggingOutHint => 'Сессия закрывается';
	@override String get logoutFailed => 'Не удалось выйти на сервере, но данные на устройстве очищены';
	@override late final _Translations$profile$personal$ru personal = _Translations$profile$personal$ru._(_root);
}

// Path: masters
class _Translations$masters$ru extends Translations$masters$uz {
	_Translations$masters$ru._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get viewProfile => 'Смотреть профиль';
	@override String get loadMore => 'Показать ещё мастеров';
	@override String get searchLoadedOnly => 'Поиск среди загруженных мастеров. Загрузите ещё, чтобы увидеть остальных.';
	@override String get masterList => 'Список мастеров';
	@override String get completedWorks => 'ВЫПОЛНЕНО';
	@override String get experience => 'ОПЫТ';
	@override String get repeatContact => 'ПОВТОРНЫЙ КОНТАКТ';
	@override String get filterTitle => 'Настройки поиска';
	@override String get professionType => 'Вид услуги';
	@override String get regionAndDistrict => 'ОБЛАСТЬ / РАЙОН';
	@override String get region => 'Область';
	@override String get selectRegion => 'Выберите область';
	@override String get allRegions => 'Все области';
	@override String get priceRange => 'ДИАПАЗОН ЦЕН (СУМ)';
	@override String get minPrice => 'Мин';
	@override String get maxPrice => 'Макс';
	@override String get minimumRating => 'МИНИМАЛЬНЫЙ РЕЙТИНГ';
	@override String get clear => 'Очистить';
	@override String get apply => 'Применить';
	@override String get aboutTitle => 'О нас';
	@override String get aboutDescription => 'Профессиональная укладка плитки. Опыт работы 5 лет и гарантия высокого качества. Выполняем работы любой сложности в срок. Работаем с современным оборудованием.';
	@override String get portfolioTitle => 'Примеры работ';
	@override String get reviewsTitle => 'Отзывы';
	@override String reviewsCount({required Object count}) => 'Отзывы (${count})';
	@override String get noReviews => 'Отзывов пока нет — вы можете быть первым.';
	@override String get estimatedPriceNotice => 'Ориентировочная цена — точная сумма согласовывается в чате в зависимости от объема работ.';
	@override String get all => 'Все';
	@override String get windowProfession => 'Окна';
	@override String get roofProfession => 'Крыша';
	@override String get cementProfession => 'Цемент';
	@override String get floorProfession => 'Пол';
	@override String get tashkentCity => 'г. Ташкент';
	@override String get tashkentRegion => 'Ташкентская область';
	@override String get ferganaRegion => 'Ферганская область';
	@override String get samarkandRegion => 'Самаркандская область';
	@override String get andijanRegion => 'Андижанская область';
	@override String get namanganRegion => 'Наманганская область';
	@override String get bukharaRegion => 'Бухарская область';
	@override String get khorezmRegion => 'Хорезмская область';
	@override String get kashkadaryaRegion => 'Кашкадарьинская область';
	@override String get surkhandaryaRegion => 'Сурхандарьинская область';
	@override String get callMaster => 'Вызвать мастера';
	@override String get aboutMaster => 'О мастере';
	@override String get searchHint => 'Имя, направление или номер телефона';
	@override String get noName => 'Имя не указано';
	@override String get noSpecialty => 'Направление не указано';
	@override String get noExperience => 'Опыт не указан';
	@override String experienceYears({required Object count}) => 'Опыт ${count} лет';
	@override String get noAddress => 'Нет адреса';
	@override String completedOrders({required Object count}) => '${count} работ';
	@override String get newMaster => 'Новый мастер';
	@override String get loadFailed => 'Не удалось загрузить список';
	@override String get noMastersYet => 'Мастеров пока нет';
	@override String searchNotFound({required Object query}) => 'По запросу «${query}» мастера не найдены.';
	@override String regionNotFound({required Object region}) => 'В регионе ${region} мастера не найдены.';
	@override String get specialtyNotFound => 'В этом направлении пока нет зарегистрированных мастеров.';
	@override String get defaultEmpty => 'Мастера появятся здесь после регистрации.';
	@override String get prices => 'Цены';
	@override String get notRated => 'Пока нет оценок';
	@override String get rating => 'Рейтинг';
	@override String get completed => 'Выполнено';
	@override String get reviews => 'Отзывы';
}

// Path: appUpdate
class _Translations$appUpdate$ru extends Translations$appUpdate$uz {
	_Translations$appUpdate$ru._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get eyebrow => 'ОБНОВЛЕНИЕ';
	@override String get titleOptional => 'Доступна новая версия';
	@override String get titleRequired => 'Требуется обновление';
	@override String get bodyOptional => 'Вышла новая версия Ustachi. Обновите приложение, чтобы использовать последние исправления и возможности.';
	@override String get bodyRequired => 'Эта версия больше не поддерживается. Обновите приложение, чтобы продолжить использование.';
	@override String get whatsNew => 'ЧТО НОВОГО';
	@override String get versionFrom => 'У вас';
	@override String get versionTo => 'Новая';
	@override String get update => 'Обновить';
	@override String get later => 'Позже';
	@override String get openFailed => 'Не удалось открыть ссылку. Обновите приложение вручную в магазине.';
}

// Path: onboarding.step1
class _Translations$onboarding$step1$ru extends Translations$onboarding$step1$uz {
	_Translations$onboarding$step1$ru._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get title => 'Мастер для любых работ по дому';
	@override String get description => 'Окна, крыша, кирпич, электрик, сантехник, кафель, покраска… Более 25 направлений. Найдите нужного мастера в одном приложении.';
}

// Path: onboarding.step2
class _Translations$onboarding$step2$ru extends Translations$onboarding$step2$uz {
	_Translations$onboarding$step2$ru._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get title => 'Узнайте цену заранее';
	@override String get description => 'Для окон выбираете размер и форму — чертёж готов. Цену называют мастера — сравниваете нескольких и выбираете.';
}

// Path: onboarding.step3
class _Translations$onboarding$step3$ru extends Translations$onboarding$step3$uz {
	_Translations$onboarding$step3$ru._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get title => 'Выберите надежного мастера';
	@override String get description => 'Выбирайте по рейтингу, примерам работ и отзывам. Согласование в чате, а этапы работы видны в приложении.';
}

// Path: auth.common
class _Translations$auth$common$ru extends Translations$auth$common$uz {
	_Translations$auth$common$ru._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get invalidPhone => 'Введите корректный номер телефона';
	@override String get minPassword => 'Пароль должен содержать минимум 6 символов';
	@override String get cancel => 'Отмена';
}

// Path: auth.selection
class _Translations$auth$selection$ru extends Translations$auth$selection$uz {
	_Translations$auth$selection$ru._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get welcome => 'Добро пожаловать!';
	@override String get chooseRole => 'Войдите в систему или создайте новый аккаунт для продолжения';
	@override String get customerRole => 'Заказчик';
	@override String get craftsmanRole => 'Мастер';
	@override String get continueBtn => 'Продолжить';
	@override String get alreadyHaveAccount => 'Уже есть аккаунт?';
	@override String get login => 'Войти';
	@override String get loginBtn => 'Войти в систему';
	@override String get registerBtn => 'Зарегистрироваться';
	@override String get easyFindMaster => 'Найти мастера теперь просто';
}

// Path: auth.login
class _Translations$auth$login$ru extends Translations$auth$login$uz {
	_Translations$auth$login$ru._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get welcome => 'Добро пожаловать!';
	@override String get subtitle => 'Войдите в систему для доступа к заказам, мастерам и личным данным.';
	@override String get phoneNumber => 'Номер телефона';
	@override String get password => 'Пароль';
	@override String get forgotPassword => 'Забыли пароль?';
	@override String get verifyOtp => 'Подтверждение OTP кода';
	@override String get inactiveAccountTitle => 'Аккаунт не подтвержден';
	@override String get inactiveAccountMessage => 'Хотите перейти на страницу подтверждения телефона через OTP?';
	@override String get loginBtn => 'Войти в систему';
	@override String get noAccount => 'Нет аккаунта?';
	@override String get register => 'Зарегистрируйтесь';
}

// Path: auth.register
class _Translations$auth$register$ru extends Translations$auth$register$uz {
	_Translations$auth$register$ru._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get title => 'Создайте аккаунт';
	@override String get subtitle => 'Создайте аккаунт за несколько минут и начните поиск нужного мастера.';
	@override String get firstName => 'Имя';
	@override String get lastName => 'Фамилия';
	@override String get firstNameHint => 'Джасур';
	@override String get lastNameHint => 'Абдуллаев';
	@override String get phoneNumber => 'Номер телефона';
	@override String get password => 'Пароль';
	@override String get requiredField => 'Поле {field} обязательно для заполнения';
	@override String get registerBtn => 'Зарегистрироваться';
	@override String get agreementPrefix => 'Регистрируясь, вы соглашаетесь с нашими ';
	@override String get terms => 'Условиями использования';
	@override String get and => ' и ';
	@override String get privacy => 'Политикой конфиденциальности';
	@override String get agreementSuffix => '.';
	@override String get haveAccount => 'Уже есть аккаунт?';
	@override String get login => 'Войти в систему';
}

// Path: auth.otp
class _Translations$auth$otp$ru extends Translations$auth$otp$uz {
	_Translations$auth$otp$ru._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get title => 'Подтверждение';
	@override String get subtitle => 'Введите 6-значный код подтверждения, отправленный на ваш телефон.';
	@override String sentMessage({required Object phone}) => 'Введите 6-значный код, отправленный на номер ${phone}';
	@override String get invalidCode => 'Введите 6-значный код полностью';
	@override String get resend => 'Отправить повторно';
	@override String get confirmBtn => 'Подтвердить';
	@override String get resendIn => 'Отправить повторно';
	@override String get changeNumber => 'Изменить номер';
}

// Path: auth.forgot
class _Translations$auth$forgot$ru extends Translations$auth$forgot$uz {
	_Translations$auth$forgot$ru._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get subtitle => 'Введите ваш номер телефона для сброса пароля. Подтвердите код из SMS и установите новый пароль.';
	@override String get requestCode => 'Получить SMS код';
	@override String get resendCode => 'Отправить код повторно';
	@override String get codeLabel => 'Код подтверждения';
	@override String get codeHint => 'Введите 6-значный код';
	@override String get verifyCode => 'Подтвердить код';
	@override String get codeVerified => 'Код подтвержден';
	@override String get newPassword => 'Новый пароль';
	@override String get updatePassword => 'Обновить пароль';
	@override String get passwordUpdated => 'Пароль успешно обновлен.';
	@override String get backToLogin => 'Вернуться к входу';
	@override String get resendAvailable => 'Повторная отправка доступна через:';
	@override String get resendHint => 'Не получили код? Вы можете отправить его повторно после завершения таймера.';
}

// Path: auth.reset
class _Translations$auth$reset$ru extends Translations$auth$reset$uz {
	_Translations$auth$reset$ru._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get title => 'Установите новый пароль';
	@override String get subtitle => 'Для безопасности вашего аккаунта введите новый пароль дважды.';
	@override String get newPasswordLabel => 'Новый пароль';
	@override String get confirmPasswordLabel => 'Повторите пароль';
	@override String get updatePassword => 'Сохранить пароль';
	@override String get passwordMismatch => 'Пароли не совпадают';
}

// Path: auth.phone
class _Translations$auth$phone$ru extends Translations$auth$phone$uz {
	_Translations$auth$phone$ru._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get title => 'Вход в приложение';
	@override String get subtitle => 'Поделитесь номером, привязанным к Telegram, в боте и вернитесь в приложение.';
	@override String get telegramBtn => 'Войти через Telegram';
	@override String get telegramHint => 'Бот запросит номер вашего Telegram-аккаунта для входа. SMS не отправляется.';
	@override String get smsOption => 'Войти через SMS';
	@override String get orOption => 'или';
	@override String get telegramOpenError => 'Не удалось открыть Telegram-бота. Попробуйте ещё раз.';
	@override String get label => 'Номер телефона';
	@override String get continueBtn => 'Продолжить';
	@override String get agreementPrefix => 'Продолжая, вы соглашаетесь с ';
	@override String get terms => 'Условиями использования';
	@override String get and => ' и ';
	@override String get privacy => 'Политикой конфиденциальности';
	@override String get agreementSuffix => '.';
	@override String get audienceRedirect => 'Если вы мастер — скачайте «Ustachi Pro»';
	@override String get audienceTitle => 'Внимание: это приложение для клиентов';
}

// Path: auth.telegram
class _Translations$auth$telegram$ru extends Translations$auth$telegram$uz {
	_Translations$auth$telegram$ru._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get loadingTitle => 'Вход через Telegram';
	@override String get loadingHint => 'Проверяем одноразовую ссылку…';
	@override String get invalidLink => 'Ссылка Telegram недействительна.';
	@override String get expiredLink => 'Срок действия ссылки истёк или она уже использована. Начните заново в боте.';
	@override String get retry => 'Повторить';
	@override String get restartBot => 'Начать заново в боте';
	@override String get smsOption => 'Войти через SMS';
}

// Path: auth.profile
class _Translations$auth$profile$ru extends Translations$auth$profile$uz {
	_Translations$auth$profile$ru._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get title => 'О себе';
	@override String get subtitle => 'Клиенты будут видеть вас под этим именем. Позже вы сможете изменить его в профиле.';
	@override String get fullNameLabel => 'Имя и фамилия';
	@override String get fullNameHint => 'Введите';
	@override String get requiredName => 'Введите имя и фамилию';
	@override String get addPhoto => 'Добавить фото';
	@override String get changePhoto => 'Изменить фото';
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

// Path: profile.help
class _Translations$profile$help$ru extends Translations$profile$help$uz {
	_Translations$profile$help$ru._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get subtitle => 'Если у вас есть вопрос или проблема — напишите или позвоните';
	@override String get callLabel => 'Позвонить';
	@override String get emailLabel => 'Электронная почта';
	@override String get telegramLabel => 'Наш Telegram-канал';
	@override String get telegramHint => 'Новости и объявления';
	@override String get workHours => 'Понедельник–суббота, 9:00–19:00';
	@override String get copied => 'Скопировано';
}

// Path: profile.personal
class _Translations$profile$personal$ru extends Translations$profile$personal$uz {
	_Translations$profile$personal$ru._(TranslationsRu root) : this._root = root, super.internal(root);

	final TranslationsRu _root; // ignore: unused_field

	// Translations
	@override String get sectionPersonal => 'Личное';
	@override String get sectionAddress => 'Адрес';
	@override String get phoneLabel => 'Телефон';
	@override String get phoneNote => 'Номер — идентификатор аккаунта, не меняется';
	@override String get joinedLabel => 'Зарегистрирован';
	@override String get empty => 'Не указано';
	@override String get edit => 'Редактировать';
	@override String get loadFailed => 'Не удалось загрузить данные';
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
			'common.loading' => 'Загрузка…',
			'common.loadingTimeout' => 'Загрузка затянулась. Проверьте интернет и повторите попытку.',
			'common.ok' => 'ОК',
			'common.start' => 'Начать',
			'common.cancel' => 'Отмена',
			'common.save' => 'Сохранить',
			'common.delete' => 'Удалить',
			'common.edit' => 'Редактировать',
			'common.close' => 'Закрыть',
			'common.back' => 'Назад',
			'common.next' => 'Далее',
			'common.skip' => 'Пропустить',
			'common.enter' => 'Введите',
			'common.wentWrong' => 'Произошла ошибка. Пожалуйста, попробуйте позже!',
			'common.common' => 'Основное',
			'common.select' => 'Выбрать',
			'common.copy' => 'Копировать',
			'common.saved' => 'Сохранено',
			'common.retry' => 'Повторить',
			'common.notFound' => 'Ничего не найдено',
			'onboarding.step1.title' => 'Мастер для любых работ по дому',
			'onboarding.step1.description' => 'Окна, крыша, кирпич, электрик, сантехник, кафель, покраска… Более 25 направлений. Найдите нужного мастера в одном приложении.',
			'onboarding.step2.title' => 'Узнайте цену заранее',
			'onboarding.step2.description' => 'Для окон выбираете размер и форму — чертёж готов. Цену называют мастера — сравниваете нескольких и выбираете.',
			'onboarding.step3.title' => 'Выберите надежного мастера',
			'onboarding.step3.description' => 'Выбирайте по рейтингу, примерам работ и отзывам. Согласование в чате, а этапы работы видны в приложении.',
			'auth.common.invalidPhone' => 'Введите корректный номер телефона',
			'auth.common.minPassword' => 'Пароль должен содержать минимум 6 символов',
			'auth.common.cancel' => 'Отмена',
			'auth.selection.welcome' => 'Добро пожаловать!',
			'auth.selection.chooseRole' => 'Войдите в систему или создайте новый аккаунт для продолжения',
			'auth.selection.customerRole' => 'Заказчик',
			'auth.selection.craftsmanRole' => 'Мастер',
			'auth.selection.continueBtn' => 'Продолжить',
			'auth.selection.alreadyHaveAccount' => 'Уже есть аккаунт?',
			'auth.selection.login' => 'Войти',
			'auth.selection.loginBtn' => 'Войти в систему',
			'auth.selection.registerBtn' => 'Зарегистрироваться',
			'auth.selection.easyFindMaster' => 'Найти мастера теперь просто',
			'auth.login.welcome' => 'Добро пожаловать!',
			'auth.login.subtitle' => 'Войдите в систему для доступа к заказам, мастерам и личным данным.',
			'auth.login.phoneNumber' => 'Номер телефона',
			'auth.login.password' => 'Пароль',
			'auth.login.forgotPassword' => 'Забыли пароль?',
			'auth.login.verifyOtp' => 'Подтверждение OTP кода',
			'auth.login.inactiveAccountTitle' => 'Аккаунт не подтвержден',
			'auth.login.inactiveAccountMessage' => 'Хотите перейти на страницу подтверждения телефона через OTP?',
			'auth.login.loginBtn' => 'Войти в систему',
			'auth.login.noAccount' => 'Нет аккаунта?',
			'auth.login.register' => 'Зарегистрируйтесь',
			'auth.register.title' => 'Создайте аккаунт',
			'auth.register.subtitle' => 'Создайте аккаунт за несколько минут и начните поиск нужного мастера.',
			'auth.register.firstName' => 'Имя',
			'auth.register.lastName' => 'Фамилия',
			'auth.register.firstNameHint' => 'Джасур',
			'auth.register.lastNameHint' => 'Абдуллаев',
			'auth.register.phoneNumber' => 'Номер телефона',
			'auth.register.password' => 'Пароль',
			'auth.register.requiredField' => 'Поле {field} обязательно для заполнения',
			'auth.register.registerBtn' => 'Зарегистрироваться',
			'auth.register.agreementPrefix' => 'Регистрируясь, вы соглашаетесь с нашими ',
			'auth.register.terms' => 'Условиями использования',
			'auth.register.and' => ' и ',
			'auth.register.privacy' => 'Политикой конфиденциальности',
			'auth.register.agreementSuffix' => '.',
			'auth.register.haveAccount' => 'Уже есть аккаунт?',
			'auth.register.login' => 'Войти в систему',
			'auth.otp.title' => 'Подтверждение',
			'auth.otp.subtitle' => 'Введите 6-значный код подтверждения, отправленный на ваш телефон.',
			'auth.otp.sentMessage' => ({required Object phone}) => 'Введите 6-значный код, отправленный на номер ${phone}',
			'auth.otp.invalidCode' => 'Введите 6-значный код полностью',
			'auth.otp.resend' => 'Отправить повторно',
			'auth.otp.confirmBtn' => 'Подтвердить',
			'auth.otp.resendIn' => 'Отправить повторно',
			'auth.otp.changeNumber' => 'Изменить номер',
			'auth.forgot.subtitle' => 'Введите ваш номер телефона для сброса пароля. Подтвердите код из SMS и установите новый пароль.',
			'auth.forgot.requestCode' => 'Получить SMS код',
			'auth.forgot.resendCode' => 'Отправить код повторно',
			'auth.forgot.codeLabel' => 'Код подтверждения',
			'auth.forgot.codeHint' => 'Введите 6-значный код',
			'auth.forgot.verifyCode' => 'Подтвердить код',
			'auth.forgot.codeVerified' => 'Код подтвержден',
			'auth.forgot.newPassword' => 'Новый пароль',
			'auth.forgot.updatePassword' => 'Обновить пароль',
			'auth.forgot.passwordUpdated' => 'Пароль успешно обновлен.',
			'auth.forgot.backToLogin' => 'Вернуться к входу',
			'auth.forgot.resendAvailable' => 'Повторная отправка доступна через:',
			'auth.forgot.resendHint' => 'Не получили код? Вы можете отправить его повторно после завершения таймера.',
			'auth.reset.title' => 'Установите новый пароль',
			'auth.reset.subtitle' => 'Для безопасности вашего аккаунта введите новый пароль дважды.',
			'auth.reset.newPasswordLabel' => 'Новый пароль',
			'auth.reset.confirmPasswordLabel' => 'Повторите пароль',
			'auth.reset.updatePassword' => 'Сохранить пароль',
			'auth.reset.passwordMismatch' => 'Пароли не совпадают',
			'auth.phone.title' => 'Вход в приложение',
			'auth.phone.subtitle' => 'Поделитесь номером, привязанным к Telegram, в боте и вернитесь в приложение.',
			'auth.phone.telegramBtn' => 'Войти через Telegram',
			'auth.phone.telegramHint' => 'Бот запросит номер вашего Telegram-аккаунта для входа. SMS не отправляется.',
			'auth.phone.smsOption' => 'Войти через SMS',
			'auth.phone.orOption' => 'или',
			'auth.phone.telegramOpenError' => 'Не удалось открыть Telegram-бота. Попробуйте ещё раз.',
			'auth.phone.label' => 'Номер телефона',
			'auth.phone.continueBtn' => 'Продолжить',
			'auth.phone.agreementPrefix' => 'Продолжая, вы соглашаетесь с ',
			'auth.phone.terms' => 'Условиями использования',
			'auth.phone.and' => ' и ',
			'auth.phone.privacy' => 'Политикой конфиденциальности',
			'auth.phone.agreementSuffix' => '.',
			'auth.phone.audienceRedirect' => 'Если вы мастер — скачайте «Ustachi Pro»',
			'auth.phone.audienceTitle' => 'Внимание: это приложение для клиентов',
			'auth.telegram.loadingTitle' => 'Вход через Telegram',
			'auth.telegram.loadingHint' => 'Проверяем одноразовую ссылку…',
			'auth.telegram.invalidLink' => 'Ссылка Telegram недействительна.',
			'auth.telegram.expiredLink' => 'Срок действия ссылки истёк или она уже использована. Начните заново в боте.',
			'auth.telegram.retry' => 'Повторить',
			'auth.telegram.restartBot' => 'Начать заново в боте',
			'auth.telegram.smsOption' => 'Войти через SMS',
			'auth.profile.title' => 'О себе',
			'auth.profile.subtitle' => 'Клиенты будут видеть вас под этим именем. Позже вы сможете изменить его в профиле.',
			'auth.profile.fullNameLabel' => 'Имя и фамилия',
			'auth.profile.fullNameHint' => 'Введите',
			'auth.profile.requiredName' => 'Введите имя и фамилию',
			'auth.profile.addPhoto' => 'Добавить фото',
			'auth.profile.changePhoto' => 'Изменить фото',
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
			'home.main' => 'Главная',
			'home.calculate' => 'Расчет',
			'home.chatting' => 'Чат',
			'home.profile' => 'Профиль',
			'home.title' => 'Профиль',
			'home.loadError' => 'Профиль не загружен',
			'home.retry' => 'Повторить',
			'home.phone' => 'Телефон',
			'home.role' => 'Роль',
			'home.status' => 'Статус',
			'home.active' => 'Активен',
			'home.inactive' => 'Неактивен',
			'home.logout' => 'Выйти',
			'home.hi' => 'Привет',
			'home.todayQuestion' => 'Что рассчитаем сегодня?',
			'home.calculatePrice' => 'Расчет стоимости',
			'home.findMaster' => 'Найти мастера',
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
			'home.roof' => 'Крыша',
			'home.concrete' => 'Бетон',
			'home.gate' => 'Ворота',
			'home.brick' => 'Кирпич',
			'home.masters' => 'Мастера',
			'home.ordersSubtitle' => 'Следите за объявлениями и выполнением работ',
			'home.calculateHeroSubtitle' => 'Несколько вопросов — и точный расчет',
			'home.step1' => 'Укажите размер',
			'home.step2' => 'Предложение и цена',
			'home.step3' => 'Вызовите мастера',
			'home.searchHint' => 'Поиск: крыша, кирпич, электрик…',
			'home.notFoundEmpty' => 'Не удалось загрузить список направлений.',
			'home.notFoundQuery' => ({required Object query}) => 'По запросу «${query}» ничего не найдено.',
			'calculatePage.som' => 'сум',
			'marketplace.chats' => 'Чаты',
			'marketplace.contactMaster' => 'Связаться с мастером',
			'marketplace.addMoreWindow' => 'Добавить еще окно',
			'marketplace.selectMaster' => 'Выбор мастера',
			'marketplace.write' => 'Написать',
			'marketplace.selectThisMaster' => 'Выбрать этого мастера',
			'marketplace.notifications' => 'Уведомления',
			'marketplace.readAll' => 'Прочитать все',
			'profile.personalData' => 'Личные данные',
			'profile.myOrders' => 'Мои заказы',
			'profile.settings' => 'Настройки',
			'profile.language' => 'Язык приложения',
			'profile.theme' => 'Оформление приложения',
			'profile.themeLight' => 'Светлая',
			'profile.themeDark' => 'Темная',
			'profile.themeSystem' => 'Как в системе',
			'profile.themeSystemHint' => 'Меняется в зависимости от настроек телефона',
			'profile.support' => 'Связаться с нами',
			'profile.logout' => 'Выйти',
			'profile.help.subtitle' => 'Если у вас есть вопрос или проблема — напишите или позвоните',
			'profile.help.callLabel' => 'Позвонить',
			'profile.help.emailLabel' => 'Электронная почта',
			'profile.help.telegramLabel' => 'Наш Telegram-канал',
			'profile.help.telegramHint' => 'Новости и объявления',
			'profile.help.workHours' => 'Понедельник–суббота, 9:00–19:00',
			'profile.help.copied' => 'Скопировано',
			'profile.logoutTitle' => 'Выйти из аккаунта?',
			'profile.logoutMessage' => 'Сессия будет закрыта, данные аккаунта удалены с устройства. При повторном входе они загрузятся заново.',
			'profile.logoutConfirm' => 'Да, выйти',
			'profile.loggingOut' => 'Выход...',
			'profile.loggingOutHint' => 'Сессия закрывается',
			'profile.logoutFailed' => 'Не удалось выйти на сервере, но данные на устройстве очищены',
			'profile.personal.sectionPersonal' => 'Личное',
			'profile.personal.sectionAddress' => 'Адрес',
			'profile.personal.phoneLabel' => 'Телефон',
			'profile.personal.phoneNote' => 'Номер — идентификатор аккаунта, не меняется',
			'profile.personal.joinedLabel' => 'Зарегистрирован',
			'profile.personal.empty' => 'Не указано',
			'profile.personal.edit' => 'Редактировать',
			'profile.personal.loadFailed' => 'Не удалось загрузить данные',
			'masters.viewProfile' => 'Смотреть профиль',
			'masters.loadMore' => 'Показать ещё мастеров',
			'masters.searchLoadedOnly' => 'Поиск среди загруженных мастеров. Загрузите ещё, чтобы увидеть остальных.',
			'masters.masterList' => 'Список мастеров',
			'masters.completedWorks' => 'ВЫПОЛНЕНО',
			'masters.experience' => 'ОПЫТ',
			'masters.repeatContact' => 'ПОВТОРНЫЙ КОНТАКТ',
			'masters.filterTitle' => 'Настройки поиска',
			'masters.professionType' => 'Вид услуги',
			'masters.regionAndDistrict' => 'ОБЛАСТЬ / РАЙОН',
			'masters.region' => 'Область',
			'masters.selectRegion' => 'Выберите область',
			'masters.allRegions' => 'Все области',
			'masters.priceRange' => 'ДИАПАЗОН ЦЕН (СУМ)',
			'masters.minPrice' => 'Мин',
			'masters.maxPrice' => 'Макс',
			'masters.minimumRating' => 'МИНИМАЛЬНЫЙ РЕЙТИНГ',
			'masters.clear' => 'Очистить',
			'masters.apply' => 'Применить',
			'masters.aboutTitle' => 'О нас',
			'masters.aboutDescription' => 'Профессиональная укладка плитки. Опыт работы 5 лет и гарантия высокого качества. Выполняем работы любой сложности в срок. Работаем с современным оборудованием.',
			'masters.portfolioTitle' => 'Примеры работ',
			'masters.reviewsTitle' => 'Отзывы',
			'masters.reviewsCount' => ({required Object count}) => 'Отзывы (${count})',
			'masters.noReviews' => 'Отзывов пока нет — вы можете быть первым.',
			'masters.estimatedPriceNotice' => 'Ориентировочная цена — точная сумма согласовывается в чате в зависимости от объема работ.',
			'masters.all' => 'Все',
			'masters.windowProfession' => 'Окна',
			'masters.roofProfession' => 'Крыша',
			'masters.cementProfession' => 'Цемент',
			'masters.floorProfession' => 'Пол',
			'masters.tashkentCity' => 'г. Ташкент',
			'masters.tashkentRegion' => 'Ташкентская область',
			'masters.ferganaRegion' => 'Ферганская область',
			'masters.samarkandRegion' => 'Самаркандская область',
			'masters.andijanRegion' => 'Андижанская область',
			'masters.namanganRegion' => 'Наманганская область',
			'masters.bukharaRegion' => 'Бухарская область',
			'masters.khorezmRegion' => 'Хорезмская область',
			'masters.kashkadaryaRegion' => 'Кашкадарьинская область',
			'masters.surkhandaryaRegion' => 'Сурхандарьинская область',
			'masters.callMaster' => 'Вызвать мастера',
			'masters.aboutMaster' => 'О мастере',
			'masters.searchHint' => 'Имя, направление или номер телефона',
			'masters.noName' => 'Имя не указано',
			'masters.noSpecialty' => 'Направление не указано',
			'masters.noExperience' => 'Опыт не указан',
			'masters.experienceYears' => ({required Object count}) => 'Опыт ${count} лет',
			'masters.noAddress' => 'Нет адреса',
			'masters.completedOrders' => ({required Object count}) => '${count} работ',
			'masters.newMaster' => 'Новый мастер',
			'masters.loadFailed' => 'Не удалось загрузить список',
			'masters.noMastersYet' => 'Мастеров пока нет',
			'masters.searchNotFound' => ({required Object query}) => 'По запросу «${query}» мастера не найдены.',
			'masters.regionNotFound' => ({required Object region}) => 'В регионе ${region} мастера не найдены.',
			'masters.specialtyNotFound' => 'В этом направлении пока нет зарегистрированных мастеров.',
			'masters.defaultEmpty' => 'Мастера появятся здесь после регистрации.',
			'masters.prices' => 'Цены',
			'masters.notRated' => 'Пока нет оценок',
			'masters.rating' => 'Рейтинг',
			'masters.completed' => 'Выполнено',
			'masters.reviews' => 'Отзывы',
			'appUpdate.eyebrow' => 'ОБНОВЛЕНИЕ',
			'appUpdate.titleOptional' => 'Доступна новая версия',
			'appUpdate.titleRequired' => 'Требуется обновление',
			'appUpdate.bodyOptional' => 'Вышла новая версия Ustachi. Обновите приложение, чтобы использовать последние исправления и возможности.',
			'appUpdate.bodyRequired' => 'Эта версия больше не поддерживается. Обновите приложение, чтобы продолжить использование.',
			'appUpdate.whatsNew' => 'ЧТО НОВОГО',
			'appUpdate.versionFrom' => 'У вас',
			'appUpdate.versionTo' => 'Новая',
			'appUpdate.update' => 'Обновить',
			'appUpdate.later' => 'Позже',
			'appUpdate.openFailed' => 'Не удалось открыть ссылку. Обновите приложение вручную в магазине.',
			_ => null,
		};
	}
}
