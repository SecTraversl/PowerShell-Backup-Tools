<#
.SYNOPSIS
  The "Backup-Ps1FilesScript" function is a specific deployment of the 'Backup-Files.ps1' function used to create an archive copy of the 'ps1_files' directory.

.EXAMPLE
  PS C:\> Backup-Ps1FilesScript -RunScript

  Creating compressed archive: 'ps1_files.zip'

  PS C:\> ls

      Directory: C:\Users\Jannus.Fugal\Documents\Temp\temp\delete-when-finished

  Mode                 LastWriteTime         Length Name
  ----                 -------------         ------ ----
  -a----        12/14/2021  11:58 AM        6552374 ps1_files.zip



  Here we run the function and in return we get a compressed copy of the 'ps1_files' directory.

.NOTES
  Name:  Backup-Ps1FilesScript.ps1
  Author:  Travis Logue
  Version History:  1.2 | 2021-12-14 | Improved documentation
  Dependencies:  Backup-Files.ps1
  Notes:
  - 

  .
#>

function Backup-Ps1FilesScript {
  [CmdletBinding()]
  param (
    [Parameter(HelpMessage = 'This is a script. If you want to run the script, use this $RunScript switch parameter')]
    [switch]
    $RunScript
  )
  
  begin {}
  
  process {

    if ($RunScript) {

      $DirectoryPath = "$HOME\Documents\Temp\ps1_files"

      if ( Test-Path $DirectoryPath -PathType Container ) {
        Backup-Files -Directory $DirectoryPath    
      }
      else {
        Write-Host "`nCould not find the following path: '$DirectoryPath'`n" -BackgroundColor Black -ForegroundColor Yellow
      }

    }

  }
  
  end {}

}

