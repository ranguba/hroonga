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
    class TableList < List
      def to_hash
        {"tables" => tables_hash}
      end

      def tables_hash
        tables_hash = {}
        tables.each do |table|
          tables_hash[table.name] = table_to_hash(table)
        end
        tables_hash
      end

      private
      def table_to_hash(table)
        domain = table.domain

        {
          "table_type" => get_table_type(table),
          "domain"     => domain.name,
          "path"       => table.path,
          "flags"      => "",   # TODO: implement this
          "range"      => domain.range,
        }
      end

      private
      def get_table_type(table)
        table.class.name.split("::").last
      end
    end
  end
end
