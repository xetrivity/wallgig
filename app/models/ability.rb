# Reference: https://github.com/ryanb/cancan/wiki/Defining-Abilities
class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new

    alias_action :create, :read, :update, :destroy, :to => :crud

    if user.admin? || user.moderator?
      can :manage, :all
    end

    # Collection
    can :read, Collection, public: true

    # Favourite
    can :read, Favourite, wallpaper: { processing: false, purity: 'sfw' }

    # User
    can :read, User

    if user.persisted?
      # Wallpaper
      can :crud, Wallpaper, user_id: user.id
      can :read, Wallpaper, processing: false
      can [:update, :update_purity], Wallpaper
      cannot :update_purity, Wallpaper, purity_locked: true

      # Favourite
      can :crud, Favourite, user_id: user.id

      # Collection
      can :crud, Collection, user_id: user.id

      # Comment
      can :crud, Comment, user_id: user.id
      cannot :destroy, Comment do |comment|
        # 15 minutes to destroy a comment
        Time.now - comment.created_at > 15.minutes
      end

      # User
      can :crud, User, id: user.id

      # Groups
      can :read, Group, access: 'public'
      can :join, Group, access: 'public'
      cannot :join, Group, users_groups: { user_id: user.id }

      can :leave, Group, users_groups: { user_id: user.id }
      cannot :leave, Group, owner_id: user.id
    else
      # Wallpaper
      can :read, Wallpaper, processing: false, purity: 'sfw'
    end
  end
end