#!/usr/bin/env bash

#
# Retrieves Marmiton recipies for the week
# Don't judge me, I'm just lazy and hungry
#


get_weekly_recipes() {
    curl --silent https://www.marmiton.org/recettes/menu-de-la-semaine.aspx \
        | grep -E "<(h(2|4)|li) " \
        | sed 's/<[^>]*>//g' \
        | tr $'\t' '-' \
        | tr ' ' '-' \
        | sed 's/--//g' \
        | sed 's/^-//g' \
        | sed 's/Lundi/-> Lundi/g' \
        | sed 's/Mardi/-> Mardi/g' \
        | sed 's/Mercredi/-> Mercredi/g' \
        | sed 's/Jeudi/-> Jeudi/g' \
        | sed 's/Vendredi/-> Vendredi/g' \
        | sed 's/Samedi/-> Samedi/g' \
        | sed 's/Dimanche/-> Dimanche/g' \
        | sed 's/Amuse-gueule/--> Amuse-gueule/g' \
        | sed 's/Plat-principal/--> Plat-principal/g' \
        | sed 's/Dessert/--> Dessert/g' \
        | sed 's/Confiserie/--> Confiserie/g' \
        | sed 's/Accompagnement/--> Accompagnement/g' \
        | sed 's/Entrée/--> Entrée/g' \
        | sed -e 's/^\([^- ]\)/--->\1/g'
}

get_ingredients() {
    RECIPE=$(echo ${1} \
        | tr 'à' 'a' \
        | tr 'é' 'e' \
        | tr 'è' 'e')

    WEBSITE_PAGE=$(curl --silent "https://www.marmiton.org/recettes/recherche.aspx?aqt=${RECIPE}" \
        | grep -E '"/recettes/[^"]*"' -o \
        | tr -d '"' \
        | head -n1)

    curl --silent "https://www.marmiton.org${WEBSITE_PAGE}" \
        | grep -E '."props":.*"customServer":(true|false)}' -o \
        | jq -r '.props.pageProps.recipeData.recipe.ingredientGroups[]
            | .items[]
            | [ "----> " + .name + " " + .complement + " : " + (.ingredientQuantity|tostring) + " " + .unitName]
            | @csv' \
        | tr -d '"'

}

get_weekly_ingredients() {
    get_weekly_recipes \
        | while read line; do
            echo $line
            (echo $line | grep -E "^--->" > /dev/null) && get_ingredients "${line}"
            done
}

get_weekly_ingredients
