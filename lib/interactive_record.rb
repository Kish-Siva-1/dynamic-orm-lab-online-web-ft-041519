require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord
  def initialize(options={})
    options.each do |property, value|
      self.send("#{property}=", value)
    end
  end
  
  def self.table_name 
    self.to_s.downcase.pluralize
  end
  
  def self.column_names
    DB[:conn].results_as_hash = true
   
    sql = "PRAGMA table_info('#{table_name}')"
   
    table_info = DB[:conn].execute(sql)
    column_names = []
   
    table_info.each do |column|
      column_names << column["name"]
    end
 
    column_names.compact
  end
  
  def table_name_for_insert
    self.class.table_name
  end
  
  def col_names_for_insert
    self.class.column_names.delete_if {|col| col == "id"}.join(", ")
  end
  
  def values_for_insert
    values = []
    self.class.column_names.each do |col_name|
      values << "'#{send(col_name)}'" unless send(col_name).nil?
    end
    values.join(", ")
  end
  
  def save
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end
  
  def self.find_by_name(name)
    sql = "SELECT * FROM #{self.table_name} WHERE name = ?"  
    DB[:conn].execute(sql,name)
  end 
  
  def self.find_by(att={})
    sql = "SELECT * FROM #{self.table_name} WHERE #{att.key(att.values[0]).to_s} = ?"  
    DB[:conn].execute(sql, att.values[0].to_s)
  end 
  
end