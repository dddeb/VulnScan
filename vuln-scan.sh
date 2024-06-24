#!/bin/bash

# Introduction: 
# automating security checks and penetration testing, to stay up-to-date and protect our assets.

# Objective:
# Write a script to automate the following checks:
    # Map the entire local network's devices for ports, services, and vulnerabilities like weak login passwords.

# ===== CONTENT ========== ========== ========== ========== ========== ========== ========== ========== ========== #

# 1.1 Get from the user a network to scan
# 1.2 Get from the user a name for the output directory
# 1.3 choose 'Basic' or 'Full' scan
# 1.3.1 Basic: scans the network for TCP and UDP, including the service version and weak passwords.
# 1.3.2 Full: include Nmap Scripting Engine (NSE), weak passwords, and vulnerability analysis.

# 2. Weak Credentials
# 2.1 Look for weak passwords used in the network for login services.# 2.1.1 Have a built-in password.lst to check for weak passwords.
# 2.1.2 Allow the user to supply their own password list.
# 2.2 Login services to check include: SSH, RDP, FTP, and TELNET.

# 3. Mapping Vulnerabilities
# 3.1 Mapping vulnerabilities should only take place if Full was chosen.
# 3.2 Display potential vulnerabilities via NSE and Searchsploit.

# 4.2 At the end, show the user the found information.
# 4.3 Allow the user to search inside the results.
# 4.4 Allow to save all results into a Zip file.

# ===== STRUCTURE ========== ========== ========== ========== ========== ========== ========== ========== ========== #

# 1. Get a network to scan. Choose auto-detect or input.
# 2. Get a name to create a new folder. Create the new folder.
# 3. Choose basic or full scan.
# 4. Scan network
    # a. Nmap host discovery scan. Save the result to a file.
    # b. Masscan open ports scan. Save the result to a file.
    # c. Nmap TCP ports service versions. Save the result to files, plain text and html.
    # d. Nmap UDP ports service versions. Save the result to a file, plain text and html.
    # e. (For full scan option) NSE TCP ports vulners scan. Save the result to a file, plain text and html.
    # f. (For full scan option) NSE UDP ports vulners scan. Save the result to a file, plain text and html.
# 5. Scan weak passwords
    # a. Get a password list. Choose default or input. Save/copy the file to the created folder.
    # b. Get a username list. Save/copy the file to the created folder.
    # c. Choose login service to scan. Choose FTP, SSH, TELNET, or RDP.
    # d. Hydra scan using saved inputs. Save the result to a file.
# 6. Summary
    # a. Save summary to a file.
    # b. Zip the entire folder.

# ===== TEXT STYLING ========== ========== ========== ========== ========== ========== ========== ========== ========== #

bold=$(tput bold)
normal=$(tput sgr0)

red=$(tput setaf 1)
green=$(tput setaf 2)
blue=$(tput setaf 4)

# ===== WELCOME BANNER ========== ========== ========== ========== ========== ========== ========== ========== ========== #

echo "${bold} 
        ~ Welcome to ~
                    __            
 \  /    | ._      (_   _  _. ._  
  \/ |_| | | |     __) (_ (_| | | 

${normal}To exit at any time use Ctrl + C
"

#  ██████   ██ 
# ██  ████ ███ 
# ██ ██ ██  ██ 
# ████  ██  ██ 
#  ██████   ██ 

# ===== STEP 01: USER INPUT: NETWORK TO SCAN ========== ========== ========== ========== ========== ========== ========== #
# 1.1 Get from the user a network to scan

#  ██████ ██   ██  ██████   ██████  ███████ ███████     ███    ██ ███████ ████████ ██     ██  ██████  ██████  ██   ██ 
# ██      ██   ██ ██    ██ ██    ██ ██      ██          ████   ██ ██         ██    ██     ██ ██    ██ ██   ██ ██  ██  
# ██      ███████ ██    ██ ██    ██ ███████ █████       ██ ██  ██ █████      ██    ██  █  ██ ██    ██ ██████  █████   
# ██      ██   ██ ██    ██ ██    ██      ██ ██          ██  ██ ██ ██         ██    ██ ███ ██ ██    ██ ██   ██ ██  ██  
#  ██████ ██   ██  ██████   ██████  ███████ ███████     ██   ████ ███████    ██     ███ ███   ██████  ██   ██ ██   ██ 

#function is for: first step of userflow. choose to auto-detect your local network CIDR or manually input a network to scan.
network-choose() {

#variable: validate network to scan
    regex_cidr="^(([1-9]?[0-9]|1[0-9][0-9]|2([0-4][0-9]|5[0-5]))\.){3}([1-9]?[0-9]|1[0-9][0-9]|2([0-4][0-9]|5[0-5]))(\/([8-9]|[1-2][0-9]|3[0-2]))$"
    #checks:
    #250-255 or 200-249 or 100-199 or 0-99 then . x3 times
    #4th same without . at the end
    # / then 8-9 or 10-29 or 30-32
    # ^ and $ to start/end wih exact match
    #input range MIN 0.0.0.0/8 MAX 255.255.255.255/32

    echo "${bold}[*] STEP 01: Getting a network to scan. ${normal}
Choose to auto detect your local network, or input a network to scan.
[-] Detect: will automatically retrieve your machine's CIDR in order to do the scan on your local network.
[-] Input: manually type in the network you wish to scan."

    while true; do
        read -e -r -p "${bold}[+] Input your choice 1) detect or 2) input: ${normal}" choice_detect_input
        sleep 1
        case $choice_detect_input in
            Detect|detect|1)
                echo "${bold}${green}You have selected Detect. Proceeding to auto detect your local network.${normal}"
                sleep 1
                network-detect
            ;;
            Input|input|2)
                echo "${bold}${green}You have selected Input. Proceeding to manual input of network.${normal}"
                sleep 1
                network-manual
            ;;
            *) #if input is anything other than accepted strings, print error, then go back to beginning of loop to choose again.
                echo "${red}ERROR! Invalid option. Choose again.${normal}"
                continue
            ;;
        esac
        break
    done
}

# ██████  ███████ ████████ ███████  ██████ ████████     ███    ██ ███████ ████████ ██     ██  ██████  ██████  ██   ██ 
# ██   ██ ██         ██    ██      ██         ██        ████   ██ ██         ██    ██     ██ ██    ██ ██   ██ ██  ██  
# ██   ██ █████      ██    █████   ██         ██        ██ ██  ██ █████      ██    ██  █  ██ ██    ██ ██████  █████   
# ██   ██ ██         ██    ██      ██         ██        ██  ██ ██ ██         ██    ██ ███ ██ ██    ██ ██   ██ ██  ██  
# ██████  ███████    ██    ███████  ██████    ██        ██   ████ ███████    ██     ███ ███   ██████  ██   ██ ██   ██

