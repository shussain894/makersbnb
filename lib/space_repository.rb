require_relative 'database_connection'
require_relative 'space'

class SpaceRepository

  # timer is an object that takes the #now method
  def initialize(timer = Time)
    @timer = timer
  end

  def all
    sql = 'SELECT * FROM spaces;'
    result_set = DatabaseConnection.exec_params(sql, [])
    spaces = []

    result_set.each do |record|
      spaces << extract_space_from_record(record) 
    end
    spaces 
  end

  def all_available
    sql = "SELECT * FROM spaces WHERE end_date > $1"
    params = [@timer.now]
    result_set = DatabaseConnection.exec_params(sql, params)
    spaces = []

    result_set.each do |record|
      spaces << extract_space_from_record(record) 
    end
    spaces
  end

  def find_by_id(id)
    sql = 'SELECT * FROM spaces WHERE id = $1;'
    params = [id]
    result_set = DatabaseConnection.exec_params(sql, params)
    
    record = result_set[0]

    extract_space_from_record(record)
  end

  def create(space)
    sql = 'INSERT INTO spaces (name, description, price, start_date, end_date, user_id) 
    VALUES ($1, $2, $3, $4, $5, $6);'
    params = [space.name, space.description, space.price, space.start_date, space.end_date, space.user_id]
    DatabaseConnection.exec_params(sql, params)
  end 
  
  private

  def extract_space_from_record(record)
    space = Space.new
    space.id = record['id'].to_i
    space.name = record['name']
    space.description = record['description']
    space.price = record['price'].to_f
    space.start_date = record['start_date']
    space.end_date = record['end_date']
    space.user_id = record['user_id'].to_i
    return space
  end

end 