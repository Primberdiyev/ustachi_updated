"""
MEDIA fayllarning TO'LIQ manzili.

Django `FileField.url` NISBIY yo'l qaytaradi (`/media/users/photos/a.jpg`).
Mobil ilova uni to'g'ridan-to'g'ri `Image.network` ga bersa rasm KO'RINMAYDI —
qurilmada "host" degan tushuncha yo'q. Shu sabab API'dan chiqadigan har bir
media manzili SHU YERDAN o'tadi va doim `https://host/media/...` bo'ladi.

`request` bo'lmasa (mas. WebSocket hodisasi, boshqaruv buyrug'i) sozlamadagi
`PUBLIC_BASE_URL` ishlatiladi; u ham bo'lmasa nisbiy yo'l qaytadi — bu
xato emas, shunchaki eng yaxshi mumkin bo'lgan javob.
"""

from django.conf import settings


def absolute_media_url(file_field, request=None) -> str | None:
    """`FileField`/`ImageField` → to'liq URL (yoki `None`)."""
    if not file_field:
        return None
    try:
        url = file_field.url
    except (AttributeError, ValueError):
        return None
    return absolute_url(url, request)


def absolute_url(url: str | None, request=None) -> str | None:
    """Nisbiy yo'lni to'liq URL'ga aylantiradi (allaqachon to'liq bo'lsa — o'zi)."""
    if not url:
        return None
    if url.startswith("http://") or url.startswith("https://"):
        return url
    if request is not None:
        return request.build_absolute_uri(url)

    base = (getattr(settings, "PUBLIC_BASE_URL", "") or "").rstrip("/")
    if not base:
        return url
    return f"{base}/{url.lstrip('/')}"
