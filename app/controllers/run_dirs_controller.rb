class RunDirsController < ApplicationController
  before_filter :dropdowns, :only => [:new, :edit]
  
  def index
    run_dirs  = RunDir.find(:all, :include => :flow_cell,
                            :order => "flow_cells.seq_run_nr, run_dirs.device_name")
    @run_dirs = run_dirs.group_by {|run_dir| run_dir.flow_cell.seq_run_nr}
    render :action => :index
  end
  
  # GET /run_dirs/1
  def show
    @run_dir = RunDir.find(params[:id])
    render :action => :show
  end
 
  def get_params 
    render :action => :get_params
  end
  
  def new
    @flow_cell, rc = find_flow_cell_using_params(params)
    
    if @flow_cell.nil?
      set_error_message(rc)
      render :action => :get_params
    else
      @run_dir  = RunDir.new(:date_verified => nil, :date_sized => nil)
      run_devices = @flow_cell.run_dirs.map(&:device_name)
      @storage_devices.delete_if{|device| run_devices.include?(device.device_name)}
      render :action => :new
    end
  end
  
  def create
    @run_dir = RunDir.new(params[:run_dir])
    
    if @run_dir.save
      flash[:notice] = 'Run directory entry successfully saved'
      redirect_to :action => :new, :flow_cell_id => @run_dir.flow_cell_id
      
    else
      flash.now[:error] = "Error saving run directory entry"
      @flow_cell = FlowCell.find(@run_dir.flow_cell_id, :include => :run_dirs)
      dropdowns
      render :action => :new
    end  
    
  end
  
  def edit
    @run_dir = RunDir.find(params[:id])
    render :action => :edit
  end
  
  
  def update
    @run_dir = RunDir.find(params[:id]) 
    #render :action => :debug

    if @run_dir.update_attributes(params[:run_dir])
      flash[:notice] = 'Run directory was successfully updated.'
      redirect_to(:action => :new, :flow_cell_id => @run_dir.flow_cell_id) 
    else
      flash.now[:error] = 'Error - Run directory not saved'
      dropdowns
      render :action => :edit, :id => @run_dir.id
    end
  end
  
  def destroy
    @run_dir = RunDir.find(params[:id])
    flow_cell_id = @run_dir.flow_cell_id
    @run_dir.destroy
    
    redirect_to :action => 'new', :flow_cell_id => flow_cell_id
  end

protected
  def dropdowns
    @storage_devices = StorageDevice.populate_dropdown
  end
  
  def find_flow_cell_using_params(params)
    rc = 0; @condition_array = nil
    if params[:flow_cell_id]
      @condition_array = ["flow_cells.id = ?", params[:flow_cell_id]]
    elsif !params[:run_nr].blank?
      @condition_array = ["flow_cells.seq_run_nr = ?", params[:run_nr].to_i] 
    elsif params[:flow_cell] && !param_blank?(params[:flow_cell][:sequencing_key])
      @condition_array = ["flow_cells.sequencing_key = ?", params[:flow_cell][:sequencing_key]]
    else
      rc = -1
    end
    
    flow_cell = FlowCell.find_flowcell_incl_rundirs(@condition_array) if rc == 0
    return flow_cell, rc 
  end
  
  def set_error_message(rc)
    error_msg = {'0' => "Sequencing run not found for parameters entered - please try again",
                 '1' => "Please enter sequencing run number, or sequencing key" }
    rc_string = rc.abs.to_s
    flash.now[:error] = error_msg[rc_string]
  end
  
end