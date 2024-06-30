#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
echo -e "\nTruncated values from tables: games, teams\n"
echo "$($PSQL "TRUNCATE TABLE teams, games;")"
# Insert all teams into teams table
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT W_GOALS O_GOALS
do
 if [[ $YEAR != "year" ]]
 then
  #get winner team_id
  TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
  #if not found
  if [[ -z $TEAM_ID ]]
  then
  #insert winner team
    INSERT_WINNER_TEAM_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
    if [[ $INSERT_WINNER_TEAM_RESULT == "INSERT 0 1" ]]
    then echo "Inserted team: $WINNER"
    fi
  fi
  
  #get opponent team_id
  TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
  #if not found
  if [[ -z $TEAM_ID ]]
  then
  #insert team
    INSERT_OPPONENT_TEAM_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
    if [[ $INSERT_OPPONENT_TEAM_RESULT == "INSERT 0 1" ]]
    then echo "Inserted team: $OPPONENT"
    fi
  fi
 fi
done

echo -e "\nInsert games into table: games\n"
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT W_GOALS O_GOALS
do
  if [[ $YEAR != "year" ]]
  then
    #get Winner and Opponent team_id
    W_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    O_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    INSERT_GAMES_RESULT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $W_TEAM_ID, $O_TEAM_ID, $W_GOALS, $O_GOALS )")
    if [[ $INSERT_GAMES_RESULT == "INSERT 0 1" ]]
    then echo "Inserted game: $YEAR, Round: $ROUND, $WINNER vs. $OPPONENT, Result: $W_GOALS - $O_GOALS"
    fi  
  fi
done