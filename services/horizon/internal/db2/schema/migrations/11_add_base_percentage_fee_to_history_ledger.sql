-- Precision 5, scale 4 to handle this number
-- 0.0045, which represents a percentage fee of 0.45%.
ALTER TABLE history_ledgers ADD base_percentage_fee INTEGER;
