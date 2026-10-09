from datetime import timedelta
from pathlib import Path

import dj_database_url
from decouple import config

BASE_DIR = Path(__file__).resolve().parent.parent

SECRET_KEY = config("SECRET_KEY", default="django-insecure-change-me-in-production")

DEBUG = config("DEBUG", default=True, cast=bool)

ALLOWED_HOSTS = ["usta-top.simpl.uz",
"ustachi.uz",
"www.ustachi.uz",
"localhost",
]

# Lokal ishlab chiqishda `127.0.0.1` ham kerak: admin panel (alohida repo)
# Vite dev-proxy'si so'rovni shu manzilga yuboradi va `changeOrigin` sabab
# Host sarlavhasi ham `127.0.0.1:8000` bo'ladi — ro'yxatda bo'lmasa
# Django `DisallowedHost` (400) qaytaradi. PROD'ga ta'sir qilmaydi.
if DEBUG:
    ALLOWED_HOSTS += ["127.0.0.1", "10.0.2.2", "[::1]", "testserver"]



CSRF_TRUSTED_ORIGINS = ["https://usta-top.simpl.uz","https://ustachi.uz","https://www.ustachi.uz"]

INSTALLED_APPS = [
    # Unfold — `django.contrib.admin` DAN OLDIN turishi SHART: u admin
    # shablonlarini almashtiradi va `admin.site` ni `UnfoldAdminSite` ga
    # o'zgartiradi (`unfold.apps.DefaultAppConfig.ready`).
    "unfold",
    "unfold.contrib.filters",  # dropdown / sana oralig'i / raqam filtrlari
    "django.contrib.admin",
    "django.contrib.auth",
    "django.contrib.contenttypes",
    "django.contrib.sessions",
    "django.contrib.messages",
    "django.contrib.staticfiles",
    # third-party
    "drf_spectacular",
    "rest_framework",
    "rest_framework_simplejwt",
    "rest_framework_simplejwt.token_blacklist",
    "django_filters",
    "corsheaders",
    "channels",
    # local
    "apps.core",
    "apps.accounts",
    "apps.locations",
    "apps.orders",
]

MIDDLEWARE = [
    "django.middleware.security.SecurityMiddleware",
    # CORS iloji boricha YUQORIDA (CommonMiddleware'dan oldin) — preflight/OPTIONS
    # javoblariga Access-Control-* sarlavhalarini qo'yishi uchun.
    "corsheaders.middleware.CorsMiddleware",
    "django.contrib.sessions.middleware.SessionMiddleware",
    "django.middleware.common.CommonMiddleware",
    "django.middleware.csrf.CsrfViewMiddleware",
    "django.contrib.auth.middleware.AuthenticationMiddleware",
    "django.contrib.messages.middleware.MessageMiddleware",
    "django.middleware.clickjacking.XFrameOptionsMiddleware",
]

ROOT_URLCONF = "config.urls"

TEMPLATES = [
    {
        "BACKEND": "django.template.backends.django.DjangoTemplates",
        # Loyiha shablonlari app'lardan OLDIN qidiriladi — admin bosh sahifasi
        # (`templates/admin/index.html`) shu yerdan Unfold'nikini almashtiradi.
        "DIRS": [BASE_DIR / "templates"],
        "APP_DIRS": True,
        "OPTIONS": {
            "context_processors": [
                "django.template.context_processors.request",
                "django.contrib.auth.context_processors.auth",
                "django.contrib.messages.context_processors.messages",
            ],
        },
    },
]

WSGI_APPLICATION = "config.wsgi.application"

