#!/bin/bash

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
RESET='\033[0m'

# Function to print colored output
print_colored() {
    local color="$1"
    local message="$2"
    echo -e "${color}${message}${RESET}"
}

# Tool Logo

print_colored $RED "   _____                    _          _____                _    ";
print_colored $RED "  / ____|                  | |        / ____|              | |   ";
print_colored $RED " | (___   ___  ___ _ __ ___| |_ ___  | |     _ __ __ _  ___| | __";
print_colored $RED "  \___ \ / _ \/ __| '__/ _ \ __/ __| | |    | '__/ _\` |/ __| |/ /";
print_colored $RED "  ____) |  __/ (__| | |  __/ |_\__ \ | |____| | | (_| | (__|   < ";
print_colored $RED ' |_____/ \___|\___|_|  \___|\__|___/  \_____|_|  \__,_|\___|_|\_\\'
print_colored $RED "                                                                 ";
print_colored $RED "                                                                 ";

# Take file parameter
file=$1

# Format the current date (YYYY-MM-DD)
current_date=$(date +"%d-%m-%Y")

# Output file
output_file="parsed_data.txt"
output_file2="Secrets-Crack-${current_date}.txt"

# Get Domain Name
Domain_name=$(cat $file |grep -A1 -i 'NTDS.DIT' |grep -iv 'NTDS.DIT' | cut -d '\' -f 1)

# Get number of records
hashes_count=$(cat $file |grep -i $Domain_name |grep -iv "\\$\|aes\|des" | wc -l)

# Get number of batches
max=25
batch_count=$((($hashes_count / 25) + 1))
print_colored $GREEN "Records Count: $hashes_count"
print_colored $GREEN "Number of batches: $batch_count"
echo ""

print_colored $BLUE "Now head to https://hashes.com/en/decrypt/hash"
echo ''
echo "Press Enter to continue..."
read -r

# Print hashes
#cat $file |grep -i $Domain_name |grep -iv "\\$\|aes\|des" | awk -F : '{print $1,$4}' | cut -d '\' -f 2 | awk '{print $2}' > $1-hashes-file.out

ctrl_c() {
	clear
    print_colored $RED "Ctrl+C caught. Exiting loop..."
	i=$((batch_count+1))
	echo ''
	
	#check if file exists
	if [ -e "$output_file" ]; then
		print_colored $BLUE "Here Is the cracked user and passwords"
		echo ""
		cat $output_file | sort -u > $output_file2
		rm $output_file
		cat $output_file2
		echo ''
		print_colored $YELLOW "Thanks For using Secrets Crack"

	fi
	exit 0
}

# Set up a trap to call the ctrl_c function on Ctrl+C
trap ctrl_c SIGINT

# The regex pattern
regex_pattern="^.{32}:.*$"

batch=25
i=1
for ((;i <= batch_count; i++)); do
	echo ''
	print_colored $GREEN "       Batch Number $i\\$batch_count";
	echo ""
	cat $file |grep -i $Domain_name |grep -iv "\\$\|aes\|des" | awk -F : '{print $1,$4}' | cut -d '\' -f 2  | awk '{print $2}' | head -n $batch | tail -n 25
	echo
	batch=$(($batch+25))

	# Talking input to save 
	print_colored $GREEN 'Enter Cracked Hashes :)'
	print_colored $GREEN "Press Ctrl+D when done:"
	echo ""

	# Read multi-line data from the terminal
	multiline_data=$(cat)

	# Check if there was input
	if [ -n "$multiline_data" ]; then
		# Loop through each line of the multi-line data
		while IFS= read -r line; do

			# Check if the line matches the regex pattern
			if [[ "$line" =~ $regex_pattern ]]; then
				#echo 'regex'
				# parsing logic
				hash_only=$(echo $line | cut -d : -f 1)
				user_pass=$(cat $file |grep -i $Domain_name |grep -iv "\\$\|aes\|des" | awk -F : '{print $1,$4}' | cut -d '\' -f 2 | grep -i $hash_only)
				while IFS= read -r user_pass; do
					user_only=$(echo $user_pass | awk '{print $1}')
					pass_only=$(echo $line | cut -d : -f 2)
					parsed_line="$user_only:$pass_only"

					# Append the parsed line to the output file
					# Check if more than one line
					if [ -n "$parsed_line" ] && [ "${#parsed_line}" -gt 1 ]; then
						echo "$parsed_line" >> "$output_file"
					fi
				done <<< "$user_pass"
			else
				echo ''
				print_colored $YELLOW "Format Must Be : NTLM-Hash:password"
				batch=$(($batch-25))
				i=$(($i-1))
				echo ''
			fi
		done <<< "$multiline_data"
	fi
done

# Sort and remove duplicate records
if [ -e "$output_file" ]; then
	cat $output_file | sort -u > $output_file2
	rm $output_file
	clear
	print_colored $BLUE "Here Is the cracked user and passwords:"
	echo ''
	cat $output_file2
	echo ''
	print_colored $YELLOW "Thanks For using Secrets Crack"
fi