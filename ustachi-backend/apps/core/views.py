from urllib.parse import quote

from django.conf import settings
from django.http import HttpResponse, JsonResponse
from django.shortcuts import render


def landing_page(request):
    """Asosiy landing sahifasi (bosh sahifa)."""
    return render(request, "landing/index.html")


def robots_txt(request):
    """Qidiruv tizimlari (Google, Yandex va b.) uchun robots.txt fayli."""
    lines = [
        "User-agent: *",
        "Allow: /",
        "Allow: /static/",
        "Disallow: /admin/",
        "Disallow: /api/",
        "",
        "Sitemap: https://ustachi.uz/sitemap.xml",
    ]
    return HttpResponse("\n".join(lines), content_type="text/plain")


def sitemap_xml(request):
    """Qidiruv tizimlari uchun sitemap.xml fayli."""
    content = """<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
    <url>
        <loc>https://ustachi.uz/</loc>
        <changefreq>weekly</changefreq>
        <priority>1.0</priority>
    </url>
    <url>
        <loc>https://ustachi.uz/account/delete/</loc>
        <changefreq>monthly</changefreq>
        <priority>0.3</priority>
    </url>
</urlset>"""
    return HttpResponse(content.strip(), content_type="application/xml")


def android_assetlinks(request):
    """Digital Asset Links association for both production Android apps."""
    apps = []
    for package_name, setting_name in (
        ("com.ustachi.pro", "ANDROID_APP_LINK_SHA256_FINGERPRINTS"),
        ("com.ustachi.mijoz", "CLIENT_ANDROID_APP_LINK_SHA256_FINGERPRINTS"),
    ):
        fingerprints = [
            fingerprint.strip().upper()
            for fingerprint in getattr(settings, setting_name, "").split(",")
            if fingerprint.strip()
        ]
        if fingerprints:
            apps.append(
                {
                    "relation": ["delegate_permission/common.handle_all_urls"],
                    "target": {
                        "namespace": "android_app",
                        "package_name": package_name,
                        "sha256_cert_fingerprints": fingerprints,
                    },
                }
            )
    return JsonResponse(apps, safe=False)


def app_order_landing(request, order_id):
    """Try opening the app from in-app browsers, with Play as a fallback."""
    return render(
        request,
        "landing/app_order.html",
        {
            "order_id": order_id,
            "play_store_url": settings.MASTER_APP_STORE_URL,
        },
    )


def _telegram_auth_landing(request, *, open_app_href, play_store_url):
    response = render(
        request,
        "landing/app_telegram_auth.html",
        {
            "open_app_href": open_app_href,
            "play_store_url": play_store_url,
        },
    )
    response["Cache-Control"] = "no-store"
    response["Referrer-Policy"] = "no-referrer"
    return response


def app_telegram_auth_landing(request, code):
    """Fallback page for Telegram in-app browsers when the client app is absent."""
    href = (
        f"intent://ustachi.uz/app/auth/telegram/{code}/#Intent;scheme=https;"
        f"package=com.ustachi.mijoz;S.browser_fallback_url={quote(settings.CLIENT_APP_STORE_URL, safe='')};end"
    )
    return _telegram_auth_landing(request, open_app_href=href, play_store_url=settings.CLIENT_APP_STORE_URL)


def app_telegram_master_auth_landing(request, code):
    """Fallback page for Telegram in-app browsers when the Ustachi Pro app is absent."""
    href = (
        f"intent://ustachi.uz/app/auth/master-telegram/{code}/#Intent;scheme=https;"
        f"package=com.ustachi.pro;S.browser_fallback_url={quote(settings.MASTER_APP_STORE_URL, safe='')};end"
    )
    return _telegram_auth_landing(request, open_app_href=href, play_store_url=settings.MASTER_APP_STORE_URL)
