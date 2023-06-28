param(
    [Parameter(Mandatory=$true)]
    [ValidateScript({Test-Path $_ -PathType 'Container'})]
    [string]$DirectoryPath
)

Function CheckExif {
    param(
        [Parameter(Mandatory=$true)]
        [string]$FilePath
    )

    if ($FilePath -match '\.(jpg|png|JPG)') {
        $directory = $PSScriptRoot
        $exePath = Join-Path $directory "exiftool.exe"
        
        $pinfo = New-Object System.Diagnostics.ProcessStartInfo
        $pinfo.FileName = $exePath
        $pinfo.RedirectStandardOutput = $true
        $pinfo.UseShellExecute = $false
        $pinfo.Arguments = "`"$FilePath`""
        $p = New-Object System.Diagnostics.Process
        $p.StartInfo = $pinfo
        $p.Start() | Out-Null
        $stdout = $p.StandardOutput.ReadToEnd()
        $p.WaitForExit()

        # echo $stdout
        # echo $stderr
        $pattern = "(Create\s+Date|Date/Time\s+Original)\s+:\s+(20\d\d):(\d\d):(\d\d)\s+(\d\d):(\d\d):(\d\d)"
        $match = [regex]::Match($stdout, $pattern)
        if ($match.Success) {
            $year = $match.Groups[2].Value
            $month = $match.Groups[3].Value
            $day = $match.Groups[4].Value
            $hour = $match.Groups[5].Value
            $minute = $match.Groups[6].Value
            $second = $match.Groups[7].Value
            Set-ItemProperty -Path $FilePath -Name LastWriteTime -Value "$year/$month/$day ${hour}:${minute}:${second}"
            return $true
        }
    }
    return $false
}

Function Update-Time {
    param(
        [Parameter(Mandatory=$true)]
        [string]$FilePath,
        [Datetime]$DateTime
    )

    $formattedTime = ($DateTime).ToString("yyyy/MM/dd HH:mm:ss")
    # $directory = $PSScriptRoot
    # $exePath = Join-Path $directory "exiftool.exe"
    # $arguments = "-DateTimeOriginal=`"$formattedTime`"","`"$FilePath`"","-overwrite_original"
    # Start-Process -FilePath $exePath -ArgumentList $arguments -Wait -NoNewWindow
    Set-ItemProperty -Path $FilePath -Name LastWriteTime -Value $formattedTime
}

Function Update-FileModificationTime {
    param(
        [Parameter(Mandatory=$true)]
        [string]$FilePath
    )

    echo $FilePath
    $exifResult = CheckExif -FilePath $FilePath
    if ($exifResult) {
        return
    }

    # unix time with milisec
    $pattern = "\\(\d+)\.(jpg|png|mp4)"
    $match = [regex]::Match($FilePath, $pattern)
    if ($match.Success) {
        $unixTimeMs = $match.Groups[1].Value
        $unixTimeSec = $unixTimeMs / 1000
        $dateTime = (Get-Date 01.01.1970).AddSeconds($unixTimeSec)

        Update-Time -FilePath $FilePath -DateTime $dateTime
        return
    }

    # include datetime
    $pattern = "(20[12]\d\d{4})[-_]?(\d{6}).*\.(jpg|png|mp4)"
    $match = [regex]::Match($FilePath, $pattern)
    if ($match.Success) {
        $date = $match.Groups[1].Value
        $time = $match.Groups[2].Value
        $dateTime = [Datetime]::ParseExact("$date $time", 'yyyyMMdd HHmmss', $null)

        Update-Time -FilePath $FilePath -DateTime $dateTime
        return
    }
}

# Recursively search for .jpg and .png files in the specified directory
Get-ChildItem $DirectoryPath -Recurse -File | ForEach-Object {
    Update-FileModificationTime -FilePath $_.FullName
}
