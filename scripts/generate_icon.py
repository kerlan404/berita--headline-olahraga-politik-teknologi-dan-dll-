"""Generate REEDSFEED app icon using Pillow (PIL)."""

from PIL import Image, ImageDraw, ImageFont
import os
import math

SIZE = 1024
RADIUS = 220  # Rounded corner radius
OUTPUT_PATH = os.path.join(os.path.dirname(os.path.dirname(__file__)), "assets", "icon", "app_icon.png")


def create_rounded_rect(draw, xy, radius, fill):
    """Draw a rounded rectangle."""
    x1, y1, x2, y2 = xy
    draw.pieslice([x1, y1, x1 + radius * 2, y1 + radius * 2], 180, 270, fill=fill)
    draw.pieslice([x2 - radius * 2, y1, x2, y1 + radius * 2], 270, 360, fill=fill)
    draw.pieslice([x1, y2 - radius * 2, x1 + radius * 2, y2], 90, 180, fill=fill)
    draw.pieslice([x2 - radius * 2, y2 - radius * 2, x2, y2], 0, 90, fill=fill)
    draw.rectangle([x1 + radius, y1, x2 - radius, y2], fill=fill)
    draw.rectangle([x1, y1 + radius, x2, y2 - radius], fill=fill)


def draw_gradient_rounded_rect(draw, xy, radius, color1, color2):
    """Draw a rounded rectangle with a vertical gradient."""
    x1, y1, x2, y2 = xy
    steps = 256
    for i in range(steps):
        ratio = i / steps
        r = int(color1[0] + (color2[0] - color1[0]) * ratio)
        g = int(color1[1] + (color2[1] - color1[1]) * ratio)
        b = int(color1[2] + (color2[2] - color1[2]) * ratio)
        y = int(y1 + (y2 - y1) * ratio)
        # Draw two horizontal lines per step (full coverage)
        draw_rounded_slice(draw, x1, x2, y, y + 2, radius, (r, g, b))


def draw_rounded_slice(draw, x1, x2, y1, y2, radius, fill):
    """Draw a thin horizontal slice of the rounded rect."""
    # Just draw the horizontal bar - corners will be masked by the full rounded rect later
    draw.rectangle([x1, y1, x2, y2], fill=fill)


def create_icon():
    """Generate the REEDSFEED app icon."""
    img = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # ── Background gradient (red theme) ──
    # Top-left to bottom-right gradient
    color_top = (213, 0, 0)      # AppTheme.primaryAccent #D50000
    color_bottom = (255, 82, 82)  # Lighter red #FF5252
    color_corner = (255, 109, 0)  # AppTheme.secondaryAccent touch

    # Draw gradient background
    for y in range(SIZE):
        ratio = y / SIZE
        # Diagonal influence
        for x in range(SIZE):
            diag_ratio = (x + y) / (SIZE * 2)
            r = int(color_top[0] + (color_bottom[0] - color_top[0]) * ratio + (color_corner[0] - color_top[0]) * diag_ratio * 0.3)
            g = int(color_top[1] + (color_bottom[1] - color_top[1]) * ratio + (color_corner[1] - color_top[1]) * diag_ratio * 0.3)
            b = int(color_top[2] + (color_bottom[2] - color_top[2]) * ratio + (color_corner[2] - color_top[2]) * diag_ratio * 0.3)
            r = min(255, max(0, r))
            g = min(255, max(0, g))
            b = min(255, max(0, b))
            draw.point((x, y), fill=(r, g, b))

    # ── Create rounded corner mask ──
    mask = Image.new("L", (SIZE, SIZE), 0)
    mask_draw = ImageDraw.Draw(mask)
    create_rounded_rect(mask_draw, (0, 0, SIZE - 1, SIZE - 1), RADIUS, 255)

    # Apply rounded corners
    rounded = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    rounded.paste(img, (0, 0), mask)

    # ── Subtle inner border ──
    inner_border = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    border_draw = ImageDraw.Draw(inner_border)
    border_coords = (8, 8, SIZE - 9, SIZE - 9)
    border_draw.pieslice([border_coords[0], border_coords[1], border_coords[0] + RADIUS * 2, border_coords[1] + RADIUS * 2], 180, 270, outline=(255, 255, 255, 20), width=2)
    border_draw.pieslice([border_coords[2] - RADIUS * 2, border_coords[1], border_coords[2], border_coords[1] + RADIUS * 2], 270, 360, outline=(255, 255, 255, 20), width=2)
    border_draw.pieslice([border_coords[0], border_coords[3] - RADIUS * 2, border_coords[0] + RADIUS * 2, border_coords[3]], 90, 180, outline=(255, 255, 255, 20), width=2)
    border_draw.pieslice([border_coords[2] - RADIUS * 2, border_coords[3] - RADIUS * 2, border_coords[2], border_coords[3]], 0, 90, outline=(255, 255, 255, 20), width=2)
    border_draw.rectangle([border_coords[0] + RADIUS, border_coords[1], border_coords[2] - RADIUS, border_coords[3]], outline=(255, 255, 255, 20), width=2)
    border_draw.rectangle([border_coords[0], border_coords[1] + RADIUS, border_coords[2], border_coords[3] - RADIUS], outline=(255, 255, 255, 20), width=2)
    rounded = Image.alpha_composite(rounded, inner_border)

    # ── Draw "RF" text ──
    # Try to find a bold font
    font_paths = [
        "C:/Windows/Fonts/segoeuib.ttf",        # Segoe UI Bold
        "C:/Windows/Fonts/arialbd.ttf",          # Arial Bold
        "C:/Windows/Fonts/arial.ttf",            # Arial
        "C:/Windows/Fonts/impact.ttf",           # Impact
        "C:/Windows/Fonts/calibrib.ttf",         # Calibri Bold
        "C:/Windows/Fonts/consolab.ttf",         # Consolas Bold
    ]
    
    font = None
    for fp in font_paths:
        if os.path.exists(fp):
            try:
                font = ImageFont.truetype(fp, 420)
                break
            except Exception:
                continue
    
    if font is None:
        font = ImageFont.load_default()

    # Draw "R"
    text = "RF"
    text_img = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    text_draw = ImageDraw.Draw(text_img)

    # Get text bounding box
    bbox = text_draw.textbbox((0, 0), text, font=font)
    tw = bbox[2] - bbox[0]
    th = bbox[3] - bbox[1]
    tx = (SIZE - tw) // 2
    ty = (SIZE - th) // 2 + 20  # Slight vertical offset for optical centering

    # Draw white text with slight shadow for depth
    # Shadow
    text_draw.text((tx + 4, ty + 4), text, font=font, fill=(0, 0, 0, 40))
    # Main white text
    text_draw.text((tx, ty), text, font=font, fill=(255, 255, 255, 250))

    # ── Add a subtle shine/highlight overlay ──
    shine = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    shine_draw = ImageDraw.Draw(shine)
    # Top-left highlight half
    shine_draw.pieslice([-100, -100, SIZE + 100, SIZE + 100], 45, 135, fill=(255, 255, 255, 8))
    rounded = Image.alpha_composite(rounded, text_img)
    rounded = Image.alpha_composite(rounded, shine)

    # ── Save ──
    rounded.save(OUTPUT_PATH, "PNG")
    print(f"Icon saved to {OUTPUT_PATH}")
    print(f"Size: {os.path.getsize(OUTPUT_PATH)} bytes")


if __name__ == "__main__":
    create_icon()
