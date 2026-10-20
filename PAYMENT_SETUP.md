# Royal Icon Furnitures payment integration

## Current release

The existing storefront is preserved. A Cloudflare Worker serves the same HTML and assets and adds server-side Paystack payments, database records, a customer payment page, and authenticated payment administration. No merchant account or API credentials are connected. PAYMENTS_MODE is disabled and LIVE_PAYMENTS_APPROVED is no. There is no visible checkout action until configuration and a valid quotation-linked request permit it.

- Payment information: /payments
- Staff administration: /admin/payments (ChatGPT sign-in plus server-side email allowlist)
- Webhook: /api/paystack/webhook
- Callback: generated server-side for the request at /payments; its private capability token stays in the URL fragment, never in the query string or referrer.
- Customer status verification uses the stored transaction reference; the callback's reference is not proof of payment.

## Recommendation and alternatives

Paystack is the initial recommendation because a single integration provides hosted checkout, cards and applicable South African EFT methods, transaction verification, signed webhooks, reconciliation metadata, and refund lookup. Availability depends on merchant approval and enabled payment channels. Checkout is not forced to channels that may not be approved.

Ozow is a credible alternative for local pay-by-bank and also advertises card products, payment requests, refunds and payouts. Confirm its specific merchant product, commercial terms and API access with Ozow before choosing a separate integration. Its payment API is not implemented in this release.

Official references inspected on 17 October 2026:
- https://paystack.com/docs/payments/accept-payments/
- https://paystack.com/docs/payments/verify-payments/
- https://paystack.com/docs/payments/webhooks/
- https://paystack.com/docs/payments/payment-channels/
- https://paystack.com/docs/api/transaction/
- https://paystack.com/docs/api/refund/
- https://paystack.com/docs/payments/test-payments/
- https://paystack.com/za/pricing
- https://ozow.com/

Paystack's published South African pricing currently lists local transactions at 2.9% + R1, excluding VAT; the R1 is waived below R10. Capitec Pay / Ozow EFT is listed at 2% with no flat fee. International transactions are listed at 3.1% + R1, excluding VAT. The public page describes settlement after two working days. These are provider-published rates, not a negotiated merchant agreement or guarantee; confirm current rates, VAT, eligibility, reserves, settlement timing, refund costs and dispute terms with Paystack. No customer surcharge or company payment policy is invented by the website.

## Merchant setup still required

1. Register the business with Paystack and complete the provider's onboarding/approval for South Africa. Supply the identity, business registration or business-type documents, ownership and banking verification that Paystack requests for the actual entity. The website cannot complete approval.
2. Confirm the merchant legal/trading name, support contact details, fulfilment timelines, deposit/payment arrangements, cancellation/refund policy, privacy information, accepted methods, fees and settlement arrangements. Include actual terms in every quotation.
3. Configure the production website URL in the merchant dashboard and use the webhook URL above. Test and live configurations are separate. Keep the dashboard's callback configuration consistent with the server-generated callback.
4. Store PAYSTACK_SECRET_KEY as a Sites runtime secret, never in source, the browser or chat. For sandbox work use the actual test secret supplied by the merchant account and set PAYMENTS_MODE=test. Keep LIVE_PAYMENTS_APPROVED=no.
5. Use /admin/payments to create test-only quotations and fixed-amount payment requests. Share only test links with testers. Verify successful cards and enabled EFT methods, declines, abandonment/cancellation, pending state, callback verification, valid and invalid signatures, duplicate webhook notifications, concurrent checkout clicks, amount/currency/customer/metadata mismatch, partial/full refunds and outstanding balances.
6. Inspect provider dashboard records and local records together. No order is paid based on a screenshot or return URL. Resolve uncertain attempts with Paystack rather than issuing fresh payment links blindly. Genuine refunded payments must be synced by their provider refund ID.
7. Record the sandbox acceptance results. Only after they pass and the merchant is approved should an authorised owner provide the real live key securely, set PAYMENTS_MODE=live and LIVE_PAYMENTS_APPROVED=yes, and publish the configuration. This release has NOT completed that acceptance test. The approval flag is an explicit operational gate, not proof of prior testing.
8. Optional: configure a business-owned email service if automatic confirmation emails are required. None is configured or claimed here; customers see verified receipt details on their private payment page. Staff can use the agreed contact channel.

## Staff workflow

