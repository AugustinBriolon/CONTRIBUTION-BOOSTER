#!/bin/bash

# Contribution Booster
# Améliorez votre présence sur GitHub

echo "======================================================"
echo "🚀 CONTRIBUTION BOOSTER 🚀"
echo "======================================================"
echo "💼 Besoin de montrer plus d'activité sur GitHub ?"
echo "🔥 Transformez votre profil en quelques minutes !"
echo "======================================================"
echo ""

# Variables par défaut
REPO_NAME="contribution-booster"
START_DATE="2024-01-01"
END_DATE="2024-12-31"
GITHUB_USERNAME=""
GIT_EMAIL=""
GIT_NAME=""
INTENSITY=2

# Infos repository
read -p "🔗 URL du repository GitHub (HTTPS ou SSH) : " REPO_URL
while [ -z "$REPO_URL" ]; do
    echo "⚠️  L'URL est obligatoire."
    read -p "🔗 URL du repository GitHub : " REPO_URL
done

# Extraction des infos depuis l'URL
if [[ $REPO_URL == *"github.com"* ]]; then
    if [[ $REPO_URL == https://* ]]; then
        GITHUB_USERNAME=$(echo $REPO_URL | sed -E 's|https://github.com/([^/]+)/.*|\1|')
        REPO_NAME=$(echo $REPO_URL | sed -E 's|https://github.com/[^/]+/([^.]+)(.git)?|\1|')
    else
        GITHUB_USERNAME=$(echo $REPO_URL | sed -E 's|git@github.com:([^/]+)/.*|\1|')
        REPO_NAME=$(echo $REPO_URL | sed -E 's|git@github.com:[^/]+/([^.]+)(.git)?|\1|')
    fi
else
    echo "⚠️  Format d'URL non valide."
    exit 1
fi

# Pré-remplissage du nom
DEFAULT_NAME=$(echo $GITHUB_USERNAME | sed 's/[._-]/ /g' | sed 's/\b\(.\)/\u\1/g')
read -p "📛 Votre nom pour Git [$DEFAULT_NAME] : " input_name
GIT_NAME=${input_name:-$DEFAULT_NAME}
while [ -z "$GIT_NAME" ]; do
    echo "⚠️  Le nom est obligatoire."
    read -p "📛 Votre nom pour Git : " GIT_NAME
done

read -p "📧 Votre email Git : " GIT_EMAIL
while [ -z "$GIT_EMAIL" ]; do
    echo "⚠️  L'email est obligatoire."
    read -p "📧 Votre email Git : " GIT_EMAIL
done

# Intensité des commits
echo ""
echo "🔥 Niveau d'activité :"
echo "  1) Débutant (1-5 commits/jour)"
echo "  2) Standard (2-15 commits/jour)"
echo "  3) Passionné (5-25 commits/jour)"
echo "  4) Intensif (jusqu'à 60 commits/jour)"
read -p "Niveau [1-4] : " INTENSITY
if ! [[ "$INTENSITY" =~ ^[1-4]$ ]]; then
    echo "⚠️  Niveau invalide, niveau 2 par défaut."
    INTENSITY=2
fi

# Période
echo ""
echo "📅 Période :"
echo "  1) 3 derniers mois"
echo "  2) 6 derniers mois"
echo "  3) Dernière année"
echo "  4) Personnalisé"
read -p "Option [1-4] : " period_option

current_year=$(date +"%Y")
current_month=$(date +"%m")
current_day=$(date +"%d")

case $period_option in
    1)
        # 3 mois
        if [ "$current_month" -le 3 ]; then
            start_month=$((current_month + 9))
            start_year=$((current_year - 1))
        else
            start_month=$((current_month - 3))
            start_year=$current_year
        fi
        START_DATE="$start_year-$start_month-$current_day"
        END_DATE="$current_year-$current_month-$current_day"
        ;;
    2)
        # 6 mois
        if [ "$current_month" -le 6 ]; then
            start_month=$((current_month + 6))
            start_year=$((current_year - 1))
        else
            start_month=$((current_month - 6))
            start_year=$current_year
        fi
        START_DATE="$start_year-$start_month-$current_day"
        END_DATE="$current_year-$current_month-$current_day"
        ;;
    3)
        # 1 an
        START_DATE="$((current_year - 1))-$current_month-$current_day"
        END_DATE="$current_year-$current_month-$current_day"
        ;;
    4)
        read -p "Date de début (AAAA-MM-JJ, ex: 2023-06-15) : " START_DATE
        read -p "Date de fin (AAAA-MM-JJ, ex: 2024-02-28) : " END_DATE
        ;;
    *)
        echo "⚠️  Option invalide, 6 mois par défaut."
        if [ "$current_month" -le 6 ]; then
            start_month=$((current_month + 6))
            start_year=$((current_year - 1))
        else
            start_month=$((current_month - 6))
            start_year=$current_year
        fi
        START_DATE="$start_year-$start_month-$current_day"
        END_DATE="$current_year-$current_month-$current_day"
        ;;
esac

