CREATE TABLE IF NOT EXISTS saas_transactions (
  id BIGSERIAL PRIMARY KEY,
  service TEXT NOT NULL,
  plan TEXT,
  description TEXT,
  category TEXT,
  subscription_type TEXT CHECK (subscription_type IN ('monthly', 'annual', 'llm_api', 'infra_api', 'one_time')),
  amount_original NUMERIC(12,2),
  currency_original TEXT DEFAULT 'USD',
  amount_usd NUMERIC(12,2),
  amount_inr NUMERIC(12,2),
  fx_rate NUMERIC(10,4),
  transaction_date DATE NOT NULL,
  status TEXT CHECK (status IN ('paid', 'failed', 'cancelled', 'ended')) DEFAULT 'paid',
  receipt_id TEXT,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_saas_transactions_date ON saas_transactions(transaction_date);
CREATE INDEX IF NOT EXISTS idx_saas_transactions_service ON saas_transactions(service);
CREATE INDEX IF NOT EXISTS idx_saas_transactions_status ON saas_transactions(status);

ALTER TABLE saas_transactions ENABLE ROW LEVEL SECURITY;

DO $$ BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename='saas_transactions' AND policyname='Allow public read') THEN
    CREATE POLICY "Allow public read" ON saas_transactions FOR SELECT USING (true);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename='saas_transactions' AND policyname='Allow service insert') THEN
    CREATE POLICY "Allow service insert" ON saas_transactions FOR INSERT WITH CHECK (true);
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE tablename='saas_transactions' AND policyname='Allow service update') THEN
    CREATE POLICY "Allow service update" ON saas_transactions FOR UPDATE USING (true);
  END IF;
END $$;
