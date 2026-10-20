# Royal Icon Furnitures

Premium responsive furniture website for Royal Icon Furnitures, Johannesburg, South Africa.

## Features

- Storefront, supplied lion logo, furniture categories, gallery, custom enquiry brief and FAQs.
- Payment interface preview at `/payment-preview` — no payments processed.
- Server-side Paystack code, secure payment verification, signed webhooks, quotation/payment administration and refund verification.
- Database migrations and automated tests.

## Build and test

Use Node.js 24 or later (the tests use built-in SQLite). No dependencies need installation.

```sh
npm run build
npm test
```

The build generates `dist/server/index.js`, a Worker ES module with `fetch(request, env, ctx)`, and Sites database/hosting metadata. Generated `dist/` files are not committed here.

## Project structure

- `source/`: existing storefront and supplied logo
- `worker/`: server routes, payment integration and payment interface preview
- `scripts/build.mjs`: dependency-free build
- `drizzle/`: database migrations
- `tests/`: simulated payment/security tests and preview interaction tests
- `.env.example`: configuration names only

## Hosting

The site currently uses ChatGPT Sites. `.openai/hosting.json` retains its existing Site identity and DB binding. Sites handles hosting, authentication headers and database migrations. Generic static hosting will not run the payment backend; other platforms require adapting the runtime/database bindings and trusted authentication boundary.

[Website](https://royal-icon-furnitures-studio.mashabakopano52.chatgpt.site) · [Payment interface preview](https://royal-icon-furnitures-studio.mashabakopano52.chatgpt.site/payment-preview)

## Payment status

**Live payments remain disabled. No merchant account or payment credentials are connected or included in this repository.** Automated tests use simulated provider responses; real gateway sandbox acceptance testing is still required.

See [PAYMENT_SETUP.md](PAYMENT_SETUP.md) for merchant approval, server secrets, authorised staff access, webhook configuration, sandbox testing and live activation requirements. Never put real API keys in browser code or source control.

Company contact details, genuine product photographs and reviews, and commercial policies still require confirmation. Inspiration images and demonstration reviews are labelled accordingly.

## Vercel deployment

Import this repository into Vercel. The checked-in `vercel.json` sets the framework to Other, build command to `npm run build:vercel`, and output directory to `public`. No manual output-directory override is required.

`npm run build:vercel` exports the unchanged storefront, payment interface preview, logo and favicon as static files. Clean URLs expose `/payment-preview`. The export includes no administration page, database records, secrets, Worker source or database migrations.

`/payments` and `/admin/payments` redirect to the existing Sites-hosted backend, which retains its database, authenticated staff access and server-side verification. The payment flow runs on that existing domain. Vercel does not run the Cloudflare Worker or impersonate its authentication. Live payments remain disabled until the merchant setup and sandbox acceptance tests described in PAYMENT_SETUP.md are complete.

The original `npm run build` still creates the Sites Worker. Moving the payment backend itself to Vercel would require a separate database/authentication migration, approved callback/webhook URLs and new acceptance testing. Do not put payment secrets in the static export or Vercel frontend variables.
