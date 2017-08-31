Function Pause($M="Press any key to continue . . . "){If($psISE){$S=New-Object -ComObject "WScript.Shell";$B=$S.Popup("Click OK to continue.",0,"Script Paused",0);Return};Write-Host -NoNewline $M;$I=16,17,18,20,91,92,93,144,145,166,167,168,169,170,171,172,173,174,175,176,177,178,179,180,181,182,183;While($K.VirtualKeyCode -Eq $Null -Or $I -Contains $K.VirtualKeyCode){$K=$Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")};Write-Host}

Function dbDetails{

    #$script:dbServer = Read-Host "Enter Server IP "
    #$script:dbName = Read-Host "Ener Database Name "
    $script:mysqlserver = Read-Host "Enter Mysql Server "
    $script:username = Read-Host "Enter Database UserName "
    $securepassword = Read-Host -Prompt "Enter Database password " -AsSecureString
    $credentials = New-Object System.Management.Automation.PSCredential `
        -ArgumentList $username, $Securepassword

    $script:plainpassword = $credentials.GetNetworkCredential().Password
}



Function Run-MySQLCustom{
<#
.DESCRIPTION
    By Default this section will use the test dabase and run an user generated MySQL Query
    
.EXAMPLE
    C:\PS> select * from domain_current where server = 'web01' order by spaceused desc limit 10;
#>
    $myQuery = Read-Host "Enter Custom Query "

    run-MySQLQuery -ConnectionString "server=$mysqlserver;Uid=$userName;Pwd=$plainpassword;database=$dbname;" -Query "$myquery"

    Pause
}

Function Run-TopTenDomains{
<#
.DESCRIPTION
    This Will Search the top 10 Domains by space used across all servers
#>
    $SelectServer = Read-Host "Enter Server eg. web01: "

    run-MySQLQuery -ConnectionString "server=$mysqlserver;Uid=$userName;Pwd=$plainpassword;database=serverspace;" -Query "select * from domain_current where server = '$selectServer' order by logfiles desc limit 10;"

    Pause
}


Function Run-TopTenLogs{
<#
.DESCRIPTION
    This Will Search the top 10 Domains by space used across a specific server
#>
    $SelectServer = Read-Host "Enter Server eg. web01: "

    run-MySQLQuery -ConnectionString "server=$mysqlserver;Uid=$userName;Pwd=$plainpassword;database=serverspace;" -Query "select * from domain_current where server = '$selectServer' order by spaceused desc limit 10;"

    Pause
}


Function Run-MySQLQuery {
<#
.SYNOPSIS
   run-MySQLQuery
    
.DESCRIPTION
   By default, this script will:
    - Will open a MySQL Connection
	- Will Send a Command to a MySQL Server
	- Will close the MySQL Connection
	This function uses the MySQL .NET Connector or MySQL.Data.dll file
     
.PARAMETER ConnectionString
    Adds the MySQL Connection String for the specific MySQL Server
     
.PARAMETER Query
 
    The MySQL Query which should be send to the MySQL Server
	
.EXAMPLE
    C:\PS> run-MySQLQuery -ConnectionString "Server=localhost;Uid=root;Pwd=p@ssword;database=project;" -Query "SELECT * FROM firsttest" 
    
    Description
    -----------
    This command run the MySQL Query "SELECT * FROM firsttest" 
	to the MySQL Server "localhost" with the Credentials User: Root and password: p@ssword and selects the database project
         
.EXAMPLE
    C:\PS> run-MySQLQuery -ConnectionString "Server=localhost;Uid=root;Pwd=p@ssword;database=project;" -Query "UPDATE firsttest SET firstname='Thomas' WHERE Firstname like 'PAUL'" 
    
    Description
    -----------
    This command run the MySQL Query "UPDATE project.firsttest SET firstname='Thomas' WHERE Firstname like 'PAUL'" 
	to the MySQL Server "localhost" with the Credentials User: Root and password: p@ssword
	
.EXAMPLE
    C:\PS> run-MySQLQuery -ConnectionString "Server=localhost;Uid=root;Pwd=p@ssword;" -Query "UPDATE project.firsttest SET firstname='Thomas' WHERE Firstname like 'PAUL'" 
    
    Description
    -----------
    This command run the MySQL Query "UPDATE project.firsttest SET firstname='Thomas' WHERE Firstname like 'PAUL'" 
	to the MySQL Server "localhost" with the Credentials User: Root and password: p@ssword and selects the database project
    
#>
	Param(
        [Parameter(
            Mandatory = $true,
            ParameterSetName = '',
            ValueFromPipeline = $true)]
            [string]$query,   
		[Parameter(
            Mandatory = $true,
            ParameterSetName = '',
            ValueFromPipeline = $true)]
            [string]$connectionString
        )
	Begin {
		Write-Verbose "Starting Begin Section"		
    }
	Process {
		Write-Verbose "Starting Process Section"
		try {
			# Load MySQL driver and create connection
			Write-Verbose "Create Database Connection"
			# Link to the DLL File
            $mySQLDataDLL = "$PSScriptRoot\Assemblies\v4.5\MySQL.Data.dll"
			[void][system.reflection.Assembly]::LoadFrom($mySQLDataDLL)
			#[void][System.Reflection.Assembly]::LoadWithPartialName("MySql.Data")
            #[void][System.Reflection.Assembly]::LoadWithPartialName("MySql.Data")
			$connection = New-Object MySql.Data.MySqlClient.MySqlConnection
			$connection.ConnectionString = $ConnectionString
			Write-Verbose "Open Database Connection"
			$connection.Open()
			
			# Run MySQL Querys
			Write-Verbose "Running MySQL Query $myQuery"
			$command = New-Object MySql.Data.MySqlClient.MySqlCommand($query, $connection)
			$dataAdapter = New-Object MySql.Data.MySqlClient.MySqlDataAdapter($command)
			$dataSet = New-Object System.Data.DataSet
			$recordCount = $dataAdapter.Fill($dataSet, "data")
			$dataSet.Tables["data"] | Format-Table
		}		
		catch {
			Write-Host "Could not run MySQL Query" $Error[0]	
		}	
		Finally {
			Write-Verbose "Close Connection"
			$connection.Close()
		}
    }
	End {
		Write-Verbose "Starting End Section"
	}
}
