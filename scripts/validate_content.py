#!/usr/bin/env python3
"""Validate the native app's bundled source data without external dependencies."""
import json
import plistlib
from datetime import date
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[1]
calendar_path = ROOT / "AlejaApp/Resources/calendario-original.json"
catalog_path = ROOT / "AlejaApp/Resources/catalogo-canciones.json"

def fail(message):
    print(f"FAIL: {message}", file=sys.stderr)
    raise SystemExit(1)

try:
    days = json.loads(calendar_path.read_text(encoding="utf-8"))
    songs = json.loads(catalog_path.read_text(encoding="utf-8"))
except Exception as exc:
    fail(f"cannot parse bundled JSON: {exc}")

if len(days) != 365:
    fail(f"expected 365 merged calendar days, got {len(days)}")
required = {"dia", "fecha", "fechaTexto", "categoria", "icono", "tono", "color",
            "buenosDias", "poema", "detalle", "buenasNoches", "cancionTitulo",
            "cancionArtista", "youtubeId", "cancionUrl"}
allowed_tones = {"amor", "filosofica", "hot", "ambiente"}
def valid_youtube_id(value):
    return isinstance(value, str) and len(value) == 11 and all(
        char in "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_-" for char in value
    )

def valid_hex_color(value):
    if not isinstance(value, str) or len(value) != 7 or not value.startswith("#"):
        return False
    try:
        int(value[1:], 16)
        return True
    except ValueError:
        return False

seen_dates = []
for index, day in enumerate(days, start=1):
    missing = required - day.keys()
    if missing:
        fail(f"calendar item {index} missing keys: {sorted(missing)}")
    if not isinstance(day["dia"], int) or isinstance(day["dia"], bool) or day["dia"] != index:
        fail(f"calendar item {index}: dia must equal its one-based position")
    try:
        parsed_date = date.fromisoformat(day["fecha"])
        seen_dates.append(parsed_date)
    except Exception:
        fail(f"calendar item {index} has invalid date {day.get('fecha')!r}")
    if not isinstance(day["poema"], list) or not day["poema"]:
        fail(f"calendar item {index}: poema must be a non-empty list")
    if any(not isinstance(line, str) or not line.strip() for line in day["poema"]):
        fail(f"calendar item {index}: poema contains an empty paragraph")
    for field in ("fechaTexto", "categoria", "icono", "tono", "buenosDias",
                  "detalle", "buenasNoches", "cancionTitulo", "cancionArtista"):
        if not isinstance(day[field], str) or not day[field].strip():
            fail(f"calendar item {index}: {field} is empty")
    if day["tono"] not in allowed_tones:
        fail(f"calendar item {index}: unsupported tone {day['tono']!r}")
    color = day["color"]
    if not isinstance(color, dict) or any(
        not valid_hex_color(color.get(field)) for field in ("principal", "suave", "oscuro")
    ):
        fail(f"calendar item {index}: expected valid principal/suave/oscuro hex colors")
    youtube_id = day["youtubeId"]
    expected_url = f"https://www.youtube.com/watch?v={youtube_id}" if youtube_id else None
    if day["cancionUrl"] != expected_url:
        fail(f"calendar item {index}: song URL does not match YouTube ID")
    if not valid_youtube_id(youtube_id):
        fail(f"calendar item {index}: malformed YouTube ID {youtube_id!r}")
if len(set(seen_dates)) != len(seen_dates):
    fail("calendar contains duplicate dates")
if [day["dia"] for day in days] != list(range(1, 366)):
    fail("calendar day numbers must run from 1 to 365")
if seen_dates != sorted(seen_dates):
    fail("calendar dates are not sorted")
added_days = [day for day in days if day["dia"] > 78]
added_song_ids = [day["youtubeId"] for day in added_days if day["youtubeId"]]
if len(added_days) != 287:
    fail(f"expected 287 days added from annual reference, got {len(added_days)}")
if len(added_song_ids) != len(set(added_song_ids)):
    fail("newly added calendar days contain repeated YouTube IDs")
for day in added_days:
    expected_url = f"https://www.youtube.com/watch?v={day['youtubeId']}" if day["youtubeId"] else None
    if day["cancionUrl"] != expected_url:
        fail(f"day {day['dia']} has inconsistent song URL and YouTube ID")
if seen_dates[0].isoformat() != "2026-10-16" or seen_dates[-1].isoformat() != "2027-10-15":
    fail(f"unexpected calendar range: {seen_dates[0]} through {seen_dates[-1]}")
