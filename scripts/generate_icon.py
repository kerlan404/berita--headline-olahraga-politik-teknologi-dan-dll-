"""Generate REEDSFEED app icon — a beautiful compass icon using Pillow (PIL)."""

from PIL import Image, ImageDraw, ImageFont
import os
import math

SIZE = 1024
RADIUS = 220  # Rounded corner radius
OUTPUT_PATH = os.path.join(os.path.dirname(os.path.dirname(__file__)), "assets", "icon", "app_icon.png")


def create_rounded_rect(draw, xy, radius, fill):
    """Draw a filled rounded rectangle."""
    x1, y1, x2, y2 = xy
    draw.pieslice([x1, y1, x1 + radius * 2, y1 + radius * 2], 180, 270, fill=fill)
    draw.pieslice([x2 - radius * 2, y1, x2, y1 + radius * 2], 270, 360, fill=fill)
    draw.pieslice([x1, y2 - radius * 2, x1 + radius * 2, y2], 90, 180, fill=fill)
    draw.pieslice([x2 - radius * 2, y2 - radius * 2, x2, y2], 0, 90, fill=fill)
    draw.rectangle([x1 + radius, y1, x2 - radius, y2], fill=fill)
    draw.rectangle([x1, y1 + radius, x2, y2 - radius], fill=fill)


def draw_compass(draw, cx, cy, size):
    """Draw a beautiful compass rose centered at (cx, cy) with given size."""
    # Outer ring
    outer_r = size // 2
    inner_r = int(outer_r * 0.78)
    
    # ─── Outer ring gradient strokes ───
    for r in range(outer_r, inner_r, -1):
        progress = 1 - (outer_r - r) / (outer_r - inner_r)
        alpha = int(80 + 120 * (1 - progress))
        draw.ellipse(
            [cx - r, cy - r, cx + r, cy + r],
            outline=(255, 255, 255, alpha),
            width=1,
        )
    
    # Outer ring solid
    draw.ellipse(
        [cx - outer_r, cy - outer_r, cx + outer_r, cy + outer_r],
        outline=(255, 255, 255, 200),
        width=3,
    )
    draw.ellipse(
        [cx - inner_r, cy - inner_r, cx + inner_r, cy + inner_r],
        outline=(255, 255, 255, 120),
        width=1,
    )
    
    # ─── Compass rose (star pattern) ───
    half_r = int(inner_r * 0.95)
    tip_len = int(half_r * 0.35)  # How far the tips extend
    
    # Colors
    north_color = (255, 60, 60, 230)      # Red for North
    south_color = (255, 255, 255, 200)     # White for South
    east_color = (255, 255, 255, 140)      # Dimmer white
    west_color = (255, 255, 255, 140)      # Dimmer white
    center_color = (255, 255, 255, 240)    # Center dot
    
    def draw_compass_arm(angle_deg, color_tip, color_body):
        """Draw one arm of the compass rose at given angle."""
        angle = math.radians(angle_deg)
        
        # Tip point (outer)
        tip_x = cx + int(half_r * math.sin(angle))
        tip_y = cy - int(half_r * math.cos(angle))
        
        # Base points (wider)
        perp_angle = angle + math.pi / 2
        base_half = int(half_r * 0.18)  # Width at base
        
        # Left and right base corners
        bl_x = cx + int(base_half * math.cos(angle) * 0.5) + int(half_r * 0.25 * math.sin(angle + math.pi))
        bl_y = cy + int(base_half * math.sin(angle) * 0.5) - int(half_r * 0.25 * math.cos(angle + math.pi))
        
        br_x = cx - int(base_half * math.cos(angle) * 0.5) + int(half_r * 0.25 * math.sin(angle + math.pi))
        br_y = cy - int(base_half * math.sin(angle) * 0.5) - int(half_r * 0.25 * math.cos(angle + math.pi))
        
        # Inner point (towards center)
        inner_factor = 0.35
        inner_x = cx - int(half_r * inner_factor * math.sin(angle))
        inner_y = cy + int(half_r * inner_factor * math.cos(angle))
        
        # Draw the arm as a polygon
        draw.polygon(
            [(tip_x, tip_y), (bl_x, bl_y), (inner_x, inner_y), (br_x, br_y)],
            fill=color_tip,
            outline=(255, 255, 255, 60),
        )
    
    # Draw 4 main directions
    draw_compass_arm(0, north_color, (255, 255, 255, 60))    # N (top)
    draw_compass_arm(90, east_color, (255, 255, 255, 40))    # E (right)
    draw_compass_arm(180, south_color, (255, 255, 255, 60))  # S (bottom)
    draw_compass_arm(270, west_color, (255, 255, 255, 40))   # W (left)
    
    # ─── Diagonal arms (smaller) ───
    diag_color = (255, 255, 255, 80)
    diag_len = int(half_r * 0.6)
    for angle_deg in [45, 135, 225, 315]:
        angle = math.radians(angle_deg)
        tip_x = cx + int(diag_len * math.sin(angle))
        tip_y = cy - int(diag_len * math.cos(angle))
        
        perp = angle + math.pi / 2
        base_w = int(diag_len * 0.12)
        bl_x = cx + int(base_w * math.cos(angle)) + int(diag_len * 0.2 * math.sin(angle + math.pi))
        bl_y = cy + int(base_w * math.sin(angle)) - int(diag_len * 0.2 * math.cos(angle + math.pi))
        br_x = cx - int(base_w * math.cos(angle)) + int(diag_len * 0.2 * math.sin(angle + math.pi))
        br_y = cy - int(base_w * math.sin(angle)) - int(diag_len * 0.2 * math.cos(angle + math.pi))
        inner_x = cx - int(diag_len * 0.25 * math.sin(angle))
        inner_y = cy + int(diag_len * 0.25 * math.cos(angle))
        
        draw.polygon(
            [(tip_x, tip_y), (bl_x, bl_y), (inner_x, inner_y), (br_x, br_y)],
            fill=diag_color,
        )
    
    # ─── Center circle ───
    center_r = int(half_r * 0.12)
    draw.ellipse(
        [cx - center_r, cy - center_r, cx + center_r, cy + center_r],
        fill=center_color,
        outline=(255, 255, 255, 100),
    )
    
    # ─── N / S / E / W labels ───
    font = None
    font_paths = [
        "C:/Windows/Fonts/segoeuib.ttf",   # Segoe UI Bold
        "C:/Windows/Fonts/arialbd.ttf",     # Arial Bold
        "C:/Windows/Fonts/arial.ttf",       # Arial
    ]
    for fp in font_paths:
        if os.path.exists(fp):
            try:
                font = ImageFont.truetype(fp, int(half_r * 0.28))
                break
            except Exception:
                continue
    
    if font is None:
        font = ImageFont.load_default()
    
    label_dist = int(half_r * 0.85)
    labels = [
        (0, -label_dist, "U", (255, 70, 70, 255)),     # Utara = North (red)
        (0, label_dist, "S", (255, 255, 255, 200)),     # Selatan = South
        (label_dist, 0, "T", (255, 255, 255, 160)),      # Timur = East
        (-label_dist, 0, "B", (255, 255, 255, 160)),     # Barat = West
    ]
    
    for dx, dy, text, color in labels:
        bbox = draw.textbbox((0, 0), text, font=font)
        tw = bbox[2] - bbox[0]
        th = bbox[3] - bbox[1]
        tx = cx + dx - tw // 2
        ty = cy + dy - th // 2
        
        # Shadow
        draw.text((tx + 1, ty + 1), text, font=font, fill=(0, 0, 0, 80))
        # Text
        draw.text((tx, ty), text, font=font, fill=color)