# ─────────────────────────── Ma'lumotlar bazasi ───────────────────────────
#
# SQLite — bitta faylda va bir vaqtda FAQAT BITTA yozuvchiga ruxsat beradi.
# Standart sozlamada o'qish ham yozishni to'sadi (rollback jurnali), busy
# kutish esa 5 soniya — shundan keyin "database is locked" otiladi.
#
# Prod'da gunicorn bir nechta worker bilan ishlaganda bu "dastur yoniq,
# lekin javob bermayapti" holatini beradi (2026-08-08 shikoyati): so'rovlar
# navbatga tizilib, qulf kutib turadi.
#
# Uchta sozlama shu og'riqni oladi:
#   * WAL           — o'quvchilar yozuvchini TO'SMAYDI (eng katta foyda);
#   * busy_timeout  — qulf bo'shashini 20 soniya kutadi, darhol yiqilmaydi;
#   * IMMEDIATE     — yozuv tranzaksiyasi qulfni BOSHIDA oladi, ish o'rtasida
#                     "locked" bo'lib qolmaydi (deadlock-ga o'xshash holat).
#
# ⚠️ Bu SQLite'ni ko'p yozuvchi uchun yaroqli qilmaydi. Yuk o'sganda
# PostgreSQL ga o'tish kerak; shungacha gunicorn `--workers 1` bilan
# ishlashi eng xavfsizi (InMemory channel layer ham shuni talab qiladi).
DATABASES = {
    "default": dj_database_url.config(
        default=config("DATABASE_URL", default=f"sqlite:///{BASE_DIR / 'db.sqlite3'}"),
        # conn_max_age=600,
        conn_health_checks=True,
    )
}

AUTH_USER_MODEL = "accounts.User"

AUTH_PASSWORD_VALIDATORS = [
    {"NAME": "django.contrib.auth.password_validation.UserAttributeSimilarityValidator"},
    {"NAME": "django.contrib.auth.password_validation.MinimumLengthValidator"},
    {"NAME": "django.contrib.auth.password_validation.CommonPasswordValidator"},
    {"NAME": "django.contrib.auth.password_validation.NumericPasswordValidator"},
]

LANGUAGE_CODE = "en-us"
TIME_ZONE = "Asia/Tashkent"
USE_I18N = True
USE_TZ = True

STATIC_URL = "/static/"
STATIC_ROOT = BASE_DIR / "static"

MEDIA_URL = "/media/"
MEDIA_ROOT = BASE_DIR / "media"

DEFAULT_AUTO_FIELD = "django.db.models.BigAutoField"

# ─────────────────────── ADMIN (django-unfold) ───────────────────────
# Yon paneldagi menyu va bosh sahifa kartalari SETTINGS'da emas, alohida
# modullarda (`config/unfold_*.py`) — ular modellarga murojaat qiladi,
# settings esa app registry tayyor bo'lmasdan o'qiladi. Unfold bu qatorlarni
# import yo'li sifatida qabul qiladi va so'rov paytida chaqiradi.
UNFOLD = {
    "SITE_TITLE": "Ustachi",
    "SITE_HEADER": "Ustachi",
    "SITE_SUBHEADER": "Boshqaruv paneli",
    # Material Symbols nomi — logotip fayli o'rniga (rasm hozircha yo'q).
    "SITE_SYMBOL": "handyman",
    "SITE_URL": None,  # sarlavhadagi "saytni ko'rish" havolasi kerak emas
    "SHOW_HISTORY": True,
    "SHOW_VIEW_ON_SITE": False,
    "SHOW_BACK_BUTTON": True,
    "BORDER_RADIUS": "6px",
    "ENVIRONMENT": "config.unfold_navigation.environment_callback",
    "DASHBOARD_CALLBACK": "config.unfold_dashboard.dashboard_callback",
    "COLORS": {
        # Ilova rangi — indigo.
        "primary": {
            "50": "238 242 255",
            "100": "224 231 255",
            "200": "199 210 254",
            "300": "165 180 252",
            "400": "129 140 248",
            "500": "99 102 241",
            "600": "79 70 229",
            "700": "67 56 202",
            "800": "55 48 163",
            "900": "49 46 129",
            "950": "30 27 75",
        },
    },
    "SIDEBAR": {
        "show_search": True,
        # Menyuda yo'q modellar ham ochilishi uchun ("Barcha ilovalar").
        "show_all_applications": True,
        "navigation": "config.unfold_navigation.sidebar_navigation",
    },
}

# --- Django REST Framework ---
REST_FRAMEWORK = {
    "DEFAULT_AUTHENTICATION_CLASSES": (
        "rest_framework_simplejwt.authentication.JWTAuthentication",
    ),
    "DEFAULT_PERMISSION_CLASSES": (
        "rest_framework.permissions.IsAuthenticated",
    ),
    "DEFAULT_SCHEMA_CLASS": "drf_spectacular.openapi.AutoSchema",
    "DEFAULT_FILTER_BACKENDS": [
        "django_filters.rest_framework.DjangoFilterBackend",
        "rest_framework.filters.OrderingFilter",
    ],
}

