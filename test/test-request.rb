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

  class TestMethod < TestCommandRequest
    def test_method
      request = create_request("#{path_prefix}/Entries", "GET")
      assert_equal("GET", request.method)
      request = create_request("#{path_prefix}/Entries", "POST")
      assert_equal("POST", request.method)
      request = create_request("#{path_prefix}/Entries", "PUT")
      assert_equal("PUT", request.method)
      request = create_request("#{path_prefix}/Entries", "DELETE")
      assert_equal("DELETE", request.method)
    end

    def test_method_specified_by_parameter
      request = create_request("#{path_prefix}/Entries?_method=GET", "GET")
      assert_equal("GET", request.method)
      request = create_request("#{path_prefix}/Entries?_method=POST", "GET")
      assert_equal("POST", request.method)
      request = create_request("#{path_prefix}/Entries?_method=PUT", "GET")
      assert_equal("PUT", request.method)
      request = create_request("#{path_prefix}/Entries?_method=DELETE", "GET")
      assert_equal("DELETE", request.method)
    end

    def test_method_specified_by_various_parameters
      request = create_request("#{path_prefix}/Entries?foo=bar&_method=POST", "GET")
      assert_equal("POST", request.method)
      request = create_request("#{path_prefix}/Entries?foo=bar&_method=POST&hoge=fuga", "GET")
      assert_equal("POST", request.method)
    end
  end

  class TestCommandPath < TestCommandRequest
    def test_simple
      request = create_request("#{path_prefix}/Entries")
      assert_equal("/Entries", request.command_path)
    end

    def test_with_parameters
      request = create_request("#{path_prefix}/Entries?foo=bar&_method=POST&hoge=fuga", "GET")
      assert_equal("/Entries", request.command_path)
    end
  end

  class TestTableName < TestCommandRequest
    def test_missing
      request = create_request(path_prefix)
      assert_nil(request.table_name)
      request = create_request("#{path_prefix}/")
      assert_nil(request.table_name)
    end

    def test_normal
      request = create_request("#{path_prefix}/Entries")
      assert_equal("Entries", request.table_name)
    end

    def test_with_suffix
      request = create_request("#{path_prefix}/Entries/columns/name")
      assert_equal("Entries", request.table_name)
    end

    def test_with_query
      request = create_request("#{path_prefix}/Entries?table_type=Hash")
      assert_equal("Entries", request.table_name)
    end
  end

  class TestTableOptions < TestCommandRequest
    def test_table_type
      request = create_request("#{path_prefix}/Entries?table_key=UInt8")
      assert_equal(:hash, request.table_type)

      request = create_request("#{path_prefix}/Entries?table_type=Hash&table_key=UInt8")
      assert_equal(:hash, request.table_type)

      request = create_request("#{path_prefix}/Entries?table_type=Array&table_key=UInt8")
      assert_equal(:array, request.table_type)

      request = create_request("#{path_prefix}/Entries?table_type=PatriciaTrie&table_key=UInt8")
      assert_equal(:patricia_trie, request.table_type)
    end

    def test_key_type
      request = create_request("#{path_prefix}/Entries?table_type=Hash")
      assert_equal(:ShortText, request.key_type)

      request = create_request("#{path_prefix}/Entries?key_type=ShortText&table_type=Hash")
      assert_equal(:ShortText, request.key_type)

      request = create_request("#{path_prefix}/Entries?key_type=UInt8&table_type=Hash")
      assert_equal(:UInt8, request.key_type)
    end
  end

  class TestColumnName < TestCommandRequest
    def test_missing
      request = create_request("#{path_prefix}/Entries/columns")
      assert_nil(request.column_name)
      request = create_request("#{path_prefix}/Entries/columns/")
      assert_nil(request.column_name)
    end

    def test_normal
      request = create_request("#{path_prefix}/Entries/columns/my_column")
      assert_equal("my_column", request.column_name)
    end

    def test_with_suffix
      request = create_request("#{path_prefix}/Entries/columns/my_column/foo/bar")
      assert_equal("my_column", request.column_name)
    end

    def test_with_query
      request = create_request("#{path_prefix}/Entries/columns/my_column?flags=foobar")
      assert_equal("my_column", request.column_name)
    end
  end

  class TestColumnOptions < TestCommandRequest
    def test_column_type
      request = create_request("#{path_prefix}/Entries/columns/my_column?value_type=UInt8")
      assert_equal(:scalar, request.column_type)

      request = create_request("#{path_prefix}/Entries/columns/my_column?column_type=Scalar&value_type=UInt8")
      assert_equal(:scalar, request.column_type)

      request = create_request("#{path_prefix}/Entries/columns/my_column?column_type=Vector&value_type=UInt8")
      assert_equal(:vector, request.column_type)

      request = create_request("#{path_prefix}/Entries/columns/my_column?column_type=Index&value_type=UInt8")
      assert_equal(:index, request.column_type)
    end

    def test_value_type
      request = create_request("#{path_prefix}/Entries?column_type=Scalar")
      assert_equal(:ShortText, request.value_type)

      request = create_request("#{path_prefix}/Entries?value_type=ShortText&column_type=Scalar")
      assert_equal(:ShortText, request.value_type)

      request = create_request("#{path_prefix}/Entries?value_type=UInt8&column_type=Scalar")
      assert_equal(:UInt8, request.value_type)
    end
  end

  class TestRecordKey < TestCommandRequest
    def test_missing
      request = create_request("#{path_prefix}/Entries/records")
      assert_nil(request.record_key)
      request = create_request("#{path_prefix}/Entries/records/")
      assert_nil(request.record_key)
    end

    def test_normal
      request = create_request("#{path_prefix}/Entries/records/my_record")
      assert_equal("my_record", request.record_key)
    end

    def test_with_suffix
      request = create_request("#{path_prefix}/Entries/records/my_record/foo/bar")
      assert_equal("my_record", request.record_key)
    end

    def test_with_query
      request = create_request("#{path_prefix}/Entries/records/my_record?flags=foobar")
      assert_equal("my_record", request.record_key)
    end
  end

  private
  def create_request(path, method="GET")
    environment = Rack::MockRequest.env_for(path, :method => method)
    Hroonga::Command::Request.new(environment)
  end

  def path_prefix
    "/api/1/tables"
  end
end
