"""Records the basic Rent Book demo flow, one take per step.

  python record_demo.py reset     reinstall the demo build (empty data) and open it
  python record_demo.py 1         record take 1 (can also be 2, 3, 4)
  python record_demo.py all       reset, then record every take in order
  python record_demo.py 3 norec   run take 3 without recording (to rehearse)

Takes are saved as out/take1.mkv ... Join them with make_video.py.
"""
import sys
import time
import traceback

from adb_driver import *

dwell = time.sleep


def take1():
    """Welcome guide, then add a group."""
    tap("Next"); dwell(0.8)
    tap("Next"); dwell(0.8)
    tap("Let's start"); dwell(1.5)
    tap("+ Add a group")
    typ("Block A"); dwell(0.6)
    tap("Save", exact=True); dwell(2.5)


def take2():
    """Open the group and add a tenant."""
    tap("Block A"); dwell(1.2)
    tap("+ Add a tenant")
    fill(0, "Ravi Kumar"); hide_kb()
    scroll_down()
    fill(0, "8000"); hide_kb(); dwell(1)
    tap("Save", exact=True); dwell(3)   # lands on the tenant's page
    back(); back(); dwell(1)            # tenant -> group -> home


def take3():
    """Record a part payment, then the rest."""
    tap("Block A"); dwell(1)
    tap("Ravi Kumar"); dwell(1.5)
    tap("Money received", exact=True); dwell(1)
    fill(0, "3000"); hide_kb(); dwell(1.5)
    swipe(540, 1500, 540, 900, 400)
    tap("Save", exact=True); dwell(3)
    tap("Money received", exact=True); dwell(1)
    tap("Fill the full balance"); dwell(1.5)
    swipe(540, 1500, 540, 900, 400)
    tap("Save", exact=True); dwell(3)
    back(); back(); dwell(1)


def take4():
    """Back on Home: show the totals."""
    tap("Home"); dwell(3)


TAKES = [take1, take2, take3, take4]


def run(i, record=True):
    rec = Rec(f"take{i}") if record else None
    try:
        TAKES[int(i) - 1]()
    except Exception:
        traceback.print_exc()
        shot(f"fail_take{i}")
        print("---- screen at failure ----")
        show()
        raise SystemExit(1)
    finally:
        if rec:
            rec.stop()


if __name__ == "__main__":
    cmd = sys.argv[1] if len(sys.argv) > 1 else "all"
    if cmd == "reset":
        fresh_install(); launch()
    elif cmd == "all":
        fresh_install(); launch()
        for n in range(1, len(TAKES) + 1):
            run(n)
    else:
        run(cmd, record=not (len(sys.argv) > 2 and sys.argv[2] == "norec"))
