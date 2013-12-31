class UsersController < ApplicationController
  before_action :set_user, only: [:show]
  impressionist actions: [:show]

  layout 'user_profile'

  # GET /users/1
  # GET /users/1.json
  def show
    @wallpapers = @user.wallpapers
                       .accessible_by(current_ability, :index)
                       .latest
                       .limit(6)

    @favourite_wallpapers = @user.favourite_wallpapers
                                 .accessible_by(current_ability, :index)
                                 .latest
                                 .limit(10)

    # OPTIMIZE
    @collections = @user.collections
                        .includes(:wallpapers)
                        .accessible_by(current_ability, :index)
                        .where({ wallpapers: { purity: 'sfw' }})
                        .where.not({ wallpapers: { id: nil } })
                        .order('collections.updated_at DESC') # FIXME
                        .limit(6)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find_by!(username: params[:id])
      authorize! :read, @user
    end
end