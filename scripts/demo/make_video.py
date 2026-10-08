"""Joins out/take*.mkv into one captioned, compressed MP4 (default: ../../docs/demo.mp4).

  python make_video.py [output.mp4]

Env vars: FFMPEG (path to ffmpeg, default "ffmpeg"), DEMO_OUT (where the takes are),
CAPTION_FONT (a .ttf file, default C:/Windows/Fonts/arialbd.ttf).
"""
import os
import subprocess
import sys

from adb_driver import OUT, ROOT

FFMPEG = os.environ.get("FFMPEG", "ffmpeg")
FONT = os.environ.get("CAPTION_FONT", "C:/Windows/Fonts/arialbd.ttf").replace(":", "\\:")
TRIM_START = 3.0   # seconds of idle at the start of every take (scrcpy start-up)
SPEED = 1.25
W, H = 540, 1200

CAPTIONS = {
    1: "Welcome guide, then add a group",
    2: "Add a tenant",
    3: "Record the money received",
    4: "Totals on the Home screen",
}


def clip(i):
    src = os.path.join(OUT, f"take{i}.mkv")
    dst = os.path.join(OUT, f"take{i}_cap.mp4")
    vf = (
        # scrcpy tags the stream with an odd colour matrix that breaks scaling, so reset it
        "setparams=colorspace=bt709:color_primaries=bt709:color_trc=bt709,"
        f"scale={W}:{H}:force_original_aspect_ratio=decrease,pad={W}:{H}:(ow-iw)/2:(oh-ih)/2:color=white,"
        f"setpts=PTS/{SPEED},fps=30,"
        f"drawtext=fontfile='{FONT}':text='{CAPTIONS[i]}':fontcolor=white:fontsize=26:"
        "box=1:boxcolor=0x1d4ed8@0.92:boxborderw=14:x=(w-text_w)/2:y=h-62"
    )
    subprocess.run([FFMPEG, "-y", "-loglevel", "error", "-ss", str(TRIM_START), "-i", src, "-an",
                    "-vf", vf, "-c:v", "libx264", "-crf", "27", "-pix_fmt", "yuv420p", dst], check=True)
    return dst


def main():
    out = sys.argv[1] if len(sys.argv) > 1 else os.path.join(ROOT, "docs", "demo.mp4")
    os.makedirs(os.path.dirname(out), exist_ok=True)
    clips = [clip(i) for i in sorted(CAPTIONS) if os.path.exists(os.path.join(OUT, f"take{i}.mkv"))]
    lst = os.path.join(OUT, "clips.txt")
    with open(lst, "w") as f:
        f.writelines(f"file '{c.replace(os.sep, '/')}'\n" for c in clips)
    subprocess.run([FFMPEG, "-y", "-loglevel", "error", "-f", "concat", "-safe", "0", "-i", lst,
                    "-c", "copy", "-movflags", "+faststart", out], check=True)
    print(f"{out}: {os.path.getsize(out) / 1e6:.1f} MB")


if __name__ == "__main__":
    main()
