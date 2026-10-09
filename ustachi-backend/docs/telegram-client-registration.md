# Telegram registration setup

The client authentication flow stays backward-compatible: the current SMS form remains available. The Telegram path itself does not send or request an SMS code. Telegram registration is enabled only after the auth bot environment settings and webhook are configured.

One bot serves both apps, distinguished by the `/start` payload:

| App | Deep link | App Link path | Package | Exchange endpoint |
|---|---|---|---|---|
| Client (Ustachi) | `?start=client_register` | `/app/auth/telegram/<code>/` | `com.ustachi.mijoz` | `POST /api/v1/client/auth/telegram/exchange/` |
| Master (Ustachi Pro) | `?start=master_register` | `/app/auth/master-telegram/<code>/` | `com.ustachi.pro` | `POST /api/v1/master/auth/telegram/exchange/` |

`/restart` (typed with no payload) keeps whichever app the chat was already registering for; a brand-new chat with no payload defaults to the client flow.

## Conversation

1. The app opens `https://t.me/ustachi_auth_bot?start=client_register` (or `master_register`).
2. The bot asks the user to share their own phone number with Telegram's contact button. Contacts that do not belong to the sender are rejected.
3. The backend checks that this is a private chat, `chat.id` matches the sender, and the shared contact's `user_id` matches the sender. Free-text numbers, forwarded contacts, and contacts without `user_id` are rejected. It binds the Telegram user ID to the phone account on first successful use; a different Telegram account cannot silently take over the binding.
4. The backend creates or activates the account and sends a five-minute, single-use app link matching the flow's app. A new account is created with the matching role (`is_master` for the master flow); an existing account keeps its current roles and only gains the new one — one phone number is always one account, so a client who registers as a master via the bot keeps client access too, exactly like the existing SMS-based master registration (`grants_master`). Staff and superuser accounts must use the existing authentication path. `/start` and grant creation are rate-limited.
5. The app exchanges that one-time code for the normal JWT pair, using its own namespace's exchange endpoint (either works against any grant — the grant itself, not the endpoint, carries the role). Only a SHA-256 digest is stored for the grant. Telegram account control is the identity factor here; it does not independently prove current SIM ownership. A changed or conflicting Telegram binding requires SMS authentication and support-assisted rebinding.

## Production setup

1. Revoke the token previously shared in chat through BotFather and create a replacement. Never commit the replacement or send it in chat.
2. Configure the server environment: `TELEGRAM_AUTH_BOT_TOKEN`, `TELEGRAM_AUTH_BOT_USERNAME=ustachi_auth_bot`, and a random `TELEGRAM_AUTH_WEBHOOK_SECRET` of at least 32 URL-safe characters. Keep the existing `TELEGRAM_BOT_TOKEN` for order notifications; the auth bot uses a separate setting.
3. Set `CLIENT_ANDROID_APP_LINK_SHA256_FINGERPRINTS` (client, `com.ustachi.mijoz`) and `ANDROID_APP_LINK_SHA256_FINGERPRINTS` (master, `com.ustachi.pro`) to each app's Play App Signing SHA-256 fingerprint. The `.well-known/assetlinks.json` response then associates `ustachi.uz` with whichever package has a fingerprint configured — an app is silently left out of the file until its variable is set.
4. Apply migrations (`python manage.py migrate`) before deploying the code. The webhook is already registered in production; reconfirm HTTPS webhook delivery and `/start` after the release.
5. Publish a client app build with the matching verified App Link intent filter. Until the client fingerprint is configured, Android may show the browser fallback page instead of opening the installed app directly.

The Telegram bot token is a secret. The bot username is public and may be used in the client UI.
