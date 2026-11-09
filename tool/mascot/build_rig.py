#!/usr/bin/env python3
"""Bangun SVG berlapis maskot RelaxMate (setengah badan) dari gambar referensi.

Koordinat mengikuti panel tengah gambar referensi (tengah badan di x = 767).
Teks "RelaxMate" diubah menjadi path dari font Plus Jakarta Sans Bold supaya aman
diimpor ke Rive (Rive tidak membawa elemen <text>).
"""
import sys
from fontTools.pens.svgPathPen import SVGPathPen
from fontTools.pens.transformPen import TransformPen
from fontTools.ttLib import TTFont

FONT = sys.argv[1]
OUT = sys.argv[2]

CX = 767  # sumbu simetri


def mx(x):
    """Cermin terhadap sumbu tengah."""
    return 2 * CX - x


def text_path(text, x, y_baseline, target_width):
    font = TTFont(FONT)
    gs = font.getGlyphSet()
    cmap = font.getBestCmap()
    upm = font["head"].unitsPerEm
    adv_total = sum(font["hmtx"][cmap[ord(c)]][0] for c in text)
    scale = target_width / adv_total
    d = []
    cursor = 0
    for c in text:
        name = cmap[ord(c)]
        pen = SVGPathPen(gs)
        # flip Y (font y naik, SVG y turun)
        tp = TransformPen(pen, (scale, 0, 0, -scale, x + cursor * scale, y_baseline))
        gs[name].draw(tp)
        d.append(pen.getCommands())
        cursor += font["hmtx"][name][0]
    return " ".join(d), upm * scale


NAVY = "#243044"
BLUE = "#8DADDB"
BLUE_DK = "#7499CE"
SEAM = "#BCD2EE"
WHITE = "#FFFFFF"
SOFT = "#EEF3FC"


BAND = "#A9C4E9"
LOGO_X, LOGO_Y = 671, 722


def C(x, y, mirror=False):
    """Koordinat panel referensi (2x, asal y=340) ke koordinat SVG."""
    if mirror:
        x = 952 - x
    return f"{round(767 + (x - 476) * 0.65, 1)},{round(578 + 0.66 * y, 1)}"


def build(cmds, mirror=False):
    out = []
    for cmd, pts in cmds:
        out.append(cmd + " ".join(C(x, y, mirror) for x, y in pts))
    return " ".join(out)


def sh(m):
    return build([("M", [(228, 90)]), ("C", [(170, 84), (105, 120), (100, 190)]),
                  ("C", [(98, 250), (130, 300), (190, 314)]), ("L", [(232, 312)]),
                  ("Z", [])], m)


def shb(m):
    return build([("M", [(98, 244)]), ("C", [(110, 290), (150, 314), (198, 328)]),
                  ("L", [(194, 288)]), ("C", [(152, 278), (126, 262), (102, 232)]),
                  ("Z", [])], m)


def up(m):
    return build([("M", [(112, 270)]), ("L", [(194, 290)]), ("L", [(190, 500)]),
                  ("L", [(46, 484)]), ("C", [(44, 420), (68, 320), (112, 270)]),
                  ("Z", [])], m)


def el(m):
    return build([("M", [(45, 470)]), ("C", [(80, 492), (140, 502), (186, 490)]),
                  ("L", [(184, 528)]), ("C", [(140, 534), (80, 528), (40, 506)]),
                  ("Z", [])], m)


def fa(m):
    return build([("M", [(44, 480)]), ("L", [(188, 480)]),
                  ("L", [(196, 760)]), ("L", [(28, 760)]),
                  ("C", [(20, 660), (20, 560), (40, 506)]), ("Z", [])], m)


torso = build([("M", [(225, 102)]), ("C", [(262, 52), (330, 40), (356, 40)]),
               ("L", [(596, 40)]), ("C", [(622, 40), (690, 52), (727, 102)]),
               ("C", [(748, 200), (757, 350), (755, 450)]),
               ("C", [(758, 540), (770, 620), (780, 760)]),
               ("L", [(172, 760)]), ("C", [(182, 620), (194, 540), (197, 450)]),
               ("C", [(195, 350), (204, 200), (225, 102)]), ("Z", [])])
