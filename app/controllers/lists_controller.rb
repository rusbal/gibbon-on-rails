class ListsController < ApplicationController

  def index
    load_lists
  end

  def show 
    load_list
  end

  def new 
    build_list
  end

  def create
    build_list
    save_list or render 'new'
  end

  def edit 
    load_list 
    build_list
  end

  def update
    load_list
    build_list
    save_list or render 'edit'
  end

  def destroy
    load_list @list.destroy 
    redirect_to lists_path
  end

  private

  def load_lists
    @lists = @gibbon.lists.retrieve["lists"]
  end

  def load_list
    @members = @gibbon.lists.send(params[:id]).members.retrieve["members"]
  end

  def build_list
    @list ||= list_scope.build @list.attributes = list_params
  end

  def save_list 
    if @list.save
      redirect_to @list 
    end
  end

  def list_params
    list_params = params[:list]
    list_params ? list_params.permit(:title, :text, :published) : {}
  end

  def list_scope 
    list.scoped
  end

end
