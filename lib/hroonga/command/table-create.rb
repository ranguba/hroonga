# -*- coding: utf-8 -*-
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

module Hroonga
  module Command
    class TableCreate
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

        create

        response["Content-Type"] = "application/json"
        response.write("{}")

        response
      end

      def create
        Groonga::Schema.define(:context => context) do |schema|
          schema.create_table(name, :type => table_type, :key_type => key_type)
        end
      end

      def name
        @name ||= parse_name
      end

      def parse_name
        name = path
        name["/"] = ""
        unescape(name)
      end

      def table_type
        @table_type ||= parse_table_type
      end

      def parse_table_type
        if query.include?("table_type")
          table_type = unescape(query["table_type"])
          table_type.downcase.to_sym
        else
          default_table_type
        end
      end

      def default_table_type
        :hash
      end

      def key_type
        @key_type ||= parse_key_type
      end

      def parse_key_type
        if query.include?("key_type")
          unescape(query["key_type"]).to_sym
        else
          default_key_type
        end
      end

      def default_key_type
        :ShortText
      end

      def parse_name
        name = path
        name["/"] = ""
        unescape(name)
      end

      class << self
        def path_prefix
          "#{Dispatcher.path_prefix}"
        end
      end
    end
  end
end
