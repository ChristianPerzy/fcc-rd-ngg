#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"


NUMBER=$(($RANDOM % 1001))
TRY=1

echo "Enter your username:"
read USERNAME

USER=$($PSQL "SELECT user_id, username, games_played, best_game FROM users WHERE username ='$USERNAME'")

if [[ -z $USER ]]
then
  echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
else
  IFS='|' read -r USER_ID USERNAME GAMES_PLAYED BEST_GAME <<< $USER
  echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

echo -e "\nGuess the secret number between 1 and 1000:"

while true
do
  read GUESS

  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
  else
    if [[ $GUESS == $NUMBER ]]
    then
      if [[ -z $USER_ID ]]
      then
        INSERT_RESULT=$($PSQL "INSERT INTO users (username, games_played, best_game) VALUES ('$USERNAME', 1, $TRY)")
      else
        UPDATE_RESULT=$($PSQL "UPDATE users SET games_played = games_played + 1 WHERE user_id = $USER_ID")
        if [[ $TRY -lt $BEST_GAME ]]
        then
          UPDATE_RESULT=$($PSQL "UPDATE users SET best_game = $TRY WHERE user_id = $USER_ID")
        fi
      fi
      echo "You guessed it in $TRY tries. The secret number was $NUMBER. Nice job!"
      break
    elif [[ $GUESS -lt $NUMBER ]]
    then
      echo "It's higher than that, guess again:"
    else
      echo "It's lower than that, guess again:"
    fi
  fi

  TRY=$(($TRY + 1))
done