def draw_gradient_background(draw, size):
    """Draw a diagonal gradient background (red theme)."""
    color_top = (213, 0, 0)       # AppTheme.primaryAccent #D50000
    color_bottom = (255, 82, 82)  # Lighter red #FF5252
    color_corner = (255, 109, 0)  # AppTheme.secondaryAccent touch
    
    for y in range(size):
        for x in range(size):
            ratio = y / size
            diag_ratio = (x + y) / (size * 2)
            r = int(color_top[0] + (color_bottom[0] - color_top[0]) * ratio + (color_corner[0] - color_top[0]) * diag_ratio * 0.3)
            g = int(color_top[1] + (color_bottom[1] - color_top[1]) * ratio + (color_corner[1] - color_top[1]) * diag_ratio * 0.3)
            b = int(color_top[2] + (color_bottom[2] - color_top[2]) * ratio + (color_corner[2] - color_top[2]) * diag_ratio * 0.3)
            r = min(255, max(0, r))
            g = min(255, max(0, g))
            b = min(255, max(0, b))
            draw.point((x, y), fill=(r, g, b))


def create_icon():
    """Generate the REEDSFEED app icon with a compass design."""
    img = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # ── Background gradient (red theme) ──
    draw_gradient_background(draw, SIZE)
    
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
    border_draw.rounded_rectangle(
        [8, 8, SIZE - 9, SIZE - 9],
        radius=RADIUS - 4,
        outline=(255, 255, 255, 25),
        width=2,
    )
    rounded = Image.alpha_composite(rounded, inner_border)
    
    # ── Draw the compass ──
    compass_size = int(SIZE * 0.65)
    draw_compass(draw, SIZE // 2, SIZE // 2, compass_size)
    
    # ── Apply rounded corners again (compass was drawn after first mask) ──
    # Re-create mask and apply
    mask2 = Image.new("L", (SIZE, SIZE), 0)
    mask2_draw = ImageDraw.Draw(mask2)
    create_rounded_rect(mask2_draw, (0, 0, SIZE - 1, SIZE - 1), RADIUS, 255)
    
    result = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    result.paste(img, (0, 0), mask2)
    
    # ── Add a subtle shine/highlight overlay ──
    shine = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    shine_draw = ImageDraw.Draw(shine)
    shine_draw.pieslice([-100, -100, SIZE + 100, SIZE + 100], 45, 135, fill=(255, 255, 255, 12))
    result = Image.alpha_composite(result, shine)
    
    # ── Save ──
    os.makedirs(os.path.dirname(OUTPUT_PATH), exist_ok=True)
    result.save(OUTPUT_PATH, "PNG")
    print(f"Icon saved to {OUTPUT_PATH}")
    print(f"Size: {os.path.getsize(OUTPUT_PATH)} bytes")
    print("✅ Compass icon generated successfully!")


if __name__ == "__main__":
    create_icon()
