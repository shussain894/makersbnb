require "spec_helper"
require "rack/test"
require_relative '../../app'
require 'json'

def reset_tables
  seed_sql = File.read('spec/seeds/table_seeds.sql')
  connection = PG.connect({ host: "127.0.0.1", dbname: "makersbnb_test" })
  connection.exec(seed_sql)
end

describe Application do
  # This is so we can use rack-test helper methods.
  include Rack::Test::Methods

  # We need to declare the `app` value by instantiating the Application
  # class so our tests work.
  let(:app) { Application.new }

  # Write your integration tests below.
  # If you want to split your integration tests
  # accross multiple RSpec files (for example, have
  # one test suite for each set of related features),
  # you can duplicate this test file to create a new one.
  before(:each) do
    reset_tables
  end

  context 'GET /' do
    it 'should get the homepage' do
      response = get('/')

      expect_redirect(response, "/login")
    end
  end


  context 'GET /users/new' do
    it "creates a new user" do
      response = get('/users/new')
      expect(response.status).to eq 200
      expect(response.body).to include ' <h1>sign up to makersbnb!</h1>'
      expect(response.body).to include '<input type="password" placeholder="Password" id="password_id" name="password" />'
    end

    it "redirects to /spaces if the user is in a session" do
      start_session
      response = get("/users/new")
      expect_redirect(response, "/spaces")
    end
  end

  context 'POST /users' do
    it "sends user to the database" do
      response = post('/users', name: 'Chris', email: 'chris@test.com', password: 'abcd')
      expect(response.status).to eq 200
      expect(response.body).to include 'Congratulations'
    end

    it "sends invalid email message" do
      response = post('/users', name: 'Chris', email: 'christest.com', password: 'abcd')
      expect(response.status).to eq 200
      expect(response.body).to include "<a href='/users/new'> Try Again</a>"
    end

    it "accepts input with an HTML injection" do
      response = post('/users',
        name: '<script> 3 + 4 </script>',
        email: 'chris@test.com',
        password: 'abcd'
      )
      expect(response.status).to eq 200
      expect(response.body).to include 'Congratulations'
    end
  end

  context "GET /login" do
    it "returns the login page" do
      response = get('/login')
      expect(response.status).to eq 200
      expect(response.body).to include '<h1> welcome to makersbnb!  </h1>'
      expect(response.body).to include '<input type="text" placeholder="email" name="email" />'
    end

    it "redirects to /spaces if the user already has a session" do
      start_session
      response = get('/login')
      expect_redirect(response, "/spaces")
    end
  end

  context "POST /login" do
    it 'starts a session for the user' do
      response = post('/login', email: 'shah@test.com', password: 'shah123')
      expect(response.status).to eq 200
      expect(response.body).to include 'welcome to makersbnb'
    end
  end

  context "GET /logout" do
    it "Ends the user session" do
      response = get('/logout')
      expect_redirect(response, "/")
    end
  end
  
  context 'GET /spaces' do
    it "should show a view with all available spaces" do
      response = get('/spaces')
      
      expect(response.status).to eq(200)
      expect(response.body).to include(
        "<h1>Book a Space!</h1>",
        "Bow Manor",
        "Stamford Bridge",
        "Aldgate Tower",
        "Versailles"
      )
    end
  end

  context 'GET /spaces/:id' do
    it "should return a space by its id" do
      response = get('/spaces/2')

      expect(response.status).to eq 200
      expect(response.body).to include("Aldgate Tower")
    end
  end 

  context 'POST /request' do
    it 'redirects to account page if not logged in' do
      response = post('/request', date: '2023-01-11', status: 'Pending', space_id: 3)

      expect_redirect(response, '/login')
    end

    it 'should allow you to post a space request' do
      start_session
      response = post('/request', date: '2023-01-11', status: 'Pending', space_id: 3)

      expect(response.status).to eq 200
      expect(response.body).to include 'Your request was submitted, thank you!'
    end

    it 'should tell user if the date is out of range' do
      start_session
      response = post('/request', date: '2023-01-15', status: 'Pending', space_id: 3)

      expect(response.status).to eq 400
      expect(response.body).to include('This request is outside available dates')
    end

    it 'should tell user if the space is not available at given date' do
      start_session
      response = post('/request', date: '2023-01-20', status: 'Pending', space_id: 1)

      expect(response.status).to eq 400
      expect(response.body).to include('This space has already been booked on 2023-01-20')
    end
  end

  context 'GET /spaces/new' do
    it "should return new space form" do
      start_session

      response = get("/spaces/new")

      expect(response.status).to eq 200
      expect(response.body).to include(
        "<h1>List a new space!</h1>"
      )
    end

    it "redirects to /login if user is logged on" do
      response = get("/spaces/new")
      expect_redirect(response, "/login")
    end
  end

  context 'POST /spaces' do
    it "should allow users to list a new space" do
      response = post('/spaces', name: 'Windsor Castle', description: 'Live like royalty', price: '2499.00', start_date: '2023-01-11', end_date: '2023-02-22', user_id: 3)

      expect(response.status).to eq 200
      expect(response.body).to include 'Congratulations, your space has listed successfully!'

      response = get('/spaces')

      expect(response.body).to include("Windsor Castle")
    end

    it "raises error when wrong parameters are given" do
      response = post("/spaces", username: "SHussain")

      expect(response.status).to eq 400
      expect(response.body).to include(
        "<h2>Cannot create new space</h2>",
        'You have entered the wrong parameters'
      )
    end
  end

  context 'GET /account' do
    it "returns list of requests made by user" do
      start_session
      response = get('/account')

      expect(response.status).to eq 200
      expect(response.body).to include("<h2>Requests I've Made:</h2>")
      expect(response.body).to include("<h2>Requests I've Received:</h2>")

      expect(response.body).to include("Stamford Bridge")
      expect(response.body).to include("Pending")
      expect(response.body).to include("2023-01-14")

      expect(response.body).to include("Stamford Bridge")
      expect(response.body).to include("Accepted")
      expect(response.body).to include("2023-01-20")
    end

    it "returns list of pending requests received by the owner" do
      start_session(2)
      response = get('/account')

      expect(response.status).to eq 200
      expect(response.body).to include("<h2>Requests I've Made:</h2>")
      expect(response.body).to include("<h2>Requests I've Received:</h2>")

      expect(response.body).to include("Stamford Bridge")
      expect(response.body).to include("2023-01-14")
      expect(response.body).to include("Pending")

      expect(response.body).to_not include("2023-01-20")
    end

    it "redirects to login in page if no user logged in" do
      response = get('/account')

      expect_redirect(response, '/login')
    end
  end

  context 'Get /requests/:id' do
    it "redirects to /account if not the owner of the space requested" do
      start_session
      response = get('/requests/1')

      expect_redirect(response, '/account')
    end

    it "redirects to /login if the user is not logged in" do
      response = get("/requests/1")
      expect_redirect(response, "/login")
    end

    it "displays pending request with option to accept / decline" do
      start_session(2)
      response = get('/requests/1')

      expect(response.status).to eq 200
      expect(response.body).to include(
        "Stamford Bridge",
        "2023-01-14",
        "shah@test.com"
      )
    end

    it "has a button to accept the request" do
      start_session(2)
      response = get('/requests/1')

      expect(response.status).to eq 200
      expect(response.body).to include(
        'form action="/accept_request" method="POST"',
        'input type="hidden" name="request_id" value="1"',
        'input type="submit" class="input__signup_3" value="Accept Request"'
      )
    end
  end

  context "POST /accept_request" do
    it "accepts one request and declines other relevant ones" do
      start_session(2)
      response = post('/accept_request', request_id: '1')

      expect_redirect(response, '/account')

      request_repo = RequestRepository.new
      
      result = request_repo.find(1)
      expect(result.status).to eq "Accepted"

      result = request_repo.find(5)
      expect(result.status).to eq "Declined"
    end

    it "redirects user to login page if they're not logged in" do
      response = post('/accept_request', request_id: '1')

      expect_redirect(response, '/login')
    end

    it "raises error if not given the correct params" do
      response = post('/accept_request')

      expect(response.status).to eq 400
      expect(response.body).to eq "Invalid Parameters"
    end
  end

  private

  # Starts a session by calling POST /login with valid login details
  def start_session(id = 1)
    logins = [
      {email: 'shah@test.com', password: 'shah123'},
      {email: 'marina@test.com', password:'marina1234'},
      {email: 'thomas@test.com', password: 'thomas1234'}
    ]
    response = post('/login', email: logins[id-1][:email], password: logins[id-1][:password])
    return nil
  end

  def expect_redirect(response, destination)
    expect(response.status).to eq 302
    expect(response.header["Location"]).to include(destination)
  end
end
