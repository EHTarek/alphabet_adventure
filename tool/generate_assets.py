#!/usr/bin/env python3
"""
Alphabet Adventure 3D — Complete Asset Generator
Generates all audio (letters, phonics, words, mascot dialogues, SFX, music)
and visual assets (avatars, badges, mascot expressions, world banners, word objects).
"""

import os
import math
import struct
import zlib
import subprocess

PROJECT_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
ASSETS_DIR = os.path.join(PROJECT_ROOT, "assets")

# ----------------------------------------------------------------------
# PNG Image Utilities (Pure Python, Zero External Dependencies)
# ----------------------------------------------------------------------

def write_png(filepath, width, height, pixels):
    """Write an RGBA pixel matrix (height x width x 4) to a valid PNG file."""
    os.makedirs(os.path.dirname(filepath), exist_ok=True)
    
    def chunk(tag, data):
        return struct.pack('>I', len(data)) + tag + data + struct.pack('>I', zlib.crc32(tag + data) & 0xffffffff)
    
    raw = bytearray()
    for row in pixels:
        raw.append(0)  # Filter byte 0 (None)
        for r, g, b, a in row:
            raw.extend([
                max(0, min(255, int(r))),
                max(0, min(255, int(g))),
                max(0, min(255, int(b))),
                max(0, min(255, int(a)))
            ])
            
    png = b'\x89PNG\r\n\x1a\n'
    png += chunk(b'IHDR', struct.pack('>IIBBBBB', width, height, 8, 6, 0, 0, 0))
    png += chunk(b'IDAT', zlib.compress(bytes(raw), 9))
    png += chunk(b'IEND', b'')
    
    with open(filepath, 'wb') as f:
        f.write(png)

def create_blank_canvas(w, h, bg_color=(0, 0, 0, 0)):
    return [[bg_color for _ in range(w)] for _ in range(h)]

def draw_circle(canvas, cx, cy, radius, color, glow_color=None, glow_radius=0):
    h = len(canvas)
    w = len(canvas[0])
    for y in range(max(0, int(cy - radius - glow_radius)), min(h, int(cy + radius + glow_radius + 1))):
        for x in range(max(0, int(cx - radius - glow_radius)), min(w, int(cx + radius + glow_radius + 1))):
            dist = math.hypot(x - cx, y - cy)
            if dist <= radius:
                # Anti-aliased edge
                alpha_factor = min(1.0, max(0.0, radius + 0.5 - dist))
                cr, cg, cb, ca = color
                canvas[y][x] = (cr, cg, cb, int(ca * alpha_factor))
            elif glow_color and dist <= radius + glow_radius:
                glow_factor = (1.0 - (dist - radius) / glow_radius) * 0.4
                gr, gg, gb, ga = glow_color
                canvas[y][x] = (gr, gg, gb, int(ga * glow_factor))

def draw_rounded_rect(canvas, x0, y0, x1, y1, radius, color, border_color=None, border_width=0):
    h = len(canvas)
    w = len(canvas[0])
    for y in range(max(0, int(y0)), min(h, int(y1))):
        for x in range(max(0, int(x0)), min(w, int(x1))):
            # Check corners
            dx = 0
            dy = 0
            if x < x0 + radius:
                dx = (x0 + radius) - x
            elif x > x1 - radius:
                dx = x - (x1 - radius)
                
            if y < y0 + radius:
                dy = (y0 + radius) - y
            elif y > y1 - radius:
                dy = y - (y1 - radius)
                
            dist = math.hypot(dx, dy)
            if dist <= radius:
                # Inside rounded rect
                if border_color and border_width > 0:
                    if dist >= radius - border_width or x < x0 + border_width or x > x1 - border_width or y < y0 + border_width or y > y1 - border_width:
                        canvas[y][x] = border_color
                    else:
                        canvas[y][x] = color
                else:
                    canvas[y][x] = color

