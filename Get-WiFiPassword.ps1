function Get-WiFiPassword {
    param (
        $SSID
    )

    if ($SSID) {

        $profile = Invoke-Expression "netsh.exe wlan show profiles name='$ssid' key=clear"

        if ($profile -like '*not found on the system*') {
            Write-Error "$SSID SSID does not exist" -ErrorAction 'Stop'
        }

        if ($password = $profile | Select-String 'Key Content') {

            [PSCustomObject]@{
                SSID     = $ssid
                Password = ($password -split ':')[-1].Trim()
            }

        } else {

            [PSCustomObject]@{
                SSID     = $ssid
                Password = 'No Password'
            }
        }

    } else {

        $profiles = (Invoke-Expression 'netsh.exe wlan show profiles' | Select-String 'All User Profile') -split ':'

        $ssids = foreach ($profile in $profiles) {
            if ($profile -notlike '*All User Profile*') {

                $profile.Trim()
            }
        }

        $output = foreach ($ssid in $ssids) {
            $password = Invoke-Expression "netsh.exe wlan show profiles name='$ssid' key=clear" | Select-String 'Key Content'

            if ($password) {

                [PSCustomObject]@{
                    SSID     = $ssid
                    Password = ($password -split ':')[-1].Trim()
                }

            } else {
                [PSCustomObject]@{
                    SSID     = $ssid
                    Password = ''
                }
            }
        }
    }
    $output
}