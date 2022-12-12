require_relative 'user'
require "bcrypt"

class UserRepository
	def all
		users = []
		sql = 'SELECT id, name, email, password FROM users'
		result_set = DatabaseConnection.exec_params(sql, [])

		result_set.each do |record|
			users << extract_user_from_record(record)
		end
		return users
	end

	def create(user)
		sql = 'INSERT INTO users (name, email, password) VALUES ($1, $2, $3)'
		params = [user.name, user.email, BCrypt::Password::create(user.password)]
		result_set = DatabaseConnection.exec_params(sql, params)

		return user
	end

	def find(id)
		sql = 'SELECT id, name, email, password FROM users WHERE id = $1'
		result_set = DatabaseConnection.exec_params(sql, [id])

		return extract_user_from_record(result_set[0])
	end

	def find_by_email(email)
		sql = 'SELECT id, name, email, password FROM users WHERE email = $1'
		result_set = DatabaseConnection.exec_params(sql, [email])

		return extract_user_from_record(result_set[0])
	end

	private

	def extract_user_from_record(record)
		user = User.new
		user.id = record['id']
		user.name = record['name']
		user.email = record['email']
		user.password = record['password']
		return user
	end
end
