# taken from: https://gist.github.com/theagreeablecow/580797ac061698a6e0af
# Modified it a bit to fit needs, removed overlay option from code
#-----------------------------------------------------------------------------------------------------------
#  Set Wallpaper Variables  #
#---------------------------

#MyPics Options
[STRING]$PicturesPath = [environment]::getfolderpath("MyPictures")+"\wallpaper"
[BOOLEAN]$ResizeMyPics = $False  

#Web Options
[INT]$MaxResults = 10
[INT]$DaysBetweenSearches = 7
[BOOLEAN]$ResizeWebPics = $True
[STRING]$WebProxyServer = "your.proxy.here.lab"

#Text Overlay Options
[BOOLEAN]$TextOverlay = $True   
[STRING]$TextColour = "White"
[STRING]$FontName = "Arial"
[INT]$FontSize = 14
[BOOLEAN]$ApplyHeader = $True
[STRING]$TextAlign = "Right"
[STRING]$Position = "High"     

#Wallpaper Style Options
[STRING]$Style = "Fill"         

#Available Colours (NB. Also ensure to update the 'New-wallpaper' function with any new colours)
$Grey = @(192,192,192)
$Black = @(0,0,0)
$White = @(255,255,255)
$Red = @(220,20,60)
$Green = @(0,128,0)
$Yellow = @(255,255,0)
$Blue = @(0,0,255)
$CornflourBlue = @(100,149,237)

#----------------------------------------------------------------------------------------------------------------
#   Supporting Functions   #
#---------------------------

Function Get-MyImages {
    Param(  [Parameter()]
            [string]$Path,

            [Parameter()]
            [string]$Selection="*",
            
            [Parameter()]
            [string]$Resize=$False
    )
   
    # Check that folder exists, then select a random image
    if (Test-Path -Path $Path -pathType container) {
    
        # Resize images to match screen resolution
        if ($Resize -eq $True){
            Write-Verbose -Message "Checking picture sizes. Large images will be resized to match screen resolution" -Verbose
            Set-ImageSize $Path
        }
    
        if ($Selection -eq "*"){
            $WPRandom = Get-ChildItem -Recurse $Path | where {$_.Extension -eq ".jpg"}  | Get-Random -Count 1  
            Set-ItemProperty -path 'HKCU:\Control Panel\Desktop\' -name wallpaper -value $WPRandom.FullName 
        }
        else{
            $WPFile = $Path+"\"+$Selection
            if (Test-Path -Path $WPFile) {
                Set-ItemProperty -path 'HKCU:\Control Panel\Desktop\' -name wallpaper -value $WPFile
            } else {
                Write-Warning -Message "Failed cannot find wallpaper file $($WPFile)"
                break
            }
        }
    }
    else {
        Write-Warning -Message "Failed cannot find wallpaper folder $($Path)"
    }   
}


Function Set-WebProxy(){
    #Use this function if proxy is required for Get-GoogleImages
    $ProxyURL = "http://" + $WebProxyServer + ":8080"
    if(Test-Connection $WebProxyServer -Count 1 -Quiet){
        $global:PSDefaultParameterValues = @{
            'Invoke-RestMethod:Proxy'=$ProxyURL
            'Invoke-WebRequest:Proxy'=$ProxyURL
            '*:ProxyUseDefaultCredentials'=$true
        }
    }
}


