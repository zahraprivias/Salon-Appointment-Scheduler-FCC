#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "\nWelcome to My Salon, how can I help you?\n"

SERVICE_CHOICE() {
	if [[ $1 ]]
	then
		echo -e "\n$1"
	fi

	#get services
	SERVICE_SELECTION=$($PSQL "SELECT * FROM services")
	
	#show service choice
	echo "$SERVICE_SELECTION" | while read SERVICE_ID BAR SNAME
	do
		echo "$SERVICE_ID) $SNAME"
	done
	read SERVICE_ID_SELECTED
  case $SERVICE_ID_SELECTED in
    [1-5]) MAIN_MENU ;;
        *) SERVICE_CHOICE "I could not find that service. What would you like today?" ;;
  esac
}

MAIN_MENU() {
		#get customer info
		echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE
		CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
		#if customer doesnt exist
        if [[ -z $CUSTOMER_NAME ]]
        then
			  #get new customer name
			  echo -e "\nI don't have a record for that phone number, what's your name?"
			  read CUSTOMER_NAME

			  #insert new customer
			  INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')") 
        fi
		
    #get customer id
		CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone ='$CUSTOMER_PHONE'")

		#get appointment time
		echo -e "\nWhat time would you like your cut, $CUSTOMER_NAME?"
		read SERVICE_TIME
		
		#insert service appointment
		INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
		
		#get service info
		SERVICE_INFO=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
		
		#send to main menu  
    if [[ $INSERT_APPOINTMENT == "INSERT 0 1" ]]
    then
      echo -e "\nI have put you down for a $SERVICE_INFO at $SERVICE_TIME, $CUSTOMER_NAME."
    fi
}

SERVICE_CHOICE