SPECTACULAR_SETTINGS = {
    "TITLE": "Usta Top API",
    "DESCRIPTION": "Role-based authentication API documentation.",
    "VERSION": "1.0.0",
    "SERVE_INCLUDE_SCHEMA": False,
    # Bir nechta modelda `status` maydoni bor — nom berilmasa schema'da
    # `Status760Enum` kabi tasodifiy nomlar chiqadi va admin panelning
    # generatsiya qilingan TypeScript tiplari o'qib bo'lmas bo'ladi.
    "ENUM_NAME_OVERRIDES": {
        "OrderStatusEnum": "apps.orders.models.order.OrderStatus.choices",
        "OrderStageEnum": "apps.orders.models.order.OrderStage.choices",
        "ResponseStatusEnum": "apps.orders.models.response.ResponseStatus.choices",
        "InviteStatusEnum": "apps.orders.models.invite.InviteStatus.choices",
        "MasterOrderStatusEnum": "apps.orders.models.master_order.MasterOrderStatus.choices",
    },
}

# --- Simple JWT ---
SIMPLE_JWT = {
    "ACCESS_TOKEN_LIFETIME": timedelta(minutes=15),
    "REFRESH_TOKEN_LIFETIME": timedelta(days=30),
    "ROTATE_REFRESH_TOKENS": True,
    "BLACKLIST_AFTER_ROTATION": True,
}

# --- Cache ---
# Eskiz auth-token shu cache'da saqlanadi: Gunicorn worker'lari aro umumiy va
# process restartidan omon qoladi (in-memory singletondan farqli). DatabaseCache
# ishlashi uchun bir marta jadval yaratish kerak:
#   python manage.py createcachetable
CACHES = {
    "default": {
        "BACKEND": "django.core.cache.backends.db.DatabaseCache",
        "LOCATION": "app_cache",
    }
}

# --- SMS (Eskiz) ---
ESKIZ_EMAIL = config("ESKIZ_EMAIL", default="")
ESKIZ_PASSWORD = config("ESKIZ_PASSWORD", default="")
ESKIZ_FROM = config("ESKIZ_FROM", default="4546")
ESKIZ_TIMEOUT = config("ESKIZ_TIMEOUT", default=15, cast=int)

# --- FCM push (firebase-admin) ---
# Xizmat akkaunti kaliti (Firebase Console → Project settings → Service
# accounts → Generate new private key). Fayl REPOGA QO'YILMAYDI — `secrets/`
# .gitignore da. Fayl topilmasa push JIMGINA o'chadi, qolgan hammasi ishlaydi.
FIREBASE_CREDENTIALS = config(
    "FIREBASE_CREDENTIALS", default=str(BASE_DIR / "secrets" / "firebase-admin.json")
)
FCM_ENABLED = config("FCM_ENABLED", default=True, cast=bool)
# Push fon oqimida yuboriladi — HTTP so'rov FCM javobini kutmaydi. Testlarda
# False qilinadi (natija darhol kerak).
FCM_BACKGROUND = config("FCM_BACKGROUND", default=True, cast=bool)
# Android 8+ bildirishnoma kanali — Flutter tomonda AYNAN shu nom bilan
# yaratilishi kerak, aks holda xabar ovozsiz keladi.
FCM_ANDROID_CHANNEL = config("FCM_ANDROID_CHANNEL", default="usta_top")
# --- OTP (tasdiqlash kodi) ---
# DEMO HISOB — Google Play / App Store tekshiruvchisi uchun.
# Do'kon moderatori ilovani ochib ko'rishi kerak, lekin unga real SMS
# bora olmaydi (raqam bizniki emas va xalqaro yetkazish kafolatlanmaydi).
# Shu raqamga kod DOIM `OTP_DEMO_CODE` bo'ladi, SMS YUBORILMAYDI va
# tezlik cheklovi qo'llanmaydi (moderator ko'p marta urinishi mumkin).
#
# ⚠️ Faqat shu ro'yxatdagi raqamlar uchun. Bo'sh qilib qo'yilsa (env orqali)
# o'sha demo hisob o'chadi.
#
# USTA ilovasi tekshiruvi uchun:
OTP_DEMO_PHONE = config("OTP_DEMO_PHONE", default="+998917777777")
OTP_DEMO_CODE = config("OTP_DEMO_CODE", default="777777")
# MIJOZ ilovasi tekshiruvi uchun ALOHIDA raqam — usta demo raqami bilan
# bitta hisobga tushib qolmasin (rollar aralashmaydi):
OTP_DEMO_PHONE_CLIENT = config("OTP_DEMO_PHONE_CLIENT", default="+998918888888")
OTP_DEMO_CODE_CLIENT = config("OTP_DEMO_CODE_CLIENT", default="888888")