Function Get-GoogleImages(){
    Param(  [Parameter()]
            [string]$SearchTerm="Wallpapers",
            
            [Parameter()]
            [string]$MaxResults,
            
            [Parameter()]
            [string]$DaysBetweenSearches,
            
            [Parameter()]
            [string]$Resize=$False
    )

    Try{
        # Identify Target folder and gather some stats on it
        $TargetFolder = "$($env:temp)\$SearchTerm"
        if ((Test-Path -Path $TargetFolder) -eq $false) {md $TargetFolder}
        $Folder = Get-Item $TargetFolder
        $Files = Get-ChildItem $TargetFolder | measure-Object

        # Run search if there are no previous results or if it hasn't been run for X Days
        if ($Files.count -eq 0 -OR (Get-Date).AddDays(-$DaysBetweenSearches) -gt $Folder.LastWriteTime){
            Write-Verbose -Message "The search term is new or has not been run for $DaysBetweenSearches days. Performing search for $MaxResults pictures..." -Verbose

            $url = "https://www.google.com/search?q=$SearchTerm&espv=210&es_sm=93&source=lnms&tbm=isch&sa=X&tbm=isch&tbs=isz:lt%2Cislt:2mp"
            $browserAgent = 'Mozilla/5.0 (Windows NT 6.3; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/33.0.1750.146 Safari/537.36'
            $page = Invoke-WebRequest -Uri $url -UserAgent $browserAgent
            $page.Links | Where-Object { $_.href -like '*imgres*' } | Select-Object -first $MaxResults | 
                ForEach-Object {($_.href -split 'imgurl=')[-1].Split('&')[0]} |
                    ForEach-Object {
                        $file = Split-Path -Path $_ -Leaf
                        $path = Join-Path -Path $TargetFolder -ChildPath $file
                        Invoke-WebRequest -Uri $_ -OutFile $path
                    }
         
            # Clean up any small files (usually poor resolution or a failed download)
            Get-ChildItem $TargetFolder | where-object {$_.length -lt 250kb} | Remove-item
            
            # Resize images to match screen resolution
            if ($Resize -eq $True){
                Write-Verbose -Message "Resizing pictures to match screen resolution" -Verbose
                Set-ImageSize $TargetFolder
            }
        }
        
        #Randomly select an image
        $WPRandom = Get-ChildItem -Recurse $TargetFolder | where {$_.Extension -eq ".jpg"}  | Get-Random -Count 1  
        Set-ItemProperty -path 'HKCU:\Control Panel\Desktop\' -name wallpaper -value $WPRandom.FullName 
    }
    Catch {
        Write-Warning -Message "$($_.Exception.Message)"
    }
}        


Function Set-ImageSize{
    Param(  [Parameter()]
            [string]$Directory
    )
    
    Try{
        [system.reflection.assembly]::loadWithPartialName('system.drawing.imaging') | out-null
        [system.reflection.assembly]::loadWithPartialName('system.windows.forms') | out-null
        $SR = [System.Windows.Forms.Screen]::AllScreens | Where Primary | Select -ExpandProperty Bounds | Select Width,Height
        $WidthPx = $SR.width
        $HeightPx = $SR.height

        $Files = Get-ChildItem $Directory -File | Select -exp Name
        
        foreach ($File in $Files){
            #Get Image size
            $OldImage = new-object System.Drawing.Bitmap "$Directory\$File"
            $OldWidth = $OldImage.Width
            $OldHeight = $OldImage.Height

            #Choose only images that are bigger than the screen resolution
            If ($OldWidth -ge $WidthPx -OR $OldHeight -ge $HeightPx){
                
                #Determine new dimensions (ensuring to keep proportions) 
                if($OldWidth -lt $OldHeight){
                    $NewWidth = $WidthPx
                    [int]$NewHeight = [Math]::Round(($NewWidth*$OldHeight)/$OldWidth)

                    if($NewHeight -gt $HeightPx){
                        $NewHeight = $HeightPx
                        [int]$NewWidth = [Math]::Round(($NewHeight*$OldWidth)/$OldHeight)
                    }
                }
                else{
                    $NewHeight = $HeightPx
                    [int]$NewWidth = [Math]::Round(($NewHeight*$OldWidth)/$OldHeight)

                    if($NewWidth -gt $WidthPx){
                        $NewWidth = $WidthPx
                        [int]$NewHeight = [Math]::Round(($NewWidth*$OldHeight)/$OldWidth)
                    }     
                }          
                
                #Resize Working Image
                $NewImage = new-object System.Drawing.Bitmap $NewWidth,$NewHeight
                $Graphics = [System.Drawing.Graphics]::FromImage($NewImage)
                $Graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
                $Graphics.DrawImage($OldImage, 0, 0, $NewWidth, $NewHeight)

                #Save Working Image
                $ImageFormat = $OldImage.RawFormat
                $OldImage.Dispose()  
                $NewImage.Save("$Directory\$File",$ImageFormat)
                $NewImage.Dispose()
            }
        }
    }
    Catch {
        Write-Warning -Message "$($_.Exception.Message)"
    }
}

