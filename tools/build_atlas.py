"""Build assets/1x/Jokers_bl.png (71x95 per card) and assets/2x/Jokers_bl.png (142x190) from the
joker-design-*.png sources. Auto-crops the card frame (non-black bbox), makes the corners transparent,
and resizes to Balatro's 71:95 card aspect. Rerun after replacing art:
    python tools/build_atlas.py
Grid position must match `pos = {x, y}` in impossible/jokers/*.lua (row y, column x)."""
from PIL import Image, ImageDraw
import os

ROWS = [
    ["thefunhoe", "bambino", "jazzyclown", "understudy", "theforger"],          # y = 0
    ["savingface", "velvetrope", "smelter", "thedude", "singularity"],          # y = 1
]
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
CW, CH = 71, 95

def frame_bbox(im, thresh=40):
    g = im.convert("L").point(lambda p: 255 if p > thresh else 0)
    return g.getbbox()

def card_sprite(path, scale):
    im = Image.open(path).convert("RGBA")
    im = im.crop(frame_bbox(im))
    w, h = CW * scale, CH * scale
    im = im.resize((w, h), Image.LANCZOS)
    mask = Image.new("L", (w, h), 0)
    ImageDraw.Draw(mask).rounded_rectangle([0, 0, w - 1, h - 1], radius=int(w * 0.07), fill=255)
    im.putalpha(mask)
    return im

cols = max(len(r) for r in ROWS)
for scale, sub in ((1, "1x"), (2, "2x")):
    atlas = Image.new("RGBA", (CW * scale * cols, CH * scale * len(ROWS)), (0, 0, 0, 0))
    for y, row in enumerate(ROWS):
        for x, name in enumerate(row):
            src = os.path.join(ROOT, f"joker-design-{name}.png")
            atlas.paste(card_sprite(src, scale), (x * CW * scale, y * CH * scale))
    out = os.path.join(ROOT, "assets", sub, "Jokers_bl.png")
    atlas.save(out)
    print(out, atlas.size)
