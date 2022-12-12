require 'user'
require 'user_repository'
require 'bcrypt'

def reset_users_table
  seed_sql = File.read('spec/seeds/table_seeds.sql')
  connection = PG.connect({ host: '127.0.0.1', dbname: 'makersbnb_test' })
  connection.exec(seed_sql)
end

RSpec.describe UserRepository do
	before(:each) do 
    reset_users_table
  end

	context "list all the users" do
		it "returns all user" do
			repo = UserRepository.new
			users = repo.all
			expect(users[0].id).to eq '1'
			expect(users[0].name).to eq 'Shah'
			expect(users[0].email).to eq 'shah@test.com'
			expect(BCrypt::Password.new(users[0].password)).to eq 'shah123'

			expect(users.length).to eq 3
		end
	end


	context "create method" do
		it "creates a new user" do
			repo = UserRepository.new
			user = User.new

			user.name = 'Robbie'
			user.email = 'robbie@test.com'
			user.password = '1234'

			repo.create(user)
			users = repo.all
			last_user = users.last
			expect(last_user.id).to eq '4'
			expect(last_user.name).to eq 'Robbie'
			expect(last_user.email).to eq 'robbie@test.com'
			expect(BCrypt::Password.new(last_user.password)).to eq '1234'
		end

		it "creates a new user with a password containing <script>" do
			repo = UserRepository.new
			user = User.new

			user.name = 'Robbie'
			user.email = 'robbie@test.com'
			user.password = '<script>1234'

			repo.create(user)
			users = repo.all
			last_user = users.last
			expect(last_user.id).to eq '4'
			expect(last_user.name).to eq 'Robbie'
			expect(last_user.email).to eq 'robbie@test.com'
			expect(BCrypt::Password.new(last_user.password)).to eq '<script>1234'
		end
	end

	context "find by email" do
		it "finds the user by email address" do
			repo = UserRepository.new
			user = repo.find_by_email('marina@test.com')
			expect(user.id).to eq '2'
			expect(user.name).to eq 'Marina' 
			expect(BCrypt::Password.new(user.password)).to eq 'marina1234' 
		end
	end
	
	context "find by id" do
		it "returns a single instance of User" do
			repo = UserRepository.new
			user = repo.find(2)
			expect(user.id).to eq '2'
			expect(user.name).to eq 'Marina' 
			expect(user.email).to eq 'marina@test.com'
			expect(BCrypt::Password.new(user.password)).to eq 'marina1234'
		end
	end
end