belly = build([("M", [(196, 600)]), ("Q", [(476, 668), (756, 600)])])
neck = build([("M", [(342, 20)]), ("L", [(612, 20)]), ("L", [(612, 56)]),
              ("Q", [(477, 118), (342, 56)]), ("Z", [])])

logo_text, _ = text_path("RelaxMate", 802, 735, 118)


LOGO_MARK = f"""    <g id="logo_mark" fill="none" stroke="{NAVY}" stroke-width="22"
         stroke-linecap="round" stroke-linejoin="round"
         transform="translate({LOGO_X} {LOGO_Y}) scale(0.128) translate(-387 -390)">
        <path id="logo_dome" d="M390,162 C370,142 310,146 285,176 C282,190 280,200 276,205 C240,195 190,215 180,265 C182,275 184,282 186,288 C150,300 130,330 135,375 C138,410 180,430 230,436"/>
        <path id="logo_dome_r" d="M390,162 C410,142 470,146 495,176 C498,190 500,200 504,205 C540,195 590,215 600,265 C598,275 596,282 594,288 C630,300 650,330 645,375 C642,410 600,430 550,436"/>
        <g stroke-width="16">
          <path d="M390,165 L390,290"/>
          <path d="M316,264 C316,238 300,222 278,214"/>
          <path d="M464,264 C464,238 480,222 502,214"/>
          <path d="M186,288 C215,282 240,295 242,318"/>
          <path d="M594,288 C565,282 540,295 538,318"/>
          <path d="M232,385 C262,380 280,398 285,432"/>
          <path d="M548,385 C518,380 500,398 495,432"/>
          <path d="M290,335 Q320,360 352,335"/>
          <path d="M435,335 Q467,360 497,335"/>
          <path d="M352,392 Q392,415 432,392"/>
        </g>
        <path id="logo_wave_left" d="M35,527 C100,455 200,425 275,435 C340,445 385,490 420,515"/>
        <path id="logo_wave_right" d="M740,525 C690,470 600,430 520,440 C470,447 430,480 395,498"/>
        <g stroke-width="16">
          <path d="M395,500 C470,450 590,445 680,478"/>
          <path d="M65,527 C140,500 230,515 290,580"/>
          <path d="M395,500 C440,535 490,548 560,545"/>
        </g>
        <path id="logo_wave_bottom" d="M290,580 C340,620 400,630 470,628 C570,625 620,585 625,545 C660,545 700,540 740,525"/>
      </g>
  """

def node(nid, px, py, inner, sx=None):
    tr = f"translate({px} {py})" + (f" scale({sx})" if sx else "")
    return (f'<g id="{nid}" data-pivot="{px},{py}" transform="{tr}">'
            f'<g id="{nid}_content" transform="translate({-px} {-py})">{inner}</g></g>\n')

def arm(side, m, sx, ex):
    forearm = node(f"forearm_{side}", ex, 906,
                   f'<path id="forearm_{side}_shape" d="{fa(m)}" fill="url(#gArm)"/>')
    return node(f"arm_{side}", sx, 712,
        forearm
        + f'<path id="shoulder_{side}_shape" d="{sh(m)}" fill="url(#gShoulder)"/>\n'
        + f'<path id="upper_arm_{side}_shape" d="{up(m)}" fill="url(#gArm)"/>\n'
        + f'<path id="shoulder_{side}_band" d="{shb(m)}" fill="{BAND}"/>\n'
        + f'<path id="elbow_{side}_band" d="{el(m)}" fill="{BAND}"/>\n')

def antenna(side, bx, tx, ballx):
    rod = (f'<path d="M{tx},196 L{bx},244" stroke="{SEAM}" stroke-width="19" stroke-linecap="round"/>'
           f'<path d="M{tx},196 L{bx},244" stroke="{WHITE}" stroke-width="13" stroke-linecap="round"/>\n')
    ball = node(f"antenna_ball_{side}", tx, 196,
                f'<circle cx="{ballx}" cy="170" r="31" fill="{WHITE}" stroke="{SEAM}" stroke-width="3"/>')
    return node(f"antenna_{side}", bx, 244, rod + ball)

def eye(side, cx):
    happy = (f'<path d="M{cx-24},420 Q{cx},390 {cx+24},420" fill="none" stroke="{WHITE}" '
             f'stroke-width="10" stroke-linecap="round"/>')
    return node(f"eye_{side}", cx, 408,
        f'<ellipse id="eye_{side}_open" cx="{cx}" cy="408" rx="24" ry="37" fill="{WHITE}"/>\n'
        + node(f"eye_{side}_happy", cx, 408, happy, 0.0001))