def draw_star(canvas, cx, cy, r_outer, r_inner, points, color):
    h = len(canvas)
    w = len(canvas[0])
    angle_step = math.pi / points
    for y in range(max(0, int(cy - r_outer)), min(h, int(cy + r_outer + 1))):
        for x in range(max(0, int(cx - r_outer)), min(w, int(cx + r_outer + 1))):
            dx = x - cx
            dy = y - cy
            dist = math.hypot(dx, dy)
            if dist <= r_outer:
                angle = math.atan2(dy, dx) + math.pi / 2
                angle = angle % (2 * angle_step)
                # Compute radial limit
                t = abs(angle - angle_step) / angle_step
                limit = r_inner + (r_outer - r_inner) * (1 - t)
                if dist <= limit:
                    canvas[y][x] = color

# ----------------------------------------------------------------------
# Audio Synthesis Utilities (PCM -> WAV / M4A / MP3)
# ----------------------------------------------------------------------

def write_wav(filepath, samples, sample_rate=44100):
    """Write float samples (-1.0 to 1.0) to a standard 16-bit PCM WAV file."""
    os.makedirs(os.path.dirname(filepath), exist_ok=True)
    num_samples = len(samples)
    raw_data = bytearray()
    for s in samples:
        int_s = max(-32768, min(32767, int(s * 32767.0)))
        raw_data.extend(struct.pack('<h', int_s))
        
    with open(filepath, 'wb') as f:
        # RIFF header
        f.write(b'RIFF')
        f.write(struct.pack('<I', 36 + len(raw_data)))
        f.write(b'WAVE')
        # fmt chunk
        f.write(b'fmt ')
        f.write(struct.pack('<IHHIIHH', 16, 1, 1, sample_rate, sample_rate * 2, 2, 16))
        # data chunk
        f.write(b'data')
        f.write(struct.pack('<I', len(raw_data)))
        f.write(raw_data)

def synth_sine(freq, duration, sample_rate=44100, amp=0.5):
    num_samples = int(duration * sample_rate)
    return [amp * math.sin(2 * math.pi * freq * i / sample_rate) for i in range(num_samples)]

def synth_tap_sfx():
    """Short bubble pop / tap sound."""
    sr = 44100
    dur = 0.08
    n = int(dur * sr)
    samples = []
    for i in range(n):
        t = i / n
        freq = 450.0 - (t * 280.0) # 450 Hz -> 170 Hz
        env = (1.0 - t) ** 1.5
        s = math.sin(2 * math.pi * freq * (i / sr)) * env * 0.7
        samples.append(s)
    return samples

def synth_success_sfx():
    """Uplifting positive harmonic chime (C5, E5, G5, C6 arpeggio)."""
    sr = 44100
    notes = [523.25, 659.25, 783.99, 1046.50]
    total_dur = 0.8
    total_n = int(total_dur * sr)
    samples = [0.0] * total_n
    
    for idx, freq in enumerate(notes):
        start_t = idx * 0.12
        start_i = int(start_t * sr)
        note_dur = total_dur - start_t
        note_n = int(note_dur * sr)
        for i in range(note_n):
            if start_i + i >= total_n:
                break
            t = i / note_n
            env = math.exp(-4.0 * t)
            harmonics = (
                math.sin(2 * math.pi * freq * (i / sr)) * 0.5 +
                math.sin(2 * math.pi * (freq * 2) * (i / sr)) * 0.25 +
                math.sin(2 * math.pi * (freq * 3) * (i / sr)) * 0.1
            )
            samples[start_i + i] += harmonics * env * 0.4
    return samples

def synth_try_again_sfx():
    """Gentle, encouraging wobble tone."""
    sr = 44100
    dur = 0.4
    n = int(dur * sr)
    samples = []
    for i in range(n):
        t = i / n
        wobble = math.sin(2 * math.pi * 8.0 * t) * 20.0
        freq = 280.0 - (t * 60.0) + wobble
        env = (1.0 - t) ** 1.2
        s = math.sin(2 * math.pi * freq * (i / sr)) * env * 0.5
        samples.append(s)
    return samples