# Confirmation
echo ""
echo "✅ Récapitulatif :"
echo "- Repo : $REPO_NAME"
echo "- GitHub : $GITHUB_USERNAME"
echo "- Niveau : $INTENSITY"
echo "- Période : $START_DATE à $END_DATE"
echo ""
read -p "💥 Prêt ? (o/n) : " confirm
if [[ "$confirm" != "o" && "$confirm" != "O" ]]; then
    echo "Annulé."
    exit 0
fi

# Init git
git init
echo "# $REPO_NAME" > README.md
git add README.md
git commit -m "Initial commit"

# Config git
git config user.name "$GIT_NAME"
git config user.email "$GIT_EMAIL"

# Fonctions de date
date_to_timestamp() {
    date -j -f "%Y-%m-%d" "$1" "+%s" 2>/dev/null || date -d "$1" "+%s" 2>/dev/null
}

timestamp_to_date() {
    date -j -f "%s" "$1" "+%Y-%m-%d" 2>/dev/null || date -d "@$1" "+%Y-%m-%d" 2>/dev/null
}

# Détection OS
if date -j -f "%Y-%m-%d" "2023-01-01" "+%s" &>/dev/null; then
    echo "🍎 macOS détecté"
elif date -d "2023-01-01" "+%s" &>/dev/null; then
    echo "🐧 Linux détecté"
else
    echo "❌ OS non supporté"
    exit 1
fi

# Timestamps
start_ts=$(date_to_timestamp "$START_DATE")
end_ts=$(date_to_timestamp "$END_DATE")
day_in_seconds=86400

# Création des commits
echo ""
echo "🔄 Génération en cours..."

function commits_par_jour() {
    local niveau=$1
    local type_jour=$((RANDOM % 10))
    
    case $niveau in
        1)  # Débutant
            case $type_jour in
                0) echo 0 ;;
                1|2) echo 1 ;;
                3|4|5|6) echo 2 ;;
                7|8) echo 3 ;;
                9) echo $((4 + RANDOM % 2)) ;;
            esac
            ;;
        2)  # Standard
            case $type_jour in
                0) echo 0 ;;
                1) echo 1 ;;
                2|3) echo 2 ;;
                4|5) echo 3 ;;
                6|7) echo $((4 + RANDOM % 3)) ;;
                8) echo $((7 + RANDOM % 4)) ;;
                9) echo $((11 + RANDOM % 5)) ;;
            esac
            ;;
        3)  # Passionné
            case $type_jour in
                0) echo 0 ;;
                1) echo $((1 + RANDOM % 2)) ;;
                2|3) echo $((3 + RANDOM % 3)) ;;
                4|5) echo $((6 + RANDOM % 3)) ;;
                6|7) echo $((9 + RANDOM % 4)) ;;
                8) echo $((13 + RANDOM % 5)) ;;
                9) echo $((18 + RANDOM % 8)) ;;
            esac
            ;;
        4)  # Intensif
            case $type_jour in
                0) echo 0 ;;
                1) echo $((1 + RANDOM % 4)) ;;
                2) echo $((5 + RANDOM % 5)) ;;
                3|4) echo $((10 + RANDOM % 6)) ;;
                5|6) echo $((16 + RANDOM % 10)) ;;
                7|8) echo $((26 + RANDOM % 15)) ;;
                9) echo $((41 + RANDOM % 20)) ;;
            esac
            ;;
        *)
            echo $((1 + RANDOM % 3))
            ;;
    esac
}

# Parcours des jours
current_ts=$start_ts
total_commits=0
total_days=0

while [ $current_ts -le $end_ts ]; do
    current_date=$(timestamp_to_date "$current_ts")
    
    # Moins de commits le weekend
    jour_semaine=$(date -d @$current_ts +%u 2>/dev/null || date -j -f %s $current_ts +%u 2>/dev/null)
    
    proba_commit=8
    if [ "$jour_semaine" -eq 6 ] || [ "$jour_semaine" -eq 7 ]; then
        proba_commit=4
    fi
    
    if [ $((RANDOM % 10)) -lt $proba_commit ]; then
        nb_commits=$(commits_par_jour $INTENSITY)
        
        for i in $(seq 1 $nb_commits); do
            echo "Mise à jour du $current_date" >> activite.log
            git add activite.log
            
            GIT_AUTHOR_DATE="$current_date 12:00:00" GIT_COMMITTER_DATE="$current_date 12:00:00" git commit -m "Mise à jour du $current_date"
            total_commits=$((total_commits + 1))
            
            if [ $((total_commits % 50)) -eq 0 ]; then
                echo "   ⏱️  $total_commits commits..."
            fi
        done
        total_days=$((total_days + 1))
    fi
    
    current_ts=$(($current_ts + $day_in_seconds))
done

echo ""
echo "✅ $total_commits commits créés sur $total_days jours."

# Publication
echo ""
echo "🚀 ÉTAPES FINALES :"
echo "   git remote remove origin"
echo "   git remote add origin $REPO_URL"
echo "   git branch -M main"
echo "   git push -u origin main"
echo ""
echo "⏰ La mise à jour du profil peut prendre quelques heures."