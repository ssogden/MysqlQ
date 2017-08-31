. "$PSScriptRoot\Core.ps1"

#Areyousure function. Alows user to select y or n when asked to exit. Y exits and N returns to main menu.  
 function areyousure {$areyousure = read-host "Are you sure you want to exit? (y/n)"  
           if ($areyousure -eq "y"){exit}  
           if ($areyousure -eq "n"){mainmenu}  
           else {write-host -foregroundcolor red "Invalid Selection"   
                 areyousure  
                }  
                     }

 #Mainmenu function. Contains the screen output for the menu and waits for and handles user input. 
 Function mainmenu{  
 cls  
 echo "---------------------------------------------------------"
 echo ""
 echo ""  
 echo "    1. Enter DB Credentials"
 echo "    2. Top 10 Domains"
 echo "    3. Top 10 Logs"
 echo "    4. Exit"  
 echo ""  
 echo ""  
 echo "---------------------------------------------------------"  
 $answer = read-host "Please Make a Selection"  
 
 
 
 if ($answer -eq 1){dbDetails; mainmenu}
 elseif ($answer -eq 2){Run-TopTenDomains; mainmenu}
 elseif ($answer -eq 3){Run-TopTenLogs; mainmenu} 
 elseif ($answer -eq 4){areyousure; mainmenu}
 else {write-host -ForegroundColor red "Invalid Selection"  
       sleep 3  
       mainmenu
      }  
                
}

mainmenu