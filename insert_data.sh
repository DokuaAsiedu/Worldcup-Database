#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

echo $($PSQL "TRUNCATE TABLE teams, games RESTART IDENTITY")

TEAMS_ARR=() # reflects teams in database

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $WINNER != winner || $OPPONENT != opponent ]] # don't include header
  then
    # Populate the Teams Table
    if ! [[ ${TEAMS_ARR[@]} =~ $WINNER ]] # check if winner is not in database
    then
      TEAMS_ARR+=("$WINNER")
      INSERT_RESPONSE=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
      echo Successfully inserted $WINNER into the database
    fi

    if ! [[ ${TEAMS_ARR[@]} =~ $OPPONENT ]] # check if opponent is not in database
    then
      TEAMS_ARR+=("$OPPONENT") 
      INSERT_TEAMS_RESPONSE=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
      echo Successfully inserted $OPPONENT into the database
    fi

    # Populate the Games Table
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$WINNER'")
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$OPPONENT'")

    INSERT_GAMES_RESPONSE=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS)")

    echo Successfully inserted match details of the $YEAR World cup $ROUND match between $WINNER and $OPPONENT
  fi
done