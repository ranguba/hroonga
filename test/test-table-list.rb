#!/usr/bin/env ruby
#
# Copyright (C) 2011  Masafumi Oyamada <stillpedant@gmail.com>
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

class TestTableList < TestHroongaCommand
  def setup
    setup_config
    @config.setup_database

    @context = Groonga::Context.new(:encoding => :utf8)
    @context.open_database(@config.database_path)

    Capybara.app = Hroonga::Command::TableList.new(@config)
  end

  def teardown
    teardown_database
  end

  def test_basic
    db_name = "Hello"
    create_concrete_table(@context, db_name)
    page.driver.get("/api/1/tables")
    assert_body({
                  "tables" => {
                    "Hello" => {
                      "domain"     => "",
                      "flags"      => "",
                      "path"       => "db/test/db.tables/Hello",
                      "range"      => "",
                      "table_type" => "Array"}}},
                :content_type => :json)
  end

  def create_table(context, name, options)
    Groonga::Schema.define(:context => context) do |schema|
      schema.create_table(name, options)
    end
  end

  def create_concrete_table(context, name, options = {})
    basic_options = {
      :type              => :hash,
      :key_type          => :ShortText,
      :default_tokenizer => :TokenBigram,
      :key_normalize     => true,
      :key_with_sis      => true,
    }

    options.each { |key, value| basic_options[key] = value }
    create_table(context, name, options)
  end
end