#function is for: if at step 01, user chose 1) detect, brings user here, to auto detect local network CIDR.
network-detect() {

    echo "${bold}[*] Detecting your local network.${normal}"

    #run ip a command, extract only CIDR
    detect_network=$(ip a | grep 192.168 | awk '{print $2}')
        #for ip address and subnet mask: ifconfig | grep broadcast | awk '{print $2, $4}' 

    #if echoed output is valid, then proceed
    if [[ $detect_network =~ $regex_cidr ]]; then
        echo "${bold}${green}Detected CIDR: $detect_network${normal}"

        #get confirmation from user to proceed or change input
        while true; do

            read -e -r -p "${bold}[!] OK to proceed with scanning the network of ${blue}'$detect_network'${normal}? ${bold}[y/n]: ${normal}" input_yn
            sleep 1

            #if input n, then redirect to another function for manual network input.
            if [[ $input_yn == "n" ]]; then
                echo "Cancelled auto detect. Returning to options."
                sleep 1
                network-choose
            
            #else if input y, then go forward
            elif [[ $input_yn == "y" ]]; then
                echo "${bold}${green}OK. Proceeding to next step.${normal}"
                confirmed_network=$detect_network
                sleep 1
                folder-input

            #else if anything other than y or n, show error and go back to beginning of loop
            else
                echo "${red}Unknown entry. Pls input 'y' to proceed, or 'n' to cancel.${normal}"
                continue
            fi
            break #exits loop
        done
    
    #else if output is NOT valid CIDR, then abandon process, automatically redirect user to manual input method.
    else
        echo "Error! Cannot detect your local network at the moment."
        echo "Redirecting to manual input."
        sleep 1
        network-manual
    fi
}

# ██ ███    ██ ██████  ██    ██ ████████     ███    ██ ███████ ████████ ██     ██  ██████  ██████  ██   ██ 
# ██ ████   ██ ██   ██ ██    ██    ██        ████   ██ ██         ██    ██     ██ ██    ██ ██   ██ ██  ██  
# ██ ██ ██  ██ ██████  ██    ██    ██        ██ ██  ██ █████      ██    ██  █  ██ ██    ██ ██████  █████   
# ██ ██  ██ ██ ██      ██    ██    ██        ██  ██ ██ ██         ██    ██ ███ ██ ██    ██ ██   ██ ██  ██  
# ██ ██   ████ ██       ██████     ██        ██   ████ ███████    ██     ███ ███   ██████  ██   ██ ██   ██

#function is for: if at step 01, user chose 2) input, brings user here, to manually input a network CIDR.
network-manual() {

    echo "${bold}[*] Input a network to scan.${normal}
[-] Format must be a valid CIDR. Example 192.168.123.0/24
[-] Valid range 0.0.0.0/8 ~ 255.255.255.255/32"

    #loop script until user input is valid + confirmed
    while true; do

        #ask for user input using read command
        # -e        use Readline to obtain the line (allow backspace, moving keyboard arrows)
        # -r        do not allow backslashes to escape any characters
        # -p prompt output the string PROMPT without a trailing newline before
        read -e -r -p "${bold}[+] Input a network to scan: ${normal}" input_network
        sleep 1

        #if string is empty, then return error message, and go back to beginning of while loop.
        if [[ -z "$input_network" ]]; then
            echo "${red}ERROR! Empty. Pls enter network to scan. The format must be valid CIDR.${normal}"
            continue #return to the top of the loop

        #else if filled in, validate input. The format must be valid CIDR
        elif [[ $input_network =~ $regex_cidr ]]; then
            echo "${bold}${green}Received input: $input_network${normal}"
            sleep 1

        #else if string is WRONG format, or any other unacceptable input/error, then return error message, and go back to beginning of while loop.
        else
            echo "${red}ERROR! '$input_network' is NOT valid format. The format must be valid CIDR.${normal}"
            continue
        fi

        #loop script until user input is confirmed.
        while true; do

            #confirm input before proceeding
            read -e -r -p "${bold}[!] OK to proceed with scanning the network of ${blue}'$input_network'${normal}? ${bold}[y/n]: ${normal}" input_yn
            sleep 1

            #if input n, then go back to beginning of nested while loop
            if [[ $input_yn == "n" ]]; then
                echo "Cancelled manual input. Returning to options."
                sleep 1
                network-choose
            
            #else if input y, then go forward
            elif [[ $input_yn == "y" ]]; then
                echo "${bold}${green}OK. Proceeding to next step.${normal}"
                confirmed_network=$input_network
                sleep 1
                folder-input

            #else if anything other than y or n, show error and go back to beginning of nested while loop
            else
                echo "${red}Unknown entry. Pls input 'y' to proceed, or 'n' to cancel.${normal}"
                continue #goes back to current(nested) loop beginning
            fi
            break #exits the nested loop
        done
        break #exits the loop
    done
}

#  ██████  ██████  
# ██  ████      ██ 
# ██ ██ ██  █████  
# ████  ██ ██      
#  ██████  ███████ 

# ===== STEP 02: USER INPUT: NAME OF OUTPUT DIRECTORY ========== ========== ========== ========== ========== ========== ========== #
# 1.2 Get from the user a name for the output directory

# ██ ███    ██ ██████  ██    ██ ████████     ███████  ██████  ██      ██████  ███████ ██████  
# ██ ████   ██ ██   ██ ██    ██    ██        ██      ██    ██ ██      ██   ██ ██      ██   ██ 
# ██ ██ ██  ██ ██████  ██    ██    ██        █████   ██    ██ ██      ██   ██ █████   ██████  
# ██ ██  ██ ██ ██      ██    ██    ██        ██      ██    ██ ██      ██   ██ ██      ██   ██ 
# ██ ██   ████ ██       ██████     ██        ██       ██████  ███████ ██████  ███████ ██   ██

