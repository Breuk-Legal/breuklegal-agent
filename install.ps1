# Breuk Agent — Windows
#
#   irm https://breuklegal.com/install.ps1 | iex
#
# Windows is not published yet. This script exists so the documented one-liner
# says so plainly instead of failing on a download that does not exist.
#
# Everything lives inside a function because the script runs through `iex`: a
# bare `exit` would close the user's PowerShell window instead of ending the
# script.

function Install-BreukAgent {
    Write-Host ""
    Write-Host "Breuk Agent is not published for Windows yet." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "It is coming. Today the application is published for Linux x86_64:"
    Write-Host "  curl -fsSL https://breuklegal.com/install.sh | bash"
    Write-Host ""
    Write-Host "Write to us at https://breuklegal.com if you need Windows —"
    Write-Host "knowing how many people ask is what moves the date."
    Write-Host ""
}

Install-BreukAgent
