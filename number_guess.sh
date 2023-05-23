#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo "Enter your username:"
read USERNAME

USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
if [[ -n $USER_ID ]]
then
  GAMES_PLAYED=$($PSQL "SELECT COUNT(game_id) FROM games INNER JOIN users USING(user_id) WHERE username='$USERNAME'")
  BEST_GAME=$($PSQL "SELECT MIN(number_of_guesses) FROM games INNER JOIN users USING(user_id) WHERE username='$USERNAME'")
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
else
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  INSERT_USER=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
fi

RANDOM_NUMBER=$(( $RANDOM % 1000 + 1 ))

TRIES=1

echo "Guess the secret number between 1 and 1000:"

while read GUESSING_NUMBER 
do
  if [[ ! $GUESSING_NUMBER =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
  else 
    if [[ $GUESSING_NUMBER -eq $RANDOM_NUMBER ]]
    then
      echo "You guessed it in $TRIES tries. The secret number was $RANDOM_NUMBER. Nice job!"
      USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
      INSERT_GAME=$($PSQL "INSERT INTO games(number_of_guesses, user_id) VALUES($TRIES, $USER_ID)")
      break;
    else
      if [[ $GUESSING_NUMBER -gt $RANDOM_NUMBER ]]
      then
        echo "It's lower than that, guess again:"
      elif [[ $GUESSING_NUMBER -lt $RANDOM_NUMBER ]]
      then
        echo "It's higher than that, guess again:"
      fi
    fi
  fi
  TRIES=$(( TRIES + 1 ))
done