#function is for: getting user to input a name for the new folder, where all scan reports will be saved.
folder-input() {

    echo "
${bold}[*] STEP 02: Please name the new folder for saving scan reports.${normal}
Folder name can only consist of alphabets or numbers. Max 100 characters.
No special characters or spaces allowed."

    while true; do

        #read user input
        read -e -r -p "${bold}[+] Input a name for the new folder: ${normal}" -n 100 input_foldername
        sleep 1

        regex_foldername="^[[:alnum:]]+$"
        #regex_foldername2="^[a-zA-Z0-9]+$"

        #if string is empty, then return error message, and go back to beginning of while loop.
        if [[ -z "$input_foldername" ]]; then
            echo "${red}ERROR! Empty. Pls enter new folder name. The name must only use alphabets and/or numbers, and have less than 100 characters.${normal}"
            continue

        #else if filled in, but folder with same name already exists in this directory
        #-d FILE    FILE exists and is a directory
        #-L FILE    FILE exists and is a symbolic link (same as -h)
        elif [[ -d $input_foldername || -L $input_foldername ]]; then
            echo "${red}ERROR! This folder already exists in this directory. Pls enter a different name.${normal}"
            continue

        #else if filled in, and not duplicate name, then validate input. NO special characters, or spaces, only a-z,A-Z,0-9
        elif [[ $input_foldername =~ $regex_foldername ]]; then
            echo "${bold}${green}Received input: '$input_foldername'${normal}"
        
        #else if string is WRONG format, or any other unacceptable input/error, then return error message, and go back to beginning of while loop.
        else
            echo "${red}ERROR! '$input_foldername' is NOT valid format. The name must only use alphabets and/or numbers, and have less than 100 characters.${normal}"
            continue
        fi

        while true; do

            #confirm input before proceeding
            read -e -r -p "${bold}[!] OK to proceed with this folder name ${blue}'$input_foldername'${normal}? ${bold}[y/n]: ${normal}" input_yn
            sleep 1

            #if input n, then go back to beginning of nested while loop
            if [[ $input_yn == "n" ]]; then
                echo "Pls enter a new folder name."
                continue 2
            
            #else if input y, then go forward
            elif [[ $input_yn == "y" ]]; then
                mkdir $input_foldername
                echo "${bold}${green}Folder '$input_foldername' has been created. Proceeding to next step.${normal}"
                sleep 1
                basicfull-choose

            #else if anything other than y or n, show error and go back to beginning of nested while loop
            else
                echo "${red}Unknown entry. Pls input y or n.${normal}"
                continue
            fi
            break
        done
        break
    done
    sleep 1
}

#  ██████  ██████  
# ██  ████      ██ 
# ██ ██ ██  █████  
# ████  ██      ██ 
#  ██████  ██████  

# ===== STEP 03: USER CHOICE: BASIC OR FULL SCAN ========== ========== ========== ========== ========== ========== ========== #
# 1.3 choose 'Basic' or 'Full' scan

#  ██████ ██   ██  ██████   ██████  ███████ ███████     ██████   █████  ███████ ███████     ██ ███████ ██    ██ ██      ██      
# ██      ██   ██ ██    ██ ██    ██ ██      ██          ██   ██ ██   ██ ██      ██         ██  ██      ██    ██ ██      ██      
# ██      ███████ ██    ██ ██    ██ ███████ █████       ██████  ███████ ███████ █████     ██   █████   ██    ██ ██      ██      
# ██      ██   ██ ██    ██ ██    ██      ██ ██          ██   ██ ██   ██      ██ ██       ██    ██      ██    ██ ██      ██      
#  ██████ ██   ██  ██████   ██████  ███████ ███████     ██████  ██   ██ ███████ ███████ ██     ██       ██████  ███████ ███████

#function is for: getting user to choose a basic or full scan.
basicfull-choose() {

    echo "
${bold}[*] STEP 03: Choose to do a basic or full scan.${normal}
[-] Basic scan will do:
    - Scan the network for hosts that are up.
    - Scan the up hosts for open TCP and UDP ports, showing the service versions.
    - Check for weak passwords on login services SSH, RDP, FTP, and TELNET.
[-] Full scan will do:
    - Everything covered in Basic scan.
    - Checking for vulnerabilities."

    while true; do

        read -e -r -p "${bold}[+] Input your choice 'Basic' or 'Full': ${normal}" choice_basic_full
        sleep 1

        case $choice_basic_full in

            Basic|basic)
                echo "${bold}${green}You have selected the Basic scan. Proceeding to next step.${normal}"
                sleep 1
                portscan
            ;;

            Full|full)
                echo "${bold}${green}You have selected the Full scan. Proceeding to next step.${normal}"
                sleep 1
                portscan
            ;;

            #if input is anything other than accepted strings, print error, then go back to beginning of loop to choose again.
            *) 
                echo "${red}ERROR! Invalid option. Choose again.${normal}"
                continue
            ;;
            
        esac
        break
    done

}

#  ██████  ██   ██ 
# ██  ████ ██   ██ 
# ██ ██ ██ ███████ 
# ████  ██      ██ 
#  ██████       ██ 

# ===== STEP 04: NETWORK SCAN ========== ========== ========== ========== ========== ========== ========== #
# 1.3.1 Basic: scans the network for TCP and UDP, including the service version and weak passwords.

