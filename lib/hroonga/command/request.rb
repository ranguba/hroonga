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
    class Request < Rack::Request
      def method
        (query["_method"] || env["REQUEST_METHOD"]).upcase
      end

      def query
        @query ||= parse_query(query_string)
      end

      def command_path
        @command_path ||= parse_command_path
      end


      def table_name
        @table_name ||= parse_table_name
      end

      def column_name
        @column_name ||= parse_column_name
      end

      def record_key
        @record_key ||= parse_record_key
      end


      def table_type
        @table_type ||= snake_cased_option("table_type") || default_table_type
      end

      def default_table_type
        :hash
      end

      def key_type
        @key_type ||= option("key_type") || default_key_type
      end

      def default_key_type
        :ShortText
      end

      def column_type
        @column_type ||= snake_cased_option("column_type") || default_column_type
      end

      def default_column_type
        :scalar
      end

      def value_type
        @value_type ||= option("value_type") || default_value_type
      end

      def default_value_type
        :ShortText
      end


      private
      def parse_command_path
        command_path = path
        command_path[Dispatcher.path_prefix] = ""
        command_path
      end

      def parse_table_name
        name = command_path.split("/")[1]
        unescape(name)
      end

      def parse_column_name
        name_match = command_path.match(/\/columns\/([^\/]+)/)
        if name_match
          unescape(name_match.to_a[1])
        else
          nil
        end
      end

      def parse_record_key
        key_match = command_path.match(/\/records\/([^\/]+)/)
        if key_match
          unescape(key_match.to_a[1])
        else
          nil
        end
      end

      def unescape(string)
        Rack::Utils.unescape(string)
      end

      def option(key)
        if query.include?(key)
          value = unescape(query[key])
          value.to_sym
        else
          nil
        end
      end

      def snake_cased_option(key)
        if query.include?(key)
          value = unescape(query[key])
          to_snake_case(value).to_sym
        else
          nil
        end
      end

      def to_snake_case(string)
        string.gsub(/([A-Z])/, "_\\1").downcase.sub(/\A_/, "")
      end
    end
  end
end
