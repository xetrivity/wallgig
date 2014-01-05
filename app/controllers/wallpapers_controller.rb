class WallpapersController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_wallpaper, only: [:show, :edit, :update, :destroy, :update_purity, :history]
  impressionist actions: [:show]

  helper_method :search_params

  # GET /wallpapers
  # GET /wallpapers.json
  def index
    search_options = search_params

    if search_options[:order] == 'random'
      search_options[:random_seed] = session[:random_seed]
      search_options[:random_seed] = nil if search_options[:page].to_i <= 1
      search_options[:random_seed] ||= Time.now.to_i
      session[:random_seed] = search_options[:random_seed]
    end

    wallpapers = WallpaperSearch.new(search_options).wallpapers
    @wallpapers = WallpapersDecorator.new(wallpapers, context: {
      user: current_user,
      search_options: search_options
    })

    if request.xhr?
      render partial: 'list', layout: false, locals: { wallpapers: @wallpapers }
    end
  end

  # GET /wallpapers/1
  # GET /wallpapers/1.json
  def show
    @wallpaper = @wallpaper.decorate
  end

  # GET /wallpapers/new
  def new
    @wallpaper = current_user.wallpapers.new
    authorize! :create, @wallpaper
  end

  # GET /wallpapers/1/edit
  def edit
    authorize! :update, @wallpaper
  end

  # POST /wallpapers
  # POST /wallpapers.json
  def create
    @wallpaper = current_user.wallpapers.new(wallpaper_params)
    authorize! :create, @wallpaper

    respond_to do |format|
      if @wallpaper.save
        format.html { redirect_to @wallpaper, notice: 'Wallpaper was successfully created.' }
        format.json { render action: 'show', status: :created, location: @wallpaper }
      else
        format.html { render action: 'new' }
        format.json { render json: @wallpaper.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /wallpapers/1
  # PATCH/PUT /wallpapers/1.json
  def update
    authorize! :update, @wallpaper

    respond_to do |format|
      if @wallpaper.update(update_wallpaper_params)
        format.html { redirect_to @wallpaper, notice: 'Wallpaper was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @wallpaper.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /wallpapers/1
  # DELETE /wallpapers/1.json
  def destroy
    authorize! :destroy, @wallpaper
    @wallpaper.destroy

    respond_to do |format|
      format.html { redirect_to wallpapers_url }
      format.json { head :no_content }
    end
  end

  # PATCH /wallpapers/1/update_purity.js
  def update_purity
    authorize! :update_purity, @wallpaper
    @wallpaper.purity = params[:purity]
    @wallpaper.save
  end

  # GET /wallpapers/1/history
  def history
  end

  # POST /wallpapers/save_search_params
  # POST /wallpapers/save_search_params.json
  def save_search_params
    session[:search_params] = search_params(false).to_hash

    respond_to do |format|
      format.html { redirect_to :back, notice: 'Search settings successfully saved.' }
      format.json { head :no_content }
    end
  end

  private
    def set_wallpaper
      @wallpaper = Wallpaper.find(params[:id])
      authorize! :read, @wallpaper
    end

    def wallpaper_params
      params.require(:wallpaper).permit(:purity, :image, :tag_list, :image_gravity, :source)
    end

    def update_wallpaper_params_with_purity
      params.require(:wallpaper).permit(:tag_list, :image_gravity, :source, :purity)
    end

    def update_wallpaper_params_without_purity
      update_wallpaper_params_with_purity.tap { |p| p.delete(:purity) }
    end

    def update_wallpaper_params
      if can? :update_purity, @wallpaper
        update_wallpaper_params_with_purity
      else
        update_wallpaper_params_without_purity
      end
    end

    def search_params(load_session = true)
      params.permit(:q, :page, :width, :height, :order, purity: [], tags: [], exclude_tags: [], colors: []).tap do |p|
        p.reverse_merge! session[:search_params] if load_session && p.blank? && session[:search_params].present?

        # Default values
        p[:order] ||= 'latest'
        p[:purity] ||= ['sfw']
      end
    end
end
