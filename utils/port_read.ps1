$COM = [System.IO.Ports.SerialPort]::getportnames()

foreach ($PORT in $COM) {
    Write-Host $PORT
}

function read-com {
    $port= New-Object System.IO.Ports.SerialPort $COM,9600,None,8,one
    $port.Open()
    do {
        $line = $port.ReadLine()
        Write-Host $line # Do stuff here
    }
    while ($port.IsOpen)
}