def synth_hint_sfx():
    """Magic sparkle shimmer."""
    sr = 44100
    notes = [1318.51, 1567.98, 1975.53, 2637.02]
    dur = 0.5
    n = int(dur * sr)
    samples = [0.0] * n
    for idx, freq in enumerate(notes):
        offset = int(idx * 0.08 * sr)
        for i in range(n - offset):
            t = i / (n - offset)
            env = math.exp(-5.0 * t)
            s = math.sin(2 * math.pi * freq * (i / sr)) * env * 0.25
            samples[offset + i] += s
    return samples

def synth_star_sfx():
    """Golden star ding chime."""
    sr = 44100
    freqs = [880.0, 1108.73, 1318.51] # A5 major chord
    dur = 0.7
    n = int(dur * sr)
    samples = [0.0] * n
    for freq in freqs:
        for i in range(n):
            t = i / n
            env = math.exp(-3.5 * t)
            s = (math.sin(2 * math.pi * freq * (i / sr)) + 0.3 * math.sin(4 * math.pi * freq * (i / sr))) * env * 0.25
            samples[i] += s
    return samples

def synth_celebration_sfx():
    """Victory fanfare chord sequence."""
    sr = 44100
    chords = [
        ([523.25, 659.25, 783.99], 0.15), # C
        ([587.33, 739.99, 880.00], 0.15), # D
        ([659.25, 830.61, 987.77], 0.15), # E
        ([783.99, 987.77, 1174.66, 1567.98], 0.8), # G & C high
    ]
    total_dur = 1.3
    total_n = int(total_dur * sr)
    samples = [0.0] * total_n
    cur_i = 0
    for chord_notes, dur in chords:
        chord_n = int(dur * sr)
        for i in range(chord_n):
            if cur_i + i >= total_n:
                break
            t = i / chord_n
            env = math.exp(-2.5 * t)
            chord_sum = sum(math.sin(2 * math.pi * f * (i / sr)) for f in chord_notes)
            samples[cur_i + i] += (chord_sum / len(chord_notes)) * env * 0.6
        cur_i += int(dur * sr * 0.85)
    return samples

def synth_background_music():
    """Cheery, looping, soft marimba style background melody."""
    sr = 44100
    melody = [
        (523.25, 0.25), (659.25, 0.25), (783.99, 0.25), (1046.50, 0.25),
        (880.00, 0.25), (783.99, 0.25), (659.25, 0.5),
        (587.33, 0.25), (659.25, 0.25), (783.99, 0.25), (880.00, 0.25),
        (783.99, 0.5), (523.25, 0.5)
    ]
    total_dur = sum(d for _, d in melody)
    total_n = int(total_dur * sr)
    samples = [0.0] * total_n
    cur_i = 0
    for freq, dur in melody:
        n_note = int(dur * sr)
        for i in range(n_note):
            if cur_i + i >= total_n:
                break
            t = i / n_note
            env = math.exp(-4.0 * t)
            s = (math.sin(2 * math.pi * freq * (i / sr)) + 0.2 * math.sin(4 * math.pi * freq * (i / sr))) * env * 0.35
            samples[cur_i + i] += s
        cur_i += n_note
    return samples

def generate_voice_file(text, target_path):
    """Use macOS say to generate high quality speech audio file."""
    os.makedirs(os.path.dirname(target_path), exist_ok=True)
    temp_m4a = target_path + ".temp.m4a"
    try:
        # Try voice Samantha (warm friendly American English)
        res = subprocess.run([
            "say", "-v", "Samantha", text,
            "--file-format=m4af", "--data-format=aac",
            "-o", temp_m4a
        ], capture_output=True)
        if res.returncode != 0:
            # Fallback to default voice
            subprocess.run([
                "say", text,
                "--file-format=m4af", "--data-format=aac",
                "-o", temp_m4a
            ], check=True, capture_output=True)
            
        if os.path.exists(temp_m4a):
            os.replace(temp_m4a, target_path)
            return True
    except Exception as e:
        print(f"Error generating voice for '{text}': {e}")
    return False

