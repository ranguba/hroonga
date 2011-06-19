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

class TestColumnCreate < TestHroongaCommand
  def setup
    setup_config
    @config.setup_database

    @context = Groonga::Context.new(:encoding => :utf8)
    @context.open_database(@config.database_path)

    Capybara.app = Hroonga::Command::ColumnCreate.new(@config)
  end

  def teardown
    teardown_database
  end

  class TestColumnType < TestColumnCreate
    def test_no_option
      setup_site_table
      assert_no_column("Site", "my_column")
      page.driver.post("/api/1/tables/Site/columns/my_column")
      assert_success
      assert_column("Site", "my_column")
    end

    def test_scalar_short_text_column
      setup_site_table
      assert_no_column("Site", "title")
      page.driver.post("/api/1/tables/Site/columns/title?column_type=Scalar&value_type=ShortText")
      assert_success
      assert_column("Site", "title",
                    :type => Groonga::VariableSizeColumn,
                    :value_type => "ShortText",
                    :vector => false)
    end

    def test_vector_short_text_column
      setup_site_table
      assert_no_column("Site", "title")
      page.driver.post("/api/1/tables/Site/columns/title?column_type=Vector&value_type=ShortText")
      assert_success
      assert_column("Site", "title",
                    :type => Groonga::VariableSizeColumn,
                    :value_type => "ShortText",
                    :vector => true)
    end

    def test_index_column
      setup_table_to_index

      setup_table("Terms", :type => :patricia_trie,
                           :key_type => :ShortText,
                           :default_tokenizer => :TokenBigram,
                           :key_normalize => true)
      assert_no_column("Terms", "blog_title")
      page.driver.post("/api/1/tables/Terms/columns/blog_title?column_type=Index&value_type=Site&source=title&flags=WITH_POSITION")
      assert_success
      assert_column("Terms", "blog_title",
                    :type => Groonga::IndexColumn,
                    :value_type => "Site")
    end
  end

  class TestIndexColumnOptions < TestColumnCreate
    def test_single_flag
      setup_terms_table

      page.driver.post("/api/1/tables/Terms/columns/blog_title?column_type=Index&value_type=Site&source=title&flags=WITH_POSITION")
      assert_success
      assert_column("Terms", "blog_title",
                    :type => Groonga::IndexColumn,
                    :value_type => "Site",
                    :with_section => false,
                    :with_position => true,
                    :with_weight => false)
    end

    def test_multiple_flags
      setup_terms_table

      page.driver.post("/api/1/tables/Terms/columns/blog_title?column_type=Index&value_type=Site&source=title&flags=WITH_POSITION%7CWITH_WEIGHT")
      assert_success
      assert_column("Terms", "blog_title",
                    :type => Groonga::IndexColumn,
                    :value_type => "Site",
                    :with_section => false,
                    :with_position => true,
                    :with_weight => true)
    end

=begin
    # commented out because there is no API to get compression method from column
    def test_compress_option_zlib
      setup_terms_table

      page.driver.post("/api/1/tables/Terms/columns/blog_title?column_type=Index&value_type=Site&source=title&compress=Zlib")
      assert_success
      assert_column("Terms", "blog_title",
                    :type => Groonga::IndexColumn,
                    :value_type => "Site",
                    :with_section => false,
                    :with_position => false,
                    :with_weight => false,
                    :compress => :zlib)
    end

    def test_compress_option_lzo
      setup_terms_table

      page.driver.post("/api/1/tables/Terms/columns/blog_title?column_type=Index&value_type=Site&source=title&compress=Lzo")
      assert_success
      assert_column("Terms", "blog_title",
                    :type => Groonga::IndexColumn,
                    :value_type => "Site",
                    :with_section => false,
                    :with_position => false,
                    :with_weight => false,
                    :compress => :lzo)
    end
=end

    private
    def setup_terms_table
      setup_table_to_index

      setup_table("Terms", :type => :patricia_trie,
                           :key_type => :ShortText,
                           :default_tokenizer => :TokenBigram,
                           :key_normalize => true)
      assert_no_column("Terms", "blog_title")
    end
  end

  private
  def setup_table(name, options)
    Groonga::Schema.define(:context => @context) do |schema|
      schema.create_table(name, options)
    end
  end

  def setup_column(table_name, column_name, options)
    Groonga::Schema.define(:context => @context) do |schema|
      schema.change_table(table_name) do |table|
        table.column(column_name, options[:value_type], options)
      end
    end
  end

  def setup_site_table
    setup_table("Site", :type => :hash, :key_type => :ShortText)
  end

  def setup_table_to_index
    setup_site_table
    setup_column("Site", "title", :type => :scalar, :value_type => :ShortText)
  end

  def assert_no_column(table_name, column_name)
    table = @context[table_name]
    assert_nil(table.column("column_name"), @context.inspect)
  end

  def assert_column(table_name, column_name, properties={})
    table = @context[table_name]
    assert_not_nil(table, @context.inspect)

    column = table.column(column_name)
    assert_not_nil(column, "#{table.columns} #{table.inspect}")

    actual = {}
    if properties.include?(:type)
      actual[:type] = column.class
    end
    if properties.include?(:value_type)
      actual[:value_type] = column.range.name
    end
    if properties.include?(:vector)
      actual[:vector] = column.vector?
    end
    if properties.include?(:with_weight)
      actual[:with_weight] = column.with_weight?
    end
    if properties.include?(:with_section)
      actual[:with_section] = column.with_section?
    end
    if properties.include?(:with_position)
      actual[:with_position] = column.with_position?
    end
    if properties.include?(:compress)
      actual[:compress] = column.compress
    end
    assert_equal(properties, actual, column.inspect)
  end
end
