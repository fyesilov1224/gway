"""Writes the chess sounds (docs/ARCHITECTURE.md §3i): GWAY's own, synthesized here, no third-party audio.

Usage: python tool/games/sounds.py
move: a short wooden tap; capture: a heavier double tap; notify: a soft two-note chime (game start and end);
lowtime: a quiet tick when the clock runs low. 44.1 kHz mono 16-bit WAV.
"""
import math, pathlib, random, struct, wave

RATE = 44100
OUT = pathlib.Path(__file__).resolve().parents[2] / 'packages/features/games/assets/sounds'


def tap(t0, length, pitch, weight, rng):
    """A knock: a pitched body that dies fast plus a burst of filtered noise for the attack."""
    samples = []
    low = 0.0
    for i in range(int(length * RATE)):
        t = i / RATE
        body = math.sin(2 * math.pi * pitch * t) * math.exp(-t * 55) + 0.5 * math.sin(2 * math.pi * pitch * 2.3 * t) * math.exp(-t * 90)
        noise = rng.uniform(-1, 1)
        low += (noise - low) * 0.25
        click = low * math.exp(-t * 400)
        samples.append((t0 + t, weight * (0.75 * body + 0.6 * click)))
    return samples


def chime(t0, notes, length):
    samples = []
    for k, f in enumerate(notes):
        start = t0 + k * 0.11
        for i in range(int(length * RATE)):
            t = i / RATE
            env = min(1, t * 200) * math.exp(-t * 6)
            v = 0.35 * env * (math.sin(2 * math.pi * f * t) + 0.25 * math.sin(2 * math.pi * f * 2 * t))
            samples.append((start + t, v))
    return samples


def write(name, parts, total):
    buf = [0.0] * int(total * RATE)
    for t, v in parts:
        i = int(t * RATE)
        if 0 <= i < len(buf):
            buf[i] += v
    peak = max(abs(x) for x in buf) or 1
    # Fade the tail so no sound ends with a click.
    fade = int(0.01 * RATE)
    for i in range(fade):
        buf[-1 - i] *= i / fade
    OUT.mkdir(parents=True, exist_ok=True)
    with wave.open(str(OUT / name), 'wb') as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(RATE)
        w.writeframes(b''.join(struct.pack('<h', int(x / peak * 0.8 * 32767)) for x in buf))


rng = random.Random(7)
write('move.wav', tap(0, 0.12, 520, 1.0, rng), 0.14)
write('capture.wav', tap(0, 0.12, 380, 1.0, rng) + tap(0.045, 0.12, 300, 0.9, rng), 0.2)
write('notify.wav', chime(0, [660, 880], 0.5), 0.65)
write('lowtime.wav', tap(0, 0.06, 1500, 0.5, rng), 0.08)
print('sounds written to', OUT)
