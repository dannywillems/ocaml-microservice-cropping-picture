CREATE SCHEMA IF NOT EXISTS cropping;

CREATE TABLE IF NOT EXISTS cropping.picture
(
  id                             bigserial   primary key,
  initial_path                   text        NOT NULL,
  cropped_path                   text        NOT NULL,
  additional_information         jsonb       NOT NULL,
  additional_information_version bigserial   NOT NULL
)
