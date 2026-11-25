#!/usr/bin/env python3
"""Generate a 40 x 30, two-cell-wide perfect maze and Quartus MIF.

The maze is stored as one 40-bit word per row: 1 is a wall and 0 is a path.
The adjacent JSON file contains snake start and goal coordinates. Coordinates
use the RTL convention {x[5:0], y[4:0]} (x is column, y is row).
"""

from __future__ import annotations

import argparse
import json
import random
from pathlib import Path

WIDTH = 40
HEIGHT = 30
MIF_DEPTH = HEIGHT + 4  # rows 30-33 hold the three start segments and exit


def make_maze(seed: int) -> tuple[list[list[int]], dict[str, object]]:
    """Carve a connected maze with 2x2 paths and one-cell-thick walls.

    The grid is tiled into 2x2 path blocks separated by single-cell walls.
    A randomized depth-first search connects every block, carving a 2x2
    connector through each selected separator. The right border has exactly
    one opening, at the goal block's row.
    """
    rng = random.Random(seed)
    maze = [[1 for _ in range(WIDTH)] for _ in range(HEIGHT)]

    # Block origins are x=1,4,...,34 and y=1,4,...,25. The outer border
    # remains one cell thick. This leaves an unused 2-cell strip at right/bottom.
    cols = list(range(1, WIDTH - 2, 3))
    rows = list(range(1, HEIGHT - 2, 3))
    if len(cols) < 2 or len(rows) < 2:
        raise ValueError("maze dimensions are too small")

    def carve_block(cx: int, cy: int) -> None:
        x, y = cols[cx], rows[cy]
        for yy in range(y, y + 2):
            for xx in range(x, x + 2):
                maze[yy][xx] = 0

    start = (0, 0)
    visited = {start}
    stack = [start]
    carve_block(*start)
    while stack:
        cx, cy = stack[-1]
        options = [(cx + dx, cy + dy) for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1))]
        options = [(nx, ny) for nx, ny in options
                   if 0 <= nx < len(cols) and 0 <= ny < len(rows) and (nx, ny) not in visited]
        if not options:
            stack.pop()
            continue
        nx, ny = rng.choice(options)
        # The connector is also 2 wide, leaving the separating wall one cell thick.
        x0, y0 = cols[cx], rows[cy]
        x1, y1 = cols[nx], rows[ny]
        if nx != cx:
            connector_x = min(x0, x1) + 1
            for yy in range(y0, y0 + 2):
                for xx in range(connector_x, connector_x + 2):
                    maze[yy][xx] = 0
        else:
            connector_y = min(y0, y1) + 1
            for yy in range(connector_y, connector_y + 2):
                for xx in range(x0, x0 + 2):
                    maze[yy][xx] = 0
        carve_block(nx, ny)
        visited.add((nx, ny))
        stack.append((nx, ny))

    # Put the exit at the right border, aligned with the center of the final
    # block in the top row. The adjacent 2-wide path reaches the opening.
    goal_cx, goal_cy = len(cols) - 1, 0
    gx, gy = cols[goal_cx], rows[goal_cy]
    goal = (WIDTH - 1, gy)
    for xx in range(gx + 2, WIDTH - 1):
        maze[gy][xx] = 0
        maze[gy + 1][xx] = 0
    maze[gy][WIDTH - 1] = 0

    # Start on the first 2-wide block, with the head toward increasing x.
    sx, sy = cols[0], rows[0]
    start_positions = {
        "head": {"x": sx + 1, "y": sy},
        "mid": {"x": sx, "y": sy},
        "tail": {"x": sx, "y": sy + 1},
    }
    metadata: dict[str, object] = {
        "width": WIDTH,
        "height": HEIGHT,
        "seed": seed,
        "bit_layout": "{x[5:0], y[4:0]}",
        "start_positions": start_positions,
        "start_pos_packed_33bit": "".join(
            f"{((p['x'] << 5) | p['y']):011b}" for p in start_positions.values()
        ),
        "end_position": {"x": goal[0], "y": goal[1]},
        "end_position_packed_11bit": f"{((goal[0] << 5) | goal[1]):011b}",
        "end_opening": "right edge; only this border cell is open",
    }
    return maze, metadata


def write_mif(path: Path, maze: list[list[int]], metadata: dict[str, object]) -> None:
    lines = [
        f"-- Generated maze: {WIDTH} columns x {HEIGHT} rows",
        "-- 1 = wall, 0 = path; each address is one row, bit 39 is x=0",
        f"WIDTH={WIDTH};",
        f"DEPTH={MIF_DEPTH};",
        "ADDRESS_RADIX=UNS;",
        "DATA_RADIX=BIN;",
        "CONTENT BEGIN",
    ]
    lines.extend(f"    {y} : {''.join(map(str, row))};" for y, row in enumerate(maze))
    starts = metadata["start_positions"]
    assert isinstance(starts, dict)
    for address, segment in zip((30, 31, 32), ("head", "mid", "tail")):
        position = starts[segment]
        assert isinstance(position, dict)
        packed = (int(position["x"]) << 5) | int(position["y"])
        lines.append(f"    {address} : {packed:040b}; -- {segment}: {{x[5:0], y[4:0]}}")
    end = metadata["end_position"]
    assert isinstance(end, dict)
    end_packed = (int(end["x"]) << 5) | int(end["y"])
    lines.append(f"    33 : {end_packed:040b}; -- exit: {{x[5:0], y[4:0]}}")
    lines.append("END;")
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text("\n".join(lines) + "\n", encoding="ascii")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--seed", type=int, default=1, help="random seed (default: 1)")
    parser.add_argument("--mif", type=Path, default=Path("src/FPGA_vga/MIF/maze1.mif"))
    parser.add_argument("--metadata", type=Path, default=Path("src/FPGA_vga/MIF/maze1.json"))
    args = parser.parse_args()

    maze, metadata = make_maze(args.seed)
    write_mif(args.mif, maze, metadata)
    args.metadata.parent.mkdir(parents=True, exist_ok=True)
    args.metadata.write_text(json.dumps(metadata, indent=2) + "\n", encoding="utf-8")
    print(f"Wrote {args.mif} and {args.metadata}")
    print(f"Start packed head/mid/tail: {metadata['start_pos_packed_33bit']}")
    print(f"End packed: {metadata['end_position_packed_11bit']}")


if __name__ == "__main__":
    main()
