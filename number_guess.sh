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
  echo "Welcome back, $USERNAME! You have played $PLAYS games, and your best game took $BEST guesses."
fi
STATUS=0
NUMBER_GUESSES=0
RANDOM_NUMBER=$(( RANDOM % 1000 + 1 ))
while (( STATUS == 0 )) 
do
 echo "Guess the secret number between 1 and 1000:"
 read NUMBER
 if [[ $NUMBER =~ ^[0-9]+$ ]] 
 then
  NUMBER_RESIDE=$(( RANDOM_NUMBER - NUMBER ))
  case $NUMBER_RESIDE in
  [1-9]*) 
  NUMBER_GUESSES=$(( NUMBER_GUESSES + 1 ))
  echo "It's higher than that, guess again:"
  ;;
  0) 
  NUMBER_GUESSES=$(( NUMBER_GUESSES + 1 ))
  ADD_GAME=$($PSQL "INSERT INTO games(guesses_to_win,user_id) VALUES($NUMBER_GUESSES,$USER_ID)")
  STATUS=1
  echo "You guessed it in $NUMBER_GUESSES tries. The secret number was $RANDOM_NUMBER. Nice job!"
  ;;
  -[1-9]*) 
  echo "It's lower than that, guess again:"
  NUMBER_GUESSES=$(( NUMBER_GUESSES + 1 ))
  ;;
  esac
 else
  echo "That is not an integer, guess again:"
 fi
done