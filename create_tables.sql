CREATE TABLE events (
  id integer(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
  game varchar(256),
  description varchar(256),
  event_date date,
  join_limit integer,
  latitude varchar(256),
  longitude varchar(256),
  created_at datetime NOT NULL,
  updated_at datetime NOT NULL
);