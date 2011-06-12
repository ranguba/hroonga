# -*- coding: utf-8 -*-
#
# Copyright (C) 2011  Kouhei Sutou <kou@clear-code.com>
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
  class GroongaCommand
    def initialize(config)
      @config = config
    end

    def call(env)
      request = Rack::Request.new(env)
      response = Rack::Response.new
      context = @config.context
      context.send(request.fullpath)
      receive_id, content = context.receive
      case File.extname(request.path)
      when /\A\.xml\z/i
        response["Content-Type"] = "application/xml"
        response.write(content) # TODO: transform XML structure.
      when /\A\.json\z/i, ""
        response["Content-Type"] = "application/json"
        response.write("[[0,0.0,0.0],") # TODO: set correct information.
        response.write(content)
        response.write("]")
      else
        # TODO: raise invalid type.
      end
      response.finish
    end
  end
end