Function New-Wallpaper {
    Param(  [Parameter()]
            [string] $OverlayText,
 
            [Parameter()]
            [string] $OutFile= "$($env:temp)\BGInfo.bmp",
 
            [Parameter()]
            [ValidateSet("Center","Left","Right")]
            [string]$TextAlign="Center",

            [Parameter()]
            [ValidateSet("High","Low")]
            [string]$Position="High",
            
            [Parameter()]
            [string]$TextColour="White",
            
            [Parameter()]
            [string]$BGColour="Grey",
 
            [Parameter()]
            [string]$FontName="Arial",
            
            [Parameter()]
            [ValidateRange(9,45)]
            [int32]$FontSize = 12,
            
            [Parameter()]
            [ValidateSet($TRUE,$FALSE)]
            [Boolean]$ApplyHeader=$TRUE,
 
            [Parameter()]
            [string]$BGType
    )
    Begin {

        # Colour Palette
        Switch ($TextColour) {
            Grey    {$TColour = $Grey}
            Black   {$TColour = $Black}
            White   {$TColour = $White}
            Red     {$TColour = $Red}
            Green   {$TColour = $Green}
            Yellow  {$TColour = $Yellow}
            Blue    {$TColour = $Blue}
            CornflourBlue {$TColour = $CornflourBlue}
            DEFAULT {
                Write-Warning "Text colour not found. Please try again"
                exit
            }
        }
        
        Switch ($BGColour) {
            Existing {$BG = "Existing"}
            Grey    {$BG = $Grey}
            Black   {$BG = $Black}
            White   {$BG = $White}
            Red     {$BG = $Red}
            Green   {$BG = $Green}
            Yellow  {$BG = $Yellow}
            Blue    {$BG = $Blue}
            CornflourBlue {$BG = $CornflourBlue}
            DEFAULT {
                Write-Warning "Background colour not found. Please try again"
                exit
            }
        }

        # Make first line a header (bigger)
        if ($ApplyHeader -eq $TRUE){
            $HeaderSize = $FontSize+1
            $TextSize = $FontSize-2
        }
        else {
            $HeaderSize = $FontSize
            $TextSize = $FontSize
        }
        
        Try {
            [system.reflection.assembly]::loadWithPartialName('system.drawing.imaging') | out-null
            [system.reflection.assembly]::loadWithPartialName('system.windows.forms') | out-null
     
            # Text alignment and position
            $sFormat = new-object system.drawing.stringformat
     
            Switch ($TextAlign) {
                Center {$sFormat.Alignment = [system.drawing.StringAlignment]::Center}
                Left {$sFormat.Alignment = [system.drawing.StringAlignment]::Near}
                Right {$sFormat.Alignment = [system.drawing.StringAlignment]::Far}
            }
     
            Switch ($Position) {
                High {$sFormat.LineAlignment = [system.drawing.StringAlignment]::Near}
                Low {$sFormat.LineAlignment = [system.drawing.StringAlignment]::Center}
            }
     
            Switch ($BGType) {

                MyPics {
                    # Create new Bitmap background
                    $wpath = (Get-ItemProperty 'HKCU:\Control Panel\Desktop' -Name WallPaper -ErrorAction Stop).WallPaper
                    if (Test-Path -Path $wpath -PathType Leaf) {
                        $bmp = new-object system.drawing.bitmap -ArgumentList $wpath
                        $image = [System.Drawing.Graphics]::FromImage($bmp)
                        $SR = $bmp | Select Width,Height
                    } 
                    else {
                        Write-Warning -Message "Failed cannot find the current wallpaper $($wpath)"
                        break
                    }
                    
                    #Set Background colour behind bitmap
                    if ($BG -ne "Existing"){
                        Set-ItemProperty 'HKCU:\Control Panel\Colors' -Name Background -Value $BG
                    }
                }
            
                Web {
                    # Create new Bitmap background
                    $wpath = (Get-ItemProperty 'HKCU:\Control Panel\Desktop' -Name WallPaper -ErrorAction Stop).WallPaper
                    if (Test-Path -Path $wpath -PathType Leaf) {
                        $bmp = new-object system.drawing.bitmap -ArgumentList $wpath
                        $image = [System.Drawing.Graphics]::FromImage($bmp)
                        $SR = $bmp | Select Width,Height
                    } 
                    else {
                        Write-Warning -Message "Failed cannot find the current wallpaper $($wpath)"
                        break
                    }
                    
                    #Set Background colour behind bitmap
                    if ($BG -ne "Existing"){
                        Set-ItemProperty 'HKCU:\Control Panel\Colors' -Name Background -Value $BG
                    }
                }
            
                Colour {
                    #Create 
                    $SR = [System.Windows.Forms.Screen]::AllScreens | Where Primary | Select -ExpandProperty Bounds | Select Width,Height
         
                    # Create Bitmap
                    $bmp = new-object system.drawing.bitmap($SR.Width,$SR.Height)
                    $image = [System.Drawing.Graphics]::FromImage($bmp)
             
                    $image.FillRectangle(
                        (New-Object Drawing.SolidBrush (
                            [System.Drawing.Color]::FromArgb($BG[0],$BG[1],$BG[2])
                        )),
                        (new-object system.drawing.rectanglef(0,0,($SR.Width),($SR.Height)))
                    )
                    
                    #Set Background colour behind bitmap
                    if ($BG -ne "Existing"){
                        Set-ItemProperty 'HKCU:\Control Panel\Colors' -Name Background -Value $BG
                    }
                }
            }
        }

        Catch {
            Write-Warning -Message "$($_.Exception.Message)"
            break
        }
    }
    Process {
     
        # Split Text array
        $artext = ($OverlayText -split "\r\n")
         
        $i = 1
        Try {
            for ($i ; $i -le $artext.Count ; $i++) {
                if ($i -eq 1) {
                    $font1 = New-Object System.Drawing.Font($FontName,$HeaderSize,[System.Drawing.FontStyle]::Bold)
                    $Brush1 = New-Object Drawing.SolidBrush (
                        [System.Drawing.Color]::FromArgb($TColour[0],$TColour[1],$TColour[2])
                    )
                    $sz1 = [system.windows.forms.textrenderer]::MeasureText($artext[$i-1], $font1)
                    $rect1 = New-Object System.Drawing.RectangleF (0,($sz1.Height),$SR.Width,$SR.Height)
                    $image.DrawString($artext[$i-1], $font1, $brush1, $rect1, $sFormat) 
                } else {
                    $font2 = New-Object System.Drawing.Font($FontName,$TextSize,[System.Drawing.FontStyle]::Bold)
                    $Brush2 = New-Object Drawing.SolidBrush (
                        [System.Drawing.Color]::FromArgb($TColour[0],$TColour[1],$TColour[2])
                    )
                    $sz2 = [system.windows.forms.textrenderer]::MeasureText($artext[$i-1], $font2)
                    $rect2 = New-Object System.Drawing.RectangleF (0,($i*$FontSize*2 + $sz2.Height),$SR.Width,$SR.Height)
                    $image.DrawString($artext[$i-1], $font2, $brush2, $rect2, $sFormat)
                }
            }
        } 
        
        Catch {
            Write-Warning -Message "Overlay Text error: $($_.Exception.Message)"
            break
        }
    }
    End {   
        Try { 
            # Close Graphics
            $image.Dispose();
     
            # Save and close Bitmap
            $bmp.Save($OutFile, [system.drawing.imaging.imageformat]::Bmp);
            $bmp.Dispose();
     
            # Output our file
            Get-Item -Path $OutFile
        } 
        
        Catch {
            Write-Warning -Message "Outfile error: $($_.Exception.Message)"
            break
        }
    }
}


