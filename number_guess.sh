#!/bin/bash
echo -e "\n~~~ Number Guessing Game ~~~\n"

PSQL="psql --username=freecodecamp --dbname=number_guess -t -c"

NUMBER=$(($RANDOM % 1000 + 1))

QUESTION() {
  echo -e "\nEnter your username:"
  read USERNAME
  #get username
  GET_USERNAME_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
  #if not found
  if [[ -z $GET_USERNAME_ID ]]
  then
    INSERT_USERNAME_RESULT=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
    GET_USERNAME_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
    if [[ $INSERT_USERNAME_RESULT == "INSERT 0 1" ]]
    then
      echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
      GUESS_NUMBER
    fi
  else
    USER_RESULT=$($PSQL "SELECT username, count(game_id), min(number_of_guess) FROM games INNER JOIN users USING(user_id) WHERE user_id=$GET_USERNAME_ID GROUP BY username") 
    echo "$USER_RESULT" | while read USER BAR COUNT BAR MIN
    do 
      echo "Welcome back, $USER! You have played $COUNT games, and your best game took $MIN guesses."
    done
    GUESS_NUMBER
  fi
}
NUMBER_OF_GUESS=0
GUESS_NUMBER() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  else
    echo -e "\nGuess the secret number between 1 and 1000:"
  fi
  read GUESSED_NUMBER
  if [[ $GUESSED_NUMBER =~ ^[0-9]+$ ]]
  then
    NUMBER_OF_GUESS=$(($NUMBER_OF_GUESS + 1))
    if [[ $GUESSED_NUMBER > $NUMBER ]]
    then
      GUESS_NUMBER "It's lower than that, guess again:"
    elif [[ $GUESSED_NUMBER < $NUMBER ]]
    then
      GUESS_NUMBER "It's higher than that, guess again:"
    else
      echo -e "\nYou guessed it in $NUMBER_OF_GUESS tries. The secret number was $NUMBER. Nice job!"
      INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(user_id,number_of_guess) VALUES($GET_USERNAME_ID,$NUMBER_OF_GUESS)")
    fi
  else 
    GUESS_NUMBER "That is not an integer, guess again:"
  fi
}

QUESTION
