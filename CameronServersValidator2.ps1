$ServerListFileAIX = "ipInputAIX.txt" 
$ServerListFileLINUX = "ipInputLINUX.txt"
$ServerListFileAll = "ipInputAll.txt"
#IP list files by Server Type

$count = 0
#server counter which are listed in Server list spreadsheet (not included in this automation)
clear

#function validateServer($option) validates the server type selected from optionSwitch()
#function optionSwitch() waits for server option to validate
#function endOfScript($bool) output the servers which the user informed has NO access

function optionSwitch(){
    echo "#############################################"
    echo "##                                         ##"
    echo "##    AIX-LINUX Login validator - v1.1     ##"
    echo "##                                         ##"
    echo "##                                         ##"
    echo "#############################################"
    echo ""
    echo "Please select Operational system:" #as LINUX and AIX are used to be diferent
    echo ""
    echo "  1 - AIX" 
    echo "  2 - LINUX" 
    echo "  3 - AIX and LINUX"
    echo ""
    $option = Read-Host 'Option'

    switch -Wildcard ($option)
        {
            '1'
            {
                echo "AIX"
                validateServer($option)
                endOfScript($x)
            }
            '2'
            {
                echo "LINUX"
                validateServer($option)
                endOfScript($x)
            }
            '3'
            {
                echo "AIX and LINUX"
                validateServer($option)
                endOfScript($x)
            }
            default
            {
                endOfScript($FALSE)
            }
        }

}

function validateServer($option) { 
    if($option -eq 1){
        $ServerList = Get-Content $ServerListFileAIX -ErrorAction SilentlyContinue
        $serverType = "AIX" 
        #loads $ServerListFileAIX to  $ServerList so the function only loads AIX servers IP
    }elseif($option -eq 2){
        $ServerList = Get-Content $ServerListFileLINUX -ErrorAction SilentlyContinue
        $serverType = "LINUX"
        $count = 63 #linux starts with 64
        #loads $ServerListFileLINUX to  $ServerList so the function only loads LINUX servers IP
    }elseif($option -eq 3){
        $ServerList = Get-Content $ServerListFileAll -ErrorAction SilentlyContinue
        $serverType = "AIX & LINUX"
        #loads $ServerListFileAll to $ServerList so the function only loads AIX and LINUX servers IP
    }else{ 
        $serverType = "wrong"
    }

    clear 

    if($serverType -ne "wrong"){
        echo "User and Password for *$serverType Servers* **Socks must be enabled"
        echo ""
        Clear-Content -path * -filter output.txt –force #clear previous outputs in output.txt file

        $userC = Read-Host 'User' 
        #gets cameron aix or linux username from the prompt

        $securePwd = Read-Host "Password" -AsSecureString 
        #gets password from secured prompt *****

        $passwordC =[Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($securePwd)) 
        #gets password which were provided by the secured prompt ***** and convert it to a string so can be loaded to the servers

        ForEach($server in $ServerList){ #run the commands below in each server ip provided on "input.txt" file

            .\plink -ssh $server -l $userC -pw $passwordC -m commands.sh -batch | Out-Default -OutVariable sv 
            # log with the user and password provided via prompt which were loaded in $userC and $passwordC variables

            if ( $sv -ne "check" ) 
            # checks if the server was already loggedin, 
            # if not it ++$count and return the 'hostname' command output (provided by commands.sh file) 
            { 
                #$count = $count + 1
                $sv = "check" 
            }else{ 
            # if yes goes to else condition and inform server spreadsheet position: '$count'
                #$count = $count + 1
                echo "Server IP: $server - NO access " | Out-File -append output.txt 
                #load the server IP '$server' to 'output.txt' file
            }    
        }
    }
}

function endOfScript($bool){
    if($bool -eq $FALSE){ #In case selects a invalid option, reruns the optionSwitch function until provided a valid option
        clear
        echo ""
        echo "******Please select a valid option******"
        echo ""
        optionSwitch($TRUE) #$TRUE value has no meaning, set just to call the optionSwitch function
    }else{
        $output = "output.txt" #loads the file to be updated 
        $ServerListOutput = Get-Content $output -ErrorAction SilentlyContinue #update the file loaded
        clear
        echo ""
        echo "Servers with NO access:"
        echo ""
        ForEach($server in $ServerListOutput){
            echo " >>> $server" #echo every line of the file loaded and updated
        }
        echo ""
        Read-Host 'THE END'
    }
}

optionSwitch($option)
validateServer($option) #loads validation function providing the server option

clear
