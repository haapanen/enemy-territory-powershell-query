function Get-Status($address, $port) {
    $udpClient = New-Object System.Net.Sockets.UdpClient
    $udpClient.Client.ReceiveTimeout = 1000
    $udpClient.Connect($address, $port)
    [Byte[]] $packet = 0xff,0xff,0xff,0xff,0x67,0x65,0x74,0x73,0x74,0x61,0x74,0x75,0x73
    $udpClient.Send($packet, $packet.Length)
    $remoteIpEndpoint = [Net.EndPoint](New-Object Net.IPEndPoint($([Net.IPAddress]::Any, 0)))
    return [System.Text.Encoding]::ASCII.GetString($udpClient.Receive([Ref]$RemoteIpEndPoint))
}

function ET-Query {
    $port = 27960
    if ($args.Length -gt 1) {
        $port = $args[1] -as [int]
    }

    $status = Get-Status $args[0] $port

    $parsed = Parse-Status $status[1]

    return $parsed
}

function Print-Server-Status {
    $port = 27960
    if ($args.Length -gt 1) {
        $port = $args[1] -as [int]
    }

    $status = Get-Status $args[0] $port

    $parsed = Parse-Status $status[1]

    Write-Output "==================================================================="
    Write-Output ("Server: `t{0}" -f $parsed.sv_hostname)
    Write-Output "==================================================================="
    Write-Output ("Players: `t{0}/{1}" -f $parsed.Names.Length, $parsed.sv_maxclients)
    Write-Output "Name"
    Write-Output "==================================================================="
    foreach ($player in $parsed.Names) {
        Write-Output $player
    }
    Write-Output "==================================================================="
}

function Parse-Status($status) {
    $lines = $status.Split("`n")
    $parsed = @{}
    $parsed["Names"] = @()

    for ($i = 2; $i -lt $lines.Length - 1; $i++) {
        $parsed["Names"] += $lines[$i].Split('"')[1]
    }

    $keyValues = $lines[1].split("\")
    $key = ""
    foreach ($keyValue in $keyValues) {
        if ($key.Length -gt 0) {
            $parsed[$key] = $keyValue
            $key = ""
        } else {
            $key = $keyValue
        }
    }

    return $parsed
}
