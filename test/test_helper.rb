require 'active_record'
require 'test/unit'

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")

require "#{File.dirname(__FILE__)}/../rails/init"

class User < ActiveRecord::Base
  has_settings
end

def setup_db
  ActiveRecord::Schema.define(:version => 1) do
    create_table :settings do |t|
      t.string :var, :null => false
      t.text   :value, :null => true
      t.integer :target_id, :null => true
      t.string :target_type, :limit => 30, :null => true
      t.timestamps :null => false
    end
    add_index :settings, [ :target_type, :target_id, :var ], :unique => true
    
    create_table :users do |t|
      t.string :name
    end
  end
end