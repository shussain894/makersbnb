require 'space_repository'
require 'space'

def reset_tables
  seed_sql = File.read('spec/seeds/table_seeds.sql')
  connection = PG.connect({ host: "127.0.0.1", dbname: "makersbnb_test" })
  connection.exec(seed_sql)
end

RSpec.describe SpaceRepository do
  before(:each) do
    reset_tables
  end

  context "# all" do
    it "shows all spaces" do
      spacerepo = SpaceRepository.new
      spaces = spacerepo.all
      expect(spaces.length).to eq 4
      expect(spaces.first).to have_attributes(
        id: 1, 
        name: 'Stamford Bridge', 
        description: 'Home of the mighty blues', 
        price: 1.00, 
        start_date: '2023-01-01', 
        end_date: '2023-02-01', 
        user_id: 2)
      
      expect(spaces.last).to have_attributes(
        id: 4,
        name: 'Versailles', 
        description:'Pretty Lush innit', 
        price: 1000.00, 
        start_date: '2022-01-01', 
        end_date: '2022-01-31', 
        user_id: 3)
    end
  end 

  context "#all_available" do
    it "shows all available spaces" do
      timer_dbl = double(:fake_timer)
      expect(timer_dbl).to receive(:now)
        .and_return(Time.new(2023, 1, 4))

      space_repo = SpaceRepository.new(timer_dbl)
      spaces = space_repo.all_available

      expect(spaces.length).to eq 3

      expect(spaces.first).to have_attributes(
        id: 1, 
        name: 'Stamford Bridge', 
        description: 'Home of the mighty blues', 
        price: 1.00, 
        start_date: '2023-01-01', 
        end_date: '2023-02-01', 
        user_id: 2
      )

      expect(spaces.last).to have_attributes(
        id: 3,
        name: 'Bow Manor', 
        description:'Cheap and cheerful', 
        price: 30.99, 
        start_date: '2023-01-03', 
        end_date: '2023-01-11', 
        user_id: 1
      )
    end

    it "shows all available spaces" do
      timer_dbl = double(:fake_timer)
      expect(timer_dbl).to receive(:now)
        .and_return(Time.new(2023, 12, 1))

      space_repo = SpaceRepository.new(timer_dbl)
      spaces = space_repo.all_available

      expect(spaces).to eq []
    end
  end

  context "find a space by its id" do
    it "should return a space based on the given id" do
      spacerepo = SpaceRepository.new
      space = spacerepo.find_by_id(2)

      expect(space).to have_attributes(
        id: 2,
        name: 'Aldgate Tower',
        price: 600,
      )
    end
  end

  context "#create method" do
    it "adds a new space" do
      space_repo = SpaceRepository.new
      new_space = Space.new
      new_space.name = 'Windsor Castle'
      new_space.description = 'Live like royalty'
      new_space.price = 2499.00
      new_space.start_date = '2023-01-11'
      new_space.end_date = '2023-02-22'
      new_space.user_id = 3

      space_repo.create(new_space)
      space = space_repo.all
      expect(space.last).to have_attributes(
        id: 5,
        name: 'Windsor Castle',
        description: 'Live like royalty', 
        price: 2499.00, 
        start_date: '2023-01-11', 
        end_date: '2023-02-22', 
        user_id: 3)
    end 
  end
end 
