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

# the app script runs when a microVM boots

# let's get the gateway IP by parsing "/sbin/ip route"
# we need this to set our nameserver here
IP=$(/sbin/ip route | awk '/default/ { print $3 }')

# set the nameserver to our gateway IP
# this way, we can use the helpful X.Y.celestial DNS service
echo nameserver "$IP" > /etc/resolv.conf

sleep 20

# ready to start the application!
# everything that is sent to stdout will be sent to our file
echo "STARTING VALIDATOR"

# the ping script should know where it can find the HTTP server
# (also at our gateway)
python3 ping.py
