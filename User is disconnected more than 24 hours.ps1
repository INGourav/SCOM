$ScomAPI        = New-Object -comObject "MOM.ScriptAPI"
$PropertyBag    = $ScomAPI.CreatePropertyBag()
 
$rawUserData    = & quser
$wellFormedData = ($rawUserData) -replace '\s{2,}',',' | ConvertFrom-Csv
$wellFormedData | Where-Object {$_.State -eq 'Disc' }
$wellFormedData | Where-Object {$_.'IDLE TIME' -ge '86400:00'}
 
$messageText    = "Found disconnected users which keeps session for long time.`n`n"
$messageText   += "Details: $($wellFormedData)"
 
$PropertyBag.AddValue("MessageText",$messageText)
 
if($wellFormedData.Count -ge 1) {
  $PropertyBag.AddValue("State","OverThreshold")
} else {
  $PropertyBag.AddValue("State","UnderThreshold")
}
            
$PropertyBag
