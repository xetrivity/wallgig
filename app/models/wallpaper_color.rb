# == Schema Information
#
# Table name: wallpaper_colors
#
#  id           :integer          not null, primary key
#  wallpaper_id :integer
#  color_id     :integer
#  percentage   :float
#

class WallpaperColor < ActiveRecord::Base
  belongs_to :wallpaper
  belongs_to :color, class_name: 'Kolor'

  delegate :red, :green, :blue, :hex, :to_html_hex, to: :color
end
