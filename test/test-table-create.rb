#!/usr/bin/env ruby
#
# Copyright (C) 2011  SHIMODA Hiroshi <shimoda@clear-code.com>
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

class TestTableCreate < TestHroongaCommand
  def setup
    setup_config
    @config.setup_database

    @context = Groonga::Context.new(:encoding => :utf8)
    @context.open_database(@config.database_path)

    Capybara.app = Hroonga::Command::TableCreate.new(@config)
  end

  def teardown
    teardown_database
  end

  def test_no_option
    assert_no_table("Entries")
    page.driver.post("/api/1/tables/Entries")
    assert_body({},
                :content_type => :json)
    assert_table_exist("Entries")
  end

  private
  def assert_no_table(name)
    assert_nil(@context[name], @context.inspect)
  end

  def assert_table_exist(name)
    table = @context[name]
    assert_not_nil(table, @context.inspect)
  end
end
