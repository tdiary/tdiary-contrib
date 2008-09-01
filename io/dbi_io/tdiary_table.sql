CREATE TABLE diarydata (
  author        TEXT       NOT NULL,
  diary_id      VARCHAR(8) NOT NULL,
  year          VARCHAR(4) NOT NULL,
  month         VARCHAR(2) NOT NULL,
  day           VARCHAR(2) NOT NULL,
  title         TEXT           NULL,
  last_modified INTEGER    NOT NULL,
  visible       BOOLEAN    NOT NULL,
  body          TEXT       NOT NULL,
  style         TEXT           NULL,
  CONSTRAINT diarydata_pkey PRIMARY KEY (author, diary_id)
);

CREATE TABLE commentdata (
  author        TEXT       NOT NULL,
  diary_id      VARCHAR(8) NOT NULL,
  no            INTEGER    NOT NULL,
  name          TEXT           NULL,
  mail          TEXT           NULL,
  last_modified INTEGER    NOT NULL,
  visible       BOOLEAN    NOT NULL,
  comment       TEXT           NULL,
  CONSTRAINT commentdata_pkey PRIMARY KEY (author, diary_id, no)
);

CREATE TABLE refererdata (
  author   TEXT       NOT NULL,
  diary_id VARCHAR(8) NOT NULL,
  no       INTEGER    NOT NULL,
  count    INTEGER    NOT NULL,
  ref      TEXT       NOT NULL,
  CONSTRAINT refererdata_pkey PRIMARY KEY (author, diary_id, no)
);
CREATE TABLE referervolatile (
  author   TEXT       NOT NULL,
  diary_id VARCHAR(8) NOT NULL,
  no       INTEGER    NOT NULL,
  count    INTEGER    NOT NULL,
  ref      TEXT       NOT NULL,
  CONSTRAINT referervolatile_pkey PRIMARY KEY (author, diary_id, no)
);
