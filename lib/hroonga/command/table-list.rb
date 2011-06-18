# -*- coding: utf-8 -*-
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

require "json"

module Hroonga
  module Command
    class TableList
      include Utils

      def initialize(config)
        @config = config
      end

      def call(env)
        @env = env
        process_request
      end

      private
      def process_request
        response = Rack::Response.new

        response["Content-Type"] = "application/json"
        response.write(to_json)

        response
      end

      def to_json
        JSON.generate(to_hash)
      end

      def to_hash
        { "tables" => tables_hash }
      end

      def database
        context.database
      end

      def tables
        @tables ||= database.find_all do |object|
          object.class <= Groonga::Table
        end
      end

      def tables_hash
        tables_hash = {}
        tables.each do |table|
          tables_hash[table.name] = table_to_hash(table)
        end
        tables_hash
      end

      private
      def table_to_hash(table)
        domain = table.domain

        {
          "table_type" => get_table_type(table),
          "domain"     => domain.name,
          "path"       => table.path,
          "flags"      => "",   # TODO: implement this
          "range"      => domain.range,
        }
      end

      def get_table_type(table)
        table.class.name.split("::").last
      end

      class << self
        def path_prefix
          "#{Dispatcher.path_prefix}"
        end
      end
    end
  end
end
