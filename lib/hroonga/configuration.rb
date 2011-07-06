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

require "pathname"
require "fileutils"

module Hroonga
  class Configuration
    def initialize
      @load_paths = []
      add_load_path(".")
    end

    def environment
      @environment ||= ENV["RACK_ENV"] || "development"
    end

    def add_load_path(path)
      path = Pathname.new(path) unless path.is_a?(Pathname)
      @load_paths << path
    end

    def load(path)
      @load_paths.each do |load_path|
        full_path = load_path + path
        if full_path.exist?
          return instance_eval(full_path.read, full_path.to_s)
        end
      end
      message = "no such file in load paths: <#{path}>" +
        ": load-paths: <#{@load_paths.inspect}>"
      raise LoadError, message
    end

    def setup_database
      @database_path = Pathname.new("db/#{environment}/db")
      if @database_path.exist?
        @database = Groonga::Database.open(database_path,
                                           :context => context)
      else
        FileUtils.mkdir_p(@database_path.dirname.to_s)
        @database = Groonga::Database.create(:context => context,
                                             :path => database_path)
      end
    end

    def database_path
      @database_path.to_s
    end

    def context
      @context ||= Groonga::Context.new(:encoding => :utf8)
    end

    def test?
      environment == "test"
    end

    def development?
      environment == "development"
    end

    def production?
      environment == "production"
    end
  end
end
