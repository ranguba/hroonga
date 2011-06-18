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
    assert_table("Entries")
  end

  def test_array_table
    assert_no_table("Entries")
    page.driver.post("/api/1/tables/Entries?table_type=Array")
    assert_body({},
                :content_type => :json)
    assert_table("Entries",
                 :type => Groonga::Array)
  end

  def test_hash_table
    assert_no_table("Entries")
    page.driver.post("/api/1/tables/Entries?table_type=Hash&key_type=ShortText&default_tokenizer=TokenBigram")
    assert_body({},
                :content_type => :json)
    assert_table("Entries",
                 :type => Groonga::Hash,
                 :key_type => "ShortText",
                 :default_tokenizer => "TokenBigram",
                 :normalize_key => false)
  end

  def test_patricia_trie_table
    assert_no_table("Terms")
    page.driver.post("/api/1/tables/Terms?table_type=PatriciaTrie&key_type=ShortText&default_tokenizer=TokenBigram&flags=KEY_NORMALIZE")
    assert_body({},
                :content_type => :json)
    assert_table("Terms",
                 :type => Groonga::PatriciaTrie,
                 :key_type => "ShortText",
                 :default_tokenizer => "TokenBigram",
                 :normalize_key => true)
  end

  # XXX test for the flag "KEY_WITH_SIS" is required!

  private
  def assert_no_table(name)
    assert_nil(@context[name], @context.inspect)
  end

  def assert_table(name, properties={})
    table = @context[name]
    assert_not_nil(table, @context.inspect)
    actual = {}
    if properties.include?(:type)
      actual[:type] = table.class
    end
    if properties.include?(:key_type)
      actual[:key_type] = table.domain.name
    end
    if properties.include?(:default_tokenizer)
      actual[:default_tokenizer] = table.default_tokenizer.name
    end
    if properties.include?(:normalize_key)
      actual[:normalize_key] = table.normalize_key? # XXX
    end
    assert_equal(properties, actual, table.inspect)
  end
end
