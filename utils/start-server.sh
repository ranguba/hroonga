#!/bin/bash

BASE_DIRECTORY="$(dirname "$0")/.."
ruby1.9.1 -I lib /var/lib/gems/1.9.1/bin/shotgun --host 0.0.0.0 --server thin --port 9393

