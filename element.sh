#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

ATOMIC_NUMBER=
NAME=
SYMBOL=
TYPE=
MASS=
MP=
BP=

if [[ $# -eq 0 ]]
then
  echo "Please provide an element as an argument."
  exit
elif [[ $1 =~ ^[0-9]+$ ]]
then
  ATOMIC_NUMBER=$1
  ELEMENT_INFO=$($PSQL "SELECT symbol, name FROM elements WHERE atomic_number = $ATOMIC_NUMBER")
  IFS='|' read SYMBOL NAME <<< "$ELEMENT_INFO"
elif [[ $1 =~ ^[A-Z][a-z]?$ ]]
then
  SYMBOL=$1
  ELEMENT_INFO=$($PSQL "SELECT atomic_number, name FROM elements WHERE symbol = '$SYMBOL'")
  IFS='|' read ATOMIC_NUMBER NAME <<< "$ELEMENT_INFO"
else
  NAME=$1
  ELEMENT_INFO=$($PSQL "SELECT atomic_number, symbol FROM elements WHERE name = '$NAME'")
  IFS='|' read ATOMIC_NUMBER SYMBOL <<< "$ELEMENT_INFO"
fi


PROPERTY_INFO=$($PSQL "SELECT types.type, atomic_mass, melting_point_celsius, boiling_point_celsius FROM properties INNER JOIN types USING(type_id) WHERE atomic_number = $ATOMIC_NUMBER")
IFS='|' read TYPE MASS MP BP <<< "$PROPERTY_INFO"


if [[ -z "$MASS" ]]
then 
  echo "I could not find that element in the database."
else
  echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MP celsius and a boiling point of $BP celsius."
fi
