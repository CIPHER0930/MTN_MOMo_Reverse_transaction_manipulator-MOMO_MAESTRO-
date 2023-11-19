#!/bin/bash

# Add ASCII art
echo ""
figlet -f standard "MTN MOMO HACKING" | lolcat
echo ""

# Define the get_headers function
function get_headers {
  # Get the response from the API
  response=$(curl -k -s -H "Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9" 'http://192.168.8.1/api/ussd/send')
  # Extract the cookie and token from the headers
  cookie=$(echo "$response" | grep -E 'Set-Cookie:' | cut -d ';' -f2 | cut -d '=' -f2)
  token=$(echo "$response" | grep -E '__RequestVerificationToken:' | cut -d '=' -f2)
  # Return the cookie and token
  if [ -z "$cookie" ] || [ -z "$token" ]; then
    echo "Failed to get cookie and token"
    exit 1
  fi
  echo "$cookie" "$token"
}

# Define the execute_ussd_command function
function execute_ussd_command {
  # Get the function arguments
  local ussd_command=$1
  # Send the USSD command using curl and store the response
  ussd_response=$(curl -X POST 'http://192.168.8.1/api/ussd/send' -H "Accept: text/plain" -H "Content-Type: application/json" -d "{\"MSISDN\": \"phoneNumber\", \"Message\": \"$ussd_command\"}" | jq -r '.Message')
  # Check for errors in the USSD response
  if [[ "$ussd_response" == *"Error"* ]]; then
    echo "Failed to execute USSD command: $ussd_command"
    exit 1
  fi
  echo "$ussd_response"
}

# Trap all errors and log them to the console
trap 'echo "Error: $?"' ERR

# Get the cookie and token
cookie_token=$(get_headers)
cookie=$(echo "$cookie_token" | cut -d ' ' -f1)
token=$(echo "$cookie_token" | cut -d ' ' -f2)

# Get the reverse transaction ID
while true; do
  reverse_transaction_id=$(dialog --title "Enter the reverse transaction ID" --inputbox "Reverse Transaction ID:" 8 80)
  exitstatus=$?
  if [ $exitstatus = 0 ]; then
    break
  fi
done

# Check if the user canceled the dialog
if [ $exitstatus = 1 ]; then
  echo "You chose to cancel."
  exit 1
fi

# Execute USSD commands to initiate transaction reversal

# Send the initial USSD command to enter the money transfer menu
execute_ussd_command "*126#"

# Send the USSD command to select the option for sending money
execute_ussd_command "7"

# Send the USSD command to select the option for reversing transactions
execute_ussd_command "6"

# Send the USSD command to enter the reverse transaction ID
execute_ussd_command "$reverse_transaction_id"

# Send the USSD command to select the transaction to reverse
execute_ussd_command "1"

# Send the USSD command to enter the PIN number
execute_ussd_command "*pin#"

# Display the final USSD response
echo "Transaction reversal completed."
