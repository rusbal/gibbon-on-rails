module ListsHelper
  def current_list
    @list_id = params[:list_id] || params[:id]
    @list = @list_id ? @gibbon.lists.send(@list_id).retrieve : {}
  end
end
