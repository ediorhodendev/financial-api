CREATE TABLE IF NOT EXISTS "__EFMigrationsHistory" (
    "MigrationId" character varying(150) NOT NULL,
    "ProductVersion" character varying(32) NOT NULL,
    CONSTRAINT "PK___EFMigrationsHistory" PRIMARY KEY ("MigrationId")
);

START TRANSACTION;
CREATE TABLE customers (
    "Id" uuid NOT NULL,
    "Name" character varying(150) NOT NULL,
    "SubjectId" character varying(200) NOT NULL,
    "CreatedAt" timestamp with time zone NOT NULL,
    CONSTRAINT "PK_customers" PRIMARY KEY ("Id")
);

CREATE TABLE accounts (
    "Id" uuid NOT NULL,
    "CustomerId" uuid NOT NULL,
    "Currency" character varying(3) NOT NULL,
    "Balance" numeric(18,2) NOT NULL,
    "CreatedAt" timestamp with time zone NOT NULL,
    CONSTRAINT "PK_accounts" PRIMARY KEY ("Id"),
    CONSTRAINT ck_balance CHECK ("Balance" >= 0),
    CONSTRAINT ck_currency CHECK ("Currency" = 'BRL'),
    CONSTRAINT "FK_accounts_customers_CustomerId" FOREIGN KEY ("CustomerId") REFERENCES customers ("Id") ON DELETE RESTRICT
);

CREATE TABLE movements (
    "Id" uuid NOT NULL,
    "AccountId" uuid NOT NULL,
    "Type" character varying(6) NOT NULL,
    "Amount" numeric(18,2) NOT NULL,
    "RegisteredAt" timestamp with time zone NOT NULL,
    "IdempotencyKey" character varying(100) NOT NULL,
    "RequestHash" character varying(64) NOT NULL,
    CONSTRAINT "PK_movements" PRIMARY KEY ("Id"),
    CONSTRAINT ck_amount CHECK ("Amount" > 0),
    CONSTRAINT ck_type CHECK ("Type" IN ('Credit', 'Debit')),
    CONSTRAINT "FK_movements_accounts_AccountId" FOREIGN KEY ("AccountId") REFERENCES accounts ("Id") ON DELETE RESTRICT
);

CREATE UNIQUE INDEX "IX_accounts_CustomerId" ON accounts ("CustomerId");

CREATE UNIQUE INDEX "IX_customers_SubjectId" ON customers ("SubjectId");

CREATE UNIQUE INDEX "IX_movements_AccountId_IdempotencyKey" ON movements ("AccountId", "IdempotencyKey");

CREATE INDEX "IX_movements_AccountId_RegisteredAt_Id" ON movements ("AccountId", "RegisteredAt", "Id");

INSERT INTO "__EFMigrationsHistory" ("MigrationId", "ProductVersion")
VALUES ('20261025230723_InitialCreate', '10.0.12');

COMMIT;

START TRANSACTION;
CREATE FUNCTION reject_movement_mutation() RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
    RAISE EXCEPTION 'Confirmed financial movements are immutable' USING ERRCODE = '23514';
END;
$$;
CREATE TRIGGER movements_immutable BEFORE UPDATE OR DELETE ON movements
FOR EACH ROW EXECUTE FUNCTION reject_movement_mutation();

INSERT INTO "__EFMigrationsHistory" ("MigrationId", "ProductVersion")
VALUES ('20261028000100_ProtectLedger', '10.0.12');

COMMIT;

