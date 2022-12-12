# Two Tables Design Recipe Template

_Copy this recipe template to design and create two related database tables from a specification._

## 1. Extract nouns from the user stories or specification

```
Any signed-up user can list a new space.
Users can list multiple spaces.
Users should be able to name their space, provide a short description of the space, and a price per night.
Users should be able to offer a range of dates where their space is available.
Any signed-up user can request to hire any space for one night, and this should be approved by the user that owns that space.
Nights for which a space has already been booked should not be available for users to book that space.
Until a user has confirmed a booking request, that space can still be booked for that night.
```

```
Nouns:


```

## 2. Infer the Table Name and Columns

Put the different nouns in this table. Replace the example with your own nouns.

| Record                | Properties          |
| --------------------- | ------------------  |
| users                 | name, email, password
| spaces                | name, description, price, start_date, end_date, user_id <!--id of the owner--> 
| requests              | date, status, user_id, space_id <!--id of the requester-->

1. Name of the first table (always plural): `users` 

    Column names: name, email, password

2. Name of the second table (always plural): `spaces` 

    Column names: name, description, price, start_date, end_date, user_id

3. Name of the third table (always plural): `requests`

    column names: date, status, user_id, space_id

## 3. Decide the column types.

[Here's a full documentation of PostgreSQL data types](https://www.postgresql.org/docs/current/datatype.html).

Most of the time, you'll need either `text`, `int`, `bigint`, `numeric`, or `boolean`. If you're in doubt, do some research or ask your peers.

Remember to **always** have the primary key `id` as a first column. Its type will always be `SERIAL`.

```
# EXAMPLE:

Table: users
id: SERIAL
name: text
email: text
password: text


Table: spaces
id: SERIAL
name: text
description: text
price: decimal(8,2)
start_date: date
end_date: date
user_id: int



Table: requests
id: SERIAL
date: date
status: text
user_id: int
space_id: int


```

## 4. Decide on The Tables Relationship

Most of the time, you'll be using a **one-to-many** relationship, and will need a **foreign key** on one of the two tables.

To decide on which one, answer these two questions:

1. Can one [ORDER] have many [ITEMS]? (No)
2. Can one [ITEM] have many [ORDERS]? (Yes)

You'll then be able to say that:

1. **[ITEM] has many [ORDERS]**
2. And on the other side, **[ORDER] belongs to [ITEM]**
3. In that case, the foreign key is in the table [ORDERS]

Replace the relevant bits in this example with your own:

```
# EXAMPLE

1. Can one ITEM have many ORDERS? YES
2. Can one ORDER have many ITEMS? NO

-> Therefore,
-> An ITEM HAS MANY ORDERS
-> An ORDER BELONGS TO an ITEM

-> Therefore, the foreign key is on the ORDERS table.
```

*If you can answer YES to the two questions, you'll probably have to implement a Many-to-Many relationship, which is more complex and needs a third table (called a join table).*

## 4. Write the SQL.

```sql
-- EXAMPLE
-- file: albums_table.sql

-- Replace the table name, columm names and types.

-- Create the table without the foreign key first.
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  name text,
  email text,
  password text
);

-- Then the table with the foreign key first.
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


```

## 5. Create the tables.

```bash
psql -h 127.0.0.1 database_name < albums_table.sql
```

<!-- BEGIN GENERATED SECTION DO NOT EDIT -->

---

**How was this resource?**  
[😫](https://airtable.com/shrUJ3t7KLMqVRFKR?prefill_Repository=makersacademy%2Fdatabases&prefill_File=resources%2Ftwo_table_design_recipe_template.md&prefill_Sentiment=😫) [😕](https://airtable.com/shrUJ3t7KLMqVRFKR?prefill_Repository=makersacademy%2Fdatabases&prefill_File=resources%2Ftwo_table_design_recipe_template.md&prefill_Sentiment=😕) [😐](https://airtable.com/shrUJ3t7KLMqVRFKR?prefill_Repository=makersacademy%2Fdatabases&prefill_File=resources%2Ftwo_table_design_recipe_template.md&prefill_Sentiment=😐) [🙂](https://airtable.com/shrUJ3t7KLMqVRFKR?prefill_Repository=makersacademy%2Fdatabases&prefill_File=resources%2Ftwo_table_design_recipe_template.md&prefill_Sentiment=🙂) [😀](https://airtable.com/shrUJ3t7KLMqVRFKR?prefill_Repository=makersacademy%2Fdatabases&prefill_File=resources%2Ftwo_table_design_recipe_template.md&prefill_Sentiment=😀)  
Click an emoji to tell us.

<!-- END GENERATED SECTION DO NOT EDIT -->