class ReactorController < ApplicationController
  def create_object
    obj_data  = params[:obj] || {}
    obj_class = obj_data.delete("obj_class")
    parent_id = obj_data.delete("parent_id").to_i
    name      = obj_data.delete("name")

    o = Obj.new(:obj_class => obj_class, :name => name, :parent => parent_id) do |obj|
      obj.send(:reload_attributes, obj_class)
      obj.update_attributes!(obj_data)
    end
    respond_to do |format|
      format.html { redirect_to(cms_path(o)) }
      format.json { render :json => o }
    end
  end

  def release_object
    obj = Obj.find(params[:id])
    obj.release!
    success = true
  rescue => e
    flash[:error] = "#{e.class}\n\n#{e.message}"
    success = false
  ensure
    respond_to do |format|
      format.html { redirect_to(:back) }
      if success
        format.json { render :json => :ok }
      else
        format.json { render :json => flash[:error], :status => :unprocessable_entity } # something smarter would be nice
      end
    end
  end

  def update_object
    obj = Obj.find(params[:id])
    obj.update_attributes!(params[:obj])
    respond_to do |format|
      format.html { redirect_to(:back) }
      format.json { render :json => :ok }
    end
  end

  def delete_object
    obj = Obj.find(params[:id])
    obj.destroy
    respond_to do |format|
      format.html { redirect_to(:back) }
      format.json { render :json => :ok }
    end
  end
end