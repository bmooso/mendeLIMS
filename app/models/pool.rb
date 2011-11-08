# == Schema Information
#
# Table name: pools
#
#  id                  :integer(4)      not null, primary key
#  pool_name           :string(35)      default(""), not null
#  tube_label          :string(15)      default(""), not null
#  pool_description    :string(80)
#  enzyme_code         :string(50)
#  source_conc_um      :decimal(8, 3)
#  pool_volume         :decimal(8, 3)
#  project_id          :integer(2)
#  storage_location_id :integer(2)
#  notes               :string(255)
#  updated_at          :timestamp
#

class Pool < ActiveRecord::Base
  establish_connection (:oligo_inventory)
  
  def pool_string
    return [tube_label, pool_name].join('/')
  end
  
  def self.get_pool_name(id=nil)
    pool = self.find(id) if !id.nil?
    return (pool.nil? ? nil : pool.pool_name)
  end
  
  def self.get_pool_label(id=nil)
    pool = self.find(id) if !id.nil?
    return (pool.nil? ? nil : pool.tube_label)
  end
  
  def self.populate_dropdown(lib_or_flowcell='lib')
    like_or_not = (lib_or_flowcell == 'lib' ? 'NOT LIKE' : 'LIKE')
    return self.find(:all, :order => "tube_label", :conditions => "tube_label #{like_or_not} 'OS%'")
  end

end
