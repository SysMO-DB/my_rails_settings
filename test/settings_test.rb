require 'test_helper'

class SettingsTest < Test::Unit::TestCase
  setup_db
  
  def setup
    Settings.create(:var => 'test',  :value => 'foo')
    Settings.create(:var => 'test2', :value => 'bar')
  end

  def teardown
    Settings.delete_all
  end

  test "defaults_false" do
    Settings.defaults[:foo] = false
    assert_equal false, Settings.foo
  end

  test "defaults" do
    Settings.defaults[:foo] = 'default foo'
    
    assert_nil Settings.target(:foo)
    assert_equal 'default foo', Settings.foo
    
    Settings.foo = 'bar'
    assert_equal 'bar', Settings.foo
    assert_not_nil Settings.target(:foo)
  end
  
  test "get" do
    assert_setting 'foo', :test
    assert_setting 'bar', :test2
  end

  test "update" do
    assert_assign_setting '321', :test
  end
  
  test "create" do
    assert_assign_setting '123', :onetwothree
  end
  
  test "complex_serialization" do
    complex = [1, '2', {:three => true}]
    Settings.complex = complex
    assert_equal complex, Settings.complex
  end
  
  test "serialization_of_float" do
    Settings.float = 0.01
    Settings.reload
    assert_equal 0.01, Settings.float
    assert_equal 0.02, Settings.float * 2
  end
  
  test "target_scope" do
    user1 = User.create :name => 'First user'
    user2 = User.create :name => 'Second user'
    
    assert_assign_setting 1, :one, user1
    assert_assign_setting 2, :two, user2
    
    assert_setting 1, :one, user1
    assert_setting 2, :two, user2
    
    assert_setting nil, :one
    assert_setting nil, :two
    
    assert_setting nil, :two, user1
    assert_setting nil, :one, user2
    
    assert_equal({ "one" => 1}, user1.settings.to_hash('one'))
    assert_equal({ "two" => 2}, user2.settings.to_hash('two'))
    assert_equal({ "one" => 1}, user1.settings.to_hash('o'))
    assert_equal({}, user1.settings.to_hash('non_existing_var'))
  end
  
  test "named_scope" do
    user_without_settings = User.create :name => 'User without settings'
    user_with_settings = User.create :name => 'User with settings'
    user_with_settings.settings.one = '1'
    user_with_settings.settings.two = '2'
    
    assert_equal [user_with_settings], User.with_settings
    assert_equal [user_with_settings], User.with_settings_for('one')
    assert_equal [user_with_settings], User.with_settings_for('two')
    assert_equal [], User.with_settings_for('foo')
    
    assert_equal [user_without_settings], User.without_settings
    assert_equal [user_without_settings], User.without_settings_for('one')
    assert_equal [user_without_settings], User.without_settings_for('two')
    assert_equal [user_without_settings, user_with_settings], User.without_settings_for('foo')
  end
  
  test "to_hash" do
    assert_equal({ "test2" => "bar", "test" => "foo" }, Settings.to_hash)
    assert_equal({ "test2" => "bar" }, Settings.to_hash('test2'))
    assert_equal({ "test2" => "bar", "test" => "foo" }, Settings.to_hash('test'))
    assert_equal({}, Settings.to_hash('non_existing_var'))
  end
  
  test "merge" do
    assert_raise(TypeError) do
      Settings.merge! :test, { :a => 1 }
    end

    Settings[:hash] = { :one => 1 }
    Settings.merge! :hash, { :two => 2 }
    assert_equal({ :one => 1, :two => 2 }, Settings[:hash])
    
    assert_raise(ArgumentError) do
      Settings.merge! :hash, 123
    end
    
    Settings.merge! :empty_hash, { :two => 2 }
    assert_equal({ :two => 2 }, Settings[:empty_hash])
  end
  
  test "destroy" do
    Settings.destroy :test
    assert_equal nil, Settings.test
  end
  
  private
    def assert_setting(value, key, scope_target=nil)
      key = key.to_sym
      
      if scope_target
        assert_equal value, scope_target.instance_eval("settings.#{key}")
        assert_equal value, scope_target.settings[key.to_sym]
        assert_equal value, scope_target.settings[key.to_s]
      else
        assert_equal value, eval("Settings.#{key}")
        assert_equal value, Settings[key.to_sym]
        assert_equal value, Settings[key.to_s]
      end
    end
    
    def assert_assign_setting(value, key, scope_target=nil)
      key = key.to_sym
      
      if scope_target
        assert_equal value, (scope_target.settings[key] = value)
        assert_setting value, key, scope_target
        scope_target.settings[key] = nil
      
        assert_equal value, (scope_target.settings[key.to_s] = value)
        assert_setting value, key, scope_target
      else
        assert_equal value, (Settings[key] = value)
        assert_setting value, key
        Settings[key] = nil
      
        assert_equal value, (Settings[key.to_s] = value)
        assert_setting value, key
      end
    end
end