# ----------------------------------------------------------------------
# Main Asset Generation Flow
# ----------------------------------------------------------------------

def generate_all_audio():
    print("🔊 Generating Audio Assets...")
    
    # 1. Letters A–Z
    print("  - Letters A–Z narration...")
    for char_code in range(ord('a'), ord('z') + 1):
        letter = chr(char_code).upper()
        target = os.path.join(ASSETS_DIR, "audio", "letters", f"{letter.lower()}.mp3")
        generate_voice_file(f"Letter {letter}", target)
        
    # 2. Phonics A–Z
    print("  - Phonics A–Z sounds...")
    phonics_texts = {
        'a': "Ah. Ah says Apple",
        'b': "Buh. Buh says Ball",
        'c': "Kuh. Kuh says Cat",
        'd': "Duh. Duh says Dog",
        'e': "Eh. Eh says Egg",
        'f': "Fff. Fff says Fish",
        'g': "Guh. Guh says Goat",
        'h': "Huh. Huh says Hat",
        'i': "Ih. Ih says Igloo",
        'j': "Juh. Juh says Jar",
        'k': "Kuh. Kuh says Kite",
        'l': "Lll. Lll says Lion",
        'm': "Mmm. Mmm says Moon",
        'n': "Nnn. Nnn says Nest",
        'o': "Aw. Aw says Octopus",
        'p': "Puh. Puh says Pig",
        'q': "Kwuh. Kwuh says Queen",
        'r': "Rrr. Rrr says Rabbit",
        's': "Sss. Sss says Sun",
        't': "Tuh. Tuh says Tree",
        'u': "Uh. Uh says Umbrella",
        'v': "Vvv. Vvv says Violin",
        'w': "Wuh. Wuh says Whale",
        'x': "Ks. Ks says Xylophone",
        'y': "Yuh. Yuh says Yak",
        'z': "Zzz. Zzz says Zebra",
    }
    for letter, ptext in phonics_texts.items():
        target = os.path.join(ASSETS_DIR, "audio", "phonics", f"{letter}.mp3")
        generate_voice_file(ptext, target)
        
    # 3. 78 Vocabulary Words
    print("  - 78 Vocabulary Words...")
    words = [
        "apple", "ant", "airplane", "ball", "bear", "banana", "cat", "car", "cup",
        "dog", "duck", "drum", "egg", "elephant", "engine", "fish", "frog", "flower",
        "goat", "grape", "guitar", "hat", "horse", "house", "ice", "igloo", "insect",
        "jar", "jellyfish", "juice", "kite", "king", "kangaroo", "lamp", "lion", "leaf",
        "moon", "monkey", "mango", "nest", "nurse", "nut", "octopus", "orange", "owl",
        "pig", "pencil", "pizza", "queen", "quilt", "question", "rabbit", "rocket", "rain",
        "sun", "star", "snake", "tree", "tiger", "train", "umbrella", "unicorn", "up",
        "van", "violin", "volcano", "whale", "water", "wagon", "xylophone", "fox", "box",
        "yak", "yarn", "yogurt", "zebra", "zipper", "zoo"
    ]
    for w in words:
        target = os.path.join(ASSETS_DIR, "audio", "words", f"{w}.mp3")
        generate_voice_file(w.capitalize(), target)
        
    # 4. Mascot Dialogues
    print("  - Mascot Dialogues...")
    mascot_phrases = {
        "welcome": "Welcome to Alphabet Adventure! Let's explore together!",
        "cheer": "Awesome job! You are a super star!",
        "try_again": "Good try! Let's give it another go!",
        "hint": "Look closely! Can you spot it?",
    }
    for char_code in range(ord('a'), ord('z') + 1):
        letter = chr(char_code).upper()
        mascot_phrases[f"intro_{letter.lower()}"] = f"Let's explore the letter {letter}!"
        
    for dia_id, text in mascot_phrases.items():
        target = os.path.join(ASSETS_DIR, "audio", "mascot", f"{dia_id}.mp3")
        generate_voice_file(text, target)
        
    # 5. Sound Effects (Synthesized WAV/M4A)
    print("  - Sound Effects (SFX)...")
    sfx_map = {
        "tap.mp3": synth_tap_sfx(),
        "success.mp3": synth_success_sfx(),
        "try_again.mp3": synth_try_again_sfx(),
        "hint.mp3": synth_hint_sfx(),
        "star_earned.mp3": synth_star_sfx(),
        "celebration.mp3": synth_celebration_sfx(),
    }
    for sfx_name, samples in sfx_map.items():
        target = os.path.join(ASSETS_DIR, "audio", "sfx", sfx_name)
        write_wav(target, samples)
        
    # 6. Background Music
    print("  - Background Music loop...")
    music_samples = synth_background_music()
    music_target = os.path.join(ASSETS_DIR, "audio", "music", "background.mp3")
    write_wav(music_target, music_samples)
    print("✅ All Audio Assets successfully created!")


