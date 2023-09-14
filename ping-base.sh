#!/bin/sh

#
# This file is part of the IC2E '23 Celestial demo
# (https://github.com/OpenFogStack/celestial-ic2e-demo).
# Copyright (c) 2023 Tobias Pfandzelter, The OpenFogStack Team.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, version 3.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#

# the base script install all the necessary dependencies during root
# filesystem compilation

# note that the root filesystem here is based on alpine, hence uses the "apk"
# package manager

# add git, curl, and python3 to the root filesystem
# our program is based on python3, hence we need to install python3
# git and curl are needed for pip
apk add git curl python3 py3-pip

# add the python3 dependencies: request and ping3
python3 -m pip install ping3 requests