for previous, current in zip(seen_dates, seen_dates[1:]):
    if (current - previous).days != 1:
        fail(f"calendar date gap: {previous} -> {current}")

if len(songs) != 360:
    fail(f"expected 360 catalog songs, got {len(songs)}")
expected_categories = {"amor": 46, "filosofica": 210, "hot": 58, "ambiente": 46}
actual_categories = {}
for index, song in enumerate(songs, start=1):
    for field in ("id", "category", "title", "artist", "youtubeID"):
        if field not in song:
            fail(f"song {index} missing field {field}")
    if not isinstance(song["id"], str) or not song["id"].strip():
        fail(f"song {index} has empty internal ID")
    if not isinstance(song["title"], str) or not song["title"].strip() or not isinstance(song["artist"], str) or not song["artist"].strip():
        fail(f"song {index} has empty title or artist")
    if song["category"] not in expected_categories:
        fail(f"song {index} has unsupported category {song['category']!r}")
    if song["youtubeID"] and not valid_youtube_id(song["youtubeID"]):
        fail(f"song {index} has malformed YouTube ID {song['youtubeID']!r}")
    actual_categories[song["category"]] = actual_categories.get(song["category"], 0) + 1
if actual_categories != expected_categories:
    fail(f"unexpected category counts: {actual_categories}")
ids = [song["id"] for song in songs]
if len(ids) != len(set(ids)):
    fail("catalog contains duplicate internal IDs")
youtube_ids = [song["youtubeID"] for song in songs if song["youtubeID"]]
if len(youtube_ids) != len(set(youtube_ids)):
    fail("catalog contains duplicate YouTube IDs")
missing_links = [song for song in songs if not song["youtubeID"]]
if len(missing_links) != 5:
    fail(f"expected 5 source songs without YouTube IDs, got {len(missing_links)}")

songs_by_youtube_id = {song["youtubeID"]: song for song in songs if song["youtubeID"]}
for index, day in enumerate(days, start=1):
    youtube_id = day["youtubeId"]
    if not youtube_id:
        fail(f"calendar item {index}: assigned song is missing its YouTube ID")
    catalog_song = songs_by_youtube_id.get(youtube_id)
    if catalog_song is None:
        fail(f"calendar item {index}: song ID {youtube_id} is absent from the catalog")
    if catalog_song["title"] != day["cancionTitulo"] or catalog_song["artist"] != day["cancionArtista"]:
        fail(f"calendar item {index}: song title/artist do not match catalog entry {youtube_id}")

# Keep app/widget sharing and deep-link configuration aligned; otherwise edits
# may save successfully but never reach the widget or open the selected card.
app_entitlements_path = ROOT / "AlejaApp/AlejaApp.entitlements"
widget_entitlements_path = ROOT / "AlejaWidget/AlejaWidget.entitlements"
info_path = ROOT / "AlejaApp/Info.plist"
try:
    with app_entitlements_path.open("rb") as stream:
        app_entitlements = plistlib.load(stream)
    with widget_entitlements_path.open("rb") as stream:
        widget_entitlements = plistlib.load(stream)
    with info_path.open("rb") as stream:
        app_info = plistlib.load(stream)
except Exception as exc:
    fail(f"cannot parse iOS configuration plist: {exc}")

expected_app_group = "group.com.anhjs01.aleja"
app_groups = app_entitlements.get("com.apple.security.application-groups", [])
widget_groups = widget_entitlements.get("com.apple.security.application-groups", [])
if expected_app_group not in app_groups or expected_app_group not in widget_groups:
    fail("app and widget must both declare the shared App Group")

url_schemes = [
    scheme
    for url_type in app_info.get("CFBundleURLTypes", [])
    for scheme in url_type.get("CFBundleURLSchemes", [])
]
if "aleja" not in url_schemes:
    fail("Info.plist must register the aleja deep-link URL scheme")

project_path = ROOT / "Aleja.xcodeproj/project.pbxproj"
project_text = project_path.read_text(encoding="utf-8")
for bundle_id in ("com.anhjs01.aleja", "com.anhjs01.aleja.widget"):
    if bundle_id not in project_text:
        fail(f"Xcode project is missing expected bundle identifier {bundle_id}")

print("PASS: shared App Group, app deep-link scheme, and app/widget bundle IDs")
print(f"PASS: {len(days)} consecutive calendar days, {seen_dates[0]} through {seen_dates[-1]}")
print(f"PASS: {len(songs)} songs with categories {actual_categories}")
print(f"INFO: {len(missing_links)} songs lack source YouTube IDs; the app will offer search links instead.")
