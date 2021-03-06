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
        create
        successfully_processed_response
      end

      def create
        Groonga::Schema.define(:context => context) do |schema|
          schema.create_table(request.table_name, options)
        end
      end

      def options
        @options ||= create_options
      end

      def create_options
        options = {}
        options[:type] = request.table_type
        options[:key_type] = request.key_type
        options[:default_tokenizer] = request.default_tokenizer
        options[:key_normalize] = true if request.table_flags[:KEY_NORMALIZE]
        options[:key_with_sis] = true if request.table_flags[:KEY_WITH_SIS]
        options
      end
    end
  end
end
