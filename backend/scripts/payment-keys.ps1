# PayTR and iyzico keys for the local API (docs/PAYMENTS.md).
#
# Keys go to `dotnet user-secrets` (%APPDATA%\Microsoft\UserSecrets\gway-api), never into the repo. The API reads them
# by itself in the Development environment, so no environment variable is needed after this.
#
#   powershell -ExecutionPolicy Bypass -File backend\scripts\payment-keys.ps1 paytr    # store PayTR keys
#   powershell -ExecutionPolicy Bypass -File backend\scripts\payment-keys.ps1 iyzico   # store iyzico keys
#   powershell -ExecutionPolicy Bypass -File backend\scripts\payment-keys.ps1 tunnel   # public API address for notifications
#   powershell -ExecutionPolicy Bypass -File backend\scripts\payment-keys.ps1 show     # what is stored (keys masked)
#   powershell -ExecutionPolicy Bypass -File backend\scripts\payment-keys.ps1 clear    # remove every payment key
#
# Restart the API afterwards. Production servers take the same names as environment variables (deploy/.env).

param([ValidateSet('paytr', 'iyzico', 'tunnel', 'show', 'clear')][string]$Step = 'show')

$ErrorActionPreference = 'Stop'
$project = Join-Path $PSScriptRoot '..\src\Gway.Api'

function Set-Secret([string]$Name, [string]$Value) {
    dotnet user-secrets set $Name $Value --project $project | Out-Null
    if ($LASTEXITCODE -ne 0) { throw "Could not store $Name" }
}

function Read-Value([string]$Prompt, [switch]$Secret) {
    if (-not $Secret) { return (Read-Host $Prompt).Trim() }
    $secure = Read-Host $Prompt -AsSecureString
    $ptr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure)
    try { return ([Runtime.InteropServices.Marshal]::PtrToStringBSTR($ptr)).Trim() }
    finally { [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($ptr) }
}

function Read-Required([string]$Prompt, [switch]$Secret) {
    do { $value = Read-Value $Prompt -Secret:$Secret } while ($value.Length -eq 0)
    return $value
}

switch ($Step) {
    'paytr' {
        Write-Host 'PayTR Magaza Paneli > Destek & Kurulum > Entegrasyon Bilgileri'
        Set-Secret 'Billing:Paytr:MerchantId' (Read-Required 'Magaza no (merchant_id)')
        Set-Secret 'Billing:Paytr:MerchantKey' (Read-Required 'Magaza parola (merchant_key)' -Secret)
        Set-Secret 'Billing:Paytr:MerchantSalt' (Read-Required 'Magaza gizli anahtar (merchant_salt)' -Secret)
        $live = (Read-Value 'Canli odeme mi? Test icin bos birak, canli icin "canli" yaz') -eq 'canli'
        Set-Secret 'Billing:Paytr:TestMode' ($(if ($live) { 'false' } else { 'true' }))
        Write-Host "PayTR kaydedildi (test modu: $(-not $live)). API'yi yeniden baslat."
    }
    'iyzico' {
        Write-Host 'iyzico paneli > Ayarlar > Firma Ayarlari (sandbox: sandbox-merchant.iyzipay.com)'
        Set-Secret 'Billing:Iyzico:ApiKey' (Read-Required 'API anahtari' -Secret)
        Set-Secret 'Billing:Iyzico:SecretKey' (Read-Required 'Guvenlik anahtari' -Secret)
        $live = (Read-Value 'Canli anahtarlar mi? Sandbox icin bos birak, canli icin "canli" yaz') -eq 'canli'
        Set-Secret 'Billing:Iyzico:BaseUrl' ($(if ($live) { 'https://api.iyzipay.com' } else { 'https://sandbox-api.iyzipay.com' }))
        Write-Host "iyzico kaydedildi ($(if ($live) { 'canli' } else { 'sandbox' })). API'yi yeniden baslat."
    }
    'tunnel' {
        Write-Host 'Saglayici bildirimleri icin API disaridan erisilebilir olmali, ornegin:'
        Write-Host '  cloudflared tunnel --url http://localhost:5089'
        $url = Read-Required 'Tunelin https adresi (bos birakmak icin "sil")'
        if ($url -eq 'sil') {
            dotnet user-secrets remove 'Billing:PublicApiUrl' --project $project | Out-Null
            Write-Host 'Tunel adresi silindi; yerel adres (appsettings.Development.json) kullanilir.'
        } else {
            Set-Secret 'Billing:PublicApiUrl' $url.TrimEnd('/')
            Write-Host "Saglayici paneline girilecek adresler:"
            Write-Host "  PayTR bildirim URL : $($url.TrimEnd('/'))/billing/paytr/notify"
            Write-Host "  iyzico webhook     : $($url.TrimEnd('/'))/billing/iyzico/webhook"
        }
    }
    'show' {
        $lines = dotnet user-secrets list --project $project | Where-Object { $_ -match '^Billing:' }
        if (-not $lines) { Write-Host 'Kayitli odeme anahtari yok.'; break }
        foreach ($line in $lines) {
            $name, $value = $line -split ' = ', 2
            $shown = if ($name -match 'Key|Salt') { '********' + $value.Substring([Math]::Max(0, $value.Length - 4)) } else { $value }
            Write-Host "$name = $shown"
        }
    }
    'clear' {
        $names = dotnet user-secrets list --project $project | Where-Object { $_ -match '^Billing:' } | ForEach-Object { ($_ -split ' = ', 2)[0] }
        foreach ($name in $names) { dotnet user-secrets remove $name --project $project | Out-Null }
        Write-Host "Silindi: $($names.Count) odeme ayari."
    }
}
