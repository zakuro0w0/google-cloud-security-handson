-- テーブルの作成
CREATE OR REPLACE TABLE `gc-security-handson.dataset_A.table_B` (
  id STRING,
  password STRING
);

-- 初期データの挿入
INSERT INTO `gc-security-handson.dataset_A.table_B` (id, password)
VALUES
  ('id1', 'password1'),
  ('id2', 'password2'),
  ('id3', 'password3');
