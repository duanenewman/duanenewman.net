param (
	[parameter(Position=0,
	   Mandatory=$false)]
	   [ValidateSet("Debug","Deploy")]
	   [string]$Action
)

if ($Action -eq ""){
	echo "No action specified, begining debug session"
	$Action = "Debug" 
}

if($Action -eq "Debug") {
	hugo server -w -D
} else {
	echo "deploying"
	rm -ErrorAction SilentlyContinue -r -force ../duanenewman.github.io/*
	hugo -F -d ../duanenewman.github.io/
	cp file.cname ../duanenewman.github.io/CNAME
}