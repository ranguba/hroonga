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

class TestCommandRequest < Test::Unit::TestCase
  def setup
  end

  def teardown
  end

  class TestTableName < TestCommandRequest
    def test_missing
      request = create_request("GET", path_prefix)
      assert_nil(request.table_name)
    end

    def test_normal
      request = create_request("GET", "#{path_prefix}/Entries")
      assert_equal("Entries", request.table_name)
    end

    def test_with_suffix
      request = create_request("GET", "#{path_prefix}/Entries/columns/name")
      assert_equal("Entries", request.table_name)
    end
  end

  private
  def create_request(method, path)
    environment = Rack::MockRequest.env_for(path, :method => method)
    Hroonga::Command::Request.new(environment)
  end

  def path_prefix
    "/api/1/tables"
  end
end
