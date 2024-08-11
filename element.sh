#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

query_db() {
  local query=$1
  echo "$($PSQL "$query")"
}

if [ -z "$1" ]; then
  echo "Please provide an element as an argument."
  exit
fi

ELEMENT=$(echo "$1" | xargs)

if [[ $ELEMENT =~ ^[0-9]+$ ]]; then
  # Input is a number (atomic number)
  query="SELECT e.atomic_number, e.symbol, e.name, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius, t.type
         FROM elements e
         INNER JOIN properties p ON e.atomic_number = p.atomic_number
         INNER JOIN types t ON p.type_id = t.type_id
         WHERE e.atomic_number = $ELEMENT;"
elif [[ $ELEMENT =~ ^[A-Za-z]+$ ]]; then
  # Input is a symbol or name
  query="SELECT e.atomic_number, e.symbol, e.name, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius, t.type
         FROM elements e
         INNER JOIN properties p ON e.atomic_number = p.atomic_number
         INNER JOIN types t ON p.type_id = t.type_id
         WHERE e.symbol = '$ELEMENT' OR e.name = '$ELEMENT';"
else
  # Input is not valid
  echo "I could not find that element in the database."
  exit 1
fi

ELEMENT_RESULT=$(query_db "$query")

if [ -z "$ELEMENT_RESULT" ]; then
  echo "I could not find that element in the database."
else
  
  IFS="|" read -r ATOMIC_NUMBER SYMBOL NAME ATOMIC_MASS MELTING_POINT BOILING_POINT TYPE <<< "$ELEMENT_RESULT"
  echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
fi
              