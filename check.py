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

import io
import os
import sys

import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.animation as animation
import seaborn as sns

if __name__ == "__main__":
    sns.set(rc={"figure.figsize": (9, 3)}, style="whitegrid")

    # create a lineplot
    fig, ax = plt.subplots()

    min_t = 0.0
    curr = 0.0
    interval = 100

    max_measurements = 100

    # sats_measurements = pd.DataFrame(columns=["t", "sat", "shell", "rtt"])

    interesting_sats = [0, 15, 30, 45, 60]

    x = []
    y = []
    sats = []

    for i in interesting_sats:
        x += [0, 0.1]
        y += [0, 0.1]
        sats += [i, i]

    sns.lineplot(
        x=x,
        y=y,
        hue=sats,
        ax=ax,
    )

    # put the legend outside
    ax.legend(loc="upper center", ncol=5, bbox_to_anchor=(0.5, 1.1))

    # add labels
    ax.set_xlabel("Time [s]")
    ax.set_ylabel("RTT [ms]")

    def animate(i: int) -> None:
        global x
        global y
        global sats
        global min_t
        global curr
        global max_measurements

        # read from stdin
        for line in sys.stdin:
            try:
                # split the line
                t, sat, shell, rtt = line.strip().split(",")

                if int(sat) not in interesting_sats:
                    continue

                x.append(float(t) - min_t)
                y.append(float(rtt))
                sats.append(int(sat))

                # lines += line.strip() + "\n"
                if float(t) - min_t > curr + (interval / 1000):
                    curr = float(t) - min_t
                    # print("break")
                    break
            except:
                pass

        # cut off old measurements
        if len(x) > max_measurements:
            x = x[-max_measurements:]
            y = y[-max_measurements:]
            sats = sats[-max_measurements:]
            ax.clear()

        print(len(x))

        # update the graph
        sns.lineplot(
            x=x,
            y=y,
            hue=sats,
            legend=False,
            ax=ax,
        )

    while True:
        try:
            # get the first line
            line = sys.stdin.readline()
            # split the line
            t, sat, shell, rtt = line.strip().split(",")
            min_t = float(t)
            break
        except:
            pass

    ani = animation.FuncAnimation(fig, animate, interval=interval, save_count=1000)
    plt.show()