#function is for: scanning host discovery, tcp and udp scans with service versions, saving all outputs to files.
portscan() {

#save reports' filenames as variables
    #nmap host discovery
    filename_hosts="$input_foldername/scan-hosts.txt"

    #masscan ports scan tcp + udp
    filename_openports="$input_foldername/scan-openports.txt"

    #nmap sV scan
    filename_tcp="$input_foldername/scan-tcp"
    filename_udp="$input_foldername/scan-udp"
    
    #nmap nse vulners scan
    filename_nse_tcp="$input_foldername/scan-vulners-tcp"
    filename_nse_udp="$input_foldername/scan-vulners-udp"

    # ██   ██  ██████  ███████ ████████ 
    # ██   ██ ██    ██ ██         ██    
    # ███████ ██    ██ ███████    ██    
    # ██   ██ ██    ██      ██    ██    
    # ██   ██  ██████  ███████    ██    

    # ===== HOST DISCOVERY ===== #
    echo
    echo "${bold}[*] STEP 04a: Host discovery scan.${normal}
Starting scan. This may take a few minutes..."

    #run nmap command
    # -sn           host discovery
    # -oG           output to greppable file
    # &>/dev/null   don't print on terminal
    nmap --noninteractive -sn $confirmed_network -oG $filename_hosts &>/dev/null

    #print feedback to user
    echo "Completed host scan."
    echo "${bold}${green}Hosts scan report has been saved to '$filename_hosts'. Proceeding to next step.${normal}"

    sleep 2

    # ██████   ██████  ██████  ████████ 
    # ██   ██ ██    ██ ██   ██    ██    
    # ██████  ██    ██ ██████     ██    
    # ██      ██    ██ ██   ██    ██    
    # ██       ██████  ██   ██    ██    

    # ===== TCP & UDP OPEN PORTS MASSCAN ===== #
    hosts_to_scan=$(cat $filename_hosts | grep 'Status: Up' | awk '{print $2}')
    hosts_to_scan_num=$(cat $filename_hosts | grep 'Status: Up' | awk '{print $2}' | wc -l)

    per_host_scan_min_time=1
    per_host_scan_max_time=2

    hosts_to_scan_min_time=$(($hosts_to_scan_num * $per_host_scan_min_time))
    hosts_to_scan_max_time=$(($hosts_to_scan_num * $per_host_scan_max_time))

    echo "
${bold}[*] STEP 04b: Scan for TCP & UDP open ports.${normal}
This may take a few minutes...
You have ${blue}${bold}$hosts_to_scan_num${normal} hosts up. Each host scan will take roughly ${blue}${bold}$per_host_scan_min_time ~ $per_host_scan_max_time minutes${normal}.
Estimated total time needed to finish scan: ${blue}${bold}$hosts_to_scan_min_time ~ $hosts_to_scan_max_time minutes${normal}."

    #run masscan command
    # -p    indicate port numbers to scan
    # U:    udp ports
    #--rate speed
    #-oG    save to greppable file

    for hosts_to_scan_single in $hosts_to_scan; do
        #echo current ip address being scanned
        echo "Scanning $hosts_to_scan_single..."
        sudo masscan -p1-65535,U:1-65535 $hosts_to_scan_single --rate=10000 -oG $filename_openports &>/dev/null

    done

    echo "Completed ports scan."
    echo "${bold}${green}Open ports scan report has been saved to '$filename_openports'. Proceeding to next step.${normal}"

    sleep 2

# ███████ ███████ ██████  ██    ██ ██  ██████ ███████     ██    ██ ███████ ██████  ███████ ██  ██████  ███    ██ 
# ██      ██      ██   ██ ██    ██ ██ ██      ██          ██    ██ ██      ██   ██ ██      ██ ██    ██ ████   ██ 
# ███████ █████   ██████  ██    ██ ██ ██      █████       ██    ██ █████   ██████  ███████ ██ ██    ██ ██ ██  ██ 
#      ██ ██      ██   ██  ██  ██  ██ ██      ██           ██  ██  ██      ██   ██      ██ ██ ██    ██ ██  ██ ██ 
# ███████ ███████ ██   ██   ████   ██  ██████ ███████       ████   ███████ ██   ██ ███████ ██  ██████  ██   ████ 

    # ===== TCP SERVICE VERSION NMAP SCAN ===== #
    echo "
${bold}[*] STEP 04c: Scan for TCP ports Service Versions.${normal}
This may take a few minutes..."

    #from list of open ports, filter hosts that have open TCP ports, remove duplicate entries of hosts
    host_tcp_all=$(cat $filename_openports | grep tcp | awk '{print $4}' | sort | uniq)

    #if no hosts are up, nothing to scan. print message.
    if [[ -z $host_tcp_all ]]; then
        echo "${red}No tcp ports open in this network.${normal} Going to next step."

        sleep 2

    #if there is at least 1 host up
    else
        #loop nmap scan for each host
        for host_tcp_single in $host_tcp_all; do

            #filter the current host being scanned, then TCP ports, convert from multiple lines to single line separated with commas
            host_tcp_single_portstoscan=$(cat $filename_openports | grep $host_tcp_single | grep tcp | awk '{print $7}' | awk -F/ '{print $1}' | paste -s -d ',')

            echo "Scanning service version of open port(s) ${blue}$host_tcp_single_portstoscan${normal}, of host ${blue}$host_tcp_single${normal}."

            #run nmap command
            # -p            port numbers
            # -sV           service version
            # --open        only open ports
            # -oA           export normal, greppable, and xml files
            sudo nmap --noninteractive --open -p $host_tcp_single_portstoscan -sV $host_tcp_single -oA $filename_tcp &>/dev/null
        done

        echo "Completed TCP ports service versions scan."

        sleep 2

        #if file exist, then convert
        if [ -f "$filename_tcp.xml" ]; then
        #convert xml to readable html
        xsltproc $filename_tcp.xml -o $filename_tcp.html
        echo "${bold}${green}TCP scan reports have been saved to '$filename_tcp'. Proceeding to next step.${normal}"
        else
            echo "${bold}No information found, no report will be created. Proceeding to next step.${normal}"
        fi

        sleep 2

    fi

    # ===== UDP SERVICE VERSION NMAP SCAN ===== #
    echo "
${bold}[*] STEP 04d: Scan for UDP ports Service Versions.${normal}
This may take a few minutes..."

    #from list of open ports, filter hosts that have open udp ports, remove duplicate entries of hosts
    host_udp_all=$(cat $filename_openports | grep udp | awk '{print $4}' | sort | uniq)

    #if no hosts are up, nothing to scan. print message.
    if [[ -z $host_udp_all ]]; then
        echo "${red}No udp ports open in this network.${normal} Going to next step."

        sleep 2

    #if there is at least 1 host up
    else
        #loop nmap scan for each host
        for host_udp_single in $host_udp_all; do

            #filter the current host being scanned, then udp ports, convert from multiple lines to single line separated with commas
            host_udp_single_portstoscan=$(cat $filename_openports | grep $host_udp_single | grep udp | awk '{print $7}' | awk -F/ '{print $1}' | paste -s -d ',')

            echo "Scanning service version of open port(s) ${blue}$host_udp_single_portstoscan${normal}, of host ${blue}$host_udp_single${normal}."

            #run nmap command
            #-sU            scan udp not tcp
            # -p            port numbers
            # -sV           service version
            # --open        only open ports
            # -oA           export normal, greppable, and xml files
            sudo nmap --noninteractive -sU --open -p $host_udp_single_portstoscan -sV $host_udp_single -oA $filename_udp &>/dev/null
        done

        echo "Completed UDP ports service versions scan."

        sleep 2

        #if file exist, then convert
        if [ -f "$filename_udp.xml" ]; then
        #convert xml to readable html
        xsltproc $filename_udp.xml -o $filename_udp.html
        echo "${bold}${green}udp scan reports have been saved to '$filename_udp'. Proceeding to next step.${normal}"
        else
            echo "${bold}No information found, no report will be created. Proceeding to next step.${normal}"
        fi

        sleep 2

    fi

    nextcheck

}

