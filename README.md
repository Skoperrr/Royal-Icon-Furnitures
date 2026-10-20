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
