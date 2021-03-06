# Copyright (C) 2011  Kouhei Sutou <kou@clear-code.com>
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License version 2.1 as published by the Free Software Foundation.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

require 'hroonga'

require 'active_groonga'

require 'test/unit/rr'
require 'test/unit/capybara'

Capybara.configure do |config|
  # just for suppress warnings
  config.default_driver = nil
  config.current_driver = nil
end

require 'active_groonga_fabrication'

ENV["RACK_ENV"] = "test"

module HroongaTestUtils
end

class TestHroongaCommand < Test::Unit::TestCase
  include Capybara

  private
  def body
    page.driver.response.body
  end

  def setup_config
    @config = Hroonga::Configuration.new
    @config.add_load_path(Pathname(__FILE__).dirname.parent)
    @config.load("etc/hroonga.conf")
    @config.setup_database
  end

  def teardown_database
    context = @config.context
    database = context.database
    database_path = database.path
    database.close
    FileUtils.rm_rf(Pathname(database_path).dirname.to_s)
  end

  def assert_success
    assert_body({},
                :content_type => :json)
  end
end

require 'models/entry'