nextcheck() {

    echo ""
    #checking next steps
    if [[ $choice_basic_full == 'Basic' || $choice_basic_full == 'basic' ]]; then
        #basic type scan
        #skip nse step
        echo "[ Basic scan option running. Skipping vulnerability scan. ]"

        sleep 2

        hydra-pass-choice
        
    elif [[ $choice_basic_full == 'Full' || $choice_basic_full == 'full' ]]; then
        #full type scan
        #go to nse step
        echo "[ Full scan option running. Do advanced vulnerability scan. ]"

        sleep 2

        portscan-nse-tcp
    fi    
}

# ===== STEP 04e: [ONLY WITH FULL SCAN OPTION] SCAN NETWORK FOR VULNS ========== ========== ========== ========== ========== ========== ========== #
# 3. Mapping Vulnerabilities
# 3.1 Mapping vulnerabilities should only take place if Full was chosen.
# 3.2 Display potential vulnerabilities via NSE and Searchsploit.

# ███    ██ ███    ███  █████  ██████      ███    ██ ███████ ███████ 
# ████   ██ ████  ████ ██   ██ ██   ██     ████   ██ ██      ██      
# ██ ██  ██ ██ ████ ██ ███████ ██████      ██ ██  ██ ███████ █████   
# ██  ██ ██ ██  ██  ██ ██   ██ ██          ██  ██ ██      ██ ██      
# ██   ████ ██      ██ ██   ██ ██          ██   ████ ███████ ███████ 

#function is for: Scanning for vulns CVE using NSE vulners
portscan-nse-tcp() {

    echo "
${bold}[*] STEP 04e: [FULL SCAN OPTION] Vulnerability Scan for TCP.${normal}"

    #from list of open ports, filter hosts that have open TCP ports, remove duplicate entries of hosts
    host_tcp_all=$(cat $filename_openports | grep tcp | awk '{print $4}' | sort | uniq)

    #NSE script run on tcp
    if [[ -z $host_tcp_all ]]; then
        echo "${red}No tcp ports open in this network.${normal} Going to next step."

        sleep 2

    else
        #loop nmap scan for each host
        for host_tcp_single in $host_tcp_all; do

            #filter the current host being scanned, then TCP ports, convert from multiple lines to single line separated with commas
            host_tcp_single_portstoscan=$(cat $filename_openports | grep $host_tcp_single | grep tcp | awk '{print $7}' | awk -F/ '{print $1}' | paste -s -d ',')

            echo "Scanning for vulnerabilities of open port(s) ${blue}$host_tcp_single_portstoscan${normal}, of host ${blue}$host_tcp_single${normal}."

            #run nmap command
            # -p            port numbers
            # -sV           service version
            # --open        only open ports
            # -oA           export normal, greppable, and xml files
            # --script      run NSE script
            nmap --noninteractive --open -p $host_tcp_single_portstoscan -sV --script vulners $host_tcp_single -oA $filename_nse_tcp &>/dev/null

        done

        echo "Completed TCP ports vulnerability scan."

        sleep 2

        #if file exist, then convert
        if [ -f "$filename_nse_tcp.xml" ]; then
        #convert xml to readable html
        xsltproc $filename_nse_tcp.xml -o $filename_nse_tcp.html
        echo "${bold}${green}TCP vulnerability scan reports have been saved to '$filename_nse_tcp'. Proceeding to next step.${normal}"
        else
            echo "${bold}No information found, no report will be created. Proceeding to next step.${normal}"
        fi

        sleep 2

    fi

    portscan-nse-udp

}

portscan-nse-udp() {

    echo "
${bold}[*] STEP 04f: [FULL SCAN OPTION] Vulnerability Scan for UDP.${normal}"

    #from list of open ports, filter hosts that have open udp ports, remove duplicate entries of hosts
    host_udp_all=$(cat $filename_openports | grep udp | awk '{print $4}' | sort | uniq)

    #NSE script run on udp
    if [[ -z $host_udp_all ]]; then
        echo "${red}No udp ports open in this network.${normal} Going to next step."

        sleep 2

    else
        #loop nmap scan for each host
        for host_udp_single in $host_udp_all; do

            #filter the current host being scanned, then udp ports, convert from multiple lines to single line separated with commas
            host_udp_single_portstoscan=$(cat $filename_openports | grep $host_udp_single | grep udp | awk '{print $7}' | awk -F/ '{print $1}' | paste -s -d ',')

            echo "Scanning for vulnerabilities of open port(s) ${blue}$host_udp_single_portstoscan${normal}, of host ${blue}$host_udp_single${normal}."

            #run nmap command
            # -p            port numbers
            # -sV           service version
            # --open        only open ports
            # -oA           export normal, greppable, and xml files
            # --script      run NSE script
            nmap --noninteractive -sU --open -p $host_udp_single_portstoscan -sV --script vulners $host_udp_single -oA $filename_nse_udp &>/dev/null

        done

        echo "Completed UDP ports vulnerability scan."

        sleep 2

        #if file exist, then convert
        if [ -f "$filename_nse_udp.xml" ]; then
        #convert xml to readable html
        xsltproc $filename_nse_udp.xml -o $filename_nse_udp.html

        echo "${bold}${green}UDP vulnerability scan reports have been saved to '$filename_nse_udp'. Proceeding to next step.${normal}"
        else
            echo "${bold}No information found, no report will be created. Proceeding to next step.${normal}"
        fi
        sleep 2

    fi

    hydra-pass-choice

}

#  ██████  ███████ 
# ██  ████ ██      
# ██ ██ ██ ███████ 
# ████  ██      ██ 
#  ██████  ███████ 

# ===== STEP 05: USER CHOICE: PASSWORD LIST DEFAULT OR SPECIFY ========== ========== ========== ========== ========== ========== ========== #
# 2. Weak Credentials
# 2.1.1 Have a built-in password.lst to check for weak passwords.
# 2.1.2 Allow the user to supply their own password list.

#  ██████ ██   ██  ██████   ██████  ███████ ███████     ██████   █████  ███████ ███████ 
# ██      ██   ██ ██    ██ ██    ██ ██      ██          ██   ██ ██   ██ ██      ██      
# ██      ███████ ██    ██ ██    ██ ███████ █████       ██████  ███████ ███████ ███████ 
# ██      ██   ██ ██    ██ ██    ██      ██ ██          ██      ██   ██      ██      ██ 
#  ██████ ██   ██  ██████   ██████  ███████ ███████     ██      ██   ██ ███████ ███████

