-- ============================================================
--  Marketing Campaign Planner — Database Schema
--  Run this script in MySQL before deploying the application.
-- ============================================================

CREATE DATABASE IF NOT EXISTS marketing_db
    DEFAULT CHARACTER SET utf8mb4
    DEFAULT COLLATE utf8mb4_unicode_ci;

USE marketing_db;

-- -------------------------------------------------------
--  campaigns
-- -------------------------------------------------------
CREATE TABLE IF NOT EXISTS campaigns (
    id          INT            PRIMARY KEY AUTO_INCREMENT,
    name        VARCHAR(100)   NOT NULL,
    description TEXT,
    start_date  DATE,
    end_date    DATE,
    budget      DOUBLE         DEFAULT 0,
    type        VARCHAR(50),
    status      VARCHAR(20)    DEFAULT 'Planned',
    leads       INT            DEFAULT 0   -- auto-synced from SUM(tasks.leads_generated)
);

-- -------------------------------------------------------
--  tasks
-- -------------------------------------------------------
CREATE TABLE IF NOT EXISTS tasks (
    id               INT          PRIMARY KEY AUTO_INCREMENT,
    campaign_id      INT          NOT NULL,
    title            VARCHAR(100),
    type             VARCHAR(50),
    deadline         DATE,
    cost             DOUBLE       DEFAULT 0,
    status           VARCHAR(20)  DEFAULT 'Pending',
    leads_generated  INT          DEFAULT 0,
    FOREIGN KEY (campaign_id) REFERENCES campaigns(id) ON DELETE CASCADE
);

-- -------------------------------------------------------
--  Sample data (optional — remove before production)
-- -------------------------------------------------------
INSERT INTO campaigns (name, description, start_date, end_date, budget, type, status, leads)
VALUES
  ('Q1 Email Blast',   'Quarterly newsletter to existing subscribers.',  '2026-01-01', '2026-03-31', 5000.00, 'Email',        'Completed', 0),
  ('Spring Ads Push',  'Google & Meta paid ads campaign for spring.',     '2026-03-01', '2026-05-31', 15000.00,'Ads',          'Active',    0),
  ('Social Awareness', 'Brand awareness across Instagram and Twitter.',   '2026-04-01', '2026-06-30', 3000.00, 'Social Media', 'Planned',   0);

INSERT INTO tasks (campaign_id, title, type, deadline, cost, status, leads_generated)
VALUES
  (1, 'Design email template',  'Design',   '2025-12-20', 200.00, 'Completed',   0),
  (1, 'Build subscriber list',  'Research', '2025-12-25', 100.00, 'Completed',   120),
  (1, 'Send campaign',          'Launch',   '2026-01-05', 50.00,  'Completed',   340),
  (2, 'Create ad creatives',    'Design',   '2026-03-10', 800.00, 'Completed',   0),
  (2, 'Launch Google Ads',      'Launch',   '2026-03-15', 5000.00,'In Progress', 95),
  (3, 'Draft social content',   'Content',  '2026-04-10', 300.00, 'Pending',     0);

-- Sync campaign leads from task data
UPDATE campaigns c
SET c.leads = (
    SELECT COALESCE(SUM(t.leads_generated), 0)
    FROM tasks t
    WHERE t.campaign_id = c.id
);
