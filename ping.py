#!/usr/bin/env python3

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

import sys
import ping3
import typing
import time


def get_real_latency(sat: int, shell: int) -> float:
    act = ping3.ping("%d.%d.celestial" % (sat, shell), unit="ms")

    if act is None or act == False:
        return float("inf")

    return float(act)


if __name__ == "__main__":
    # num_sats = 6 * 11
    interesting_sats = [0, 15, 30, 45, 60]

    print("t,shell,sat,rtt\n", flush=True)

    while True:
        for sat in interesting_sats:
            act = get_real_latency(sat, 0)

            print(
                f"{time.time()},{sat},{0},{act}",
                flush=True,
            )

        time.sleep(0.2)
