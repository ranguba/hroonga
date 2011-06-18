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

require "cgi"
require "groonga"

class String
  def snake_case
    self.gsub(/([A-Z])/, "_\\1").downcase.sub(/\A_/, "")
  end
end

module Hroonga
  module Command
    module Utils
      include Rack::Utils

      def context
        @config.context
      end

      def request
        @request ||= Rack::Request.new(@env)
      end

      def path
        @path ||= path_for_command
      end

      def path_for_command
        path = request.path
        path[self.class.path_prefix] = ""
        path
      end

      def query
        @query ||= parse_query(request.query_string)
      end

      def request_method
        query["_method"] || request.env["REQUEST_METHOD"]
      end
    end
  end
end
