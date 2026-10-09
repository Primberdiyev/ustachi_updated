param(
    [string]$Match = 'ustachi_web_phone',
    [int]$Width = 430,
    [int]$Height = 1020,
    [int]$X = 80,
    [int]$Y = 15,
    [int]$TimeoutMinutes = 6
)

# Zamonaviy Chrome oddiy oyna uchun --window-size ni e'tiborsiz qoldiradi,
# shuning uchun oyna ochilgandan keyin uni Win32 API orqali o'lchaymiz.

Add-Type @'
using System;
using System.Runtime.InteropServices;
public class UstachiWin {
  [DllImport("user32.dll")] public static extern bool SetWindowPos(IntPtr h, IntPtr after, int x, int y, int cx, int cy, uint flags);
  [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr h, int cmd);
  [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr h);
}
'@

Add-Type -AssemblyName System.Windows.Forms

$deadline = (Get-Date).AddMinutes($TimeoutMinutes)
while ((Get-Date) -lt $deadline) {
    $proc = Get-CimInstance Win32_Process -Filter "Name='chrome.exe'" |
        Where-Object { $_.CommandLine -like "*$Match*" -and $_.CommandLine -notlike '*--type=*' }
    if ($proc) {
        $handle = (Get-Process -Id $proc.ProcessId -ErrorAction SilentlyContinue).MainWindowHandle
        if ($handle -and $handle -ne 0) {
            Start-Sleep -Seconds 2
            # Keep the whole app, including bottom navigation, above the taskbar.
            $workArea = [System.Windows.Forms.Screen]::FromHandle($handle).WorkingArea
            $fitWidth = [Math]::Min($Width, $workArea.Width)
            $fitHeight = [Math]::Min($Height, $workArea.Height)
            $fitX = [Math]::Max($workArea.Left, [Math]::Min($X, $workArea.Right - $fitWidth))
            $fitY = [Math]::Max($workArea.Top, [Math]::Min($Y, $workArea.Bottom - $fitHeight))
            [void][UstachiWin]::ShowWindow($handle, 9)          # SW_RESTORE
            [void][UstachiWin]::SetWindowPos($handle, [IntPtr]::Zero, $fitX, $fitY, $fitWidth, $fitHeight, 0x0004)
            [void][UstachiWin]::SetForegroundWindow($handle)
            Write-Output "Oyna ${fitWidth}x${fitHeight} qilib o'lchandi."
            exit 0
        }
    }
    Start-Sleep -Seconds 2
}
Write-Output "Chrome oynasi topilmadi (timeout)."