# Statik kod FAQAT SMS xizmati sozlanmagan (lokal dev) muhitda ishlaydi —
# productionda (Eskiz sozlangan) har doim tasodifiy kod yuboriladi, shuning
# uchun bu endi xavfsizlik teshigi emas.
OTP_STATIC_CODE = config("OTP_STATIC_CODE", default="111111")

# --- CORS (django-cors-headers) ---
# Flutter Web (Netlify) narx VA auth endpointlariga cross-origin murojaat qilishi
# uchun. Narx endpointlari public; auth Bearer-token (cookie EMAS) → credentials
# shart emas. Netlify (production + preview) va lokal web-dev ruxsat etiladi.
CORS_ALLOWED_ORIGIN_REGEXES = [
    r"^https://.*\.netlify\.app$",     # Netlify: <sayt>.netlify.app + deploy-preview
    r"^http://localhost:\d+$",         # lokal: flutter run -d chrome
    r"^http://127\.0\.0\.1:\d+$",
]
# Custom domen ulasangiz shu yerga qo'shing (masalan):
# CORS_ALLOWED_ORIGINS = ["https://web.usta-top.uz"]

# ─────────────────────── REAL-TIME (WebSocket) ───────────────────────
# Ilova bitta WS ulanishi ochadi va hodisalarni SHU YERDAN oladi (davriy
# so'rov qilmaydi). Prod'da bir nechta worker bo'lsa Redis SHART — aks holda
# bir worker'dagi hodisa boshqasidagi ulanishga yetib bormaydi.
ASGI_APPLICATION = "config.asgi.application"

REDIS_URL = config("REDIS_URL", default="")
CHANNEL_LAYERS = {
    "default": (
        {
            "BACKEND": "channels_redis.core.RedisChannelLayer",
            "CONFIG": {
                "hosts": [
                    {
                        "address": REDIS_URL,
                        # BRPOP dan (5s) KATTA bo'lishi shart — teng bo'lsa
                        # WS har 5 soniyada TimeoutError bilan uziladi.
                        "socket_timeout": 30,
                        "socket_connect_timeout": 10,
                        "socket_keepalive": True,
                        "health_check_interval": 30,
                    }
                ]
            },
        }
        if REDIS_URL
        else {"BACKEND": "channels.layers.InMemoryChannelLayer"}
    )
}

# ─────────────────────── PUSH (Firebase Cloud Messaging) ───────────────────────
# Telefon ekranidagi bildirishnoma. Sozlanmagan bo'lsa ilova to'liq ishlaydi:
# in-app ro'yxat va WebSocket hodisalari push'ga bog'liq emas.
#
#   FCM_PROJECT_ID       — Firebase loyihasi ID (masalan "ustatop-f3940")
#   FCM_CREDENTIALS_FILE — service-account JSON fayl yo'li (serverda)
#   FCM_CREDENTIALS_JSON — yoki o'sha JSON'ning O'ZI (bitta qatorda)
FCM_PROJECT_ID = config("FCM_PROJECT_ID", default="")
FCM_CREDENTIALS_FILE = config("FCM_CREDENTIALS_FILE", default="")
FCM_CREDENTIALS_JSON = config("FCM_CREDENTIALS_JSON", default="")

