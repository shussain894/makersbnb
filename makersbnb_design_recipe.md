# {{User, Space, Request}} Model and Repository Classes Design Recipe

_Copy this recipe template to design and implement Model and Repository classes for a database table._

## 1. Design and create the Table

If the table is already created in the database, you can skip this step.

Otherwise, [follow this recipe to design and create the SQL schema for your table](./single_table_design_recipe_template.md).

*In this template, we'll use an example table `students`*

```
```

## 2. Create Test SQL seeds

Your tests will depend on data stored in PostgreSQL to run.

If seed data is provided (or you already created it), you can skip this step.

```sql
-- EXAMPLE
-- (file: spec/seeds_{table_name}.sql)

-- Write your SQL seed here. 

-- First, you'd need to truncate the table - this is so our table is emptied between each test run,
-- so we can start with a fresh state.
-- (RESTART IDENTITY resets the primary key)

TRUNCATE TABLE users RESTART IDENTITY CASCADE; -- replace with your own table name.
TRUNCATE TABLE spaces RESTART IDENTITY CASCADE;
TRUNCATE TABLE requests RESTART IDENTITY;
-- Below this line there should only be `INSERT` statements.
-- Replace these statements with your own seed data.

INSERT INTO users (name, email, password) VALUES ('Shah', 'shah@test.com', 'shah123'),
('Marina', 'marina@test.com', 'marina1234'),
('Thomas', 'thomas@test.com', 'thomas1234');


INSERT INTO spaces (name, description, price, start_date, end_date, user_id) VALUES ('Stamford Bridge', 'Home of the mighty blues', 1.00, '2023-01-01', '2023-02-01', 2),
('Aldgate Tower', 'Hipster Heaven', 600.00, '2023-01-15', '2023-01-30', 1),
('Bow Manor', 'Cheap and cheerful', 30.99, '2023-01-03', '2023-01-11', 1),
('Versailles', 'Pretty Lush innit', 1000.00, '2022-01-01', '2022-01-31', 3);


INSERT INTO requests (date, status, user_id, space_id) VALUES ('2023-01-14', 'Pending', 1, 1),
('2023-01-15', 'Declined', 3, 2),
('2023-01-15', 'Accepted', 2, 2),
('2023-01-20', 'Accepted', 1, 1);


```

Run this SQL file on the database to truncate (empty) the table, and insert the seed data. Be mindful of the fact any existing records in the table will be deleted.

```bash
psql -h 127.0.0.1 makersbnb_test < spec/seeds/table_seeds.sql
```

## 3. Define the class names

Usually, the Model class name will be the capitalised table name (single instead of plural). The same name is then suffixed by `Repository` for the Repository class name.

```ruby
# EXAMPLE
# Table name: students

# Model class
# (in lib/student.rb)
class User
end

class Space
end

class Request
end

# Repository class
# (in lib/student_repository.rb)
class UserRepository
end

class SpaceRepository
end

class RequestRepository
end
```

## 4. Implement the Model class

Define the attributes of your Model class. You can usually map the table columns to the attributes of the class, including primary and foreign keys.

```ruby
# EXAMPLE
# Table name: makersbnb

# Model class
# (in lib/student.rb)

class User

  # Replace the attributes by your own columns.
  attr_accessor :id, :name, :email, :password
end

class Space

  # Replace the attributes by your own columns.
  attr_accessor :id, :name, :description, :price, :start_date, :end_date, :user_id
end

class Request

  # Replace the attributes by your own columns.
  attr_accessor :id, :date, :status, :user_id, :space_id
end

# The keyword attr_accessor is a special Ruby feature
# which allows us to set and get attributes on an object,
# here's an example:
#
# student = Student.new
# student.name = 'Jo'
# student.name
```

*You may choose to test-drive this class, but unless it contains any more logic than the example above, it is probably not needed.*

## 5. Define the Repository Class interface

Your Repository class will need to implement methods for each "read" or "write" operation you'd like to run against the database.

