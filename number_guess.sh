#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo -e "\n~~ WELCOME TO NUMBER-GUESS ~~\n"

NUMBER=$(($RANDOM%999+1))
echo $NUMBER

echo -e "\nEnter your username:"

read USERNAME

USER_CHECK=$($PSQL "SELECT username FROM players WHERE username='$USERNAME'")
GAMES_PLAYED=$($PSQL "SELECT total_games FROM players WHERE username='$USERNAME'")
BEST_GAME=$($PSQL "SELECT best_game FROM players WHERE username='$USERNAME'")


if [[ -z $USER_CHECK ]]
then
echo "Welcome, $USERNAME! It looks like this is your first time here."
else
echo "Welcome back, $USER_CHECK! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

echo "Guess the secret number between 1 and 1000:"

TRIES=0

while [[ $INPUT != $NUMBER ]]
do
read INPUT

(( TRIES++ ))
if [[ $INPUT == $NUMBER ]]
then
echo "You guessed it in $TRIES tries. The secret number was $NUMBER. Nice job!"
else
if [[ $INPUT =~ ^[0-9]+$ ]]
then
if [[ $INPUT -lt $NUMBER ]]
then
echo "It's higher than that, guess again:"
else
echo "It's lower than that, guess again:"
fi
else
echo "That is not an integer, guess again:"
fi
fi
done

TOTAL_GAMES_PLAYED=$(( $GAMES_PLAYED + 1 ))

if [[ -z $USER_CHECK ]]
then
USER_INSERT=$($PSQL "INSERT INTO players(username,total_games,best_game) VALUES('$USERNAME', $TOTAL_GAMES_PLAYED, $TRIES)")
else
USER_INSERT1=$($PSQL "UPDATE players SET total_games=$TOTAL_GAMES_PLAYED WHERE username='$USER_CHECK'")
if [[ $TRIES < $BEST_GAME ]]
then
USER_INSERT2=$($PSQL "UPDATE players SET best_game=$TRIES WHERE username='$USER_CHECK'")
fi
fi