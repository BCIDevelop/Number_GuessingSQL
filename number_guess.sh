#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
echo Enter your username:
read USERNAME
USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")

if [[ -z $USER_ID ]]
then
  ADD_USER=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
  echo "Welcome, $USERNAME! It looks like this is your first time here."
else
  GAME_INFO=$($PSQL "SELECT COUNT(*),MIN(guesses_to_win) FROM users INNER JOIN games USING(user_id) WHERE user_id=$USER_ID GROUP BY user_id")

  IFS='|' read PLAYS BEST <<< $GAME_INFO
  echo Welcome back, $USERNAME! You have played $PLAYS games, and your best game took $BEST guesses.
fi
