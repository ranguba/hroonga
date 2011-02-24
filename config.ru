# -*- mode: ruby; coding: utf-8 -*-
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

require "bundler/setup"

require "pathname"
require "hroonga"

base_dir = Pathname(__FILE__).dirname

config = Hroonga::Configuration.new
config.add_load_path(base_dir)
config.load("etc/hroonga.conf")

if config.development?
  use Rack::ShowExceptions
  use Rack::CommonLogger
elsif config.production?
end

use Rack::Runtime
use Rack::ContentLength

urls = ["/favicon.", "/css/", "/images/", "/javascripts/"]

if config.development?
  class DirectoryIndex
    def initialize(app, options={})
      @app = app
      @urls = options[:urls]
    end

    def call(env)
      path = env["PATH_INFO"]
      can_serve = @urls.any? { |url| path.index(url) == 0 }
      env["PATH_INFO"] += "index.html" if can_serve and /\/\z/ =~ path
      @app.call(env)
    end
  end

  use DirectoryIndex, :urls => urls
end

use Rack::Static, :urls => urls, :root => (base_dir + "public").to_s

use Racknga::Middleware::Deflater
use Rack::ConditionalGet

use Racknga::Middleware::JSONP

use Rack::Lint
use Rack::Head

map "/api/version/1/select" do
  run Hroonga::Command::Selector.new(config)
end
