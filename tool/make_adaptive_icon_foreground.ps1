# Membuat latar depan ikon adaptif Android (assets/icon/app_icon_foreground.png) dari logo.
#
# Launcher yang ikonnya bulat memotong sudut gambar, dan telinga beruang ikut terpotong kalau
# logo dipakai apa adanya. Skrip ini menaruh logo di kanvas yang sedikit lebih besar dan
# meneruskan warna tepinya ke ruang tambahan itu, jadi gambarnya tetap memenuhi semua bentuk
# ikon dan logonya sendiri tidak diubah.
#
# Jalankan dari akar proyek setiap kali assets/icon/app_icon.png diganti:
#   powershell -ExecutionPolicy Bypass -File tool/make_adaptive_icon_foreground.ps1
#   dart run flutter_launcher_icons
param(
    [string]$Source = 'assets/icon/app_icon.png',
    [string]$Output = 'assets/icon/app_icon_foreground.png',
    # Ruang tambahan di tiap sisi, dalam piksel logo. 54 dari 1024 membuat telinga beruang
    # masuk seluruhnya ke ikon bulat.
    [int]$Margin = 54
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

# Baris terluar logo sering bernoda, jadi warna tepi diambil beberapa piksel ke dalam dan
# dirata-rata sepanjang tepi. Tanpa itu nodanya ikut memanjang menjadi garis-garis.
$skip = 4
$depth = 4
$along = 2

$logo = New-Object System.Drawing.Bitmap (Resolve-Path $Source).Path
$w = $logo.Width
$h = $logo.Height

# $side: 0 kiri, 1 kanan, 2 atas, 3 bawah. $position: letak di sepanjang tepi itu.
function Get-EdgeColor([int]$side, [int]$position) {
    $length = if ($side -lt 2) { $h } else { $w }
    $r = 0; $g = 0; $b = 0; $count = 0
    for ($a = -$along; $a -le $along; $a++) {
        $q = [Math]::Min($length - 1, [Math]::Max(0, $position + $a))
        for ($d = $skip; $d -lt $skip + $depth; $d++) {
            switch ($side) {
                0 { $pixel = $logo.GetPixel($d, $q) }
                1 { $pixel = $logo.GetPixel($w - 1 - $d, $q) }
                2 { $pixel = $logo.GetPixel($q, $d) }
                3 { $pixel = $logo.GetPixel($q, $h - 1 - $d) }
            }
            $r += $pixel.R; $g += $pixel.G; $b += $pixel.B; $count++
        }
    }
    [System.Drawing.Color]::FromArgb([int]($r / $count), [int]($g / $count), [int]($b / $count))
}

$canvas = New-Object System.Drawing.Bitmap ($w + 2 * $Margin), ($h + 2 * $Margin), ([System.Drawing.Imaging.PixelFormat]::Format24bppRgb)
$graphics = [System.Drawing.Graphics]::FromImage($canvas)
$graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
$graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::Half
$brush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::Black)

# Sisi kiri dan kanan, termasuk sudut: sudut memakai warna ujung sisi itu.
for ($y = 0; $y -lt $h; $y++) {
    $top = if ($y -eq 0) { 0 } else { $y + $Margin }
    $height = if ($y -eq 0 -or $y -eq $h - 1) { $Margin + 1 } else { 1 }
    $brush.Color = Get-EdgeColor 0 $y
    $graphics.FillRectangle($brush, 0, $top, $Margin, $height)
    $brush.Color = Get-EdgeColor 1 $y
    $graphics.FillRectangle($brush, $w + $Margin, $top, $Margin, $height)
}

# Sisi atas dan bawah.
for ($x = 0; $x -lt $w; $x++) {
    $brush.Color = Get-EdgeColor 2 $x
    $graphics.FillRectangle($brush, $x + $Margin, 0, 1, $Margin)
    $brush.Color = Get-EdgeColor 3 $x
    $graphics.FillRectangle($brush, $x + $Margin, $h + $Margin, 1, $Margin)
}

# Logo di tengah, piksel demi piksel tanpa diubah.
$target = New-Object System.Drawing.Rectangle $Margin, $Margin, $w, $h
$graphics.DrawImage($logo, $target, 0, 0, $w, $h, [System.Drawing.GraphicsUnit]::Pixel)

$path = [System.IO.Path]::GetFullPath((Join-Path (Get-Location).Path $Output))
$canvas.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)

$brush.Dispose()
$graphics.Dispose()
$canvas.Dispose()
$logo.Dispose()

"${Output}: $($w + 2 * $Margin) x $($h + 2 * $Margin) piksel, tepi $Margin"