Only the website owner's allowed account is initially authorised, through PAYMENT_ADMIN_EMAILS (server secret). Add other staff explicitly through runtime settings; do not publish an unrestricted admin role. The platform's authenticated identity headers are trusted only behind Sites' dispatch boundary. Never deploy the Worker on a different, direct public origin without replacing that identity boundary.

1. Sign in at /admin/payments using the authorised account.
2. Record the confirmed quotation reference, customer/contact email, detailed specifications and delivery arrangements, exact total in Rand, and actual payment/order terms. Records are immutable through this UI; corrections require a separately referenced quotation and unused payment requests must be closed.
3. Issue an exact deposit amount agreed with the customer, the full quotation total before any payments, or the exact outstanding balance. No default deposit percentage exists. One open payment request per quotation prevents competing requests.
4. Set a link expiry and confirm that the requested amount and terms are agreed. The new private link is shown once; its token is stored only as a SHA-256 hash. Copy it to the intended customer through the agreed channel. It grants access to that quotation and must be kept private. Close an unused request to revoke a lost link, then issue a fresh one if appropriate.
5. The customer reviews the quotation and terms, accepts them, and continues to hosted checkout only when gateway configuration allows it.
6. Paystack-signed notifications and server verification reconcile payment. Admin records show amounts received, refunds and outstanding balances. Customer confirmation includes quotation reference, amount, verified status, gateway payment date, and next steps.
7. Use Verify with Paystack to reconcile pending/failed/abandoned attempts. An uncertain or pending attempt cannot be closed to create a fresh charge. A definite failed/abandoned/reversed attempt can be closed by staff after verification; do not rely on merely closing the browser.
8. Process any refund through the provider dashboard under the actual company refund policy. Verify & record refund fetches the provider's refund ID server-side, validates the transaction/amount/currency/domain, and records its status. Only processed refunds reduce received amounts. It does not initiate a transfer or assume a refund succeeded.

## Security and limitations

- No raw card or bank credentials are collected or stored. Paystack hosts checkout.
- Secrets stay in server runtime settings. Source includes test-only fixtures that never call the provider.
- Quotation amounts are integer cents, controlled by staff and checked on the server. Customer-supplied amount overrides are rejected.
- Every payment is linked to a quotation, request, customer email and unique provider reference. Success requires matching amount, currency, email, metadata, reference and test/live domain.
- HMAC-SHA512 signature verification runs on the raw webhook body before processing. Provider verification remains required for charge events.
- Database uniqueness and atomic statement batches prevent duplicate success accounting. Full/balance totals come from verified transactions minus processed refunds. Overpayment flags require manual review.
- One checkout attempt per request is reserved before calling Paystack. Retries reuse a known checkout URL; ambiguous initialization failures require reconciliation rather than a fresh charge.
- Admin mutations require an authenticated allowlisted staff account and same-origin JSON. APIs return no-store responses. Public payment records require an unguessable private bearer token; personal data is not written to browser storage.
- No automatic background reconciliation job or email delivery is configured. Pending attempts can be checked by the customer/admin, and gateway webhooks handle successful payments and known refunds. No automated fulfilment is triggered.
- A link's website expiry stops new initialization; already-created provider checkout sessions remain subject to Paystack's own expiry. Staff must reconcile them before reissuing a payment request.
- Local automated tests use SQLite and mocked gateway responses. They are not actual Paystack sandbox transactions. Browser QA remains unavailable because the required browser-control skill is not installed.
- Before live enablement, assess privacy retention/access procedures, staff access, merchant account approval, real test results, and operating terms for the business. Record refunds/charge reversals and investigate duplicate real charges rather than treating them as additional fulfilment.

## Build and validation

npm run build
npm test

Build embeds the unchanged storefront, logo and payment routes in the Worker output. Migrations are in drizzle/ and copied into deployment metadata. Sites provisions D1 and applies migrations during publication. Tests use only ephemeral in-memory SQLite; no simulated customer records are seeded into the live database.


## Vercel frontend export

The Vercel build uses `npm run build:vercel` and `public/`. Only the unchanged storefront and design preview are exported. `/payments` and `/admin/payments` redirect to the existing Sites backend. Keep merchant API secrets, DB binding and authorised staff configuration on that backend. This configuration does not migrate live payment processing, data or authentication to Vercel and does not enable payments.
