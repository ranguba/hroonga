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
    class ColumnCreate
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
        create
        successfully_processed_response
      end

      def create
        Groonga::Schema.define(:context => context) do |schema|
          schema.change_table(request.table_name) do |table|
            if request.column_type == :index
              table.index(request.value_type, request.column_source, options)
            else
              table.column(request.column_name, request.value_type, options)
            end
          end
        end
      end

      def options
        @options ||= create_options
      end

      def create_options
        options = {}
        options[:type] = request.column_type
        options[:with_section] = true if request.column_flags[:WITH_SECTION]
        options[:with_weight] = true if request.column_flags[:WITH_WEIGHT]
        options[:with_position] = true if request.column_flags[:WITH_POSITION]
        options
      end
    end
  end
end
