# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

screen_resolutions = [
  { width: 800, height: 600, category: :standard },
  { width: 1024, height: 768, category: :standard },
  { width: 1280, height: 960, category: :standard },
  { width: 1280, height: 1024, category: :standard },
  { width: 1400, height: 1050, category: :standard },
  { width: 1600, height: 1200, category: :standard },
  { width: 2560, height: 2048, category: :standard },
  { width: 1024, height: 600, category: :widescreen },
  { width: 1280, height: 800, category: :widescreen },
  { width: 1366, height: 768, category: :widescreen },
  { width: 1440, height: 900, category: :widescreen },
  { width: 1600, height: 900, category: :widescreen },
  { width: 1680, height: 1050, category: :widescreen },
  { width: 1920, height: 1080, category: :widescreen },
  { width: 1920, height: 1200, category: :widescreen },
  { width: 2560, height: 1440, category: :widescreen },
  { width: 2560, height: 1600, category: :widescreen },
]

screen_resolutions.each do |screen_resolution|
  ScreenResolution.find_or_create_by(screen_resolution)
end

user = User.create!({username: 'admin', email: 'admin@example.com', password: 'password', admin: true})
user.confirm!