hydra-pass-choice() {

    passlist_builtin="/usr/share/nmap/nselib/data/SecLists/Passwords/2023-200_most_used_passwords.txt"
    passlist_builtin_title="2023-200_most_used_passwords.txt"

    echo "
${bold}[*] STEP 05a: Choose password list for scanning weak passwords.${normal}
[-] Built-in password list:
    - Will use [$passlist_builtin_title], a pre-selected list of weak passwords.
[-] Manually specify password list :
    - Provide your own list of weak passwords.
"

    read -e -r -p "${bold}[+] Input your choice 1) default or 2) input: ${normal}" input_choice_passlst
    sleep 1

    while true; do
        case $input_choice_passlst in
            1|Default|default)
                echo "${bold}${green}Chose built-in list.${normal}"
                sleep 1
                hydra-pass-builtin
            ;;
            2|Input|input)
                echo "${bold}${green}Chose manual input.${normal}"
                sleep 1
                hydra-pass-input
            ;;

            #if input is anything other than accepted strings, print error, then go back to beginning of loop to choose again.
            *) 
                echo "${red}ERROR! Invalid option. Choose again.${normal}"
                continue
            ;;
        esac
        break
    done
}

# ██████  ██    ██ ██ ██      ████████       ██ ███    ██     ██████   █████  ███████ ███████ 
# ██   ██ ██    ██ ██ ██         ██          ██ ████   ██     ██   ██ ██   ██ ██      ██      
# ██████  ██    ██ ██ ██         ██    █████ ██ ██ ██  ██     ██████  ███████ ███████ ███████ 
# ██   ██ ██    ██ ██ ██         ██          ██ ██  ██ ██     ██      ██   ██      ██      ██ 
# ██████   ██████  ██ ███████    ██          ██ ██   ████     ██      ██   ██ ███████ ███████ 

hydra-pass-builtin() {

    passlist_builtin_dl="https://raw.githubusercontent.com/danielmiessler/SecLists/master/Passwords/2023-200_most_used_passwords.txt"
    passlist_builtin_dl_path="$input_foldername/$passlist_builtin_title"

    #if this file doesn't exist, then download.
    if [[ ! -f $passlist_builtin_dl_path ]]; then
        echo "File does not exist on machine. Downloading list...'"
        curl -s -o "$passlist_builtin_dl_path" $passlist_builtin_dl &>/dev/null
    fi

    confirmed_passlst="$passlist_builtin_dl_path"

    hydra-pass-confirm

}

# ██ ███    ██ ██████  ██    ██ ████████     ██████   █████  ███████ ███████ 
# ██ ████   ██ ██   ██ ██    ██    ██        ██   ██ ██   ██ ██      ██      
# ██ ██ ██  ██ ██████  ██    ██    ██        ██████  ███████ ███████ ███████ 
# ██ ██  ██ ██ ██      ██    ██    ██        ██      ██   ██      ██      ██ 
# ██ ██   ████ ██       ██████     ██        ██      ██   ██ ███████ ███████ 
                                     
hydra-pass-input() {

    #read user input, use their own specified password list for hydra scans
    read -e -r -p "${bold}[+] Input filepath: ${normal}" input_own_passlst
    sleep 1
    echo "${bold}${green}Using this password list: $input_own_passlst${normal}"

    #if file doesn't exist, then print error.
    if [ ! -f $input_own_passlst ]; then
        echo "${red}Error! File not found.${normal}"
        echo "Returning to options..."

        sleep 1

        hydra-pass-choice

    fi

    confirmed_passlst="$input_own_passlst"

    hydra-pass-confirm

}

#  ██████  ██████  ███    ██ ███████ ██ ██████  ███    ███     ██████   █████  ███████ ███████ 
# ██      ██    ██ ████   ██ ██      ██ ██   ██ ████  ████     ██   ██ ██   ██ ██      ██      
# ██      ██    ██ ██ ██  ██ █████   ██ ██████  ██ ████ ██     ██████  ███████ ███████ ███████ 
# ██      ██    ██ ██  ██ ██ ██      ██ ██   ██ ██  ██  ██     ██      ██   ██      ██      ██ 
#  ██████  ██████  ██   ████ ██      ██ ██   ██ ██      ██     ██      ██   ██ ███████ ███████ 

hydra-pass-confirm() {

    #print preview of file content
    echo "Preview of '$confirmed_passlst':"
    echo "$(cat $confirmed_passlst | head -n 5)"
    echo "[ $(cat $confirmed_passlst | wc -l) Lines ]"

    while true; do
        read -e -r -p "${bold}[!] Proceed with this list? [y/n]: ${normal}" input_yn

        if [[ $input_yn == y ]]; then

            #filter out just the filename
            confirmed_passlst_filenameonly=$(echo "$confirmed_passlst" | awk -F/ '{print $(NF-0)}')

            #path of password file in new folder
            confirmed_passlst_innewfolder="$input_foldername/$confirmed_passlst_filenameonly"

            #if file is NOT located in the new scan folder, copy in.
            if [ ! -f $confirmed_passlst_innewfolder ]; then

                #copy file into new folder, so user can review together with reports.
                echo "Saving a copy of passlist '$confirmed_passlst_filenameonly' to folder '$input_foldername'."
                cp $confirmed_passlst $confirmed_passlst_innewfolder

            fi

            echo "${bold}${green}Saved password list to folder: $confirmed_passlst_innewfolder${normal}"            
            
            echo "Proceeding to next step."

            sleep 1

            hydra-choice-user

        elif [[ $input_yn == n ]]; then
            echo "Cancelled. Returning to options..."

            sleep 1

            hydra-pass-choice

        else
            echo "${red}Pls re-enter choice. 'y' or 'n'${normal}"
            continue
        fi
        break
    done
    
}

# ██    ██ ███████ ███████ ██████  
# ██    ██ ██      ██      ██   ██ 
# ██    ██ ███████ █████   ██████  
# ██    ██      ██ ██      ██   ██ 
#  ██████  ███████ ███████ ██   ██ 

