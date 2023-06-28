#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --no-align --tuples-only -c"

echo -e "\n~~~~~ Salon Appointment Scheduler ~~~~~\n"
MAIN_MENU(){
  if [[ $1 ]]
    then
      echi -e "\n"
  fi
  echo -e "\n What service would like to use?\n"
  SERVICES=$($PSQL "SELECT * FROM SERVICES ORDER BY service_id");
  echo "$SERVICES" | while IFS="|" read SERVICE_ID SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
  read SERVICE_ID_SELECTED
  if [[ ! $SERVICE_ID_SELECTED =~ ^[1-5]+$ ]]
    then
      MAIN_MENU "That is not a valid service."
    else
      SALON_SCHEDULER $SERVICE_ID_SELECTED
  fi
}
SALON_SCHEDULER(){
  SERVICE_ID_SELECTED=$1
  #check if they are customers
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE
  CUSTOMER_ID_BY_PHONE=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  #if not add them
  if [[ -z $CUSTOMER_ID_BY_PHONE ]]
      then
      #Insert into database
      echo -e "\nWhat is your name?"
      read CUSTOMER_NAME
      INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone,name) VALUES('$CUSTOMER_PHONE','$CUSTOMER_NAME')")
  fi
  CUSTOMER_ID_BY_PHONE=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  CUSTOMER_NAME_BY_ID=$($PSQL "SELECT name FROM customers WHERE customer_id=$CUSTOMER_ID_BY_PHONE")
  #if customers book a time
  echo -e "\nWhat time do you want to book?"
  read SERVICE_TIME
  # insert into appointments
  INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(time,customer_id,service_id) VALUES('$SERVICE_TIME',$CUSTOMER_ID_BY_PHONE,$SERVICE_ID_SELECTED)")
  echo -e "\nI have put you down for a $(echo $($PSQL "SELECT name FROM SERVICES WHERE service_id=$SERVICE_ID_SELECTED")) at $SERVICE_TIME, $CUSTOMER_NAME_BY_ID."
  EXIT
}
EXIT(){
  echo -e "\nThank you for stopping by."
}
MAIN_MENU
