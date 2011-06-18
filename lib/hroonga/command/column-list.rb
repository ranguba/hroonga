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
require "hroonga/command/list"

module Hroonga
  module Command
    class ColumnList < List
      include Utils

      def table_name
        request.table_name
      end

      def table
        @table ||= table_by_name(table_name)
      end

      def is_successful
        table != nil
      end

      def to_hash
        {"columns" => columns_hash}
      end

      def columns_hash
        ColumnList.get_column_array(table)
      end

      def self.get_column_array(table)
        ColumnList.get_special_column_array(table).
          concat(ColumnList.columns_to_hash(table.columns))
      end

      def self.columns_to_hash(columns)
        columns.map { |column| ColumnList.column_to_hash(column) }
      end

      def self.column_to_hash(column)
        [column.local_name, column.range.name]
      end

      def self.get_special_column_hash(table, name)
        column = table.column(name)
        if column
          [name, column.range.name]
        end
      end

      def self.get_special_column_array(table)
        array = []
        column = ColumnList.get_special_column_hash(table, "_id")
        array.push(column) if column
        column = ColumnList.get_special_column_hash(table, "_key")
        array.push(column) if column && table.support_key?
        array
      end
    end
  end
end
