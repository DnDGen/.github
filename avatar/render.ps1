# Renders avatar.svg to avatar.png (1000 x 1000), scales that down to each smaller avatar-<size>.png,
# and packs the 32 x 32 one into favicon.ico.
# Headless Edge won't render a window much smaller than 500 pixels, so the small sizes are scaled down
# from the 1000 x 1000 render instead of rendered directly.
param(
    [string]$Browser = "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe"
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$svg = Join-Path $PSScriptRoot 'avatar.svg'
$png = Join-Path $PSScriptRoot 'avatar.png'
$browserProfile = Join-Path ([IO.Path]::GetTempPath()) 'dndgen-avatar-render'

Start-Process -FilePath $Browser -Wait -NoNewWindow -ArgumentList @(
    '--headless', '--hide-scrollbars', '--disable-gpu',
    "--user-data-dir=`"$browserProfile`"",
    '--window-size=1000,1000',
    "--screenshot=`"$png`"",
    ([Uri]$svg).AbsoluteUri
)

$source = [System.Drawing.Image]::FromFile($png)
try {
    foreach ($size in 512, 192, 180, 128, 32) {
        $bitmap = New-Object System.Drawing.Bitmap -ArgumentList $size, $size
        $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
        $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
        $graphics.DrawImage($source, 0, 0, $size, $size)
        $graphics.Dispose()
        $bitmap.Save((Join-Path $PSScriptRoot "avatar-$size.png"), [System.Drawing.Imaging.ImageFormat]::Png)
        $bitmap.Dispose()
    }
}
finally {
    $source.Dispose()
}

# favicon.ico holds the 32 x 32 PNG as its only image: a 6-byte header, one 16-byte directory entry, then the PNG.
$icon = [IO.File]::ReadAllBytes((Join-Path $PSScriptRoot 'avatar-32.png'))
$stream = New-Object IO.MemoryStream
$writer = New-Object IO.BinaryWriter -ArgumentList $stream
$writer.Write([UInt16]0)            # reserved
$writer.Write([UInt16]1)            # type: icon
$writer.Write([UInt16]1)            # image count
$writer.Write([Byte]32)             # width
$writer.Write([Byte]32)             # height
$writer.Write([Byte]0)              # palette colours: none
$writer.Write([Byte]0)              # reserved
$writer.Write([UInt16]1)            # colour planes
$writer.Write([UInt16]32)           # bits per pixel
$writer.Write([UInt32]$icon.Length) # image size
$writer.Write([UInt32]22)           # image offset: after the header and the one entry
$writer.Write($icon)
$writer.Flush()
[IO.File]::WriteAllBytes((Join-Path $PSScriptRoot 'favicon.ico'), $stream.ToArray())
$writer.Dispose()
