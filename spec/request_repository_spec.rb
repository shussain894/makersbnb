require 'request_repository'

def reset_tables
  seed_sql = File.read('spec/seeds/table_seeds.sql')
  connection = PG.connect({ host: "127.0.0.1", dbname: "makersbnb_test" })
  connection.exec(seed_sql)
end

RSpec.describe RequestRepository do

  before(:each) do
    reset_tables
  end

  context "create a new request" do
    it "should create a new space request" do
      requestrepo = RequestRepository.new
      new_requests = Request.new 
      new_requests.date = '2023-01-08'
      new_requests.status = 'Pending'
      new_requests.user_id = 2
      new_requests.space_id = 3

      requestrepo.create(new_requests)
      request = requestrepo.find_by_user_id(2)
      expect(request).to include(have_attributes(
        date: '2023-01-08',
        status: 'Pending',
        space_id: 3))
    end

    it "fails when adding a date out of bounds" do
      request_repo = RequestRepository.new
      
      request = Request.new
      request.date = "2022-12-09"
      request.status = 'Pending'
      request.user_id = 3
      request.space_id = 1

      expect { request_repo.create(request) }.to raise_error "This request is outside available dates"
    end

    it "fails when adding on a date that has already been booked" do
      request_repo = RequestRepository.new
      
      request = Request.new
      request.date = "2023-01-20"
      request.status = 'Pending'
      request.user_id = 3
      request.space_id = 1

      expect { request_repo.create(request) }.to raise_error "This space has already been booked on 2023-01-20"
    end
  end 

  context "find requests with user_id" do
    it "should return requests per the user_id" do
      requestrepo = RequestRepository.new
      requests = requestrepo.find_by_user_id(1)

      expect(requests.length).to eq 2
      expect(requests.first).to have_attributes(
        date: '2023-01-14',
        status: 'Pending',
        space_id: 1,
      )
    end
  end

  context "finds requests on spaces owned by user_id" do
    it "should return an array of requests" do
      request_repo = RequestRepository.new
      requests = request_repo.find_by_owner_id(1)

      expect(requests.length).to eq 3
      expect(requests[1]).to have_attributes(
        date: '2023-01-15',
        status: 'Accepted',
        user_id: 2,
        space_id: 2
      )
    end
  end

  context "finds request by it's id" do
    it "should return a single instance of Request" do
      request_repo = RequestRepository.new
      request = request_repo.find(2)

      expect(request).to have_attributes(
        date: '2023-01-15',
        status: 'Declined',
        user_id: 3,
        space_id: 2
      )
    end
  end

  context "accepts 1 request and declines all other pending" do
    it "should update the status column for a given date and space" do
      request_repo = RequestRepository.new
      request_repo.accept_request(1)

      expect(request_repo.find(1).status).to eq "Accepted"
      expect(request_repo.find(5).status).to eq "Declined"
      expect(request_repo.find(6).status).to eq "Pending"
      expect(request_repo.find(7).status).to eq "Pending"
    end

    it "raises an error when given a request that isn't pending" do
      request_repo = RequestRepository.new
      expect{ request_repo.accept_request(2) }.to raise_error "This request is not pending and cannot be updated"
    end
  end


end 

