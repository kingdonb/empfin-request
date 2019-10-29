class EmptiesController < ApplicationController
  before_action :set_empty, only: [:show, :edit, :update, :destroy]

  # GET /empties
  # GET /empties.json
  def index
    @empties = Empty.all
  end

  # GET /empties/1
  # GET /empties/1.json
  def show
  end

  # GET /empties/new
  def new
    @empty = Empty.new
  end

  # GET /empties/1/edit
  def edit
  end

  # POST /empties
  # POST /empties.json
  def create
    @empty = Empty.new(empty_params)

    respond_to do |format|
      if @empty.save
        format.html { redirect_to @empty, notice: 'Empty was successfully created.' }
        format.json { render :show, status: :created, location: @empty }
      else
        format.html { render :new }
        format.json { render json: @empty.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /empties/1
  # PATCH/PUT /empties/1.json
  def update
    respond_to do |format|
      if @empty.update(empty_params)
        format.html { redirect_to @empty, notice: 'Empty was successfully updated.' }
        format.json { render :show, status: :ok, location: @empty }
      else
        format.html { render :edit }
        format.json { render json: @empty.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /empties/1
  # DELETE /empties/1.json
  def destroy
    @empty.destroy
    respond_to do |format|
      format.html { redirect_to empties_url, notice: 'Empty was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_empty
      @empty = Empty.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def empty_params
      params.fetch(:empty, {})
    end
end
