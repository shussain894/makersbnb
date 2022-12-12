require_relative 'request'

class RequestRepository
  
  def create(request)
    check_availability(request)

    sql = 'INSERT INTO requests (date, status, user_id, space_id) 
    VALUES ($1, $2, $3, $4);'
    params = [request.date, request.status, request.user_id, request.space_id]
    DatabaseConnection.exec_params(sql, params)
  end 

  def find(id)
    sql = 'SELECT * from requests WHERE id = $1;'
    params = [id]
    result_set = DatabaseConnection.exec_params(sql, params)

    record = result_set[0]

    extract_request_from_record(record)
  end

  def find_by_user_id(id)
    sql = 'SELECT * from requests WHERE user_id = $1;'
    params = [id]
    result_set = DatabaseConnection.exec_params(sql, params)
    requests = []
    result_set.each do |record|
      requests << extract_request_from_record(record) 
    end  
    requests 
  end

  def find_by_owner_id(id)
    sql =
    'SELECT
      requests.id,
      date,
      status,
      requests.user_id,
      space_id,
      spaces.user_id AS owner_id
    FROM requests
    JOIN spaces ON requests.space_id = spaces.id
    WHERE spaces.user_id = $1;'
    params = [id]
    result_set = DatabaseConnection.exec_params(sql, params)

    requests = []
    result_set.each do |record|
      requests << extract_request_from_record(record) 
    end
    return requests
  end

  def accept_request(id)
    records = DatabaseConnection.exec_params("SELECT * FROM requests WHERE id = $1", [id])
    request = extract_request_from_record(records.first)
    fail "This request is not pending and cannot be updated" unless request.status == "Pending"

    sql_accept =
    "UPDATE requests
    SET status = 'Accepted'
    WHERE id = $1;"
    DatabaseConnection.exec_params(sql_accept, [id])

    sql_decline =
    "UPDATE requests
    SET status = 'Declined'
    WHERE id != $1
      AND date = $2
      AND space_id = $3;"
    params = [id, request.date, request.space_id]
    DatabaseConnection.exec_params(sql_decline, params)
  end

  private

  def extract_request_from_record(record)
    request = Request.new
    request.id = record['id'].to_i
    request.date = record['date']
    request.status = record['status']
    request.user_id = record['user_id'].to_i
    request.space_id = record['space_id'].to_i
    return request
  end

  def check_availability(request)
    # Checks whether the request falls within the start and end dates
    sql = "SELECT start_date, end_date FROM spaces WHERE id = $1;"
    result_set = DatabaseConnection.exec_params(sql, [request.space_id])

    space = result_set.first
    if request.date < space["start_date"] || request.date > space["end_date"]
      fail "This request is outside available dates"
    end

    # Checks the space is available at the given date
    sql = 
    "SELECT *
    FROM requests
    WHERE date = $1
      AND space_id = $2
      AND status = 'Accepted';"
    params = [request.date, request.space_id]
    result_set = DatabaseConnection.exec_params(sql, params)

    if result_set.num_tuples >= 1
      fail "This space has already been booked on #{request.date}"
    end

    return nil
  end
end 