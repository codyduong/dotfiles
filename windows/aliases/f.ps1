function f {
        try {
                # fetch command and error from session history only when not in cnf mode
                if ($env:_PR_MODE -ne 'cnf') {
                        $env:_PR_LAST_COMMAND = (Get-History | Select-Object -Last 1 | ForEach-Object {$_.CommandLine});
                        $err = Get-Error;
                        if ($env:_PR_LAST_COMMAND -eq $err.InvocationInfo.Line) {
                                $env:_PR_ERROR_MSG = $err.Exception.Message
                        }
                }
                $env:_PR_SHELL = 'pwsh';
                &'C:\Users\duong\.cargo\bin\pay-respects.exe';
        }
        finally {
                # restore mode from cnf
                if ($env:_PR_MODE -eq 'cnf') {
                        $env:_PR_MODE = $env:_PR_PWSH_ORIGIN_MODE;
                        $env:_PR_PWSH_ORIGIN_MODE = $null;
                }
        }
}

$ExecutionContext.InvokeCommand.CommandNotFoundAction =
{
        param(
                [string]
                $commandName,
                [System.Management.Automation.CommandLookupEventArgs]
                $eventArgs
        )
        # powershell does not support run command with specific environment variables
        # but you must set global variables. so we are memorizing the current mode and the alias function will reset it later.
        $env:_PR_PWSH_ORIGIN_MODE=$env:_PR_MODE;
        $env:_PR_MODE='cnf';
        # powershell may search command with prefix 'get-' or '.\' first when this hook is hit, strip them
        $env:_PR_LAST_COMMAND=$commandName -replace '^get-|\.\\','';
        $eventArgs.Command = (Get-Command f);
        $eventArgs.StopSearch = $True;
}