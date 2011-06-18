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

require "hroonga/command/utils"
require "hroonga/command/selector"
require "hroonga/command/table-create"
require "hroonga/command/record-select"

module Hroonga
  module Command
    class Dispatcher
      include Utils

      def initialize(config)
        @config = config
      end

      def call(env)
        @env = env

        command_class = dispatch
        command = command_class.new(@config)

        response = command.call(@env)
      end

      private
      def dispatch
        case request.command_path
        when /\A\/[^\/\?]+\/?\z/
          dispatch_table_command
        when /\A\/[^\/\?]+\/columns\/[^\/\?]+\/?\z/
          dispatch_column_command
        when /\A\/[^\/\?]+\/columns\/?\z/
          ColumnList
        when /\A\/[^\/\?]+\/records\/?\z/
          RecordSelect
        when /\A\/?\z/
          TableList
        else
          default_command
        end
      end

      def dispatch_table_command
        case request.method
        when "POST"
          TableCreate
        when "DELETE"
          TableRemove
        else
          default_command
        end
      end

      def dispatch_column_command
        case request.method
        when "POST"
          ColumnCreate
        when "DELETE"
          ColumnRemove
        else
          default_command
        end
      end

      def default_command
        nil # XXX this should return an error command
      end

      class << self
        def path_prefix
          "/api/1/tables"
        end
      end
    end
  end
end
