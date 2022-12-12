require 'sinatra/base'
require 'sinatra/reloader'
require 'rack'
require 'bcrypt'
require_relative 'lib/user_repository'
require_relative 'lib/space_repository'
require_relative 'lib/request_repository'
require_relative 'lib/database_connection'
require_relative 'lib/request'


if ENV['ENV'] == 'test'
  DatabaseConnection.connect('makersbnb_test')
else
  DatabaseConnection.connect('makersbnb')
end

class Application < Sinatra::Base

enable :sessions

  configure :development do
    register Sinatra::Reloader
  end

  before do
    @session = session[:user_id]
    unless @session.nil?
      user_repo = UserRepository.new
      @user = user_repo.find(@session)
    end
    clean_params(params)
  end

  get '/' do
    redirect("/login")
    # @session = session[:user_id]
    # return erb(:homepage)
  end

  get '/users/new' do
    redirect("/spaces") unless session[:user_id].nil?

    return erb(:new_users)
  end

  post '/users' do
    if params[:email].include?('@')
      user = User.new
      user.name = params[:name]
      user.email = params[:email]
      user.password = params[:password]

      repo = UserRepository.new
      repo.create(user)
      return erb(:user_created)
    else
      return erb(:invalid_email)
    end
  end

  get '/login' do
    redirect("/spaces") unless session[:user_id].nil?

    return erb(:login_page)
  end

  post '/login' do
    email = params[:email]
    password = params[:password]

    repo = UserRepository.new
    user = repo.find_by_email(email)
    if BCrypt::Password.new(user.password) == password && user.email == email
      session[:user_id] = user.id
      @user = user
      return erb(:login_success)
    else
      redirect '/login'
   end
  end

  get '/logout' do
    session.clear
    redirect '/'
  end

  get '/spaces' do
    @spaces = SpaceRepository.new.all 
    return erb(:'spaces/index')
  end 

  get '/spaces/new' do
    redirect("/login") if session["user_id"].nil?

    return erb(:'spaces/new')
  end

  get '/spaces/:id' do
    spacerepo = SpaceRepository.new
    @space = spacerepo.find_by_id(params[:id]) 
    return erb(:'spaces/request_space')
  end 

  post '/request' do
    redirect('/login') if session[:user_id].nil?

    requestrepo = RequestRepository.new
    spacerepo = SpaceRepository.new
    request = Request.new
    request.date = params[:date]
    request.status = 'Pending'
    request.user_id = session[:user_id]
    request.space_id = params[:space_id]

    begin
      requestrepo.create(request)
    rescue => error
      status 400
      return error.message
    end

    return erb(:request_success)
  end 

  post '/spaces' do
    if invalid_post_spaces?
      status 400
      return erb(:'spaces/error')
    end

    space = Space.new
    space.name = params[:name]
    space.description = params[:description]
    space.price = params[:price]
    space.start_date = params[:start_date]
    space.end_date = params[:end_date]
    space.user_id = session[:user_id] # check this

    SpaceRepository.new.create(space)

    return erb(:'spaces/new_space_confirmation')
  end

  get '/account' do
    redirect("/login") if session["user_id"].nil?

    request_repo = RequestRepository.new
    @requests_made = request_repo.find_by_user_id(session[:user_id])

    @space_repo = SpaceRepository.new
    user_repo = UserRepository.new
    @user = user_repo.find(session[:user_id])

    @requests_received = request_repo.find_by_owner_id(session[:user_id])
    
    erb(:account)
  end

  get '/requests/:id' do
    redirect("/login") if session[:user_id].nil?

    request_repo = RequestRepository.new
    requests = request_repo.find_by_owner_id(session[:user_id])

    match = requests.any? do |request|
      request.id == params[:id].to_i
    end

    redirect '/account' unless match

    @pending_request = request_repo.find(params[:id])
    @space = SpaceRepository.new.find_by_id(@pending_request.space_id)
    @user = UserRepository.new.find(@pending_request.user_id)

    return erb(:request)
  end

  post '/accept_request' do
    if params[:request_id] == nil
      status 400
      return "Invalid Parameters"
    end

    redirect("/login") if session[:user_id].nil?

    request_repo = RequestRepository.new

    request_repo.accept_request(params[:request_id])

    redirect '/account'
  end

  private

  def invalid_post_spaces?
    return params[:name].nil? ||
      params[:description].nil? ||
      params[:price].nil? ||
      params[:start_date].nil? ||
      params[:end_date].nil? ||
      params[:user_id].nil?
  end

  def clean_params(params)
    params.update(params) do |key, value|
      Rack::Utils.escape_html(value)
    end
  end
end
