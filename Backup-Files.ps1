
<#
.SYNOPSIS
  The "Backup-Files" function creates a compressed copy of a given directory. If a compressed copy (the default name used is $Directory.zip) already exists, this code will recurse the directory and if any of the LastWriteTime stamps are greater than the LastWriteTime of the compressed copy - then a backup copy will be created called (.old.zip) and a compressed copy of the directory (the designated $Directory) will again be created (with the default name of $Directory.zip)

.EXAMPLE
  PS C:\> ls

  Directory: C:\Users\super.user\Documents\Temp\temp\TryAgain

  Mode                LastWriteTime         Length Name
  ----                -------------         ------ ----
  d-----       10/21/2020   1:39 PM                ps1_files

  PS C:\> Backup-Files .\ps1_files\ -ZipFileName bubba.zip
  PS C:\> ls

    Directory: C:\Users\super.user\Documents\Temp\temp\TryAgain

  Mode                LastWriteTime         Length Name
  ----                -------------         ------ ----
  d-----       10/21/2020   1:39 PM                ps1_files
  -a----       10/21/2020   1:47 PM         934166 bubba.zip


  Here we specified the directory we wanted to bakup, and the name that we wanted to call the backup (we overrode the default value, which would have been "ps1_files.zip") using the parameter "-ZipFileName"


.EXAMPLE

  PS C:\> 'blah' > .\ps1_files\DJSJSJS.TXT
  PS C:\>
  PS C:\> Backup-Files .\ps1_files\ -ZipFileName bubba.zip
  ...New or updated files exist... Creating new Backup

  The following are the new/updated file(s):

  FullName                                                                 LastWriteTime
  --------                                                                 -------------
  C:\Users\super.user\Documents\Temp\temp\TryAgain\ps1_files\DJSJSJS.TXT 10/21/2020 1:47:59 PM


  PS C:\> ls

    Directory: C:\Users\super.user\Documents\Temp\temp\TryAgain


  Mode                LastWriteTime         Length Name
  ----                -------------         ------ ----
  d-----       10/21/2020   1:47 PM                ps1_files
  -a----       10/21/2020   1:47 PM         934166 bubba.old.zip
  -a----       10/21/2020   1:48 PM         934300 bubba.zip


  Here we added a file to the directory, then ran the function again. Once again, we specified the name of the backup, and because a ".zip" by that name already existed, the code recursively searched for Files/Folders within the $Directory to see if the LastWriteTime on any of those objects was greater than the ".zip" file.  There was one file (the one we just created) and that gets listed at the end.  We see that the previous ".zip" was renamed to ".old.zip" and the most recent backup gets saved as ".zip" 

.NOTES
  Name:  Backup-Files.ps1
  Author:  Travis Logue
  Version History:  1.7 | 2021-12-14 | Improved documentation
  Dependencies:  
  Notes:
  -   I was getting this error when trying to 'write over' the existing .old.zip with the newer archive - "Rename-Item : Cannot create a file when that file already exists."  This was helpful in understaning that "Move-Item -Force" was likely the cmdlet that I was after. https://stackoverflow.com/questions/32311875/rename-item-and-override-if-filename-exists


  .
#>
function Backup-Files {
  [CmdletBinding()]
  param (
    [Parameter(HelpMessage = 'Reference the directory to archive to a .zip file',Mandatory=$true)]
    [psobject]
    $Directory,
    [Parameter(HelpMessage='Reference the destination path and file name for the .zip file. DEFAULT name will simply be "$Directory.zip"')]
    [psobject]
    $ZipFileName,
    [Parameter(HelpMessage='*NOTE*: This is a faster way to run this function. Using this switch parameter your $Directory name will be embedded within the $ZipFileName archive along with all of the Child Items underneath the $Directory.  If you do not use this switch parameter then the function defaults to recursing the Child Items within $Directory, compressing and storing those in the $ZipFileName you specified.')]
    [switch]
    $EmbedFolderInArchive
  )
  
  begin {}
  
  process {

    # If the $Directory object is a Directory, then...
    if (Test-Path -PathType Container $Directory ) {
      
      # Get the objects so that we can wield them...
      $DirItem = Get-Item -Path $Directory 

      if ( -not ($ZipFileName)) {
        $ZipFileName = "$($DirItem.Name).zip"
      }

      # If the $ZipFileName does not exist: Create a compressed file of the $Directory
      # *NOTE* - Compress-Archive will automatically append ".zip" if it is not present - see "help Compress-Archive -Examples"
      if ( -not (Test-Path -PathType Leaf $ZipFileName)) {
        Compress-Archive -Path "$Directory\*" -DestinationPath $ZipFileName
        Write-Host "`nCreating compressed archive: '$ZipFileName' `n" -BackgroundColor Black -ForegroundColor Green  
      }
      else {
        $ZipFile = Get-Item -Path $ZipFileName

        # Getting all of the files and folders underneath...
        $ChildItems = Get-ChildItem -Path $DirItem -Recurse

        # Creating a new array in order to place any "new" or "updated" files into it for later use...
        $ArrayOfNewFiles = @()

        # Here we are taking each child item, looking at its last modified time and comparing that with the timestamp of the $ZipFile; if the child item is newer than the $ZipFile, we are putting that child item into the $Array we created
        $ChildItems | ForEach-Object {
          if ($_.LastWriteTime -gt $ZipFile.LastWriteTime) {
            $prop = [ordered]@{
              FullName      = $_.FullName
              LastWriteTime = $_.LastWriteTime
            }
            $obj = New-Object -TypeName psobject -Property $prop
            $ArrayOfNewFiles += $obj
          }
        }

        # If the $Array actually has items within it, then we are outputing those items, and
        if ($ArrayOfNewFiles) {
          Write-Host "...New or updated files exist... Creating new Backup`n" -ForegroundColor Green -BackgroundColor Black
          Write-Host "The following are the new/updated file(s):" -ForegroundColor Green -BackgroundColor Black          
          Write-Output $ArrayOfNewFiles

          Move-Item -Path $ZipFile -Destination "$($ZipFileName.Replace('.zip','.old.zip'))" -Force
          # Rename-Item -Path $ZipFile -NewName "$($ZipFileName.Replace('.zip','.old.zip'))" -Force ### See "Notes" section in Comment Based Help
          Compress-Archive -Path "$Directory\*" -DestinationPath $ZipFileName -Force
        }
        else {
          Write-Host "`nNo new or updated files/folders were found.  Exiting...`n" -BackgroundColor Black -ForegroundColor Green
        }
      }    

    }


  }
  
  end {}

}