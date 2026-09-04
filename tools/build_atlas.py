"""Build assets/1x/Jokers_bl.png (71x95 per card) and assets/2x/Jokers_bl.png (142x190) from the
joker-design-*.png sources. Auto-crops the card frame (non-black bbox), makes the black outside the
rounded frame transparent, and resizes to Balatro's 71:95 card aspect. Rerun after replacing art:
    python tools/build_atlas.py
Atlas column order must match `pos.x` in impossible/jokers/*.lua."""
from PIL import Image, ImageDraw
import os

ORDER = ["thefunhoe", "bambino", "jazzyclown", "understudy", "theforger"]   # pos.x = 0..4
ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
CW, CH = 71, 95

def frame_bbox(im, thresh=40):
    g = im.convert("L").point(lambda p: 255 if p > thresh else 0)
    return g.getbbox()

def card_sprite(path, scale):
    im = Image.open(path).convert("RGBA")
    bb = frame_bbox(im)
    im = im.crop(bb)
    w, h = CW * scale, CH * scale
    im = im.resize((w, h), Image.LANCZOS)
    # transparent rounded corners (radius ~ 6% of width), like vanilla card sprites
    mask = Image.new("L", (w, h), 0)
    ImageDraw.Draw(mask).rounded_rectangle([0, 0, w - 1, h - 1], radius=int(w * 0.07), fill=255)
    im.putalpha(mask)
    return im

for scale, sub in ((1, "1x"), (2, "2x")):
    atlas = Image.new("RGBA", (CW * scale * len(ORDER), CH * scale), (0, 0, 0, 0))
    for i, name in enumerate(ORDER):
        src = os.path.join(ROOT, f"joker-design-{name}.png")
        atlas.paste(card_sprite(src, scale), (i * CW * scale, 0))
    out = os.path.join(ROOT, "assets", sub, "Jokers_bl.png")
    atlas.save(out)
    print(out, atlas.size)