Function Update-Wallpaper {
    Param(
        [Parameter(Mandatory=$true)]
        $Path,
         
        [ValidateSet('Center','Stretch','Fill','Tile','Fit')]
        $Style
    )
    Try {
        if (-not ([System.Management.Automation.PSTypeName]'Wallpaper.Setter').Type) {
            Add-Type -TypeDefinition @"
            using System;
            using System.Runtime.InteropServices;
            using Microsoft.Win32;
            namespace Wallpaper {
                public enum Style : int {
                    Center, Stretch, Fill, Fit, Tile
                }
                public class Setter {
                    public const int SetDesktopWallpaper = 20;
                    public const int UpdateIniFile = 0x01;
                    public const int SendWinIniChange = 0x02;
                    [DllImport("user32.dll", SetLastError = true, CharSet = CharSet.Auto)]
                    private static extern int SystemParametersInfo (int uAction, int uParam, string lpvParam, int fuWinIni);
                    public static void SetWallpaper ( string path, Wallpaper.Style style ) {
                        SystemParametersInfo( SetDesktopWallpaper, 0, path, UpdateIniFile | SendWinIniChange );
                        RegistryKey key = Registry.CurrentUser.OpenSubKey("Control Panel\\Desktop", true);
                        switch( style ) {
                            case Style.Tile :
                                key.SetValue(@"WallpaperStyle", "0") ; 
                                key.SetValue(@"TileWallpaper", "1") ; 
                                break;
                            case Style.Center :
                                key.SetValue(@"WallpaperStyle", "0") ; 
                                key.SetValue(@"TileWallpaper", "0") ; 
                                break;
                            case Style.Stretch :
                                key.SetValue(@"WallpaperStyle", "2") ; 
                                key.SetValue(@"TileWallpaper", "0") ;
                                break;
                            case Style.Fill :
                                key.SetValue(@"WallpaperStyle", "10") ; 
                                key.SetValue(@"TileWallpaper", "0") ; 
                                break;
                            case Style.Fit :
                                key.SetValue(@"WallpaperStyle", "6") ; 
                                key.SetValue(@"TileWallpaper", "0") ; 
                                break;
}
                        key.Close();
                    }
                }
            }
"@ -ErrorAction Stop 
            } 
        } 
        Catch {
            Write-Warning -Message "Wallpaper not changed because $($_.Exception.Message)"
        }
    [Wallpaper.Setter]::SetWallpaper( $Path, $Style )
}