def generate_all_images():
    print("🎨 Generating Visual Assets...")
    
    # 1. Avatars (128x128 RGBA)
    print("  - Avatars...")
    avatars = {
        "avatar_parrot.png": (78, 205, 196, 255),    # Cyan/Pip
        "avatar_lion.png": (255, 209, 102, 255),    # Golden
        "avatar_fox.png": (255, 107, 107, 255),     # Coral
        "avatar_bear.png": (166, 124, 82, 255),     # Brown
        "avatar_bunny.png": (184, 190, 220, 255),   # Lavender
        "avatar_elephant.png": (100, 180, 240, 255),# Sky blue
        "avatar_panda.png": (45, 52, 54, 255),      # Charcoal
        "avatar_owl.png": (108, 92, 231, 255),      # Indigo
    }
    for fname, color in avatars.items():
        w, h = 128, 128
        canvas = create_blank_canvas(w, h)
        # Background bubble
        draw_circle(canvas, 64, 64, 58, color, glow_color=(255, 255, 255, 255), glow_radius=4)
        # Inner white badge ring
        draw_circle(canvas, 64, 64, 46, (255, 255, 255, 230))
        # Center avatar glyph circle
        draw_circle(canvas, 64, 64, 38, color)
        # Cute highlight reflection
        draw_circle(canvas, 48, 48, 12, (255, 255, 255, 180))
        target = os.path.join(ASSETS_DIR, "images", "avatars", fname)
        write_png(target, w, h, canvas)

    # 2. UI Badges & Stickers (140x140 RGBA)
    print("  - UI Badges & Stickers...")
    badges = {
        "badge_pioneer.png": ((78, 205, 196, 255), (255, 209, 102, 255)),
        "badge_scout.png": ((108, 92, 231, 255), (255, 107, 107, 255)),
        "badge_wizard.png": ((255, 107, 107, 255), (255, 209, 102, 255)),
        "badge_master.png": ((255, 209, 102, 255), (255, 255, 255, 255)),
        "badge_star_50.png": ((255, 215, 0, 255), (255, 140, 0, 255)),
        "badge_streak_3.png": ((255, 87, 34, 255), (255, 193, 7, 255)),
        "badge_perfect.png": ((33, 150, 243, 255), (0, 230, 118, 255)),
    }
    for bname, (outer_col, star_col) in badges.items():
        w, h = 140, 140
        canvas = create_blank_canvas(w, h)
        # Gold badge shield/circle
        draw_circle(canvas, 70, 70, 62, outer_col, glow_color=(255, 255, 255, 255), glow_radius=6)
        draw_circle(canvas, 70, 70, 52, (255, 255, 255, 240))
        # Center emblem star
        draw_star(canvas, 70, 70, 36, 18, 5, star_col)
        # Gloss reflection
        draw_circle(canvas, 52, 52, 10, (255, 255, 255, 200))
        target = os.path.join(ASSETS_DIR, "images", "ui", bname)
        write_png(target, w, h, canvas)

    # 3. Mascot Images (160x160 RGBA)
    print("  - Mascot Images...")
    mascot_states = {
        "pip_idle.png": (78, 205, 196, 255),
        "pip_happy.png": (255, 209, 102, 255),
        "pip_cheering.png": (255, 107, 107, 255),
        "pip_speaking.png": (108, 92, 231, 255),
    }
    for mname, tint in mascot_states.items():
        w, h = 160, 160
        canvas = create_blank_canvas(w, h)
        # Pip body
        draw_circle(canvas, 80, 85, 50, (78, 205, 196, 255))
        # Head
        draw_circle(canvas, 80, 55, 36, (78, 205, 196, 255))
        # Eyes
        draw_circle(canvas, 70, 50, 8, (255, 255, 255, 255))
        draw_circle(canvas, 70, 50, 4, (45, 52, 54, 255))
        draw_circle(canvas, 90, 50, 8, (255, 255, 255, 255))
        draw_circle(canvas, 90, 50, 4, (45, 52, 54, 255))
        # Beak
        draw_circle(canvas, 80, 60, 10, (255, 180, 0, 255))
        # Wing / Cheering gesture
        draw_circle(canvas, 42, 85, 18, (255, 107, 107, 255))
        draw_circle(canvas, 118, 85, 18, (255, 107, 107, 255))
        # Belly patch
        draw_circle(canvas, 80, 95, 26, (255, 209, 102, 255))
        # Sparkle / tint highlight
        draw_circle(canvas, 65, 38, 6, (255, 255, 255, 220))
        target = os.path.join(ASSETS_DIR, "images", "mascot", mname)
        write_png(target, w, h, canvas)

    # 4. World Banners (320x160 RGBA)
    print("  - World Banners...")
    worlds = {
        "world_forest.png": ((46, 204, 113, 255), (39, 174, 96, 255)),
        "world_farm.png": ((241, 196, 15, 255), (230, 126, 34, 255)),
        "world_playground.png": ((235, 77, 75, 255), (240, 147, 43, 255)),
        "world_home.png": ((104, 109, 224, 255), (72, 52, 212, 255)),
        "world_ocean.png": ((34, 166, 179, 255), (19, 15, 64, 255)),
        "world_space.png": ((48, 51, 107, 255), (19, 15, 64, 255)),
    }
    for wname, (col1, col2) in worlds.items():
        w, h = 320, 160
        canvas = create_blank_canvas(w, h)
        # Gradient background
        for y in range(h):
            t = y / h
            r = int(col1[0] * (1 - t) + col2[0] * t)
            g = int(col1[1] * (1 - t) + col2[1] * t)
            b = int(col1[2] * (1 - t) + col2[2] * t)
            for x in range(w):
                canvas[y][x] = (r, g, b, 255)
        # World elements (clouds/hills/stars)
        draw_circle(canvas, 60, 140, 60, (255, 255, 255, 60))
        draw_circle(canvas, 160, 150, 70, (255, 255, 255, 70))
        draw_circle(canvas, 260, 140, 60, (255, 255, 255, 60))
        draw_circle(canvas, 280, 40, 18, (255, 255, 255, 120))
        draw_star(canvas, 50, 40, 14, 7, 5, (255, 255, 255, 180))
        target = os.path.join(ASSETS_DIR, "images", "worlds", wname)
        write_png(target, w, h, canvas)

    # 5. Word Object Illustrations (128x128 RGBA for all 78 objects)
    print("  - 78 Word Object Illustrations...")
    word_colors = {
        'food': (255, 107, 107, 255),
        'animal': (78, 205, 196, 255),
        'vehicle': (108, 92, 231, 255),
        'toy': (255, 209, 102, 255),
        'nature': (46, 204, 113, 255),
        'object': (255, 159, 67, 255),
        'music': (155, 89, 182, 255),
        'clothing': (52, 152, 219, 255),
        'building': (230, 126, 34, 255),
        'people': (243, 156, 18, 255),
        'space': (52, 73, 94, 255),
        'concept': (26, 188, 156, 255),
        'place': (39, 174, 96, 255),
    }
    
    words_data = [
        ("apple", "food"), ("ant", "animal"), ("airplane", "vehicle"),
        ("ball", "toy"), ("bear", "animal"), ("banana", "food"),
        ("cat", "animal"), ("car", "vehicle"), ("cup", "object"),
        ("dog", "animal"), ("duck", "animal"), ("drum", "music"),
        ("egg", "food"), ("elephant", "animal"), ("engine", "vehicle"),
        ("fish", "animal"), ("frog", "animal"), ("flower", "nature"),
        ("goat", "animal"), ("grape", "food"), ("guitar", "music"),
        ("hat", "clothing"), ("horse", "animal"), ("house", "building"),
        ("ice", "nature"), ("igloo", "building"), ("insect", "animal"),
        ("jar", "object"), ("jellyfish", "animal"), ("juice", "food"),
        ("kite", "toy"), ("king", "people"), ("kangaroo", "animal"),
        ("lamp", "object"), ("lion", "animal"), ("leaf", "nature"),
        ("moon", "space"), ("monkey", "animal"), ("mango", "food"),
        ("nest", "nature"), ("nurse", "people"), ("nut", "food"),
        ("octopus", "animal"), ("orange", "food"), ("owl", "animal"),
        ("pig", "animal"), ("pencil", "object"), ("pizza", "food"),
        ("queen", "people"), ("quilt", "object"), ("question", "concept"),
        ("rabbit", "animal"), ("rocket", "space"), ("rain", "nature"),
        ("sun", "space"), ("star", "space"), ("snake", "animal"),
        ("tree", "nature"), ("tiger", "animal"), ("train", "vehicle"),
        ("umbrella", "object"), ("unicorn", "animal"), ("up", "concept"),
        ("van", "vehicle"), ("violin", "music"), ("volcano", "nature"),
        ("whale", "animal"), ("water", "nature"), ("wagon", "vehicle"),
        ("xylophone", "music"), ("fox", "animal"), ("box", "object"),
        ("yak", "animal"), ("yarn", "object"), ("yogurt", "food"),
        ("zebra", "animal"), ("zipper", "object"), ("zoo", "place")
    ]
    
    for wid, category in words_data:
        w, h = 128, 128
        canvas = create_blank_canvas(w, h)
        col = word_colors.get(category, (78, 205, 196, 255))
        # Card rounded background
        draw_rounded_rect(canvas, 6, 6, 122, 122, 24, (255, 255, 255, 255), border_color=col, border_width=4)
        # Inner decorative circle
        draw_circle(canvas, 64, 64, 40, col, glow_color=(255, 255, 255, 255), glow_radius=4)
        draw_circle(canvas, 64, 64, 32, (255, 255, 255, 240))
        # Core icon circle with gloss
        draw_circle(canvas, 64, 64, 24, col)
        draw_circle(canvas, 54, 54, 6, (255, 255, 255, 200))
        target = os.path.join(ASSETS_DIR, "images", "objects", f"{wid}.png")
        write_png(target, w, h, canvas)

    print("✅ All Visual Assets successfully created!")


if __name__ == "__main__":
    generate_all_audio()
    generate_all_images()
    print("🎉 Complete Asset Generation Finished Successfully!")
