from django.test import Client, SimpleTestCase
from django.urls import resolve, reverse

from apps.core.views import landing_page, robots_txt, sitemap_xml


class LandingPageViewTests(SimpleTestCase):
    def setUp(self):
        self.client = Client()

    def test_landing_page_url_resolves_to_correct_view(self):
        found = resolve("/")
        self.assertEqual(found.func, landing_page)

    def test_landing_page_reverse_lookup(self):
        url = reverse("core:landing")
        self.assertEqual(url, "/")

    def test_landing_page_returns_200(self):
        response = self.client.get("/")
        self.assertEqual(response.status_code, 200)

    def test_landing_page_uses_index_template(self):
        response = self.client.get("/")
        self.assertTemplateUsed(response, "landing/index.html")

    def test_landing_page_contains_key_content(self):
        response = self.client.get("/")
        content = response.content.decode("utf-8")
        self.assertIn("Ustachi", content)
        self.assertIn("landing/css/styles.css", content)
        self.assertIn("landing/js/script.js", content)
        self.assertIn("landing/images/logo.png", content)
        self.assertIn("https://ustachi.uz/", content)
        self.assertIn("og:title", content)
        self.assertIn("application/ld+json", content)
        self.assertIn("hisoblagich", content)
        self.assertIn("Google Play", content)
        self.assertIn("App Store", content)

    def test_robots_txt(self):
        response = self.client.get("/robots.txt")
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response["Content-Type"], "text/plain")
        content = response.content.decode("utf-8")
        self.assertIn("User-agent: *", content)
        self.assertIn("Sitemap: https://ustachi.uz/sitemap.xml", content)

    def test_sitemap_xml(self):
        response = self.client.get("/sitemap.xml")
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response["Content-Type"], "application/xml")
        content = response.content.decode("utf-8")
        self.assertIn("<loc>https://ustachi.uz/</loc>", content)

    def test_favicon_redirect(self):
        response = self.client.get("/favicon.ico")
        self.assertEqual(response.status_code, 301)
        self.assertEqual(response["Location"], "/static/landing/images/logo.png")


class AppOrderLandingViewTests(SimpleTestCase):
    def test_order_link_renders_app_open_fallback_instead_of_redirecting(self):
        response = Client().get("/app/order/123/")

        self.assertEqual(response.status_code, 200)
        self.assertTemplateUsed(response, "landing/app_order.html")
        content = response.content.decode("utf-8")
        self.assertIn("Buyurtma №123", content)
        self.assertIn("intent://ustachi.uz/app/order/123/", content)
        self.assertIn(
            "https://play.google.com/store/apps/details?id=com.ustachi.pro", content
        )
