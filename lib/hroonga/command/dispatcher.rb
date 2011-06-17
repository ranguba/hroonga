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

require "hroonga/command/selector"
require "hroonga/command/table-create"

module Hroonga
  module Command
    class Dispatcher
      attr_reader :request

      def initialize(config)
        @config = config
      end

      def call(env)
        @env = env
        @request = Rack::Request.new(@env)

        command_class = dispatch
        command = command_class.new(@config)

        response = command.call(@env)
      end

      private
      def dispatch
        path = request.path
        path[path_prefix] = ""

p request.inspect
        case path
        when /\A\/[^\/\?]+\/?\z/
          TableCreate
          TableRemove
        when /\A\/[^\/\?]+\/columns\/[^\/\?]+\/?\z/
          ColumnCreate
          ColumnRemove
        when /\A\/[^\/\?]+\/columns\/?\z/
          ColumnList
        when /\A\/?\z/
          TableList
        else
          nil # XXX this should return an error command
        end
      end

      def path_prefix
        "/api/1/tables"
      end
    end
  end
end
