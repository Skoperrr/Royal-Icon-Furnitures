CREATE TABLE quotes (
 id TEXT PRIMARY KEY,
 reference TEXT NOT NULL UNIQUE,
 customer_name TEXT NOT NULL,
 customer_email TEXT NOT NULL,
 description TEXT NOT NULL,
 terms TEXT NOT NULL,
 total_cents INTEGER NOT NULL CHECK(total_cents > 0),
 approved INTEGER NOT NULL DEFAULT 0 CHECK(approved IN (0,1)),
 created_at TEXT NOT NULL,
 created_by TEXT NOT NULL
);
--> statement-breakpoint
CREATE TABLE payment_requests (
 id TEXT PRIMARY KEY,
 quote_id TEXT NOT NULL REFERENCES quotes(id),
 token_hash TEXT NOT NULL UNIQUE,
 kind TEXT NOT NULL CHECK(kind IN ('deposit','full','balance')),
 amount_cents INTEGER NOT NULL CHECK(amount_cents > 0),
 state TEXT NOT NULL DEFAULT 'open' CHECK(state IN ('open','paid','closed')),
 accepted_at TEXT,
 expires_at TEXT NOT NULL,
 created_at TEXT NOT NULL,
 created_by TEXT NOT NULL
);
--> statement-breakpoint
CREATE UNIQUE INDEX one_open_request_per_quote ON payment_requests(quote_id) WHERE state='open';
--> statement-breakpoint
CREATE TABLE transactions (
 reference TEXT PRIMARY KEY,
 request_id TEXT NOT NULL UNIQUE REFERENCES payment_requests(id),
 provider_id TEXT UNIQUE,
 status TEXT NOT NULL DEFAULT 'created',
 checkout_url TEXT,
 amount_cents INTEGER NOT NULL,
 currency TEXT NOT NULL DEFAULT 'ZAR',
 domain TEXT NOT NULL,
 paid_at TEXT,
 verified_at TEXT,
 created_at TEXT NOT NULL
);
--> statement-breakpoint
CREATE TABLE refunds (
 provider_id TEXT PRIMARY KEY,
 transaction_reference TEXT NOT NULL REFERENCES transactions(reference),
 amount_cents INTEGER NOT NULL CHECK(amount_cents > 0),
 status TEXT NOT NULL,
 verified_at TEXT NOT NULL
);
--> statement-breakpoint
CREATE INDEX tx_status ON transactions(status);
--> statement-breakpoint
CREATE INDEX refunds_transaction ON refunds(transaction_reference);
--> statement-breakpoint
CREATE TABLE payment_audit (
 id TEXT PRIMARY KEY,
 actor TEXT NOT NULL,
 action TEXT NOT NULL,
 reference TEXT NOT NULL,
 created_at TEXT NOT NULL
);
