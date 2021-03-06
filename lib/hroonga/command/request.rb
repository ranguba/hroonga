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

require "json"

module Hroonga
  module Command
    class Request < Rack::Request
      def method
        (params["_method"] || env["REQUEST_METHOD"]).upcase
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

      def default_tokenizer
        @default_tokenizer ||= option("default_tokenizer") || default_default_tokenizer
      end

      def default_default_tokenizer
        nil
      end

      def table_flags
        @table_flags ||= flags_option("flags") || default_table_flags
      end

      def default_table_flags
        {}
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

      def column_source
        @column_source ||= option("source")
      end

      def column_compress
        @column_compress ||= snake_cased_option("compress")
      end

      def column_flags
        @column_flags ||= flags_option("flags") || default_column_flags
      end

      def default_column_flags
        {}
      end


      def record
        @record ||= reject_special_keys(json_option("record"))
      end

      def records
        @records ||= parse_records
      end


      private
      def parse_command_path
        command_path = path
        command_path[Dispatcher.path_prefix] = ""
        command_path
      end

      def parse_table_name
        name_match = command_path.match(/\A\/([^\/]+)/)
        if name_match
          unescape(name_match.to_a[1])
        else
          nil
        end
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

      def parse_records
        records = json_option("records")
        records_hash = {}
        records.each do |record|
          key = record["_key"]
          next unless key
          records_hash[key] = reject_special_keys(record)
        end
        records_hash
      end

      def unescape(string)
        Rack::Utils.unescape(string)
      end

      def to_snake_case(string)
        string.gsub(/([A-Z])/, "_\\1").downcase.sub(/\A_/, "")
      end

      def option(key)
        if params.include?(key) and not params[key].empty?
          value = unescape(params[key])
          value.to_sym
        else
          nil
        end
      end

      def string_option(key)
        if params.include?(key)
          unescape(params[key])
        else
          nil
        end
      end

      def snake_cased_option(key)
        if params.include?(key)
          value = unescape(params[key])
          to_snake_case(value).to_sym
        else
          nil
        end
      end

      def flags_option(key)
        if params.include?(key)
          flags = {}
          value = unescape(params[key])
          value.strip.split(/\s*\|\s*/).each do |flag|
            flags[flag.to_sym] = true
          end
          flags
        else
          nil
        end
      end

      def json_option(key)
        if params.include?(key)
          flags = {}
          value = unescape(params[key])
          JSON.parse(value)
        else
          nil
        end
      end

      def reject_special_keys(record)
        record.keys.each do |key|
          record.delete(key) if key[0] == "_"
        end
        record
      end
    end
  end
end