Using comments, define the method signatures (arguments and return value) and what they do - write up the SQL queries that will be used by each method.

```ruby
# EXAMPLE
# Table name: students

# Repository class
# (in lib/student_repository.rb)

class UserRepository

  # Selecting all records
  # No arguments
  def all
    # Executes the SQL query:
    # SELECT id, name, cohort_name FROM students;

    # Returns an array of Student objects.
  end

  # Gets a single record by its ID
  # One argument: the id (number)
  def find(id)
    # Executes the SQL query:
    # SELECT id, name, cohort_name FROM students WHERE id = $1;

    # Returns a single Student object.
  end

  # Add more methods below for each operation you'd like to implement.

  def create(space)


  end

  # def update(student)
  # end

  # def delete(student)
  # end
end
```

## 6. Write Test Examples

Write Ruby code that defines the expected behaviour of the Repository class, following your design from the table written in step 5.

These examples will later be encoded as RSpec tests.

```ruby
# EXAMPLES

# 1
# Get all items

repo = UserRepository.new

users = repo.all

users.length # =>  2

users[0].id # =>  1
users[0].name # =>  'shoes'
users[0].price # =>  120
users[0].quantity # => 10

users[1].id # =>  2
users[1].name # =>  'jacket'
users[1].cohort_name # =>  250
users[0].quantity # => 15

# 2
# Get a single item

repo = UserRepository.new

user = repo.find(1)

user.id # =>  1
user.name # =>  'shoes'
user.price # =>  120
user.quantity # => 10

# 3
#creates a new item

repo = UserRepository.new

user = User.new
user.name = 'jeans'
user.price = 180
user.quantity = 50

repo.create(item) 

items = repo.all
last_item = items.last
expect(items.length).to eq 3
expect(last_item.name).to eq 'jeans'
expect(last_item.price).to eq 180
expect(last_item.quantity).to eq 50


```

Encode this example as a test.

## 7. Reload the SQL seeds before each test run

Running the SQL code present in the seed file will empty the table and re-insert the seed data.

This is so you get a fresh table contents every time you run the test suite.

```ruby
# EXAMPLE

# file: spec/student_repository_spec.rb

def reset_items_table
  seed_sql = File.read('seeds_items.sql')
  connection = PG.connect({ host: '127.0.0.1', dbname: 'shop_manager_test' })
  connection.exec(seed_sql)
end

RSpec.describe ItemRepository do
  before(:each) do 
    reset_items_table
  end

  # (your tests will go here).
end
```

## 8. Test-drive and implement the Repository class behaviour

_After each test you write, follow the test-driving process of red, green, refactor to implement the behaviour._

<!-- BEGIN GENERATED SECTION DO NOT EDIT -->

---

**How was this resource?**  
[😫](https://airtable.com/shrUJ3t7KLMqVRFKR?prefill_Repository=makersacademy%2Fdatabases&prefill_File=resources%2Frepository_class_recipe_template.md&prefill_Sentiment=😫) [😕](https://airtable.com/shrUJ3t7KLMqVRFKR?prefill_Repository=makersacademy%2Fdatabases&prefill_File=resources%2Frepository_class_recipe_template.md&prefill_Sentiment=😕) [😐](https://airtable.com/shrUJ3t7KLMqVRFKR?prefill_Repository=makersacademy%2Fdatabases&prefill_File=resources%2Frepository_class_recipe_template.md&prefill_Sentiment=😐) [🙂](https://airtable.com/shrUJ3t7KLMqVRFKR?prefill_Repository=makersacademy%2Fdatabases&prefill_File=resources%2Frepository_class_recipe_template.md&prefill_Sentiment=🙂) [😀](https://airtable.com/shrUJ3t7KLMqVRFKR?prefill_Repository=makersacademy%2Fdatabases&prefill_File=resources%2Frepository_class_recipe_template.md&prefill_Sentiment=😀)  
Click an emoji to tell us.

<!-- END GENERATED SECTION DO NOT EDIT -->