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
          @response.write("{")
          table.each_with_index do |record, i|
            if i.zero?
              @response.write("\n")
            else
              @response.write(",\n")
            end
            @response.write(JSON.generate(record.attributes))
            break if i == 20
          end
          @response.write("\n")
          @response.write("}")
        end
      end
    end
  end
end