hydra-choice-user(){

    echo "
${bold}[*] STEP 05b: Input username list for scanning weak passwords.${normal}"
    while true; do

        read -e -r -p "${bold}[+]Input username list: ${normal}" input_userlist

        #if file doesn't exist, then print error.
        if [ ! -f $input_userlist ]; then
            echo "${red}Error! File not found.${normal}"
            echo "Pls enter a new username list."
            sleep 1
            hydra-choice-user

        #else if empty input
        elif [[ -z "$input_userlist" ]]; then
            echo "${red}ERROR! Empty. Pls enter a username list.${normal}"
            continue
        
        else
            echo "${bold}${green}Recieved username: $input_userlist${normal}"

            #print preview of file content
            echo "Preview of '$input_userlist':"
            echo "$(cat $input_userlist | head -n 5)"
            echo "[ $(cat $input_userlist | wc -l) Lines ]"

            #confirm choice
            while true; do
                read -e -r -p "${bold}[!] Proceed with this username list? [y/n]: ${normal}" input_yn

                if [[ $input_yn == y ]]; then

                    #filter out just the filename
                    confirmed_userlist_filenameonly=$(echo "$input_userlist" | awk -F/ '{print $(NF-0)}')

                    #path of password file in new folder
                    confirmed_userlist_innewfolder="$input_foldername/$confirmed_userlist_filenameonly"

                    #if file is NOT located in the new scan folder, copy in.
                    if [ ! -f $confirmed_userlist_innewfolder ]; then

                    #copy file into new folder, so user can review together with reports.
                    echo "Saving a copy of username list '$confirmed_userlist_filenameonly' to folder '$input_foldername'."
                    cp $input_userlist $confirmed_userlist_innewfolder

                    fi

                    echo "${bold}${green}Saved username list to folder: $confirmed_userlist_innewfolder${normal}"
                    echo "${bold}${green}Proceeding to next step.${normal}"
                    sleep 1
                    hydra-choice-service

                elif [[ $input_yn == n ]]; then
                    echo "Cancelled. Pls enter a new username."
                    sleep 1
                    hydra-choice-user

                else
                    echo "${red}Pls re-enter choice. 'y' or 'n'${normal}"
                    continue
                fi
                break
            done
        fi
        break
    done

}

#  ██████ ██   ██  ██████   ██████  ███████ ███████     ███████ ███████ ██████  ██    ██ ██  ██████ ███████ 
# ██      ██   ██ ██    ██ ██    ██ ██      ██          ██      ██      ██   ██ ██    ██ ██ ██      ██      
# ██      ███████ ██    ██ ██    ██ ███████ █████       ███████ █████   ██████  ██    ██ ██ ██      █████   
# ██      ██   ██ ██    ██ ██    ██      ██ ██               ██ ██      ██   ██  ██  ██  ██ ██      ██      
#  ██████ ██   ██  ██████   ██████  ███████ ███████     ███████ ███████ ██   ██   ████   ██  ██████ ███████ 

# ===== STEP 05: SCAN NETWORK FOR WEAK PASSWORDS ========== ========== ========== ========== ========== ========== ========== #
# 2. Weak Credentials
# 2.1 Look for weak passwords used in the network for login services.
# 2.2 Login services to check include: SSH, RDP, FTP, and TELNET.

hydra-choice-service() {

    echo "
${bold}[*] STEP 05c: Choose login service for scanning weak passwords.${normal}
"
    #CHECK IF SERVICE IS OPEN THEN DISPLAY AS OPTION
    check_ftp=$(cat $filename_openports | grep "21/open/tcp//ftp//")
    check_ssh=$(cat $filename_openports | grep "22/open/tcp//ssh//")
    check_telnet=$(cat $filename_openports | grep "23/open/tcp//telnet//")
    check_rdp=$(cat $filename_openports | grep "3389/open/tcp//rdp//")

    while true; do
        echo "These ports are open for scanning:"

        # if previous scan report says this port is open, then display as selectable option
        if [[ ! -z $check_ftp ]]; then
            echo "  ftp      (port 21)"
        fi

        if [[ ! -z $check_ssh ]]; then
            echo "  ssh      (port 22)"
        fi

        if [[ ! -z $check_telnet ]]; then
            echo "  telnet   (port 23)"
        fi

        if [[ ! -z $check_rdp ]]; then
            echo "  rdp      (port 3389)"
        fi

        #if none are available then print message and skip scan
        if [[ -z $check_ftp && -z $check_ssh && -z $check_telnet && -z $check_rdp ]]; then
            echo "  No applicable login services are open. Skipping password scan..."

            sleep 5

            report

        else
            #user input, choose which service to scan
            read -e -r -p "${bold}[+] Input your choice: ${normal}" choice_service
            sleep 1
            case $choice_service in
                ftp)
                    echo "${bold}${green}You have selected FTP (port 21).${normal}"
                    if [[ -z $check_ftp ]]; then
                        echo "FTP service is not open. Please select another service."
                    fi
                ;;

                ssh)
                    echo "${bold}${green}You have selected SSH (port 22).${normal}"
                    if [[ -z $check_ssh ]]; then
                        echo "SSH service is not open. Please select another service."
                    fi
                ;;

                telnet)
                    echo "${bold}${green}You have selected TELNET (port 23).${normal}"
                    if [[ -z $check_telnet ]]; then
                        echo "TELNET service is not open. Please select another service."
                    fi
                ;;

                rdp)
                    echo "${bold}${green}You have selected RDP (port 3389).${normal}"
                    if [[ -z $check_rdp ]]; then
                        echo "RDP service is not open. Please select another service."
                    fi
                ;;
                
                *) 
                    echo "${red}ERROR! Invalid option. Choose again.${normal}"
                    continue
                ;;
            esac

            #user input, confirm choice
            read -e -r -p "${bold}[!] Confrim choice '$choice_service' ? [y/n]: ${normal}" input_yn
            if [[ $input_yn == n ]]; then
                echo "Pls enter new choice."
                continue
            elif [[ $input_yn == y ]]; then
                echo "${bold}${green}Proceeding to next step.${normal}"

                sleep 2

                hydra-scan
            else
                echo "${red}Pls re-enter choice. 'y' or 'n'${normal}"
            fi
        fi
        break
    done

}

# ██   ██ ██    ██ ██████  ██████   █████  
# ██   ██  ██  ██  ██   ██ ██   ██ ██   ██ 
# ███████   ████   ██   ██ ██████  ███████ 
# ██   ██    ██    ██   ██ ██   ██ ██   ██ 
# ██   ██    ██    ██████  ██   ██ ██   ██ 

