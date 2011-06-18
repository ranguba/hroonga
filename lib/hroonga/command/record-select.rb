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

require "hroonga/command/select"

module Hroonga
  module Command
    class RecordSelect
      include Utils

      def initialize(config)
        @config = config
      end

      def call(env)
        @env = env
        selector = SelectorByMethod.new(context, context.database.path)
        result = selector.select(Query.new(:table => request.table_name, :output_columns => "_id _key"))

        response = Rack::Response.new
        response["Content-Type"] = "application/json"
        response.write(JSON.generate({
          :columns => [], #XXX
          :records => result.formatted_result,
        }))
        response
      end
    end
  end
end
