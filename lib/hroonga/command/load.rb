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
    class Load
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
        load
        successfully_processed_response
      end

      def load
        if request.record_key.nil?
          request.records.each do |key, record|
            table.add(key, record)
          end
        else
          table.add(request.record_key, request.record)
        end
      end

      def table
        @table ||= @config.context[request.table_name]
      end
    end
  end
end
