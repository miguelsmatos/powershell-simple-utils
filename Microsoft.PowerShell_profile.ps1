function isCurrentDirectoryGit {
	if (Test-Path ".git") {
        return $true
    }
    # should add stuff for the parent directory for later
    return $false
}

# Get git status
function gitStatusInLine{
    # initialize
    $modified = 0
    $untracked = 0
    $deleted=0
    $added=0
    # git status 
    $statusOutput = (git status --porcelain) -split "`r`n"
    # iterate all of the outputs
    $statusOutput | ForEach-Object {
        $statusId = $_.Trim()[0]
        if ($statusId -eq "M") {
            $modified += 1
        }
        elseif ($statusId -eq "D") {
            $deleted += 1
        }
        elseif ($statusId -eq "?") {
            $untracked +=1
        }
        elseif ($statusId -eq "A") {
            $added += 1
        }
    }
    if (-not ($modified+$deleted+$untracked+$added) ) {
        Write-Host(' =') -NoNewline -ForegroundColor Green
        return
    }
    if ($added) {
        Write-Host(' +' + $added) -NoNewline -ForegroundColor Green
    }
    if ($modified) {
        Write-Host(' ~' + $modified) -NoNewline -ForegroundColor Yellow
    }
    if ($deleted) {
        Write-Host(' -' + $deleted) -NoNewline -ForegroundColor Red
    }
    if ($untracked) {
        Write-Host(' ?' + $untracked) -NoNewline -ForegroundColor DarkGray
    }
}

function gitSummaryInLine{
    $gitBranch = (git rev-parse --abbrev-ref HEAD) 
    Write-Host("[") -NoNewline
    Write-Host($gitBranch) -NoNewline -ForegroundColor Cyan
    gitStatusInLine
    Write-Host("]") -NoNewline
}

function ShortPwd{
    $shortPwd = ""
    $splitPath = (Get-Location).ToString().Split('\')
    $shortPwd = $splitPath[0] + '\'
    $splitPath[1..($splitPath.Length-2)] | ForEach-Object {
        $shortPwd += $_[0] + '\'
    }
    $shortPwd += $splitPath[-1]
return $shortPwd
}

function prompt {
    $promptColor = "Cyan"
    $branchColor = "Magenta"
    $branchSymbol = "`u{E0A0}"
    if (isCurrentDirectoryGit) {
        $branchName = (git rev-parse --abbrev-ref HEAD)
        Write-Host ("PS [$env:USERNAME] " + $(ShortPwd) + " [") -NoNewLine -ForegroundColor $promptColor
        Write-Host ("$branchSymbol $branchName") -NoNewLine -ForegroundColor $branchColor
        gitStatusInLine
        Write-Host ("]>") -NoNewLine -ForegroundColor $promptColor
    } else {
        Write-Host ("PS [$env:USERNAME] " + $(ShortPwd) +">") -NoNewLine -ForegroundColor $promptColor
    }
    
    return " "
}
