# Elektr montaj hisoblagichi qoidalari

2026-09-24. Manba: loyiha egasi bilan kelishilgan talablar.

## Hisob chegarasi va ekranlar

- Faqat materiallar miqdori va tannarxi hisoblanadi.
- Xizmat haqini **usta o‘z ilovasida belgilaydi**. Mijozdan xizmat haqi
  so‘ralmaydi, materiallar jamiga qo‘shilmaydi va `customer_labor_price`
  yuborilmaydi. Bu avvalgi mijoz narx kiritishi haqidagi talabni almashtiradi.
- Jami materiallar tannarxi natija ro‘yxatining eng pastida ko‘rsatiladi.
- Qadamlar: uy va kirish masofalari → montaj/material → har xona yoritishi
  → materiallar ro‘yxati va jami → buyurtma sahifasi.
- Mijoz uy uzunligi, eni, jami xonalar soni, ustundan uygacha va hisoblagichdan
  shitgacha masofani kiritadi. Xona ichidagi sim yo‘llarini o‘lchamaydi.
- Oshxona, hammom, yo‘lak ham xonalar soniga kiradi; bir xil sarf me’yorlari.
- Oddiy yoki har xonaga alohida montaj; mis yoki alyuminiy; arzon yoki qimmat
  materiallar tanlanadi. Gofra narx toifasi alohida tanlanadi.

## Kirish qismi

| Material | Miqdor | Narx, so‘m |
|---|---|---|
| SIP 2×16 | Ustundan uy kirishigacha, metr | 7 500/m |
| Traverz | Butun uyga 1 dona | 80 000 / 100 000 |
| Hisoblagich | 1 dona | 1 000 000 |
| Asosiy shit | 1 dona, ikkala montajda ham | 100 000 |
| Hisoblagich chiqishidagi avtomat | **Doim butun uyga 2 dona** | 13 000 / 19 000 dona |
| AVG NG 2×16 alyuminiy | Hisoblagichdan shitgacha, metr | 5 000/m |

Alohida montajda qo‘shimcha har xonaga 1 avtomat (13 000 / 19 000 so‘m)
va 1 kichik avtomat qutisi (45 000 so‘m). Asosiy 2 avtomat xonalar soniga
ko‘paytirilmaydi. Kirish kabellari ichki mis/alyuminiy tanloviga bog‘liq emas.

## Ichki materiallar

| Material | Me’yor | Arzon / qimmat narx, so‘m |
|---|---|---|
| Mis 2×2,5 | Rozetka va umumiy/xona liniyasi | 11 500/m |
| Mis 2×1,5 | Faqat yoritish | 7 500/m |
| Alyuminiy 2×4 | Rozetka va umumiy/xona liniyasi | 4 000/m |
| Alyuminiy 2×2,5 | Faqat yoritish | 2 500/m |
| Bittalik rozetka | Xonaga 2 dona | 11 000 / 30 000 |
| Bir tugmali viklyuchatel | Xonaga 1 dona | 9 000 / 25 000 |
| Podrozetnik | Xonaga 3 dona | 1 500 |
| Raspayka qutisi | Xonaga 1 dona | 3 000 |
| WAGO | Xonaga 4 dona | 5 000 |
| Izolenta | 4 xonaga 2 dona | 10 000 |
| Gofra | **Faqat yoritish kabeli uzunligicha** | 800 / 5 500 metr |

## Yoritish

Har xona uchun bir yoki bir nechta tur birga tanlanadi.

| Tur | Me’yor | Arzon / qimmat narx, so‘m |
|---|---|---|
| Oddiy lampochka | Xonaga 1 dona | 12 000 |
| Patron | Oddiy lampochkaga 1 dona | 5 000 |
| Nuqtali svetilnik | 5×5 m xonaga 4 dona | 13 000 / 80 000 |
| Duralayt | Xona perimetri | 9 000 / 25 000 metr |
| Blok pitaniya | Duralayt uchun | 15 000 |
| Rels | 2 metrlik dona | 50 000 |
| Rels svetilnigi | Xona o‘rtasiga 1 dona | 65 000 |

Murakkab yoritishda qo‘shimcha kabel va gofra hisoblanadi.

## Dastlabki taxminiy formulalar

Quyidagilar aniq elektr loyihasi emas, rejasiz smeta uchun dasturiy taxminlar.
Egasi bergan tayanch misol: 10×10 m uy, 4 xona, balandlik 3 m; xona ichiga
15 m rozetka kabeli va oddiy lampaga 5 m; oddiy umumiy liniyaga yana 10 m.

- Xonalar teng maydonli, uy tomonlari nisbatini saqlaydi:
  `a = uy uzunligi / sqrt(xonalar)`, `b = uy eni / sqrt(xonalar)`.
- Sarf koeffitsienti: `k = (a + b) / 10`. Balandlik 3 m deb olinadi.
- Rozetka kabeli: `ceil(15 × k × xonalar + kirish liniyalari)`.
- Oddiy umumiy liniya: `(uy uzunligi + uy eni) / 2`, butun uyga bir marta.
- Alohida liniyalar: shu o‘rtacha masofa × xonalar soni.
- Har tanlangan yoritish tizimiga `5 × k` metr asosiy yoritish yo‘li.
- Nuqtali soni: `ceil(a × b × 4 / 25)`. Qo‘shimcha kabel to‘r joylashuvi
  bo‘yicha: ustunlar `ceil(sqrt(n))`, qatorlar `ceil(n / ustunlar)`;
  `qatorlar × a × (ustunlar−1)/ustunlar + b × (qatorlar−1)/qatorlar`.
- Duralaytga xona perimetri bo‘yicha qo‘shimcha kabel; har tanlangan xonaga
  1 blok pitaniya — boshlang‘ich taxmin.
- Relsli turga har tanlangan xonaga 1 dona 2 metrlik rels va 2 m qo‘shimcha
  kabel — boshlang‘ich taxmin.
- Yoritish kabeli jami butun metrga yuqoriga yaxlitlanadi; gofra shuncha.
- Duralayt jami butun metrga yuqoriga yaxlitlanadi.
- Izolenta: `ceil(xonalar / 2)` — 4 xonali misoldan chiqarilgan qoida.
- Kabel kesimi va himoya jihozlarini montajdan oldin elektrik tekshiradi.

## Tayanch tekshiruvlar

10×10 m, 4 xona, oddiy montaj, oddiy lampalar:
70 m rozetka/umumiy kabel + 20 m yoritish kabeli.
Faqat ichki kabel: mis **955 000**, alyuminiy **330 000** so‘m.
Ustun masofasi 20 m, shit masofasi 5 m, arzon material va gofra bilan
to‘liq materiallar: mis **2 674 000**, alyuminiy **2 049 000** so‘m.
Alohida mis montaj shu shartlarda **3 251 000** so‘m.

Asosiy kod: `ustachi_mijoz/lib/features/calculate_prices/domain/services/electrical_calculator.dart`.
Testlar: `electrical_calculator_test.dart`, `electrical_calculator_page_test.dart`.
Web oyna ishchi ekran chegarasiga, Windows vazifalar panelidan yuqoriga sig‘ishi
kerak; foydalanuvchi uchun hozirgi qulay o‘lcham 460×640.
