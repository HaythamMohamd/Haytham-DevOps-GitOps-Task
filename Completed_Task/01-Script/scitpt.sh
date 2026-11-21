#!/bin/bash

# begin with the line number 2 and make while loop for the line
tail -n +2 data.txt | while read line; do

    # cut the field number 2 from the line and delete the spaces and save the rsult at email variable
    email=$(echo "$line" | cut -d',' -f2 | tr -d ' ')
    # cut the field number 3 from the line and delete the spaces and save the rsult at email variable
    id=$(echo "$line" | cut -d',' -f3 | tr -d ' ')
    
    # will check the id and bad id will skip this line 
    if [[ ! $id =~ ^[0-9]+$ ]]; then
        echo "Warning: Invalid user_id -> $id"
        continue
    fi

    # will check the email and bad id will skip this line 
    if [[ $email != *@*.* ]]; then
        echo "Warning: Invalid Email -> $email"
        continue
    fi

    # will check it id is even or odd
    if (( id % 2 == 0 )); then
        echo "the $id of $email is even number"
    else
        echo "the $id of $email is odd number"
    fi
done
