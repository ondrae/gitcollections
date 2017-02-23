class CollectionsController < ApplicationController
  before_action :set_collection, only: [:show, :edit, :update, :destroy, :update_from_github, :owner_only]
  before_action :owner_only, only: [:edit, :update, :destroy]

  # PUT /update_from_github
  def update_from_github
    @collection.update_projects
    redirect_to request.referer
  end

  # GET /collections
  # GET /collections.json
  def index
    if params[:user_id]
      user = User.friendly.find(params[:user_id])
      @collections = user.collections.page(params[:page])
    else
      @collections = Collection.all.page(params[:page])
    end
    if params[:search]
      @collections = @collections.basic_search(params[:search]).page(params[:page])
    end
  end

  # GET /collections/1
  # GET /collections/1.json
  def show
    if params[:search]
      @projects = @collection.projects.basic_search params[:search]
      @issues = search_labels + search_titles
    end
  end

  # GET /collections/new
  def new
    @collection = Collection.new
  end

  # GET /collections/1/edit
  def edit
  end

  # POST /collections
  # POST /collections.json
  def create
    @collection = Collection.new(collection_params.merge(user: current_user))

    respond_to do |format|
      if @collection.save
        format.html { redirect_to collections_path, notice: 'Collection was successfully created.' }
        format.json { render :show, status: :created, location: @collection }
      else
        format.html { render :new }
        format.json { render json: @collection.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /collections/1
  # PATCH/PUT /collections/1.json
  def update
    respond_to do |format|
      if @collection.update(collection_params)
        format.html { redirect_to @collection, notice: 'Collection was successfully updated.' }
        format.json { render :show, status: :ok, location: @collection }
      else
        format.html { render :edit }
        format.json { render json: @collection.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /collections/1
  # DELETE /collections/1.json
  def destroy
    @collection.destroy
    respond_to do |format|
      format.html { redirect_to collections_url, notice: 'Collection was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_collection
      @collection = Collection.friendly.find params[:id]
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def collection_params
      params.require(:collection).permit(:name, :description)
    end

    def owner_only
      render json: {}, status: :forbidden unless current_user == @collection.user
    end

    def search_labels
      @collection.issues.joins(:labels).where("labels.name ILIKE :search", { search: "%#{params[:search]}%" } )
    end

    def search_titles
      @collection.issues.basic_search params[:search]
    end
end
