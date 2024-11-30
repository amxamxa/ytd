#!/usr/bin/env bash
# file="ytd.sh"
# usage: ./ytd.sh $URL

# Farben definieren
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # Kein Farbschema

# Skript-Name für die Hilfe
SCRIPT_NAME=$(basename "$0")

# Funktion: Hilfe anzeigen
usage() {
    echo -e "${GREEN}Usage:${NC} ${YELLOW}./$SCRIPT_NAME <URL>${NC}"
    echo -e "Beispiel: ${YELLOW}./$SCRIPT_NAME https://youtu.be/KDTIpTY-oW0${NC}"
}

# Prüfen, ob eine URL übergeben wurde
if [ -z "$1" ]; then
    echo -e "${RED}Keine URL angegeben.${NC}"
    echo -e "${YELLOW}Bitte gib eine gültige URL ein:${NC}"
    read -rp "URL: " VIDEO_URL
else
    VIDEO_URL="$1"
fi

# Prüfen, ob die URL jetzt verfügbar ist
if [ -z "$VIDEO_URL" ]; then
    echo -e "${RED}URL erforderlich! Beenden.${NC}"
    exit 1
fi

# Basispfad
BASE_PATH="xyz"

# Hole Video-Informationen (Titel und Beschreibung)
echo -e "${GREEN}Hole Informationen über das Video...${NC}"
INFO=$(yt-dlp --print "title,description" "$VIDEO_URL" 2>/dev/null)
if [ $? -ne 0 ]; then
    echo -e "${RED}Fehler beim Abrufen der Video-Informationen.${NC}"
    exit 1
fi

TITLE=$(echo "$INFO" | head -n 1)
DESCRIPTION=$(echo "$INFO" | tail -n +2)

# Erstelle einen ordentlichen Ordnernamen
FOLDER_NAME=$(echo "$TITLE" | sed 's/ /-/g' | sed 's/|/-/g')
TARGET_PATH="$BASE_PATH/$FOLDER_NAME"
mkdir -p "$TARGET_PATH"

# Kapitel als separate MP3-Dateien herunterladen und richtig benennen
echo -e "${GREEN}Lade Kapitel herunter...${NC}"
yt-dlp --verbose -x --audio-format mp3 --split-chapters \
    --paths "$TARGET_PATH" --output "%(section_number)03d_%(artist)s-%(title)s.%(ext)s" "$VIDEO_URL"

# Verhindere zusätzliches .mp3-File
echo -e "${YELLOW}Entferne unnötige Dateien...${NC}"
rm -f "$TARGET_PATH/$TITLE.mp3"

# README.md mit URL und Beschreibung erstellen
echo -e "${GREEN}Erstelle README.md...${NC}"
cat <<EOF > "$TARGET_PATH/README.md"
# $TITLE

**URL:** $VIDEO_URL

**Beschreibung:**
$DESCRIPTION
EOF

echo -e "${GREEN}Fertig! Die Dateien befinden sich im Ordner:${NC} ${YELLOW}$TARGET_PATH${NC}"


