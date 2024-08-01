# VulnScan  
A Bash CLI script to automate mapping the network for open ports and their service versions, and CVES related to them. As well as weak login passwords for login services.  
All results are logged, and a summary report is generated at the end.  
Tested on Kali Linux.  

## How to Use  
In linux terminal, enter `bash vuln-scan.sh`  
  
## Content Structure  
1. Get a network to scan. Choose auto-detect your machine's network, or input.  
2. Get a name to create a new folder. Create the new folder.  
3. Choose basic or full scan.  
4. Scan network  
    a. Nmap host discovery scan. Save the result to a text file.  
    b. Masscan open ports scan. Save the result to a text file.  
    c. Nmap TCP ports service versions. Save the result to files, plain text and html.  
    d. Nmap UDP ports service versions. Save the result to a file, plain text and html.  
    e. (For full scan option) NSE TCP ports vulners scan. Save the result to a file, plain text and html.  
    f. (For full scan option) NSE UDP ports vulners scan. Save the result to a file, plain text and html.  
5. Scan weak passwords  
    a. Get a password list. Choose default or input. Save/copy the file to the created folder.  
    b. Get a username list. Save/copy the file to the created folder.  
    c. Choose login service to scan. Choose FTP, SSH, TELNET, or RDP.  
    d. Hydra scan using saved inputs. Save the result to a file.  
    e. Allow option to scan another login service, or proceed to next step.  
7. Summary  
    a. Save summary to a file.  
    b. Zip the entire folder.  
  
## Output  
Choosing detect for step 1  
![image of detect network](output_imgs/01-detect.png "detect network")  
Choosing input for step 1  
![image of input network](output_imgs/01-input.png "input network")  
Step 2  
![image of input folder name](output_imgs/02-folder.png "input folder name")  
Choosing full scan for step 3  
![image of choose full scan](output_imgs/03-full.png "choose full scan")  
Step 4abcd  
![image of scanning](output_imgs/04abc-host-masscan-tcp.png "scanning")  
![image of scanning2](output_imgs/04d-udp.png "scanning2")  
Step 4ef (only for full scan)  
![image of nse scan](output_imgs/04ef-nsetcp-nseudp.png "nse scan")  
Choosing input for step 5a  
![image of input pass file](output_imgs/05a-pass-input.png "input pass file")  
Step 5b  
![image of input user file](output_imgs/05b-userinput.png "input user file")  
Step 5c  
![image of choose login service](output_imgs/05c-loginservice.png "choose login service")  
Step 5d
![image of hydra scan](output_imgs/05d-hydra.png "hydra scan")  
![image of hydra scan](output_imgs/05d-hydra-result2.png "hydra scan")  
![image of hydra input choice](output_imgs/05d-hydra2.png "hydra input choice")  
Step 6  
![image of summary](output_imgs/06-summary.png "summary")  
Sample files output into newly created folder    
![image of files](output_imgs/07-folder.png "files")  
  
