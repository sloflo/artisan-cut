#!/bin/bash

if [ -z "$1" ]; then
  echo "Please enter the file name:"
  read file_name
else
  file_name=$1
fi

echo "Offset in mm (default is 6):"
read offset

default_offset=6
offset=${offset:-$default_offset}

echo "Chosen Offset: $offset"


#were using index values so it really starts on line 2
line_start=1
line_count=1

output_file="${file_name%.*}_modified.${file_name##*.}"

if [ -f "$output_file" ]; then
    rm "$output_file"
fi


while read line; do

  echo "Parsing line #$line_count"
  ((line_count++))
  if [[ "$line" =~ ^$ ]]; then
    echo "$line" >> "$output_file"
    continue
  fi


   if [[ "$line" =~ ^G0 ]]; then
    if [[ "$line" == "G0 Z5.00"* ]]; then
      if [[ ${#second_line[@]} -gt 0 ]]; then
        #echo "it goes here" >> "$output_file"
        for i in "${second_line[@]}"
        do
        #echo "new line" >> "$output_file"
        echo "$i" >> "$output_file"
        done
        echo "$line" >> "$output_file"
        unset second_line
        continue
      else
       echo "$line" >> "$output_file"
       continue
      fi
    else
      echo "$line" >> "$output_file"
      current_offset_x=0
      current_offset_y=0
      second_line=()
      count=0
      reset=0
      continue
    fi
  fi

  if [[ "$line" =~ ^G1 ]]; then
    if (( count >= line_start )); then
      if [[ ${#second_line[@]} -gt 0 ]]; then
        #here we do the math and if less or equal to offset we continue
      #else we reset count so that it stops

        pattern="^G1 X-?[0-9]+(\.[0-9]+)? Y-?[0-9]+(\.[0-9]+)?$"

        length_array=${#second_line[@]};
        last_value=${second_line[$length_array-1]}

        if ! [[ "$line" =~ $pattern ]]; then
          line=$last_value
        fi

        x=$(echo "$line" | cut -d' ' -f2 | cut -c2-)
        y=$(echo "$line" | cut -d' ' -f3 | cut -c2-)


        xa=$(echo "$last_value" | cut -d' ' -f2 | cut -c2-)
        ya=$(echo "$last_value" | cut -d' ' -f3 | cut -c2-)


        #do the math
        #if last value is greater than current values subtract them backwards
        #lets check x first
        if [[ $x > $xa ]]; then
          new_x=$(bc <<< "$x - $xa")
        else
          new_x=$(bc <<< "$xa - $x")
        fi

        current_offset_x=$(echo "$current_offset_x + $new_x" | bc -l)

        #lets check y next
        if [[ $y > $ya ]]; then
          new_y=$(bc <<< "$y - $ya")
        else
          new_y=$(bc <<< "$ya - $y")
        fi

        current_offset_y=$(echo "$current_offset_y + $new_y" | bc -l)

        if [[ $reset == 0 ]]; then
         second_line+=("$line")
        fi

        if (( $(echo "$current_offset_x > $offset" | bc -l) || $(echo "$current_offset_y > $offset" | bc -l) )); then
          reset=1
          unset count  
        fi
      else
        second_line+=("$line")
      fi
    else
      if [ -n "$count" ]; then
        count=$((count+1)) 
      #  echo "increased count to $count" >> "$output_file"
      fi
    fi
    echo "$line" >> "$output_file"
    continue
  fi

  # check if the last line has been processed and output it to the output file if it hasn't
  if [[ "$line" =~ ^[mM]3 ]]; then
    :
  else
    echo "$line" >> "$output_file"
  fi

done <"$file_name"

# check if the last line has been processed and output it to the output file if it hasn't
if [[ -z "$line" ]]; then
  : # the last line has already been processed or it is empty, do nothing
else
  echo "$line" >> "$output_file"
fi

echo "Output written to $output_file"