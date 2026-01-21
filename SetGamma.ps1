param([double]$gamma = 1.0)

Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;

public class GammaControl {
    [DllImport("gdi32.dll")]
    public static extern bool SetDeviceGammaRamp(IntPtr hDC, ref RAMP lpRamp);
    
    [DllImport("gdi32.dll")]
    public static extern IntPtr CreateDC(string lpszDriver, string lpszDevice, string lpszOutput, IntPtr lpInitData);
    
    [DllImport("gdi32.dll")]
    public static extern bool DeleteDC(IntPtr hdc);

    [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Ansi)]
    public struct RAMP {
        [MarshalAs(UnmanagedType.ByValArray, SizeConst = 256)]
        public ushort[] Red;
        [MarshalAs(UnmanagedType.ByValArray, SizeConst = 256)]
        public ushort[] Green;
        [MarshalAs(UnmanagedType.ByValArray, SizeConst = 256)]
        public ushort[] Blue;
    }

    public static bool SetGamma(double gamma, string deviceName) {
        if (gamma < 0.5) gamma = 0.5;
        if (gamma > 2.0) gamma = 2.0;

        RAMP ramp = new RAMP();
        ramp.Red = new ushort[256];
        ramp.Green = new ushort[256];
        ramp.Blue = new ushort[256];

        for (int i = 0; i < 256; i++) {
            int value = (int)(Math.Pow(i / 255.0, 1.0 / gamma) * 65535);
            if (value > 65535) value = 65535;
            ramp.Red[i] = ramp.Green[i] = ramp.Blue[i] = (ushort)value;
        }

        IntPtr hdc = CreateDC(deviceName, null, null, IntPtr.Zero);
        if (hdc == IntPtr.Zero) {
            Console.WriteLine("Failed to get device context for: " + deviceName);
            return false;
        }
        
        bool result = SetDeviceGammaRamp(hdc, ref ramp);
        DeleteDC(hdc);
        return result;
    }
}
"@

Add-Type -AssemblyName System.Windows.Forms
$primaryMonitor = [System.Windows.Forms.Screen]::PrimaryScreen.DeviceName

Write-Host "Primary monitor: $primaryMonitor"
Write-Host "Setting gamma to: $gamma"

$result = [GammaControl]::SetGamma($gamma, $primaryMonitor)

if ($result) {
    Write-Host "Gamma applied successfully!" -ForegroundColor Green
} else {
    Write-Host "Failed to apply gamma. Try running as Administrator." -ForegroundColor Red
}