hydra-scan() {

    echo "
${bold}[*] STEP 05d: Scanning weak passwords.${normal}
This may take a few minutes...
"

    filename_hydra="$input_foldername/scan-hydra.txt"

    ftp_ver="21/open/tcp//ftp//"
    ssh_ver="22/open/tcp//ssh//"
    telnet_ver="23/open/tcp//telnet//"
    rdp_ver="3389/open/tcp//rdp//"

    if [[ $choice_service == 'ftp' ]]; then
        service_grepfilter=$ftp_ver
    elif [[ $choice_service == 'ssh' ]]; then
        service_grepfilter=$ssh_ver
    elif [[ $choice_service == 'telnet' ]]; then
        service_grepfilter=$telnet_ver
    elif [[ $choice_service == 'rdp' ]]; then
        service_grepfilter=$rdp_ver
    fi

    check_service_hosts=$(cat $filename_openports | grep "$service_grepfilter" | awk '{print $4}')

    #if user selected FTP
    #hydra use FTP service
    #hydra use FTP host list WITH LOOP

    for hosts_to_scan_single in $check_service_hosts; do

        echo "Now scanning host: $hosts_to_scan_single..."

        #hydra -L <user list> -P <pass list> <host> <service> -o <output filename>
        
        hydra -L $input_userlist -P $confirmed_passlst_innewfolder $hosts_to_scan_single $choice_service -o $filename_hydra &>/dev/null

    done

    #filter show successful results ONLY from this latest scan.
    # tac   Write each FILE to standard output, last line first.
    # awk   find latest occurance of '#' then print that line until the last line of file.
    hydra_found_this_scan=$(tac $filename_hydra | awk '!flag; /#/{flag = 1};' | tac)

    hydra_found_thisscan_pass=$(echo "$hydra_found_this_scan" | grep "password:" )

    echo "$hydra_found_this_scan"
    if [[ -z $hydra_found_thisscan_pass ]]; then
        echo "Completed. No password found."
    fi

    echo "${bold}${green}Weak passwords scan report has been saved to '$filename_hydra'.${normal}"

    #ASK IF WANT TO SCAN ANOTHER SERVICE, OR PROCEED TO NEXT STEP
    echo
    echo "${bold}[*] Do you want to scan another service? Or proceed to next step?${normal}
    1) Scan another service
    2) Proceed to next step
    "

    read -e -r -p "${bold}[+] Input 1 or 2: ${normal}" input_go_no
    case $input_go_no in
        1)
            echo "Chose to scan another service."

            sleep 1

            hydra-choice-service
        ;;
        2)
            echo "Chose to proceed to next step."

            sleep 1

            report
        ;;
        *)
            echo "${red}ERROR! Invalid option. Choose again.${normal}"
        ;;
    esac
}

#  ██████   ██████  
# ██  ████ ██       
# ██ ██ ██ ███████  
# ████  ██ ██    ██ 
#  ██████   ██████  

# ===== STEP 06: FINISHED SCAN. SUMMARY + SEARCH + ZIP OPTION ========== ========== ========== ========== ========== ========== ========== #
# 4.2 At the end, show the user the found information.
# 4.3 Allow the user to search inside the results.
# 4.4 Allow to save all results into a Zip file.

# ██████  ███████ ██████   ██████  ██████  ████████ 
# ██   ██ ██      ██   ██ ██    ██ ██   ██    ██    
# ██████  █████   ██████  ██    ██ ██████     ██    
# ██   ██ ██      ██      ██    ██ ██   ██    ██    
# ██   ██ ███████ ██       ██████  ██   ██    ██    

report() {

    hydra_found_all_pass=$(cat $filename_hydra | grep "password:" | sort | uniq )

    echo "
${bold}[*] STEP 06: [LAST STEP] Summary of findings.${normal}
"

    sleep 1

    #summary report filename
    summary_filepath="$input_foldername/summary-report.txt"

    # ===== CREATE A SUMMARY ===== #

    summarycontent="
===== SUMMARISED REPORT ==========================

[*] Basic or Full scan: $choice_basic_full
[*] Username provided:  $confirmed_userlist_innewfolder
[*] Password list used: $confirmed_passlst_innewfolder

==================================================

[*] Network scanned:    $confirmed_network
[*] No. of hosts up:    $hosts_to_scan_num

[*] List of up hosts:
$hosts_to_scan

[*] Found weak passwords:
$hydra_found_all_pass

==================================================

[*] Network reports saved to folder:        $input_foldername

    Report for hosts detected:              $filename_hosts
    Report for open ports detected:         $filename_openports

    Report for TCP ports service versions:  $filename_tcp
    Report for UDP ports service versions:  $filename_udp

        - Read the .html for results organised neatly and formatted in a webpage.
        - Read the .nmap for a simple list formatted in plain text.

    Report for vulns on TCP ports:          $filename_nse_tcp
    Report for vulns on UDP ports:          $filename_nse_udp
    
    Report for weak passwords scan:         $filename_hydra

===== END OF SUMMARISED REPORT ===================
"
    
    # ===== SAVE SUMMARY TO FILE ===== #

    #save a short summary of results to a text file
    echo "$summarycontent" > $summary_filepath

    echo "${bold}${green}Summary report has been saved to '$input_foldername'.${normal}"

    sleep 2
    
    # ===== ASK IF WANT TO OPEN FOLDER OF REPORTS ===== #

    #pwd current directory, -P absolute filepath, + folder name for reports
    absolute_filepath=$(echo "$(pwd -P)/$input_foldername" )

    echo "
All scans have been completed and saved in: $absolute_filepath
You may browse the full reports for more details.
"

    sleep 2
    
    while true; do
        read -e -r -p "${bold}[!] Open directory of reports '$input_foldername' now? ${bold}[y/n]: ${normal}" input_yn
        sleep 1
        if [[ $input_yn == "n" ]]; then
            echo "Skipped."

            sleep 2

        elif [[ $input_yn == "y" ]]; then
            echo "${bold}${green}Opening directory...${normal}"

            sleep 2

            open $input_foldername

            sleep 5

        else
            echo "${red}Unknown entry. Pls input 'y' or 'n'.${normal}"
            continue
        fi
        break
    done

    # ===== ZIP FILES ===== #
    echo ""
    echo "Folder of reports will also be saved as a ZIP for portability."
    echo "Saving..."

    sleep 2
    
    zip $input_foldername.zip $input_foldername/* &>/dev/null

    echo "${bold}${green}Folder of scan reports '$input_foldername' has been compressed into a ZIP.${normal}"

    sleep 2
    
    #open current directory, to see zip file
    while true; do
        read -e -r -p "${bold}[!] Open directory of ZIP file now? ${bold}[y/n]: ${normal}" input_yn
        sleep 1
        if [[ $input_yn == "n" ]]; then
            echo "Skipped."

            sleep 2

        elif [[ $input_yn == "y" ]]; then
            echo "${bold}${green}Opening directory...${normal}"

            sleep 2

            open .

            sleep 5

        else
            echo "${red}Unknown entry. Pls input 'y' or 'n'.${normal}"
            continue
        fi
        break
    done

    sleep 2
    
    echo "
${bold}***** All functions completed. Goodbye. *****${normal}
"

}


network-choose


#End of script.