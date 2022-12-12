makersbnb challenge
=================

This week in Makers, we were tasked with building a 'airbnb' clone.

## How to use

1. Clone the repository to your machine
2. Create 2 postgresql databases:

   - `makersbnb`
   - `makersbnb_test`
     [If psql is installed this can be done with `createdb chitter`]

3. Setup your tables with:

```sql
psql -h 127.0.0.1 makersbnb < spec/table_seeds.sql

psql -h 127.0.0.1 makersbnb_test < spec/table_seeds.sql
```

4. Seed your tables with:

```sql
psql -h 127.0.0.1 makersbnb < spec/table_seeds.sql

psql -h 127.0.0.1 makersbnb_test < spec/table_seeds.sql
```

5. install gems

```bash
bundle install
```

6. To test

```bash
rpsec
```

6. To use in the browser

```bash
rackup
```

Then head to the browser with

```bash
http://localhost:9292/
```

# Project specification

We would like a web application that allows users to list spaces they have available, and to hire spaces for the night.

### Headline specifications

- Any signed-up user can list a new space.
- Users can list multiple spaces.
- Users should be able to name their space, provide a short description of the space, and a price per night.
- Users should be able to offer a range of dates where their space is available.
- Any signed-up user can request to hire any space for one night, and this should be approved by the user that owns that space.
- Nights for which a space has already been booked should not be available for users to book that space.
- Until a user has confirmed a booking request, that space can still be booked for that night.

### Nice-to-haves

- Users should receive an email whenever one of the following happens:
 - They sign up
 - They create a space
 - They update a space
 - A user requests to book their space
 - They confirm a request
 - They request to book a space
 - Their request to book a space is confirmed
 - Their request to book a space is denied
- Users should receive a text message to a provided number whenever one of the following happens:
 - A user requests to book their space
 - Their request to book a space is confirmed
 - Their request to book a space is denied
- A ‘chat’ functionality once a space has been booked, allowing users whose space-booking request has been confirmed to chat with the user that owns that space
- Basic payment implementation though Stripe.