Function Set-Wallpaper {
    [CmdletBinding()]
    Param(  [Parameter(Mandatory=$True,ValueFromPipeline=$true,ValueFromPipelineByPropertyName = $true,Position=0)]
            [string]$Source,
 
            [Parameter(Mandatory=$false,ValueFromPipeline=$true,ValueFromPipelineByPropertyName = $true,Position=1)]
            [string]$Selection
    )
    Begin {
        # Select Background colour
        if ($Source -eq "Colour") {
            $BGColour = $Selection
        }
        # If selected, get local pictures
        elseif ($Source -eq "MyPics"){
            Get-MyImages -Path $PicturesPath -Selection $Selection -Resize $ResizeMyPics
            $BGColour = "Existing"
        }

        #If selected, get web pictures
        elseif ($Source -eq "Web"){
            Set-WebProxy
            Get-GoogleImages -SearchTerm $Selection -MaxResults $MaxResults -DaysBetweenSearches $DaysBetweenSearches -Resize $ResizeWebPics
            $BGColour = "Existing"
        }
    }
    Process{
        $Background = @{
            BGType = $source ;   
            BGColour = $BGColour 
        }
    }
    End{
        $WallPaper = New-Wallpaper @Overlay @Background
        Update-Wallpaper -Path $WallPaper.FullName -Style $Style
    }
}


#----------------------------------------------------------------------------------------------------------------
#   Pipeline Validation and Launch  #

mkdir C:\Users\vagrant\Pictures\wallpaper
Copy-Item C:\vagrant\resources\windows\backbag.png C:\Users\vagrant\Pictures\wallpaper\background.png
Set-Wallpaper -Source MyPics -Selection background.png