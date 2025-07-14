#!/bin/bash
set -e

# --- CONFIGURATION ---
REPO="Free-TV/IPTV"
UPSTREAM_URL="https://github.com/$REPO.git"
PROJECT_ROOT="."
GITHUB_WORKFLOW_URL="https://raw.githubusercontent.com/qbikmuzik615/iptv-automation-templates/main/.github/workflows/main.yml"
SCRIPT_BASE_URL="https://raw.githubusercontent.com/qbikmuzik615/iptv-automation-templates/main/scripts"
MAKE_PLAYLIST_URL="https://raw.githubusercontent.com/$REPO/master/make_playlist.py"
LISTS=(zz_news_en.md zz_movies.md zz_documentaries_en.md usa_vod.md usa.md australia.md)
LISTS_BASE_URL="https://raw.githubusercontent.com/$REPO/master/lists"
EPOCH=$(date +%s)

# --- FOLDER STRUCTURE ---
mkdir -p "$PROJECT_ROOT/lists" "$PROJECT_ROOT/scripts" "$PROJECT_ROOT/.github/workflows"

# --- DOWNLOAD CORE SCRIPTS ---
curl -fsSL "$SCRIPT_BASE_URL/combine_channels.sh" -o scripts/combine_channels.sh
curl -fsSL "$SCRIPT_BASE_URL/shorten_epg_links.py" -o scripts/shorten_epg_links.py
curl -fsSL "$SCRIPT_BASE_URL/check_links.py" -o scripts/check_links.py
chmod +x scripts/*.sh

# --- WORKFLOW ---
curl -fsSL "$GITHUB_WORKFLOW_URL" -o .github/workflows/main.yml

# --- MAIN LOGIC ---
curl -fsSL "$MAKE_PLAYLIST_URL" -o make_playlist.py
curl -fsSL "$LISTS_BASE_URL/../epglist.txt" -o epglist.txt
for L in "${LISTS[@]}"; do
  curl -fsSL "$LISTS_BASE_URL/$L" -o lists/$L
done

# --- README ---
cat <<EOF > README.md
# IPTV Automation

## How to Use

1. Add your GitHub and API secrets (see .github/workflows/main.yml).
2. Push any changes to the repo or wait for the weekly schedule.
3. Artifacts and notifications will be handled automatically!

## Structure

- All scripts and workflows are auto-fetched by setup.sh.
- No manual steps required after this initial setup.
EOF

# --- GIT INIT (if needed) ---
if [ ! -d .git ]; then
  git init
  git add .
  git commit -m "Initial IPTV automation setup ($EPOCH)"
fi

echo "✅ Project structure, scripts, and workflow created."
echo "Push this repo to GitHub. After that, all automation runs from the cloud."
