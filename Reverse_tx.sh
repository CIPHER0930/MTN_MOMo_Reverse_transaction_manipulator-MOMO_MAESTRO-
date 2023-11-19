#!/bin/bash

# Add ASCII art
echo ""
figlet -f standard "MTN MOMO HACKING Reverse transaction" | lolcat
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

# Define the get_curl_command function
function get_curl_command {
  # Get the function arguments
  local url=$1
  local cookie=$2
  local token=$3
  # Return the curl command
  echo "curl -X POST '$url' -H 'Cookie: $cookie' -H 'x-requested-with: XMLHttpRequest' -H '__RequestVerificationToken: $token'"
}

# Define the execute_curl_commands function
function execute_curl_commands {
  # Create a local variable to store the error message
  local error_message=""
  # Execute the curl commands
  for curl_command in "$@"; do
    # Check for errors in the curl command
    if ! output=$(eval "$curl_command"); then
      error_message="Failed to execute curl command: $curl_command"
      break
    fi
  done
  # Check if there was an error
  if [ -n "$error_message" ]; then
    echo "$error_message"
    exit 1
  fi
}

# Define the try_curl_command function
function try_curl_command {
  # Get the function arguments
  local curl_command=$1
  # Try to execute the curl command
  if ! output=$(curl -s "$curl_command"); then
    error_message="Failed to execute curl command: $curl_command"
    return 1
  fi
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

# Get the curl commands
curl_commands=()
while true; do
  curl_command=$(dialog --title "Enter a curl command" --inputbox "Curl Command:" 8 80)
  exitstatus=$?
  if [ $exitstatus = 1 ]; then
    break
  fi
  curl_commands+=("$curl_command")
done

# Execute the curl commands
execute_curl_commands "${curl_commands[@]}"

# Trap all errors and log them to the console
trap 'echo "Error: $?"' EXIT