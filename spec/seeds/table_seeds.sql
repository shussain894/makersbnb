DROP TABLE IF EXISTS users CASCADE;

CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  name text,
  email text UNIQUE,
  password text
);

DROP TABLE IF EXISTS spaces CASCADE;
CREATE TABLE spaces (
  id SERIAL PRIMARY KEY,
  name text,
  description text,
  price decimal(8,2),
  start_date date,
  end_date date,
-- The foreign key name is always {other_table_singular}_id
  user_id int,
  constraint fk_users foreign key(user_id)
    references users(id)
    on delete cascade
);

DROP TABLE IF EXISTS requests CASCADE;
CREATE TABLE requests (
  id SERIAL PRIMARY KEY,
  date date,
  status text,
-- The foreign key name is always {other_table_singular}_id
  user_id int,
  constraint fk_users foreign key(user_id)
    references users(id)
    on delete cascade,
    space_id int, 
    constraint fk_spaces foreign key(space_id)
    references spaces(id)
    on delete cascade
);

TRUNCATE TABLE users RESTART IDENTITY CASCADE; -- replace with your own table name.
TRUNCATE TABLE spaces RESTART IDENTITY CASCADE;
TRUNCATE TABLE requests RESTART IDENTITY;
-- Below this line there should only be `INSERT` statements.
-- Replace these statements with your own seed data.

INSERT INTO users (name, email, password) VALUES
-- Password: shah123
('Shah', 'shah@test.com', '$2a$12$foqJd7nCF1OP8TjQskvr0OWUzdb5CKe5KNmP9WwwYxAGKxDNRDgX.'),
-- Password: marina1234
('Marina', 'marina@test.com', '$2a$12$STaU0k1wKmXkWBa0PZlwtuVBOFAxiNvRK/5cVMF10jj.gCZCQ0Rt2'),
-- Password: thomas1234
('Thomas', 'thomas@test.com', '$2a$12$at/67jo9NwFP0ZY2owWh1OrvzFTWEWRIMjk4w.9u09bJ5.f63lrXG');


INSERT INTO spaces (name, description, price, start_date, end_date, user_id) VALUES ('Stamford Bridge', 'Home of the mighty blues', 1.00, '2023-01-01', '2023-02-01', 2),
('Aldgate Tower', 'Hipster Heaven', 600.00, '2023-01-15', '2023-01-30', 1),
('Bow Manor', 'Cheap and cheerful', 30.99, '2023-01-03', '2023-01-11', 1),
('Versailles', 'Pretty Lush innit', 1000.00, '2022-01-01', '2022-01-31', 3);


INSERT INTO requests (date, status, user_id, space_id) VALUES ('2023-01-14', 'Pending', 1, 1),
('2023-01-15', 'Declined', 3, 2),
('2023-01-15', 'Accepted', 2, 2),
('2023-01-20', 'Accepted', 1, 1),
('2023-01-14', 'Pending', 3, 1),
('2023-01-15', 'Pending', 3, 1),
('2023-01-14', 'Pending', 2, 3);