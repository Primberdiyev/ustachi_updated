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
class TranslationsTr extends Translations with BaseTranslations<AppLocale, Translations> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	TranslationsTr({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.tr,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		super.$meta.setFlatMapFunction($meta.getTranslation); // copy base translations to super.$meta
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <tr>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	@override dynamic operator[](String key) => $meta.getTranslation(key) ?? super.$meta.getTranslation(key);

	late final TranslationsTr _root = this; // ignore: unused_field

	@override 
	TranslationsTr $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => TranslationsTr(meta: meta ?? this.$meta);

	// Translations
	@override String get applicationName => 'Ustachi';
	@override late final _TranslationsCommonTr common = _TranslationsCommonTr._(_root);
	@override late final _TranslationsOnboardingTr onboarding = _TranslationsOnboardingTr._(_root);
	@override late final _TranslationsAuthTr auth = _TranslationsAuthTr._(_root);
	@override late final _TranslationsCountryTr country = _TranslationsCountryTr._(_root);
	@override late final _TranslationsHomeTr home = _TranslationsHomeTr._(_root);
	@override late final _TranslationsCalculatePageTr calculatePage = _TranslationsCalculatePageTr._(_root);
	@override late final _TranslationsProfileTr profile = _TranslationsProfileTr._(_root);
	@override late final _TranslationsDashboardTr dashboard = _TranslationsDashboardTr._(_root);
	@override late final _TranslationsOrdersTr orders = _TranslationsOrdersTr._(_root);
	@override late final _TranslationsOwnOrdersTr ownOrders = _TranslationsOwnOrdersTr._(_root);
	@override late final _TranslationsOrderFormTr orderForm = _TranslationsOrderFormTr._(_root);
	@override late final _TranslationsChatTr chat = _TranslationsChatTr._(_root);
	@override late final _TranslationsNotificationsTr notifications = _TranslationsNotificationsTr._(_root);
	@override late final _TranslationsMastersTr masters = _TranslationsMastersTr._(_root);
	@override late final _TranslationsOrderFlowTr orderFlow = _TranslationsOrderFlowTr._(_root);
	@override late final _TranslationsCompanyTr company = _TranslationsCompanyTr._(_root);
	@override late final _TranslationsCompanyRatesTr companyRates = _TranslationsCompanyRatesTr._(_root);
	@override late final _TranslationsMaterialsTr materials = _TranslationsMaterialsTr._(_root);
	@override late final _TranslationsProfessionalTr professional = _TranslationsProfessionalTr._(_root);
	@override late final _TranslationsAppUpdateTr appUpdate = _TranslationsAppUpdateTr._(_root);
}

// Path: common
class _TranslationsCommonTr extends TranslationsCommonUz {
	_TranslationsCommonTr._(TranslationsTr root) : this._root = root, super.internal(root);

	final TranslationsTr _root; // ignore: unused_field

	// Translations
	@override String get ok => 'Tamam';
	@override String get start => 'Başla';
	@override String get cancel => 'Vazgeç';
	@override String get save => 'Kaydet';
	@override String get delete => 'Sil';
	@override String get edit => 'Düzenle';
	@override String get close => 'Kapat';
	@override String get back => 'Geri';
	@override String get next => 'İleri';
	@override String get skip => 'Atla';
	@override String get enter => 'Girin';
	@override String get wentWrong => 'Bir hata oluştu. Lütfen biraz sonra tekrar deneyin!';
	@override String get common => 'Genel';
	@override String get select => 'Seç';
	@override String get retry => 'Tekrar dene';
	@override String get refresh => 'Yenile';
	@override String get saved => 'Kaydedildi';
	@override String get saveFailed => 'Kaydedilmedi — tekrar deneyin';
	@override String get notFound => 'Bulunamadı';
	@override String get empty => 'Boş';
	@override String get loading => 'Yükleniyor…';
	@override String get yes => 'Evet';
	@override String get no => 'Hayır';
	@override String get add => 'Ekle';
	@override String get copy => 'Kopyala';
	@override String get apply => 'Uygula';
	@override String get reset => 'Sıfırla';
	@override String get done => 'Hazır';
	@override String get all => 'Tümü';
	@override String get som => 'som';
	@override String get cm => 'cm';
	@override String get mm => 'mm';
	@override String get pcs => 'adet';
	@override String get hoursShort => 'sa';
	@override String get minutesShort => 'dk';
	@override List<String> get months => [
		'Ocak',
		'Şubat',
		'Mart',
		'Nisan',
		'Mayıs',
		'Haziran',
		'Temmuz',
		'Ağustos',
		'Eylül',
		'Ekim',
		'Kasım',
		'Aralık',
	];
	@override List<String> get weekdays => [
		'Pazar',
		'Pazartesi',
		'Salı',
		'Çarşamba',
		'Perşembe',
		'Cuma',
		'Cumartesi',
	];
	@override String get today => 'Bugün';
	@override String get tomorrow => 'Yarın';
	@override String get comingSoon => 'Yakında';
}

// Path: onboarding
class _TranslationsOnboardingTr extends TranslationsOnboardingUz {
	_TranslationsOnboardingTr._(TranslationsTr root) : this._root = root, super.internal(root);

	final TranslationsTr _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsOnboardingStep1Tr step1 = _TranslationsOnboardingStep1Tr._(_root);
	@override late final _TranslationsOnboardingStep2Tr step2 = _TranslationsOnboardingStep2Tr._(_root);
	@override late final _TranslationsOnboardingStep3Tr step3 = _TranslationsOnboardingStep3Tr._(_root);
}

// Path: auth
class _TranslationsAuthTr extends TranslationsAuthUz {
	_TranslationsAuthTr._(TranslationsTr root) : this._root = root, super.internal(root);

	final TranslationsTr _root; // ignore: unused_field

	// Translations
	@override String get tagline => 'USTANIN ÇALIŞMA ALANI';
	@override late final _TranslationsAuthCommonTr common = _TranslationsAuthCommonTr._(_root);
	@override late final _TranslationsAuthPhoneTr phone = _TranslationsAuthPhoneTr._(_root);
	@override late final _TranslationsAuthOtpTr otp = _TranslationsAuthOtpTr._(_root);
	@override late final _TranslationsAuthProfileTr profile = _TranslationsAuthProfileTr._(_root);
	@override late final _TranslationsAuthTelegramTr telegram = _TranslationsAuthTelegramTr._(_root);
}

// Path: country
class _TranslationsCountryTr extends TranslationsCountryUz {
	_TranslationsCountryTr._(TranslationsTr root) : this._root = root, super.internal(root);

	final TranslationsTr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Ülkenizi seçin';
	@override String get subtitle => 'Uygulama dili ülkenize göre seçilir. Daha sonra profilinizden değiştirebilirsiniz.';
	@override String get continueBtn => 'Devam et';
	@override String get changeTitle => 'Ülke ve dil';
}

// Path: home
class _TranslationsHomeTr extends TranslationsHomeUz {
	_TranslationsHomeTr._(TranslationsTr root) : this._root = root, super.internal(root);

	final TranslationsTr _root; // ignore: unused_field

	// Translations
	@override String get main => 'Ana sayfa';
	@override String get chatting => 'Sohbet';
	@override String get profile => 'Profil';
	@override String get title => 'Profil';
	@override String get loadError => 'Profil yüklenmedi';
	@override String get retry => 'Tekrar dene';
	@override String get phone => 'Telefon';
	@override String get role => 'Rol';
	@override String get status => 'Durum';
	@override String get active => 'Aktif';
	@override String get inactive => 'Pasif';
	@override String get logout => 'Çıkış';
	@override String get hi => 'Merhaba';
	@override String get serviceType => 'Hizmet türleri';
	@override String get lastOrders => 'Son siparişler';
	@override String get all => 'Tümü';
	@override String get tapRepair => 'Musluk tamiri';
	@override String get chandelierInstallation => 'Avize montajı';
	@override String get completed => 'Tamamlandı';
	@override String get inProgress => 'Devam ediyor';
	@override String get window => 'Pencere';
	@override String get furtiniture => 'Mobilya';
	@override String get electric => 'Elektrik';
	@override String get plumber => 'Tesisat';
}

// Path: calculatePage
class _TranslationsCalculatePageTr extends TranslationsCalculatePageUz {
	_TranslationsCalculatePageTr._(TranslationsTr root) : this._root = root, super.internal(root);

	final TranslationsTr _root; // ignore: unused_field

	// Translations
	@override String get window => 'Pencere';
	@override String get door => 'Kapı';
	@override String get glass => 'Kemerler';
	@override String get windowConfigurator => 'Pencere yapılandırması';
	@override String get windowLayouts => 'Bölme türleri';
	@override String get windowPremiumLayouts => 'Premium seçenekler';
	@override String get windowModernLayouts => 'Modern seçenekler';
	@override String get doorConfigurator => 'Kapı yapılandırması';
	@override String get doorModels => 'Kapı modelleri';
	@override String get doorExtraModels => 'Ek modeller';
	@override String get material => 'Malzeme';
	@override String get plastic => 'Plastik';
	@override String get aluminium => 'Alüminyum';
	@override String get termo => 'Termo';
	@override String get glassShowcase => 'Kemer seçenekleri';
	@override String get customTemplateTitleWindow => 'Kendi pencerenizi oluşturun';
	@override String get customTemplateTitleDoor => 'Kendi kapınızı oluşturun';
	@override String get customTemplateTitleArch => 'Kendi kemerinizi oluşturun';
	@override String get customTemplateSubtitle => 'Hazır şablon değil — ölçüyü ve bölmeyi kendiniz çizersiniz';
	@override String get customTemplateAction => 'Başla';
	@override String get readyTemplates => 'Hazır şablonlar';
}

// Path: profile
class _TranslationsProfileTr extends TranslationsProfileUz {
	_TranslationsProfileTr._(TranslationsTr root) : this._root = root, super.internal(root);

	final TranslationsTr _root; // ignore: unused_field

	// Translations
	@override String get personalData => 'Kişisel bilgiler';
	@override String get professional => 'Mesleki bilgiler';
	@override String get company => 'İşletme';
	@override String get myOrders => 'Siparişlerim';
	@override String get settings => 'Ayarlar';
	@override String get support => 'Bize ulaşın';
	@override String get logout => 'Çıkış';
	@override String get logoutTitle => 'Hesaptan çıkılsın mı?';
	@override String get logoutMessage => 'İndirilen fiyatlar ve hesaplama verileri cihazdan silinecek. Tekrar giriş yaptığınızda yeniden indirilecek.';
	@override String get logoutConfirm => 'Evet, çık';
	@override String get loggingOut => 'Çıkılıyor...';
	@override String get loggingOutHint => 'Oturum kapatılıyor, fiyat önbelleği temizleniyor';
	@override String get logoutFailed => 'Sunucudan çıkılamadı ama cihazdaki veriler temizlendi';
	@override late final _TranslationsProfilePersonalTr personal = _TranslationsProfilePersonalTr._(_root);
	@override late final _TranslationsProfileHelpTr help = _TranslationsProfileHelpTr._(_root);
}

// Path: dashboard
class _TranslationsDashboardTr extends TranslationsDashboardUz {
	_TranslationsDashboardTr._(TranslationsTr root) : this._root = root, super.internal(root);

	final TranslationsTr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Çalışma masası';
	@override String get greetingMorning => 'Günaydın,';
	@override String get greetingDay => 'İyi günler,';
	@override String get greetingEvening => 'İyi akşamlar,';
	@override String get master => 'usta';
	@override String get availableTitle => 'Sipariş kabul ediyorum';
	@override String get availableOn => 'Yeni talepler gelmeye devam edecek';
	@override String get availableOff => 'Talepler durduruldu';
	@override String get repairTitle => 'Tamire giderim';
	@override String get repairOn => 'Tamir talepleri de gelecek';
	@override String get repairOff => 'Tamir talepleri gelmeyecek';
	@override String get repairHint => 'Eski pencere-kapı ayarı, aksesuar veya cam değişimi';
	@override String get newRequests => 'Yeni talepler';
	@override String get activeOrders => 'Aktif siparişler';
	@override String get all => 'Tümü';
	@override String get quickCalculate => 'Pencere çizimi';
	@override String get quickCalculateHint => 'Pencere ve kapı çizimi';
	@override String get quickPortfolio => 'İş örneği';
	@override String get quickPortfolioHint => 'Tamamlanan işten ekleyin';
	@override String get emptyRequests => 'Yeni talep yok';
	@override String get emptyRequestsHint => 'Müsaitlik anahtarı açıksa talepler buraya düşer.';
	@override String get quickCompany => 'İşletme';
	@override String get quickCompanyHint => 'Ad ve logo';
	@override String get quickRates => 'Hizmet fiyatlarım';
	@override String get quickRatesHint => 'Alanınıza göre iş ücretleri';
	@override String get quickOrdersHeroTitle => 'Yeni siparişler ve Pazar';
	@override String get quickOrdersHeroHint => 'Alanınızdaki ilanları görün ve teklif gönderin';
	@override String get quickOpenOrders => 'Açık siparişler';
	@override String get quickOpenOrdersHint => 'Usta seçilmemiş ilanlar — teklif gönderin';
	@override String get calcStep1 => 'Çerçeve seçin';
	@override String get calcStep2 => 'Ayarlayın';
	@override String get calcStep3 => 'Çizim hazır';
}

// Path: orders
class _TranslationsOrdersTr extends TranslationsOrdersUz {
	_TranslationsOrdersTr._(TranslationsTr root) : this._root = root, super.internal(root);

	final TranslationsTr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Siparişler';
	@override String get segmentNew => 'Açık';
	@override String get segmentActive => 'Devam eden';
	@override String get segmentDone => 'Tamamlanan';
	@override String stepOf({required Object total, required Object step}) => '${total} aşamadan ${step}.';
	@override String lateDays({required Object days}) => '${days} gün gecikti';
	@override String get dueToday => 'Bugün bitiyor';
	@override String daysLeft({required Object days}) => '${days} gün kaldı';
	@override String get offerBtn => 'Teklif ver';
	@override String get retry => 'Tekrar dene';
	@override String get loadFailed => 'Siparişler yüklenemedi';
	@override String get emptyNewTitle => 'Açık sipariş yok';
	@override String get emptyNewMessage => 'Bölgenizde yeni bir ilan yayınlandığında burada görünür.';
	@override String get emptyActiveTitle => 'Aktif sipariş yok';
	@override String get emptyActiveMessage => 'Yeni bir talebi kabul ettiğinizde burada görünecek.';
	@override String get emptyDoneTitle => 'Tamamlanan iş yok';
	@override String get emptyDoneMessage => 'İlk siparişi teslim ettiğinizde burada görünecek.';
	@override late final _TranslationsOrdersStageTr stage = _TranslationsOrdersStageTr._(_root);
	@override late final _TranslationsOrdersDetailTr detail = _TranslationsOrdersDetailTr._(_root);
	@override late final _TranslationsOrdersRequestTr request = _TranslationsOrdersRequestTr._(_root);
	@override late final _TranslationsOrdersSpecTr spec = _TranslationsOrdersSpecTr._(_root);
	@override String get invalidId => 'Geçersiz sipariş numarası.';
	@override String get invalidRequestId => 'Geçersiz talep numarası.';
	@override late final _TranslationsOrdersOpenTr open = _TranslationsOrdersOpenTr._(_root);
	@override String get personalTitle => 'Siparişlerim';
}

// Path: ownOrders
class _TranslationsOwnOrdersTr extends TranslationsOwnOrdersUz {
	_TranslationsOwnOrdersTr._(TranslationsTr root) : this._root = root, super.internal(root);

	final TranslationsTr _root; // ignore: unused_field

	// Translations
	@override String get orderTitle => 'Sipariş';
	@override String itemsCount({required Object count}) => '${count} pencere';
	@override String get statusTitle => 'Sipariş durumu';
	@override String get statusRow => 'Durum';
	@override String get saving => 'Kaydediliyor…';
	@override String get tapToChange => 'Değiştirmek için dokunun';
	@override String get alreadyDone => 'Bu sipariş zaten tamamlandı.';
	@override String get cannotChange => 'Bu siparişin durumu değiştirilemez.';
	@override late final _TranslationsOwnOrdersStatusTr status = _TranslationsOwnOrdersStatusTr._(_root);
	@override late final _TranslationsOwnOrdersHintTr hint = _TranslationsOwnOrdersHintTr._(_root);
}

// Path: orderForm
class _TranslationsOrderFormTr extends TranslationsOrderFormUz {
	_TranslationsOrderFormTr._(TranslationsTr root) : this._root = root, super.internal(root);

	final TranslationsTr _root; // ignore: unused_field

	// Translations
	@override String get noProducts => 'Siparişte ürün yok.';
	@override String get queued => 'İnternet yok — sipariş sıraya alındı, kendisi gönderilecek.';
	@override String get saved => 'Sipariş kaydedildi';
	@override String get saveTitle => 'Siparişi kaydet';
	@override String get customer => 'Sipariş veren';
	@override String get nameLabel => 'Adı';
	@override String get nameHint => 'Ahmet';
	@override String get nameRequired => 'Ad yazın';
	@override String get addressHint => 'Chilanzar 9. blok';
	@override String get noteLabel => 'Ek not';
	@override String get noteHint => '2. kat, asansör yok';
	@override String itemsSummary({required Object kinds, required Object count}) => '${kinds} çeşit pencere · ${count} adet';
}

// Path: chat
class _TranslationsChatTr extends TranslationsChatUz {
	_TranslationsChatTr._(TranslationsTr root) : this._root = root, super.internal(root);

	final TranslationsTr _root; // ignore: unused_field

	// Translations
	@override String get threadsTitle => 'Sohbetler';
	@override String get conversation => 'Sohbet';
	@override String get messageHint => 'Mesaj yazın...';
	@override String get emptyChat => 'Fiyat ve şartları burada kararlaştırırsınız';
	@override String get emptyThreadsTitle => 'Henüz sohbet yok';
	@override String get emptyThreadsMessage => 'Bir usta siparişinize yanıt verdiğinde burada yazışırsınız.';
}

// Path: notifications
class _TranslationsNotificationsTr extends TranslationsNotificationsUz {
	_TranslationsNotificationsTr._(TranslationsTr root) : this._root = root, super.internal(root);

	final TranslationsTr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Bildirimler';
	@override String get markAllRead => 'Tümünü okundu yap';
	@override String get empty => 'Bildirim yok';
	@override String get open => 'Aç';
}

// Path: masters
class _TranslationsMastersTr extends TranslationsMastersUz {
	_TranslationsMastersTr._(TranslationsTr root) : this._root = root, super.internal(root);

	final TranslationsTr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Usta hakkında';
	@override String get master => 'Usta';
	@override String get client => 'Müşteri';
	@override String get write => 'Yaz';
	@override String get chooseThis => 'Bu ustayı seç';
	@override String get choose => 'Seç';
	@override String get chosen => 'Seçilen usta';
	@override String get notFound => 'Bilgi bulunamadı';
	@override String get works => 'Yaptığı işler';
	@override String reviews({required Object count}) => 'Yorumlar (${count})';
	@override String get reviewsLabel => 'Yorumlar';
	@override String get noReviews => 'Henüz yorum yok — ilk siz olabilirsiniz.';
	@override String experienceYears({required Object years}) => '${years} yıl deneyim';
	@override String get rating => 'Puan';
	@override String get completed => 'Tamamlanan';
	@override String responses({required Object count}) => '${count} yanıt';
	@override String get estimate => 'Hesap';
}

// Path: orderFlow
class _TranslationsOrderFlowTr extends TranslationsOrderFlowUz {
	_TranslationsOrderFlowTr._(TranslationsTr root) : this._root = root, super.internal(root);

	final TranslationsTr _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsOrderFlowStatusTr status = _TranslationsOrderFlowStatusTr._(_root);
	@override late final _TranslationsOrderFlowStageTr stage = _TranslationsOrderFlowStageTr._(_root);
	@override late final _TranslationsOrderFlowResponseTr response = _TranslationsOrderFlowResponseTr._(_root);
}

// Path: company
class _TranslationsCompanyTr extends TranslationsCompanyUz {
	_TranslationsCompanyTr._(TranslationsTr root) : this._root = root, super.internal(root);

	final TranslationsTr _root; // ignore: unused_field

	// Translations
	@override String get title => 'İşletme';
	@override String get nameLabel => 'İşletme adı';
	@override String get nameHint => 'Örneğin: Ustachi Servis';
	@override String get nameEmpty => 'İşletme adı girilmedi';
	@override String get nameNote => 'Sipariş formunda görünür';
	@override String get logoHint => 'Logo ekle';
}

// Path: companyRates
class _TranslationsCompanyRatesTr extends TranslationsCompanyRatesUz {
	_TranslationsCompanyRatesTr._(TranslationsTr root) : this._root = root, super.internal(root);

	final TranslationsTr _root; // ignore: unused_field

	// Translations
	@override String get onlyDigits => 'Yalnızca rakam';
}

// Path: materials
class _TranslationsMaterialsTr extends TranslationsMaterialsUz {
	_TranslationsMaterialsTr._(TranslationsTr root) : this._root = root, super.internal(root);

	final TranslationsTr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Malzemeler';
	@override String get on => 'Bu malzemeyle çalışıyorum — siparişler gelecek';
	@override String get off => 'Kapalı — bu malzemedeki siparişler gelmeyecek';
	@override String get allOff => 'En az bir malzeme açık kalmalı';
}

// Path: professional
class _TranslationsProfessionalTr extends TranslationsProfessionalUz {
	_TranslationsProfessionalTr._(TranslationsTr root) : this._root = root, super.internal(root);

	final TranslationsTr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Mesleki bilgiler';
	@override String get headline => 'Nasıl bir usta olduğunuzu anlatın';
	@override String get headlineHint => 'Müşteri sizi seçmeden önce bu bilgileri görür. Sonra istediğiniz zaman değiştirebilirsiniz.';
	@override String get specialty => 'Uzmanlık alanları';
	@override String get specialtyPick => 'Uzmanlık alanlarınızı seçin';
	@override String get specialtyLoadFailed => 'Uzmanlık listesi yüklenmedi — internetinizi kontrol edip tekrar girin.';
	@override String get experienceQuestion => 'Kaç yıllık deneyiminiz var?';
	@override String get experienceHint => 'Örneğin: 5';
	@override String get experienceRequired => 'Deneyimi girin';
	@override String get experienceRange => 'Deneyim 0 ile 70 arasında olmalı';
	@override String get aboutLabel => 'Kendiniz hakkında (isteğe bağlı)';
	@override String get aboutHint => 'Hangi işleri yaparsınız, neye dikkat edersiniz — kısaca yazın.';
	@override String get works => 'Yaptığınız işler';
	@override String get worksHint => 'Fotoğraf eklerseniz müşteri işinizi görür ve sizi seçme ihtimali artar. İsteğe bağlı — sonra da ekleyebilirsiniz.';
	@override String get deleteSampleTitle => 'Örnek silinsin mi?';
	@override String get deleteSampleMessage => 'Müşteriler bu fotoğrafı artık göremeyecek.';
	@override String get deleteFailed => 'Silinemedi';
	@override String get pickSpecialty => 'En az bir alan seçin';
	@override String get specialtyHint => 'Birkaçını seçebilirsiniz — siparişler yalnızca bu alanlardan gelir.';
}

// Path: appUpdate
class _TranslationsAppUpdateTr extends TranslationsAppUpdateUz {
	_TranslationsAppUpdateTr._(TranslationsTr root) : this._root = root, super.internal(root);

	final TranslationsTr _root; // ignore: unused_field

	// Translations
	@override String get eyebrow => 'GÜNCELLEME';
	@override String get titleOptional => 'Yeni sürüm hazır';
	@override String get titleRequired => 'Güncelleme gerekli';
	@override String get bodyOptional => 'Ustachi Pro\'nun yeni sürümü çıktı. Son düzeltmeler ve özellikler için güncelleyin.';
	@override String get bodyRequired => 'Bu sürüm artık desteklenmiyor. Uygulamayı kullanmaya devam etmek için güncelleyin.';
	@override String get whatsNew => 'NELER YENİ';
	@override String get versionFrom => 'Sizde';
	@override String get versionTo => 'Yeni';
	@override String get update => 'Güncelle';
	@override String get later => 'Daha sonra';
	@override String get openFailed => 'Bağlantı açılamadı. Uygulamayı mağazadan elle güncelleyin.';
}

// Path: onboarding.step1
class _TranslationsOnboardingStep1Tr extends TranslationsOnboardingStep1Uz {
	_TranslationsOnboardingStep1Tr._(TranslationsTr root) : this._root = root, super.internal(root);

	final TranslationsTr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Kendi alanınızı seçin';
	@override String get description => 'Pencere, çatı, tuğla, elektrik, tesisat, fayans, boya… 25\'ten fazla alan. Siparişler sizin alanınıza göre gelir.';
}

// Path: onboarding.step2
class _TranslationsOnboardingStep2Tr extends TranslationsOnboardingStep2Uz {
	_TranslationsOnboardingStep2Tr._(TranslationsTr root) : this._root = root, super.internal(root);

	final TranslationsTr _root; // ignore: unused_field

	// Translations
	@override String get title => 'İşler sizi bulur';
	@override String get description => 'Bölgenize ve alanınıza uygun yeni ilanlar anında bildirim olarak gelir — aramanıza gerek kalmaz.';
}

// Path: onboarding.step3
class _TranslationsOnboardingStep3Tr extends TranslationsOnboardingStep3Uz {
	_TranslationsOnboardingStep3Tr._(TranslationsTr root) : this._root = root, super.internal(root);

	final TranslationsTr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Fiyatı siz belirlersiniz';
	@override String get description => 'Kendi fiyatlarınızı girersiniz, müşteriyle sohbette anlaşır ve işin aşamalarını işaretlersiniz.';
}

// Path: auth.common
class _TranslationsAuthCommonTr extends TranslationsAuthCommonUz {
	_TranslationsAuthCommonTr._(TranslationsTr root) : this._root = root, super.internal(root);

	final TranslationsTr _root; // ignore: unused_field

	// Translations
	@override String get invalidPhone => 'Geçerli bir telefon numarası girin';
	@override String get cancel => 'Vazgeç';
}

// Path: auth.phone
class _TranslationsAuthPhoneTr extends TranslationsAuthPhoneUz {
	_TranslationsAuthPhoneTr._(TranslationsTr root) : this._root = root, super.internal(root);

	final TranslationsTr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Uygulamaya giriş';
	@override String get subtitle => 'Numaranızı girin — SMS ile 6 haneli kod göndereceğiz. Şifre gerekmez.';
	@override String get label => 'Telefon numarası';
	@override String get continueBtn => 'Devam et';
	@override String get orOption => 'veya';
	@override String get telegramBtn => 'Telegram ile giriş yap';
	@override String get telegramHint => 'Bot, giriş için Telegram hesabınıza bağlı numarayı isteyecek. SMS gönderilmez.';
	@override String get telegramOpenError => 'Telegram botu açılamadı. Lütfen tekrar deneyin.';
	@override String get agreementPrefix => 'Devam ederek ';
	@override String get terms => 'Kullanım koşullarını';
	@override String get and => ' ve ';
	@override String get privacy => 'Gizlilik politikasını';
	@override String get agreementSuffix => ' kabul etmiş olursunuz.';
	@override String get audienceRedirect => 'Usta mı arıyorsunuz? «Ustachi» indirin';
	@override String get audienceTitle => 'Dikkat: bu uygulama ustalar için';
}

// Path: auth.otp
class _TranslationsAuthOtpTr extends TranslationsAuthOtpUz {
	_TranslationsAuthOtpTr._(TranslationsTr root) : this._root = root, super.internal(root);

	final TranslationsTr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Kodu girin';
	@override String sentMessage({required Object phone}) => '${phone} numarasına gönderilen 6 haneli kodu girin';
	@override String get invalidCode => '6 hanenin tamamını girin';
	@override String get resend => 'Kodu tekrar gönder';
	@override String get resendIn => 'Tekrar gönder';
	@override String get confirmBtn => 'Onayla';
	@override String get changeNumber => 'Başka numara gir';
}

// Path: auth.profile
class _TranslationsAuthProfileTr extends TranslationsAuthProfileUz {
	_TranslationsAuthProfileTr._(TranslationsTr root) : this._root = root, super.internal(root);

	final TranslationsTr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Kendiniz hakkında';
	@override String get subtitle => 'Müşteriler sizi bu isimle görecek. Daha sonra profilinizden değiştirebilirsiniz.';
	@override String get fullNameLabel => 'Ad soyad';
	@override String get fullNameHint => 'Girin';
	@override String get requiredName => 'Ad soyadınızı girin';
	@override String get addPhoto => 'Fotoğraf ekle';
	@override String get changePhoto => 'Fotoğrafı değiştir';
	@override String get saveBtn => 'Kaydet ve devam et';
	@override String get skip => 'Sonra dolduracağım';
	@override String get regionLabel => 'İl';
	@override String get regionHint => 'İl seçin';
	@override String get districtLabel => 'İlçe / şehir';
	@override String get districtHint => 'İlçe seçin';
	@override String get addressLabel => 'Adres';
	@override String get addressHint => 'Sokak, ev numarası';
	@override String get requiredRegion => 'İl seçin';
	@override String get requiredDistrict => 'İlçe seçin';
	@override String get loadFailed => 'Liste yüklenemedi';
}

// Path: auth.telegram
class _TranslationsAuthTelegramTr extends TranslationsAuthTelegramUz {
	_TranslationsAuthTelegramTr._(TranslationsTr root) : this._root = root, super.internal(root);

	final TranslationsTr _root; // ignore: unused_field

	// Translations
	@override String get loadingTitle => 'Telegram ile giriş yapılıyor';
	@override String get loadingHint => 'Tek kullanımlık bağlantı doğrulanıyor…';
	@override String get invalidLink => 'Telegram bağlantısı geçersiz.';
	@override String get expiredLink => 'Bağlantının süresi doldu veya daha önce kullanıldı. Botta yeniden başlayın.';
	@override String get retry => 'Tekrar dene';
	@override String get restartBot => 'Botta yeniden başla';
	@override String get smsOption => 'SMS ile giriş yap';
}

// Path: profile.personal
class _TranslationsProfilePersonalTr extends TranslationsProfilePersonalUz {
	_TranslationsProfilePersonalTr._(TranslationsTr root) : this._root = root, super.internal(root);

	final TranslationsTr _root; // ignore: unused_field

	// Translations
	@override String get sectionPersonal => 'Kişisel';
	@override String get sectionAddress => 'Adres';
	@override String get sectionProfessional => 'Mesleki';
	@override String get phoneLabel => 'Telefon';
	@override String get phoneNote => 'Numara hesabın kimliğidir, değiştirilemez';
	@override String get joinedLabel => 'Kayıt tarihi';
	@override String get empty => 'Girilmemiş';
	@override String get edit => 'Düzenle';
	@override String get openProfessional => 'Uzmanlık, deneyim ve iş örnekleri';
	@override String get loadFailed => 'Bilgiler yüklenemedi';
}

// Path: profile.help
class _TranslationsProfileHelpTr extends TranslationsProfileHelpUz {
	_TranslationsProfileHelpTr._(TranslationsTr root) : this._root = root, super.internal(root);

	final TranslationsTr _root; // ignore: unused_field

	// Translations
	@override String get subtitle => 'Soru veya sorun varsa — yazın ya da arayın';
	@override String get callLabel => 'Ara';
	@override String get emailLabel => 'E-posta';
	@override String get telegramLabel => 'Telegram kanalımız';
	@override String get telegramHint => 'Haberler ve duyurular';
	@override String get workHours => 'Pzt–Cmt, 9:00–19:00';
	@override String get copied => 'Kopyalandı';
}

// Path: orders.stage
class _TranslationsOrdersStageTr extends TranslationsOrdersStageUz {
	_TranslationsOrdersStageTr._(TranslationsTr root) : this._root = root, super.internal(root);

	final TranslationsTr _root; // ignore: unused_field

	// Translations
	@override String get accepted => 'Teklif kabul edildi';
	@override String get measured => 'Ölçü alındı';
	@override String get production => 'Üretim';
	@override String get installation => 'Montaj';
	@override String get handover => 'Teslim ve ödeme';
}

// Path: orders.detail
class _TranslationsOrdersDetailTr extends TranslationsOrdersDetailUz {
	_TranslationsOrdersDetailTr._(TranslationsTr root) : this._root = root, super.internal(root);

	final TranslationsTr _root; // ignore: unused_field

	// Translations
	@override String get stages => 'Aşamalar';
	@override String get spec => 'Şartname';
	@override String get client => 'Müşteri';
	@override String get total => 'Toplam';
	@override String get prepaid => 'Ön ödeme';
	@override String get remaining => 'Kalan';
	@override String get dueDate => 'Kararlaştırılan süre';
	@override String get finishOrder => 'Teslim et ve bitir';
	@override String get completed => 'Sipariş tamamlandı';
	@override String stageDone({required Object stage}) => '${stage} tamamlandı';
	@override String get notFound => 'Sipariş bulunamadı';
	@override String get drawings => 'Çizimler';
	@override String get drawingsHint => 'İki parmakla yakınlaştırın · ölçüler mm cinsinden';
	@override String get markMeasured => 'Ölçü alındı';
	@override String get markProduction => 'Üretim başladı';
	@override String get markInstallation => 'Montaja çıktık';
	@override String get stageSaved => 'İşaretlendi — müşteriye bildirim gitti';
}

// Path: orders.request
class _TranslationsOrdersRequestTr extends TranslationsOrdersRequestUz {
	_TranslationsOrdersRequestTr._(TranslationsTr root) : this._root = root, super.internal(root);

	final TranslationsTr _root; // ignore: unused_field

	// Translations
	@override String get title => 'Talep';
	@override String get clientSpec => 'Müşterinin hesapladığı şartname';
	@override String get priceOffer => 'Fiyat teklifi';
	@override String get serviceFee => 'Montaj ve nakliye';
	@override String get yourOffer => 'Sizin teklifiniz';
	@override String get workDays => 'Süre — iş günü';
	@override String get note => 'Not (isteğe bağlı)';
	@override String get notePlaceholder => 'Müşteriye ek not…';
	@override String get send => 'Teklifi gönder';
	@override String get decline => 'Reddet';
	@override String get declineTitle => 'Talep reddedilsin mi?';
	@override String get declineMessage => 'Bu talep listeden tamamen silinecek.';
	@override String expiresIn({required Object time}) => '${time} kaldı';
	@override String get expired => 'Süresi doldu';
	@override String distance({required Object km}) => '${km} km';
	@override String get sent => 'Teklif gönderildi';
	@override String get invalidFee => 'İşçilik ücreti negatif olamaz';
	@override String get chatNote => 'Fiyat ve şartları müşteriyle sohbette kararlaştırırsınız.';
	@override String get withdrawOffer => 'Teklifi geri çek';
	@override String get declineInviteTitle => 'Teklifi reddedelim mi?';
	@override String get declineInviteMessage => 'Müşteri hemen bilgilendirilir ve başka usta seçebilir.';
	@override String get clientPrice => 'Sipariş fiyatı';
	@override String get priceInChat => 'Fiyat sohbette kararlaştırılır';
}

// Path: orders.spec
class _TranslationsOrdersSpecTr extends TranslationsOrdersSpecUz {
	_TranslationsOrdersSpecTr._(TranslationsTr root) : this._root = root, super.internal(root);

	final TranslationsTr _root; // ignore: unused_field

	// Translations
	@override String get size => 'Ölçü (mm)';
	@override String get shape => 'Şekil';
	@override String get brand => 'Marka';
	@override String get color => 'Renk';
	@override String get material => 'Malzeme';
	@override String get glass => 'Cam';
	@override String get sill => 'Denizlik (cm)';
	@override String get flower => 'Desen';
	@override String get address => 'Adres';
	@override String get product => 'Ürünler';
	@override String get phone => 'Telefon';
	@override String get discount => 'İndirim';
	@override String get note => 'Not';
	@override String itemsValue({required Object kinds, required Object count}) => '${kinds} çeşit · ${count} adet';
	@override late final _TranslationsOrdersSpecValuesTr values = _TranslationsOrdersSpecValuesTr._(_root);
	@override String get area => 'Alan';
	@override String get unitPrice => 'm² fiyatı';
	@override String get variant => 'Seviye';
}

// Path: orders.open
class _TranslationsOrdersOpenTr extends TranslationsOrdersOpenUz {
	_TranslationsOrdersOpenTr._(TranslationsTr root) : this._root = root, super.internal(root);

	final TranslationsTr _root; // ignore: unused_field

	// Translations
	@override String get offerSent => 'Teklif gönderildi';
	@override String get waitingClient => 'Müşterinin yanıtı bekleniyor';
	@override String offersCount({required Object count}) => '${count} teklif';
	@override String get beFirst => 'İlk siz olun';
	@override String get newBadge => 'Yeni';
	@override String get pageTitle => 'Açık siparişler';
	@override String get tabWaiting => 'Yanıt bekliyor';
	@override String get tabSent => 'Teklif gönderildi';
	@override String get emptySentTitle => 'Gönderilmiş teklif yok';
	@override String get emptySentMessage => 'Yanıtladığınız ilanlar burada müşterinin yanıtını bekler.';
	@override String get tabInvited => 'Size teklif';
	@override String get invitedBadge => 'Size teklif';
	@override String get repairBadge => 'Tamir';
	@override String get acceptInvite => 'Kabul ediyorum';
	@override String get emptyInvitedTitle => 'Kişisel teklif yok';
	@override String get emptyInvitedMessage => 'Müşterinin sizi seçtiği siparişler burada görünür.';
	@override String get invitedNote => 'Müşteri bu siparişi doğrudan size gönderdi — diğer ustalar göremez.';
}

// Path: ownOrders.status
class _TranslationsOwnOrdersStatusTr extends TranslationsOwnOrdersStatusUz {
	_TranslationsOwnOrdersStatusTr._(TranslationsTr root) : this._root = root, super.internal(root);

	final TranslationsTr _root; // ignore: unused_field

	// Translations
	@override String get draft => 'Taslak';
	@override String get newOrder => 'Yeni';
	@override String get inProgress => 'Devam ediyor';
	@override String get done => 'Tamamlandı';
	@override String get debt => 'Borçlu';
	@override String get cancelled => 'İptal edildi';
}

// Path: ownOrders.hint
class _TranslationsOwnOrdersHintTr extends TranslationsOwnOrdersHintUz {
	_TranslationsOwnOrdersHintTr._(TranslationsTr root) : this._root = root, super.internal(root);

	final TranslationsTr _root; // ignore: unused_field

	// Translations
	@override String get newOrder => 'Kabul edildi, henüz başlamadı';
	@override String get inProgress => 'Üretim ya da montaj sürüyor';
	@override String get done => 'Teslim edildi ve tamamı ödendi';
	@override String get debt => 'İş bitti ama ödeme tamamlanmadı';
	@override String get cancelled => 'Sipariş iptal edildi';
}

// Path: orderFlow.status
class _TranslationsOrderFlowStatusTr extends TranslationsOrderFlowStatusUz {
	_TranslationsOrderFlowStatusTr._(TranslationsTr root) : this._root = root, super.internal(root);

	final TranslationsTr _root; // ignore: unused_field

	// Translations
	@override String get published => 'Yayınlandı';
	@override String get assigned => 'Usta seçildi';
	@override String get completed => 'Tamamlandı';
	@override String get cancelled => 'İptal edildi';
	@override String get expired => 'Süresi doldu';
}

// Path: orderFlow.stage
class _TranslationsOrderFlowStageTr extends TranslationsOrderFlowStageUz {
	_TranslationsOrderFlowStageTr._(TranslationsTr root) : this._root = root, super.internal(root);

	final TranslationsTr _root; // ignore: unused_field

	// Translations
	@override String get accepted => 'Kabul edildi';
	@override String get measured => 'Ölçü alındı';
	@override String get production => 'Üretim';
	@override String get installation => 'Montaj';
	@override String get handover => 'Teslim edildi';
}

// Path: orderFlow.response
class _TranslationsOrderFlowResponseTr extends TranslationsOrderFlowResponseUz {
	_TranslationsOrderFlowResponseTr._(TranslationsTr root) : this._root = root, super.internal(root);

	final TranslationsTr _root; // ignore: unused_field

	// Translations
	@override String get interested => 'Kabul ediyorum';
	@override String get withdrawn => 'Vazgeçti';
	@override String get chosen => 'Seçildi';
	@override String get rejected => 'Seçilmedi';
}

// Path: orders.spec.values
class _TranslationsOrdersSpecValuesTr extends TranslationsOrdersSpecValuesUz {
	_TranslationsOrdersSpecValuesTr._(TranslationsTr root) : this._root = root, super.internal(root);

	final TranslationsTr _root; // ignore: unused_field

	// Translations
	@override String get plastic => 'Plastik';
	@override String get aluminium => 'Alüminyum';
	@override String get termo => 'Termo';
	@override String get doubleGlass => 'Çift cam';
	@override String get singleGlass => 'Tek cam';
	@override String get large => 'Büyük';
	@override String get medium => 'Orta';
	@override String get small => 'Küçük';
}

/// The flat map containing all translations for locale <tr>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on TranslationsTr {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'applicationName' => 'Ustachi',
			'common.ok' => 'Tamam',
			'common.start' => 'Başla',
			'common.cancel' => 'Vazgeç',
			'common.save' => 'Kaydet',
			'common.delete' => 'Sil',
			'common.edit' => 'Düzenle',
			'common.close' => 'Kapat',
			'common.back' => 'Geri',
			'common.next' => 'İleri',
			'common.skip' => 'Atla',
			'common.enter' => 'Girin',
			'common.wentWrong' => 'Bir hata oluştu. Lütfen biraz sonra tekrar deneyin!',
			'common.common' => 'Genel',
			'common.select' => 'Seç',
			'common.retry' => 'Tekrar dene',
			'common.refresh' => 'Yenile',
			'common.saved' => 'Kaydedildi',
			'common.saveFailed' => 'Kaydedilmedi — tekrar deneyin',
			'common.notFound' => 'Bulunamadı',
			'common.empty' => 'Boş',
			'common.loading' => 'Yükleniyor…',
			'common.yes' => 'Evet',
			'common.no' => 'Hayır',
			'common.add' => 'Ekle',
			'common.copy' => 'Kopyala',
			'common.apply' => 'Uygula',
			'common.reset' => 'Sıfırla',
			'common.done' => 'Hazır',
			'common.all' => 'Tümü',
			'common.som' => 'som',
			'common.cm' => 'cm',
			'common.mm' => 'mm',
			'common.pcs' => 'adet',
			'common.hoursShort' => 'sa',
			'common.minutesShort' => 'dk',
			'common.months.0' => 'Ocak',
			'common.months.1' => 'Şubat',
			'common.months.2' => 'Mart',
			'common.months.3' => 'Nisan',
			'common.months.4' => 'Mayıs',
			'common.months.5' => 'Haziran',
			'common.months.6' => 'Temmuz',
			'common.months.7' => 'Ağustos',
			'common.months.8' => 'Eylül',
			'common.months.9' => 'Ekim',
			'common.months.10' => 'Kasım',
			'common.months.11' => 'Aralık',
			'common.weekdays.0' => 'Pazar',
			'common.weekdays.1' => 'Pazartesi',
			'common.weekdays.2' => 'Salı',
			'common.weekdays.3' => 'Çarşamba',
			'common.weekdays.4' => 'Perşembe',
			'common.weekdays.5' => 'Cuma',
			'common.weekdays.6' => 'Cumartesi',
			'common.today' => 'Bugün',
			'common.tomorrow' => 'Yarın',
			'common.comingSoon' => 'Yakında',
			'onboarding.step1.title' => 'Kendi alanınızı seçin',
			'onboarding.step1.description' => 'Pencere, çatı, tuğla, elektrik, tesisat, fayans, boya… 25\'ten fazla alan. Siparişler sizin alanınıza göre gelir.',
			'onboarding.step2.title' => 'İşler sizi bulur',
			'onboarding.step2.description' => 'Bölgenize ve alanınıza uygun yeni ilanlar anında bildirim olarak gelir — aramanıza gerek kalmaz.',
			'onboarding.step3.title' => 'Fiyatı siz belirlersiniz',
			'onboarding.step3.description' => 'Kendi fiyatlarınızı girersiniz, müşteriyle sohbette anlaşır ve işin aşamalarını işaretlersiniz.',
			'auth.tagline' => 'USTANIN ÇALIŞMA ALANI',
			'auth.common.invalidPhone' => 'Geçerli bir telefon numarası girin',
			'auth.common.cancel' => 'Vazgeç',
			'auth.phone.title' => 'Uygulamaya giriş',
			'auth.phone.subtitle' => 'Numaranızı girin — SMS ile 6 haneli kod göndereceğiz. Şifre gerekmez.',
			'auth.phone.label' => 'Telefon numarası',
			'auth.phone.continueBtn' => 'Devam et',
			'auth.phone.orOption' => 'veya',
			'auth.phone.telegramBtn' => 'Telegram ile giriş yap',
			'auth.phone.telegramHint' => 'Bot, giriş için Telegram hesabınıza bağlı numarayı isteyecek. SMS gönderilmez.',
			'auth.phone.telegramOpenError' => 'Telegram botu açılamadı. Lütfen tekrar deneyin.',
			'auth.phone.agreementPrefix' => 'Devam ederek ',
			'auth.phone.terms' => 'Kullanım koşullarını',
			'auth.phone.and' => ' ve ',
			'auth.phone.privacy' => 'Gizlilik politikasını',
			'auth.phone.agreementSuffix' => ' kabul etmiş olursunuz.',
			'auth.phone.audienceRedirect' => 'Usta mı arıyorsunuz? «Ustachi» indirin',
			'auth.phone.audienceTitle' => 'Dikkat: bu uygulama ustalar için',
			'auth.otp.title' => 'Kodu girin',
			'auth.otp.sentMessage' => ({required Object phone}) => '${phone} numarasına gönderilen 6 haneli kodu girin',
			'auth.otp.invalidCode' => '6 hanenin tamamını girin',
			'auth.otp.resend' => 'Kodu tekrar gönder',
			'auth.otp.resendIn' => 'Tekrar gönder',
			'auth.otp.confirmBtn' => 'Onayla',
			'auth.otp.changeNumber' => 'Başka numara gir',
			'auth.profile.title' => 'Kendiniz hakkında',
			'auth.profile.subtitle' => 'Müşteriler sizi bu isimle görecek. Daha sonra profilinizden değiştirebilirsiniz.',
			'auth.profile.fullNameLabel' => 'Ad soyad',
			'auth.profile.fullNameHint' => 'Girin',
			'auth.profile.requiredName' => 'Ad soyadınızı girin',
			'auth.profile.addPhoto' => 'Fotoğraf ekle',
			'auth.profile.changePhoto' => 'Fotoğrafı değiştir',
			'auth.profile.saveBtn' => 'Kaydet ve devam et',
			'auth.profile.skip' => 'Sonra dolduracağım',
			'auth.profile.regionLabel' => 'İl',
			'auth.profile.regionHint' => 'İl seçin',
			'auth.profile.districtLabel' => 'İlçe / şehir',
			'auth.profile.districtHint' => 'İlçe seçin',
			'auth.profile.addressLabel' => 'Adres',
			'auth.profile.addressHint' => 'Sokak, ev numarası',
			'auth.profile.requiredRegion' => 'İl seçin',
			'auth.profile.requiredDistrict' => 'İlçe seçin',
			'auth.profile.loadFailed' => 'Liste yüklenemedi',
			'auth.telegram.loadingTitle' => 'Telegram ile giriş yapılıyor',
			'auth.telegram.loadingHint' => 'Tek kullanımlık bağlantı doğrulanıyor…',
			'auth.telegram.invalidLink' => 'Telegram bağlantısı geçersiz.',
			'auth.telegram.expiredLink' => 'Bağlantının süresi doldu veya daha önce kullanıldı. Botta yeniden başlayın.',
			'auth.telegram.retry' => 'Tekrar dene',
			'auth.telegram.restartBot' => 'Botta yeniden başla',
			'auth.telegram.smsOption' => 'SMS ile giriş yap',
			'country.title' => 'Ülkenizi seçin',
			'country.subtitle' => 'Uygulama dili ülkenize göre seçilir. Daha sonra profilinizden değiştirebilirsiniz.',
			'country.continueBtn' => 'Devam et',
			'country.changeTitle' => 'Ülke ve dil',
			'home.main' => 'Ana sayfa',
			'home.chatting' => 'Sohbet',
			'home.profile' => 'Profil',
			'home.title' => 'Profil',
			'home.loadError' => 'Profil yüklenmedi',
			'home.retry' => 'Tekrar dene',
			'home.phone' => 'Telefon',
			'home.role' => 'Rol',
			'home.status' => 'Durum',
			'home.active' => 'Aktif',
			'home.inactive' => 'Pasif',
			'home.logout' => 'Çıkış',
			'home.hi' => 'Merhaba',
			'home.serviceType' => 'Hizmet türleri',
			'home.lastOrders' => 'Son siparişler',
			'home.all' => 'Tümü',
			'home.tapRepair' => 'Musluk tamiri',
			'home.chandelierInstallation' => 'Avize montajı',
			'home.completed' => 'Tamamlandı',
			'home.inProgress' => 'Devam ediyor',
			'home.window' => 'Pencere',
			'home.furtiniture' => 'Mobilya',
			'home.electric' => 'Elektrik',
			'home.plumber' => 'Tesisat',
			'calculatePage.window' => 'Pencere',
			'calculatePage.door' => 'Kapı',
			'calculatePage.glass' => 'Kemerler',
			'calculatePage.windowConfigurator' => 'Pencere yapılandırması',
			'calculatePage.windowLayouts' => 'Bölme türleri',
			'calculatePage.windowPremiumLayouts' => 'Premium seçenekler',
			'calculatePage.windowModernLayouts' => 'Modern seçenekler',
			'calculatePage.doorConfigurator' => 'Kapı yapılandırması',
			'calculatePage.doorModels' => 'Kapı modelleri',
			'calculatePage.doorExtraModels' => 'Ek modeller',
			'calculatePage.material' => 'Malzeme',
			'calculatePage.plastic' => 'Plastik',
			'calculatePage.aluminium' => 'Alüminyum',
			'calculatePage.termo' => 'Termo',
			'calculatePage.glassShowcase' => 'Kemer seçenekleri',
			'calculatePage.customTemplateTitleWindow' => 'Kendi pencerenizi oluşturun',
			'calculatePage.customTemplateTitleDoor' => 'Kendi kapınızı oluşturun',
			'calculatePage.customTemplateTitleArch' => 'Kendi kemerinizi oluşturun',
			'calculatePage.customTemplateSubtitle' => 'Hazır şablon değil — ölçüyü ve bölmeyi kendiniz çizersiniz',
			'calculatePage.customTemplateAction' => 'Başla',
			'calculatePage.readyTemplates' => 'Hazır şablonlar',
			'profile.personalData' => 'Kişisel bilgiler',
			'profile.professional' => 'Mesleki bilgiler',
			'profile.company' => 'İşletme',
			'profile.myOrders' => 'Siparişlerim',
			'profile.settings' => 'Ayarlar',
			'profile.support' => 'Bize ulaşın',
			'profile.logout' => 'Çıkış',
			'profile.logoutTitle' => 'Hesaptan çıkılsın mı?',
			'profile.logoutMessage' => 'İndirilen fiyatlar ve hesaplama verileri cihazdan silinecek. Tekrar giriş yaptığınızda yeniden indirilecek.',
			'profile.logoutConfirm' => 'Evet, çık',
			'profile.loggingOut' => 'Çıkılıyor...',
			'profile.loggingOutHint' => 'Oturum kapatılıyor, fiyat önbelleği temizleniyor',
			'profile.logoutFailed' => 'Sunucudan çıkılamadı ama cihazdaki veriler temizlendi',
			'profile.personal.sectionPersonal' => 'Kişisel',
			'profile.personal.sectionAddress' => 'Adres',
			'profile.personal.sectionProfessional' => 'Mesleki',
			'profile.personal.phoneLabel' => 'Telefon',
			'profile.personal.phoneNote' => 'Numara hesabın kimliğidir, değiştirilemez',
			'profile.personal.joinedLabel' => 'Kayıt tarihi',
			'profile.personal.empty' => 'Girilmemiş',
			'profile.personal.edit' => 'Düzenle',
			'profile.personal.openProfessional' => 'Uzmanlık, deneyim ve iş örnekleri',
			'profile.personal.loadFailed' => 'Bilgiler yüklenemedi',
			'profile.help.subtitle' => 'Soru veya sorun varsa — yazın ya da arayın',
			'profile.help.callLabel' => 'Ara',
			'profile.help.emailLabel' => 'E-posta',
			'profile.help.telegramLabel' => 'Telegram kanalımız',
			'profile.help.telegramHint' => 'Haberler ve duyurular',
			'profile.help.workHours' => 'Pzt–Cmt, 9:00–19:00',
			'profile.help.copied' => 'Kopyalandı',
			'dashboard.title' => 'Çalışma masası',
			'dashboard.greetingMorning' => 'Günaydın,',
			'dashboard.greetingDay' => 'İyi günler,',
			'dashboard.greetingEvening' => 'İyi akşamlar,',
			'dashboard.master' => 'usta',
			'dashboard.availableTitle' => 'Sipariş kabul ediyorum',
			'dashboard.availableOn' => 'Yeni talepler gelmeye devam edecek',
			'dashboard.availableOff' => 'Talepler durduruldu',
			'dashboard.repairTitle' => 'Tamire giderim',
			'dashboard.repairOn' => 'Tamir talepleri de gelecek',
			'dashboard.repairOff' => 'Tamir talepleri gelmeyecek',
			'dashboard.repairHint' => 'Eski pencere-kapı ayarı, aksesuar veya cam değişimi',
			'dashboard.newRequests' => 'Yeni talepler',
			'dashboard.activeOrders' => 'Aktif siparişler',
			'dashboard.all' => 'Tümü',
			'dashboard.quickCalculate' => 'Pencere çizimi',
			'dashboard.quickCalculateHint' => 'Pencere ve kapı çizimi',
			'dashboard.quickPortfolio' => 'İş örneği',
			'dashboard.quickPortfolioHint' => 'Tamamlanan işten ekleyin',
			'dashboard.emptyRequests' => 'Yeni talep yok',
			'dashboard.emptyRequestsHint' => 'Müsaitlik anahtarı açıksa talepler buraya düşer.',
			'dashboard.quickCompany' => 'İşletme',
			'dashboard.quickCompanyHint' => 'Ad ve logo',
			'dashboard.quickRates' => 'Hizmet fiyatlarım',
			'dashboard.quickRatesHint' => 'Alanınıza göre iş ücretleri',
			'dashboard.quickOrdersHeroTitle' => 'Yeni siparişler ve Pazar',
			'dashboard.quickOrdersHeroHint' => 'Alanınızdaki ilanları görün ve teklif gönderin',
			'dashboard.quickOpenOrders' => 'Açık siparişler',
			'dashboard.quickOpenOrdersHint' => 'Usta seçilmemiş ilanlar — teklif gönderin',
			'dashboard.calcStep1' => 'Çerçeve seçin',
			'dashboard.calcStep2' => 'Ayarlayın',
			'dashboard.calcStep3' => 'Çizim hazır',
			'orders.title' => 'Siparişler',
			'orders.segmentNew' => 'Açık',
			'orders.segmentActive' => 'Devam eden',
			'orders.segmentDone' => 'Tamamlanan',
			'orders.stepOf' => ({required Object total, required Object step}) => '${total} aşamadan ${step}.',
			'orders.lateDays' => ({required Object days}) => '${days} gün gecikti',
			'orders.dueToday' => 'Bugün bitiyor',
			'orders.daysLeft' => ({required Object days}) => '${days} gün kaldı',
			'orders.offerBtn' => 'Teklif ver',
			'orders.retry' => 'Tekrar dene',
			'orders.loadFailed' => 'Siparişler yüklenemedi',
			'orders.emptyNewTitle' => 'Açık sipariş yok',
			'orders.emptyNewMessage' => 'Bölgenizde yeni bir ilan yayınlandığında burada görünür.',
			'orders.emptyActiveTitle' => 'Aktif sipariş yok',
			'orders.emptyActiveMessage' => 'Yeni bir talebi kabul ettiğinizde burada görünecek.',
			'orders.emptyDoneTitle' => 'Tamamlanan iş yok',
			'orders.emptyDoneMessage' => 'İlk siparişi teslim ettiğinizde burada görünecek.',
			'orders.stage.accepted' => 'Teklif kabul edildi',
			'orders.stage.measured' => 'Ölçü alındı',
			'orders.stage.production' => 'Üretim',
			'orders.stage.installation' => 'Montaj',
			'orders.stage.handover' => 'Teslim ve ödeme',
			'orders.detail.stages' => 'Aşamalar',
			'orders.detail.spec' => 'Şartname',
			'orders.detail.client' => 'Müşteri',
			'orders.detail.total' => 'Toplam',
			'orders.detail.prepaid' => 'Ön ödeme',
			'orders.detail.remaining' => 'Kalan',
			'orders.detail.dueDate' => 'Kararlaştırılan süre',
			'orders.detail.finishOrder' => 'Teslim et ve bitir',
			'orders.detail.completed' => 'Sipariş tamamlandı',
			'orders.detail.stageDone' => ({required Object stage}) => '${stage} tamamlandı',
			'orders.detail.notFound' => 'Sipariş bulunamadı',
			'orders.detail.drawings' => 'Çizimler',
			'orders.detail.drawingsHint' => 'İki parmakla yakınlaştırın · ölçüler mm cinsinden',
			'orders.detail.markMeasured' => 'Ölçü alındı',
			'orders.detail.markProduction' => 'Üretim başladı',
			'orders.detail.markInstallation' => 'Montaja çıktık',
			'orders.detail.stageSaved' => 'İşaretlendi — müşteriye bildirim gitti',
			'orders.request.title' => 'Talep',
			'orders.request.clientSpec' => 'Müşterinin hesapladığı şartname',
			'orders.request.priceOffer' => 'Fiyat teklifi',
			'orders.request.serviceFee' => 'Montaj ve nakliye',
			'orders.request.yourOffer' => 'Sizin teklifiniz',
			'orders.request.workDays' => 'Süre — iş günü',
			'orders.request.note' => 'Not (isteğe bağlı)',
			'orders.request.notePlaceholder' => 'Müşteriye ek not…',
			'orders.request.send' => 'Teklifi gönder',
			'orders.request.decline' => 'Reddet',
			'orders.request.declineTitle' => 'Talep reddedilsin mi?',
			'orders.request.declineMessage' => 'Bu talep listeden tamamen silinecek.',
			'orders.request.expiresIn' => ({required Object time}) => '${time} kaldı',
			'orders.request.expired' => 'Süresi doldu',
			'orders.request.distance' => ({required Object km}) => '${km} km',
			'orders.request.sent' => 'Teklif gönderildi',
			'orders.request.invalidFee' => 'İşçilik ücreti negatif olamaz',
			'orders.request.chatNote' => 'Fiyat ve şartları müşteriyle sohbette kararlaştırırsınız.',
			'orders.request.withdrawOffer' => 'Teklifi geri çek',
			'orders.request.declineInviteTitle' => 'Teklifi reddedelim mi?',
			'orders.request.declineInviteMessage' => 'Müşteri hemen bilgilendirilir ve başka usta seçebilir.',
			'orders.request.clientPrice' => 'Sipariş fiyatı',
			'orders.request.priceInChat' => 'Fiyat sohbette kararlaştırılır',
			'orders.spec.size' => 'Ölçü (mm)',
			'orders.spec.shape' => 'Şekil',
			'orders.spec.brand' => 'Marka',
			'orders.spec.color' => 'Renk',
			'orders.spec.material' => 'Malzeme',
			'orders.spec.glass' => 'Cam',
			'orders.spec.sill' => 'Denizlik (cm)',
			'orders.spec.flower' => 'Desen',
			'orders.spec.address' => 'Adres',
			'orders.spec.product' => 'Ürünler',
			'orders.spec.phone' => 'Telefon',
			'orders.spec.discount' => 'İndirim',
			'orders.spec.note' => 'Not',
			'orders.spec.itemsValue' => ({required Object kinds, required Object count}) => '${kinds} çeşit · ${count} adet',
			'orders.spec.values.plastic' => 'Plastik',
			'orders.spec.values.aluminium' => 'Alüminyum',
			'orders.spec.values.termo' => 'Termo',
			'orders.spec.values.doubleGlass' => 'Çift cam',
			'orders.spec.values.singleGlass' => 'Tek cam',
			'orders.spec.values.large' => 'Büyük',
			'orders.spec.values.medium' => 'Orta',
			'orders.spec.values.small' => 'Küçük',
			'orders.spec.area' => 'Alan',
			'orders.spec.unitPrice' => 'm² fiyatı',
			'orders.spec.variant' => 'Seviye',
			'orders.invalidId' => 'Geçersiz sipariş numarası.',
			'orders.invalidRequestId' => 'Geçersiz talep numarası.',
			'orders.open.offerSent' => 'Teklif gönderildi',
			'orders.open.waitingClient' => 'Müşterinin yanıtı bekleniyor',
			'orders.open.offersCount' => ({required Object count}) => '${count} teklif',
			'orders.open.beFirst' => 'İlk siz olun',
			'orders.open.newBadge' => 'Yeni',
			'orders.open.pageTitle' => 'Açık siparişler',
			'orders.open.tabWaiting' => 'Yanıt bekliyor',
			'orders.open.tabSent' => 'Teklif gönderildi',
			'orders.open.emptySentTitle' => 'Gönderilmiş teklif yok',
			'orders.open.emptySentMessage' => 'Yanıtladığınız ilanlar burada müşterinin yanıtını bekler.',
			'orders.open.tabInvited' => 'Size teklif',
			'orders.open.invitedBadge' => 'Size teklif',
			'orders.open.repairBadge' => 'Tamir',
			'orders.open.acceptInvite' => 'Kabul ediyorum',
			'orders.open.emptyInvitedTitle' => 'Kişisel teklif yok',
			'orders.open.emptyInvitedMessage' => 'Müşterinin sizi seçtiği siparişler burada görünür.',
			'orders.open.invitedNote' => 'Müşteri bu siparişi doğrudan size gönderdi — diğer ustalar göremez.',
			'orders.personalTitle' => 'Siparişlerim',
			'ownOrders.orderTitle' => 'Sipariş',
			'ownOrders.itemsCount' => ({required Object count}) => '${count} pencere',
			'ownOrders.statusTitle' => 'Sipariş durumu',
			'ownOrders.statusRow' => 'Durum',
			'ownOrders.saving' => 'Kaydediliyor…',
			'ownOrders.tapToChange' => 'Değiştirmek için dokunun',
			'ownOrders.alreadyDone' => 'Bu sipariş zaten tamamlandı.',
			'ownOrders.cannotChange' => 'Bu siparişin durumu değiştirilemez.',
			'ownOrders.status.draft' => 'Taslak',
			'ownOrders.status.newOrder' => 'Yeni',
			'ownOrders.status.inProgress' => 'Devam ediyor',
			'ownOrders.status.done' => 'Tamamlandı',
			'ownOrders.status.debt' => 'Borçlu',
			'ownOrders.status.cancelled' => 'İptal edildi',
			'ownOrders.hint.newOrder' => 'Kabul edildi, henüz başlamadı',
			'ownOrders.hint.inProgress' => 'Üretim ya da montaj sürüyor',
			'ownOrders.hint.done' => 'Teslim edildi ve tamamı ödendi',
			'ownOrders.hint.debt' => 'İş bitti ama ödeme tamamlanmadı',
			'ownOrders.hint.cancelled' => 'Sipariş iptal edildi',
			'orderForm.noProducts' => 'Siparişte ürün yok.',
			'orderForm.queued' => 'İnternet yok — sipariş sıraya alındı, kendisi gönderilecek.',
			'orderForm.saved' => 'Sipariş kaydedildi',
			'orderForm.saveTitle' => 'Siparişi kaydet',
			'orderForm.customer' => 'Sipariş veren',
			'orderForm.nameLabel' => 'Adı',
			'orderForm.nameHint' => 'Ahmet',
			'orderForm.nameRequired' => 'Ad yazın',
			'orderForm.addressHint' => 'Chilanzar 9. blok',
			'orderForm.noteLabel' => 'Ek not',
			'orderForm.noteHint' => '2. kat, asansör yok',
			'orderForm.itemsSummary' => ({required Object kinds, required Object count}) => '${kinds} çeşit pencere · ${count} adet',
			'chat.threadsTitle' => 'Sohbetler',
			'chat.conversation' => 'Sohbet',
			'chat.messageHint' => 'Mesaj yazın...',
			'chat.emptyChat' => 'Fiyat ve şartları burada kararlaştırırsınız',
			'chat.emptyThreadsTitle' => 'Henüz sohbet yok',
			'chat.emptyThreadsMessage' => 'Bir usta siparişinize yanıt verdiğinde burada yazışırsınız.',
			'notifications.title' => 'Bildirimler',
			'notifications.markAllRead' => 'Tümünü okundu yap',
			'notifications.empty' => 'Bildirim yok',
			'notifications.open' => 'Aç',
			'masters.title' => 'Usta hakkında',
			'masters.master' => 'Usta',
			'masters.client' => 'Müşteri',
			'masters.write' => 'Yaz',
			'masters.chooseThis' => 'Bu ustayı seç',
			'masters.choose' => 'Seç',
			'masters.chosen' => 'Seçilen usta',
			'masters.notFound' => 'Bilgi bulunamadı',
			'masters.works' => 'Yaptığı işler',
			'masters.reviews' => ({required Object count}) => 'Yorumlar (${count})',
			'masters.reviewsLabel' => 'Yorumlar',
			'masters.noReviews' => 'Henüz yorum yok — ilk siz olabilirsiniz.',
			'masters.experienceYears' => ({required Object years}) => '${years} yıl deneyim',
			'masters.rating' => 'Puan',
			'masters.completed' => 'Tamamlanan',
			'masters.responses' => ({required Object count}) => '${count} yanıt',
			'masters.estimate' => 'Hesap',
			'orderFlow.status.published' => 'Yayınlandı',
			'orderFlow.status.assigned' => 'Usta seçildi',
			'orderFlow.status.completed' => 'Tamamlandı',
			'orderFlow.status.cancelled' => 'İptal edildi',
			'orderFlow.status.expired' => 'Süresi doldu',
			'orderFlow.stage.accepted' => 'Kabul edildi',
			'orderFlow.stage.measured' => 'Ölçü alındı',
			'orderFlow.stage.production' => 'Üretim',
			'orderFlow.stage.installation' => 'Montaj',
			'orderFlow.stage.handover' => 'Teslim edildi',
			'orderFlow.response.interested' => 'Kabul ediyorum',
			'orderFlow.response.withdrawn' => 'Vazgeçti',
			'orderFlow.response.chosen' => 'Seçildi',
			'orderFlow.response.rejected' => 'Seçilmedi',
			'company.title' => 'İşletme',
			'company.nameLabel' => 'İşletme adı',
			'company.nameHint' => 'Örneğin: Ustachi Servis',
			'company.nameEmpty' => 'İşletme adı girilmedi',
			'company.nameNote' => 'Sipariş formunda görünür',
			'company.logoHint' => 'Logo ekle',
			'companyRates.onlyDigits' => 'Yalnızca rakam',
			'materials.title' => 'Malzemeler',
			'materials.on' => 'Bu malzemeyle çalışıyorum — siparişler gelecek',
			'materials.off' => 'Kapalı — bu malzemedeki siparişler gelmeyecek',
			'materials.allOff' => 'En az bir malzeme açık kalmalı',
			'professional.title' => 'Mesleki bilgiler',
			'professional.headline' => 'Nasıl bir usta olduğunuzu anlatın',
			'professional.headlineHint' => 'Müşteri sizi seçmeden önce bu bilgileri görür. Sonra istediğiniz zaman değiştirebilirsiniz.',
			'professional.specialty' => 'Uzmanlık alanları',
			'professional.specialtyPick' => 'Uzmanlık alanlarınızı seçin',
			'professional.specialtyLoadFailed' => 'Uzmanlık listesi yüklenmedi — internetinizi kontrol edip tekrar girin.',
			'professional.experienceQuestion' => 'Kaç yıllık deneyiminiz var?',
			'professional.experienceHint' => 'Örneğin: 5',
			'professional.experienceRequired' => 'Deneyimi girin',
			'professional.experienceRange' => 'Deneyim 0 ile 70 arasında olmalı',
			'professional.aboutLabel' => 'Kendiniz hakkında (isteğe bağlı)',
			'professional.aboutHint' => 'Hangi işleri yaparsınız, neye dikkat edersiniz — kısaca yazın.',
			'professional.works' => 'Yaptığınız işler',
			'professional.worksHint' => 'Fotoğraf eklerseniz müşteri işinizi görür ve sizi seçme ihtimali artar. İsteğe bağlı — sonra da ekleyebilirsiniz.',
			'professional.deleteSampleTitle' => 'Örnek silinsin mi?',
			'professional.deleteSampleMessage' => 'Müşteriler bu fotoğrafı artık göremeyecek.',
			'professional.deleteFailed' => 'Silinemedi',
			'professional.pickSpecialty' => 'En az bir alan seçin',
			'professional.specialtyHint' => 'Birkaçını seçebilirsiniz — siparişler yalnızca bu alanlardan gelir.',
			'appUpdate.eyebrow' => 'GÜNCELLEME',
			'appUpdate.titleOptional' => 'Yeni sürüm hazır',
			'appUpdate.titleRequired' => 'Güncelleme gerekli',
			'appUpdate.bodyOptional' => 'Ustachi Pro\'nun yeni sürümü çıktı. Son düzeltmeler ve özellikler için güncelleyin.',
			'appUpdate.bodyRequired' => 'Bu sürüm artık desteklenmiyor. Uygulamayı kullanmaya devam etmek için güncelleyin.',
			'appUpdate.whatsNew' => 'NELER YENİ',
			'appUpdate.versionFrom' => 'Sizde',
			'appUpdate.versionTo' => 'Yeni',
			'appUpdate.update' => 'Güncelle',
			'appUpdate.later' => 'Daha sonra',
			'appUpdate.openFailed' => 'Bağlantı açılamadı. Uygulamayı mağazadan elle güncelleyin.',
			_ => null,
		};
	}
}
