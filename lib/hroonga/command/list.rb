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
    class List
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

      private
      def is_successful
        true
      end

      def database
        context.database
      end

      def tables
        @tables ||= database.find_all do |object|
          object.class <= Groonga::Table
        end
      end

      def table_by_name(name)
        tables.find { |table| table.name == name }
      end

      private
      def failure_hash
        {"error" => 501}
      end

      def to_json
        JSON.generate(is_successful ? to_hash : failure_hash)
      end

      def to_hash
        {}
      end

      class << self
        def path_prefix
          "#{Dispatcher.path_prefix}"
        end
      end
    end
  end
end
