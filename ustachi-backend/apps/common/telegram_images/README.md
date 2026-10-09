# Ustachi buyurtmalar kanali rasmlari

Har bir JPEG fayl nomi `MasterSpecialty.code` bilan bir xil. Yangi ochiq buyurtma
kanalga yuborilganda shu rasm va avvalgi buyurtma matni caption sifatida ishlatiladi.
Yo‘nalish uchun rasm topilmasa, avvalgi matnli xabar yuboriladi.

Rasmlar `sources.json` dagi Pexels suratlari asosida Ustachi uslubiga moslab
qayta ishlangan. [Pexels litsenziyasi](https://www.pexels.com/license/) suratlarni
tahrirlash va tijoratda ishlatishga ruxsat beradi. Suratlar xizmat turini
tasvirlaydi; undagi shaxslar Ustachi xodimi yoki hamkori degan ma’no bermaydi.

2026-09-28 kuni ko‘ringan 33 ta avvalgi buyurtma postining xabar va buyurtma
IDlari `channel_posts_2026-09-28.json` da saqlangan. Serverda eski postlarni
yangilashdan oldin:

```powershell
python manage.py backfill_telegram_order_photos
```

Ro‘yxat tekshirilgach, kanalga xabar yuboradigan bot huquqi mavjud bo‘lsa:

```powershell
python manage.py backfill_telegram_order_photos --apply
```

Har bir `EDITED` qatori Telegram javobi muvaffaqiyatli bo‘lganini bildiradi;
`FAILED` qatorlari qo‘lda tekshiriladi. Buyruq mavjud suratli postni farqlamaydi,
shuning uchun `--apply` ni takrorlashdan oldin kanal holatini tekshiring.

Eski xabarlar o‘chirilgan bo‘lsa, yuqoridagi tahrirlash buyrug‘i ishlamaydi.
Hozir ham ochiq bo‘lgan buyurtmalarni yangi rasmli post sifatida yuborish uchun:

```powershell
python manage.py repost_open_telegram_orders --dry-run
python manage.py repost_open_telegram_orders
```

Bu buyruq faqat `published`, muddati o‘tmagan va ommaga ochiq buyurtmalarni
tanlaydi. Kanal tarixida hali mavjud buyurtma havolasini topsa, takror yubormaydi.
