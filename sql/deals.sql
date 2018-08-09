DROP TABLE IF EXISTS deals, deal_categories, deal_memberships, deal_images, deal_votes, deal_comments;

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";  -- uuid
CREATE EXTENSION IF NOT EXISTS "postgis";    -- geography & location
CREATE EXTENSION IF NOT EXISTS "pg_trgm";    -- similarity

CREATE TABLE deal_categories
(
  id              smallserial primary key,
  name            text not null,
  max_images      integer default 12,
  max_active_days integer default 21,
  CHECK (length(name) <= 42)
);

INSERT INTO deal_categories (name) VALUES ('shirts');

CREATE TABLE deals
(
  id              uuid primary key default uuid_generate_v4(),
  title           text not null,
  description     text not null,
  thumbnail_id    text,
  latitude        float,
  longitude       float,
  point           geography,
  location_text   text,
  total_price     decimal(15,2),
  total_savings   decimal(15,2),
  quantity        int,
  category_id     serial references deal_categories(id) not null,
  poster_id       uuid references users(id) not null,
  posted_at       timestamp default now(),
  updated_at      timestamp,
  inactive_at     timestamp,
  city_id         serial references cities(id),
  CHECK (length(title) <= 128),
  CHECK (length(description) <= 512),
  CHECK (length(location_text) <= 128)
);

INSERT INTO deals (
  id, title, description, thumbnail_id,
  latitude, longitude, point,
  location_text, total_price, total_savings,
  category_id, poster_id, city_id)
VALUES (
  uuid_generate_v4(), 'deal1', 'some shirt', 'thumb',
  1.3521, 103.8198, ST_MakePoint(103.8198, 1.3521),
  'singapura mall', 40, 10.5,
  1, '93dda1a7-67a4-4e81-abcf-f3a2aba687f4', 37541);

CREATE TABLE deal_memberships
(
  id          bigserial primary key,
  user_id     uuid references users(id),
  deal_id     uuid references deals(id),
  joined_at   timestamp default now(),
  left_at     timestamp
);

CREATE TABLE deal_images
(
  id          bigserial primary key,
  deal_id     uuid references deals(id),
  image_url   text,
  poster_id   uuid references users(id),
  posted_at   timestamp default now(),
  CHECK (length(image_url) <= 255)
);

CREATE TABLE deal_votes
(
  id          bigserial primary key,
  deal_id     uuid references deals(id),
  user_id     uuid references users(id),
  posted_at   timestamp default now()
);

CREATE TABLE deal_comments
(
  id          bigserial primary key,
  deal_id     uuid references deals(id),
  user_id     uuid references users(id),
  comment     text not null,
  posted_at   timestamp default now(),
  CHECK (length(comment) <= 255)
);