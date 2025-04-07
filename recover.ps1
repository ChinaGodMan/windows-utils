function Expand-JsonFiles {
    param (
        [Parameter(Mandatory = $true)]
        [string]$BasePath,
        [Parameter(Mandatory = $true)]
        [hashtable]$Softs
    )
    foreach ($Soft in $Softs.Keys) {
        if ($Soft -in @("url", "noUnzip")) {
            continue
        }
        if ($Softs[$Soft] -is [hashtable] -and $Softs[$Soft].ContainsKey("url")) {
            $url = $Softs[$Soft]["url"]
            $fileName = [System.IO.Path]::GetFileName($url)
            if ($Softs[$Soft].ContainsKey("noUnzip") -and $Softs[$Soft]["noUnzip"]) {
                # 直接下载到基目录
                $filePath = Join-Path -Path $BasePath -ChildPath $fileName
                Invoke-WebRequest -Uri $url -OutFile $filePath
                Write-Host "已下载文件（无需解压）：$filePath"
            }
            else {
                # 对嵌套的创建子目录并解压
                # ! 这里可以保留,因为有的压缩包是嵌套压缩包,我们可以控制是否创建子目录
                $newPath = Join-Path -Path $BasePath -ChildPath $Soft
                if (-not (Test-Path $newPath)) {
                    New-Item -Path $newPath -ItemType Directory | Out-Null
                }
                $filePath = Join-Path -Path $newPath -ChildPath $fileName
                Invoke-WebRequest -Uri $url -OutFile $filePath
                Write-Host "已下载文件：$filePath"
                Write-Host "解压文件：$filePath 到目录：$newPath"
                Start-Process -FilePath "7z" -ArgumentList "x `"$filePath`" -o`"$newPath`" -y" -NoNewWindow -Wait
                Remove-Item $filePath
            }
        }
        elseif ($Softs[$Soft] -is [hashtable]) {
            $newPath = Join-Path -Path $BasePath -ChildPath $Soft
            if (-not (Test-Path $newPath)) {
                New-Item -Path $newPath -ItemType Directory | Out-Null
            }
            Expand-JsonFiles -BasePath $newPath -Softs $Softs[$Soft]
        }
        elseif ($Softs[$Soft] -is [string]) {
            $url = $Softs[$Soft]
            $fileName = [System.IO.Path]::GetFileName($url)
            $filePath = Join-Path -Path $BasePath -ChildPath $fileName
            Invoke-WebRequest -Uri $url -OutFile $filePath
            Write-Host "已下载文件：$filePath"
            Write-Host "解压文件：$filePath 到目录：$BasePath"
            Start-Process -FilePath "7z" -ArgumentList "x `"$filePath`" -o`"$BasePath\$Soft`" -y" -NoNewWindow -Wait
            Remove-Item $filePath
        }
    }
}
$Target = Get-Location
$jsonPath = "$Target\resources.json"
$Softs = Get-Content -Path $jsonPath -Raw | ConvertFrom-Json -AsHashtable -Depth 10
if (-not (Test-Path $Target)) {
    New-Item -Path $Target -ItemType Directory | Out-Null
}
Expand-JsonFiles -BasePath $Target -Softs $Softs
Write-Host "文件下载和处理完成！"