# ─────────────────────── TELEGRAM ───────────────────────
# Ochiq buyurtmalar kanalga, yangi foydalanuvchilar admin guruhi topigiga
# yuboriladi (`apps/common/telegram.py`). Token bo'sh bo'lsa — o'chiq.
#   TELEGRAM_CHAT_ID           — admin guruhi ID (masalan -1001234567890)
#   TELEGRAM_ORDERS_CHANNEL_ID — ommaviy kanal @username'i yoki IDsi
_optional_int = lambda v: int(v) if str(v).strip() else None  # noqa: E731
TELEGRAM_ENABLED = config("TELEGRAM_ENABLED", default=True, cast=bool)
TELEGRAM_BOT_TOKEN = config("TELEGRAM_BOT_TOKEN", default="")
TELEGRAM_AUTH_BOT_TOKEN = config("TELEGRAM_AUTH_BOT_TOKEN", default="")
TELEGRAM_AUTH_WEBHOOK_SECRET = config("TELEGRAM_AUTH_WEBHOOK_SECRET", default="")
TELEGRAM_AUTH_BOT_USERNAME = config("TELEGRAM_AUTH_BOT_USERNAME", default="")
CLIENT_APP_STORE_URL = config(
    "CLIENT_APP_STORE_URL",
    default="https://play.google.com/store/apps/details?id=com.ustachi.mijoz",
)
TELEGRAM_CHAT_ID = config("TELEGRAM_CHAT_ID", default="")
TELEGRAM_ORDERS_CHANNEL_ID = config("TELEGRAM_ORDERS_CHANNEL_ID", default="@ustachi_buyurtmalar")
TELEGRAM_ORDERS_CHANNEL_URL = config(
    "TELEGRAM_ORDERS_CHANNEL_URL", default="https://t.me/ustachi_buyurtmalar"
)
TELEGRAM_USERS_TOPIC_ID = config("TELEGRAM_USERS_TOPIC_ID", default="", cast=_optional_int)
TELEGRAM_TIMEOUT = config("TELEGRAM_TIMEOUT", default=10, cast=int)
# Fon oqimida yuborish (so'rov Telegram javobini kutmaydi). Testlarda False.
TELEGRAM_BACKGROUND = config("TELEGRAM_BACKGROUND", default=True, cast=bool)

# Media/statik fayllarning TASHQI manzili — `request` bo'lmagan joylarda
# (WebSocket hodisasi, boshqaruv buyruqlari) to'liq URL qurish uchun.
# Bo'sh bo'lsa nisbiy yo'l qaytadi.
PUBLIC_BASE_URL = config("PUBLIC_BASE_URL", default="https://usta-top.simpl.uz")

# Android App Links for Telegram order cards. The SHA-256 fingerprint must be
# the Play App Signing certificate (Play Console → App integrity), not upload key.
APP_LINK_BASE_URL = config(
    "APP_LINK_BASE_URL", default="https://ustachi.uz"
).rstrip("/")
MASTER_APP_STORE_URL = config(
    "MASTER_APP_STORE_URL",
    default="https://play.google.com/store/apps/details?id=com.ustachi.pro",
)
ANDROID_APP_LINK_SHA256_FINGERPRINTS = config(
    "ANDROID_APP_LINK_SHA256_FINGERPRINTS",
    default=(
        "90:0F:82:A3:8D:C2:89:D7:28:3D:07:30:F1:CB:42:B7:"
        "5D:DC:EB:27:EB:AC:F0:24:E1:6E:9C:71:73:73:07:FC"
    ),
)
CLIENT_ANDROID_APP_LINK_SHA256_FINGERPRINTS = config(
    "CLIENT_ANDROID_APP_LINK_SHA256_FINGERPRINTS", default=""
)

# ─────────────────────────────── LOG ───────────────────────────────
# Bu blok bo'lmasa `apps.*` dagi `logger.info()` hech qayerga chiqmaydi —
# Django faqat o'z `django` logger'ini sozlaydi. Konsolga (stderr) yoziladi,
# systemd ostida `journalctl` da ko'rinadi.
LOG_LEVEL = config("LOG_LEVEL", default="INFO").upper()

LOGGING = {
    "version": 1,
    "disable_existing_loggers": False,
    "formatters": {
        "simple": {
            "format": "{asctime} {levelname} {name}: {message}",
            "style": "{",
        },
    },
    "handlers": {
        "console": {
            "class": "logging.StreamHandler",
            "formatter": "simple",
        },
    },
    "loggers": {
        "apps": {
            "handlers": ["console"],
            "level": LOG_LEVEL,
            "propagate": False,
        },
    },
}