mouths = (
    node("mouth_smile", 768, 470,
         f'<path d="M727,461 Q768,494 809,461" fill="none" stroke="{WHITE}" stroke-width="13" stroke-linecap="round"/>')
    + node("mouth_flat", 768, 470,
         f'<path d="M738,468 L798,468" fill="none" stroke="{WHITE}" stroke-width="13" stroke-linecap="round"/>', 0.0001)
    + node("mouth_open", 768, 470,
         f'<ellipse cx="768" cy="474" rx="26" ry="20" fill="{WHITE}"/>', 0.0001)
    + node("mouth_o", 768, 470,
         f'<circle cx="768" cy="474" r="13" fill="{WHITE}"/>', 0.0001))

face = node("face_group", 767, 409,
    f'<rect id="face_screen" x="585" y="275" width="364" height="268" rx="120" ry="108" fill="{NAVY}"/>\n'
    f'<path id="shine" d="M619,360 C618,322 642,298 680,293 L683,306 C656,311 640,330 635,362 Z" fill="#9DBBE4" opacity="0.9"/>\n'
    + eye("left", 678) + eye("right", mx(678)) + mouths)

head = node("head_group", 767, 600,
    node("ear_right", mx(548), 424, f'<ellipse cx="{mx(520)}" cy="424" rx="33" ry="78" fill="{BLUE}"/>')
    + node("ear_left", 548, 424, '<ellipse cx="520" cy="424" rx="33" ry="78" fill="{BLUE}"/>'.replace('{BLUE}', BLUE))
    + antenna("right", mx(660), mx(626), mx(620))
    + antenna("left", 660, 626, 620)
    + f'<rect id="head_shape" x="532" y="228" width="470" height="372" rx="190" ry="160" fill="url(#gHead)" stroke="{SEAM}" stroke-width="2" stroke-opacity="0.6"/>\n'
    + face)

torso_node = node("torso", 767, 960,
    f'<path id="torso_shape" d="{torso}" fill="url(#gBody)"/>\n'
    f'<path id="belly_line" d="{belly}" fill="none" stroke="#E1EAF8" stroke-width="10" stroke-linecap="round"/>\n'
    f'<g id="logo">\n{LOGO_MARK}    <path id="logo_text" d="{logo_text}" fill="{NAVY}"/>\n</g>\n')

neck_node = node("neck", 767, 600, f'<path id="neck_shape" d="{neck}" fill="url(#gNeck)"/>')

rig_root = node("rig_root", 767, 1000,
    arm("right", True, 969, 1002) + arm("left", False, 565, 532)
    + torso_node + neck_node + head)

svg = f"""<svg xmlns="http://www.w3.org/2000/svg" viewBox="437 100 660 900" width="660" height="900">
  <title>RelaxMate maskot, rig bertingkat</title>
  <defs>
    <linearGradient id="gHead" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0" stop-color="#FFFFFF"/>
      <stop offset="0.7" stop-color="#FFFFFF"/>
      <stop offset="1" stop-color="#EAF1FB"/>
    </linearGradient>
    <linearGradient id="gBody" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0" stop-color="#FFFFFF"/>
      <stop offset="0.75" stop-color="#FFFFFF"/>
      <stop offset="1" stop-color="#EEF3FC"/>
    </linearGradient>
    <linearGradient id="gNeck" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0" stop-color="{BLUE_DK}"/>
      <stop offset="1" stop-color="#8FB0DD"/>
    </linearGradient>
    <linearGradient id="gArm" x1="0" y1="0" x2="1" y2="0">
      <stop offset="0" stop-color="#F1F6FD"/>
      <stop offset="1" stop-color="#FFFFFF"/>
    </linearGradient>
    <linearGradient id="gShoulder" x1="0" y1="0" x2="1" y2="0">
      <stop offset="0" stop-color="#EEF4FC"/>
      <stop offset="1" stop-color="#DCE7F8"/>
    </linearGradient>
  </defs>
{rig_root}</svg>
"""
open(OUT, "w", encoding="utf-8").write(svg)
print("ditulis", OUT, len(svg), "byte")
