#!/usr/bin/env ruby
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

$VERBOSE = true

$KCODE = "u" if RUBY_VERSION < "1.9"

require "pathname"

base_dir = Pathname.new(__FILE__).dirname.parent.expand_path
lib_dir = base_dir + "lib"
test_dir = base_dir + "test"

require "bundler/setup"

require 'test/unit'
require 'test/unit/notify'

Test::Unit::Notify.enable = true

$LOAD_PATH.unshift(lib_dir.to_s)
$LOAD_PATH.unshift(test_dir.to_s)

require 'hroonga-test-utils'

exit Test::Unit::AutoRunner.run(true, test_dir)
