# -*- coding: utf-8 -*-
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

require "json"

module Hroonga
  module Command
    class Selector
      def initialize(config)
        @config = config
      end

      def call(env)
        request = Rack::Request.new(env)
        response = Rack::Response.new
        session = Session.new(@config, request, response)
        session.process
        response.finish
      end

      class Session
        def initialize(config, request, response)
          @config = config
          @request = request
          @response = response
        end

        def process
          table_name = @request["table"]
          raise "FIXME: table is missing" if table_name.nil?
          table = @config.context[table_name]
          raise "FIXME: table_name is invalid" if table.nil?
          @response["Content-Type"] = "application/json"
          @response.write("[")
          output_columns = resolve_output_columns(table)
          write_header(output_columns)
          table.each_with_index do |record, i|
            break if i == 10
            @response.write(",\n")
            write_record(record, output_columns)
          end
          @response.write("\n")
          @response.write("]")
        end

        private
        def resolve_output_columns(table)
          columns = []
          columns = []
          columns << ["_id", "UInt32"]
          columns << ["_key", table.domain.name] if table.domain
          table.columns.each do |column|
            columns << [column.local_name, column.range.name]
          end
          columns
        end

        def write_header(columns)
          @response.write(JSON.generate(columns))
        end

        def write_record(record, columns)
          record_values = columns.collect do |name, type_name|
            record.send(name)
          end
          @response.write(JSON.generate(record_values))
        end
      end
    end
  end
end
