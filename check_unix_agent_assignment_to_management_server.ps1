$GetTLMEfromPoolTask = Get-SCOMTask -Displayname "Get Top Level Instances Monitored By A Pool Member"
$HealthServiceClass = Get-SCOMClass -Name "Microsoft.SystemCenter.HealthService"
$ResourcePools = Get-SCOMResourcePool  | ? { $_.DisplayName -eq "Unix/Linux Resource Pool" }
$TLMEInstances = @()
foreach($pool in $ResourcePools)
{
    foreach($ms in $pool.Members)
    {
        $hs = Get-SCOMClassInstance -Class $HealthServiceClass | ? { $_.DisplayName -eq $ms.DisplayName }
        $param = @{
            PoolId = $pool.Id.ToString()
        }
        $out = Start-SCOMTask -Task $GetTLMEfromPoolTask -Instance $hs -Override $param -ErrorAction SilentlyContinue
        do
        {
            $batch = $out.BatchId
            Start-Sleep -Seconds 3
        }
        while ($batch -eq $null)
        do
        {
            $result = Get-SCOMTaskResult -BatchId $batch -ErrorAction SilentlyContinue
            $status = $result.Status
            Start-Sleep -Seconds 5
        }
        while($status -eq "Started")
        [xml]$output = $result.Output
        if($output -ne $null)
        {
            $TLMEs = $output.SelectNodes("//ManagedEntity")
            foreach($TLME in $TLMEs)
            {
                $TLMEInstance = Get-SCOMClassInstance -Id $TLME.GetAttribute("managedEntityId")
                $TLMEClass = Get-SCOMClass -Id $TLMEInstance.MonitoringClassIds
                $hash = @{
                    ResourcePool = $pool.DisplayName
                    ManagementServer = $ms.DisplayName
                    TLMEFullName = $TLMEInstance.FullName
                    TLMEDisplayName = $TLMEInstance.DisplayName
                    TLMEClass = $TLMEClass
                    TLMEId = $TLMEInstance.Id
                }
                $obj = New-Object PSObject -Property $hash
                $TLMEInstances += $obj
            }
        }
    }
}
$TLMEInstances | Sort-Object ResourcePool, ManagementServer, TLMEClass | Out-GridView
