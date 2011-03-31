#!/usr/bin/env ruby
#
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

class TestSelect < Test::Unit::TestCase
  include Capybara

  def setup
    @config = Hroonga::Configuration.new
    @config.add_load_path(Pathname(__FILE__).dirname.parent)
    @config.load("etc/hroonga.conf")
    @config.setup_database
    setup_database
    Capybara.app = Hroonga::Command::Selector.new(@config)
  end

  def teardown
    context = @config.context
    database = context.database
    database_path = database.path
    database.close
    FileUtils.rm_rf(Pathname(database_path).dirname.to_s)
  end

  private
  def setup_database
    ActiveGroonga::Base.context = @config.context
    ActiveGroonga::Schema.define do |schema|
      schema.create_table(:entries) do |table|
        table.short_text :title
      end
    end
  end

  class TestNoQuery < TestSelect
    def test_no_records
      visit("/api/version/1/select?table=entries")
      assert_body([
                   [
                    ["_id", "UInt32"],
                    ["title", "ShortText"],
                   ],
                  ],
                  :content_type => :json)
    end

    def test_many_records
      records = []
      11.times do
        entry = Fabricate(:entry)
        records << [entry.id, entry.title] if records.size < 10
      end
      visit("/api/version/1/select?table=entries")
      assert_body([
                   [
                    ["_id", "UInt32"],
                    ["title", "ShortText"],
                   ],
                   *records
                  ],
                  :content_type => :json)
    end
  end
end
