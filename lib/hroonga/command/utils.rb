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

require "groonga"
require "hroonga/command/request"
require "hroonga/command/response"

module Hroonga
  module Command
    module Utils
      include Rack::Utils

      def context
        @config.context
      end

      def request
        @request ||= request_class.new(@env)
      end

      def request_class
        Request
      end

      def successfully_processed_response
        @successfully_processed_response = create_successfully_processed_response
      end

      def create_successfully_processed_response
        response = Response.new({})
      end
    end
  end
end
