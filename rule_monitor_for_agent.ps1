# https://social.technet.microsoft.com/Forums/en-US/06150795-6c94-4784-9132-8e5d725e0810/scom-2016-list-all-monitors-rules-for-a-given-agent-using-powershell?forum=operationsmanagergeneral#dacdf892-01ba-4602-a110-17bfab926198

param (
[Parameter(Mandatory=$true)][string]$computer,
[Parameter(Mandatory=$true)][string]$scom
 )

$array =@()
$path = "C:\Temp\"

Write-Host -ForegroundColor Yellow "Creating folder path $path ..."
If (!(Test-Path -Path $path)) {New-Item $path -Type Directory}

Write-Host -ForegroundColor Yellow "Connecting to management group..."
New-SCOMManagementGroupConnection -ComputerName $scom #-Credential (Get-Credential) #Uncomment -Credential to get prompted for credentials

Write-Host -ForegroundColor Yellow "Retrieving configuration for $computer..."
$class = Get-SCOMClass -Name "Microsoft.Windows.Computer"
$members= Get-SCOMClassInstance -Class $class | Where-Object {$_.DisplayName -eq $computer}
$members | ForEach-Object { Export-SCOMEffectiveMonitoringConfiguration –Instance $_ -Path ($path + "$computer.csv") –RecurseContainedObjects }

Write-Host -ForegroundColor Yellow "Building array..."
$lines = Get-Content ($path + "$computer.csv")

ForEach ($line in $lines) {

    	ForEach ($field in $line)
		
		{
		
		$Values = $field.Split('|')
        $Monitor = Get-SCOMMonitor -Name $Values[2]
        $Rule = Get-SCOMRule -Name $Values[2]
		$object = New-Object –TypeName PSObject
		$object | Add-Member –MemberType NoteProperty –Name Class –Value $Values[0].Replace('"','')
		$object | Add-Member –MemberType NoteProperty –Name InstanceName –Value $Values[1]
		$object | Add-Member –MemberType NoteProperty –Name Monitor –Value $Monitor.DisplayName
        $object | Add-Member –MemberType NoteProperty –Name Rule –Value $Rule.DisplayName
		$object | Add-Member –MemberType NoteProperty –Name Enabled –Value $Values[3]
		$object | Add-Member –MemberType NoteProperty –Name GeneratesAlert –Value $Values[4]
		$object | Add-Member –MemberType NoteProperty –Name AlertSeverity –Value $Values[5]
		$object | Add-Member –MemberType NoteProperty –Name AlertPriority –Value $Values[6]
		$object | Add-Member –MemberType NoteProperty –Name AlertType –Value $Values[7]
		$object | Add-Member –MemberType NoteProperty –Name AlertDescription –Value $Values[8]
		$object | Add-Member –MemberType NoteProperty –Name Overriden –Value $Values[9]
		$object | Add-Member –MemberType NoteProperty –Name Parameter1 –Value $Values[10]
		$object | Add-Member –MemberType NoteProperty –Name DefaultValue1 –Value $Values[11]
		$object | Add-Member –MemberType NoteProperty –Name EffectiveValue1 –Value $Values[12]
		$object | Add-Member –MemberType NoteProperty –Name Parameter2 –Value $Values[13]
		$object | Add-Member –MemberType NoteProperty –Name DefaultValue2 –Value $Values[14]
		$object | Add-Member –MemberType NoteProperty –Name EffectiveValue2 –Value $Values[15]
		$object | Add-Member –MemberType NoteProperty –Name Parameter3 –Value $Values[16]
		$object | Add-Member –MemberType NoteProperty –Name DefaultValue3 –Value $Values[17]
		$object | Add-Member –MemberType NoteProperty –Name EffectiveValue3 –Value $Values[18]
        $object | Add-Member –MemberType NoteProperty –Name Parameter4 –Value $Values[19]
        $object | Add-Member –MemberType NoteProperty –Name DefaultValue4  –Value $Values[20]
        $object | Add-Member –MemberType NoteProperty –Name EffectiveValue4 –Value $Values[21]
		$array += $object
		
		}
}

Write-Host -ForegroundColor Yellow "Dumping data.."
$array | Out-Gridview
