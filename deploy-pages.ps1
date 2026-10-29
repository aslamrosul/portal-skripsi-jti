# Script Deploy ke GitHub Pages untuk Portal Skripsi JTI Polinema
$ErrorActionPreference = "Stop"

$repoName = "portal-skripsi-jti"
$root = $PSScriptRoot
Set-Location -LiteralPath $root

Write-Host "=== Memeriksa Autentikasi GitHub ===" -ForegroundColor Cyan
try {
    $user = (gh api user -q .login)
    Write-Host "Terdeteksi akun GitHub: $user" -ForegroundColor Green
} catch {
    Write-Host "PERINGATAN: GitHub CLI belum terdeteksi login di sesi ini." -ForegroundColor Yellow
    Write-Host "Jika menggunakan Git biasa, pastikan repository https://github.com/aqfiazfan/$repoName sudah dibuat." -ForegroundColor Yellow
    $user = "aqfiazfan"
}

Write-Host "=== Memeriksa / Membuat Repository di GitHub ===" -ForegroundColor Cyan
$repoExists = $false
try {
    gh repo view "$user/$repoName" *> $null
    $repoExists = $true
    Write-Host "Repository $user/$repoName sudah ada di GitHub." -ForegroundColor Green
} catch {
    Write-Host "Membuat repository publik baru: $user/$repoName..." -ForegroundColor Cyan
    try {
        gh repo create $repoName --public --description "Portal Riset & Direktori Skripsi Terapan JTI Polinema (97 Dosen, 8 Lab, SINTA)" --source=. --remote=origin
        $repoExists = $true
    } catch {
        Write-Host "Gagal membuat via 'gh'. Mengatur remote git manual..." -ForegroundColor Yellow
    }
}

$remotes = @(git remote)
if ($remotes -notcontains "origin") {
    git remote add origin "https://github.com/$user/$repoName.git"
} else {
    git remote set-url origin "https://github.com/$user/$repoName.git"
}

Write-Host "=== Melakukan Push Branch Main ===" -ForegroundColor Cyan
git push -u origin main

Write-Host "=== Mengaktifkan GitHub Pages ===" -ForegroundColor Cyan
try {
    gh api repos/$user/$repoName/pages -X POST -F "build_type=legacy" -F "source[branch]=main" -F "source[path]=/" *> $null
    Write-Host "GitHub Pages berhasil diaktifkan!" -ForegroundColor Green
} catch {
    Write-Host "Info: Halaman Pages mungkin sudah aktif atau dapat diaktifkan lewat menu Settings -> Pages di GitHub." -ForegroundColor Yellow
}

$pagesUrl = "https://$user.github.io/$repoName/"
Write-Host ""
Write-Host "==========================================================" -ForegroundColor Green
Write-Host "  SELESAI! Web Portal Anda Aktif di GitHub Pages:" -ForegroundColor Green
Write-Host "  $pagesUrl" -ForegroundColor White
Write-Host "  Repository: https://github.com/$user/$repoName" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Green
