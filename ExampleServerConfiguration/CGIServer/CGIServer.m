(* ::Package:: *)

(* :Title: ServerBean *)

(* :Author: Kirill Belov *)
(* :Email: KirillBelovTest@gmail.com *)

(* :Keywords: cgi-server; common gateway interface *)
(* :Version: 0.0.1 *)

CGIServer::usage = 
"CGIServer[port]"; 

CGIScriptOutput::usage = 
"CGIScriptOutput[]"

Begin["`Private`"]; 

$ResourcesPath = FileNameJoin[{DirectoryName[$InputFileName], "Resources"}]; 

(* checkers and components of the request parser *)
RequestToCGIScriptQ[request_String] := 
If[
	Apply[
		Or, 
		Map[
			StringMatchQ[
				request, 
				"GET /CGIServer/" ~~ __ ~~ # <> " HTTP/1.1"
			]&, 	
			{".m", ".m/"}
		]
	], 
	
	FileExistsQ[
		FileNameJoin[
			{
				$ResourcesPath, 
				First[
					StringCases[
						First[StringSplit[request, "\r\n"]], 
						"GET /CGIServer/" ~~ filename__ ~~ " HTTP/1.1" :> filename, 
						IgnoreCase -> True
					]
				]
			}
		]
	], 
	
	False
]; 

RequestToCGIIndexQ[request_String] := 
Apply[
	Or, 
	Map[
		StringMatchQ[
			request, 
			"GET " <> # <> " HTTP/1.1", 
			IgnoreCase -> True
		]&, 
		
		{"/", "/CGIServer", "/CGIServer/", "/CGIServer/Index", "/CGIServer/Index/"}
	]
]; 

RequestErrorQ[request_String] := 
Not[RequestToCGIIndexQ[request]] && Not[RequestToCGIScriptQ[request]]; 

RequestTakeAddress[request_String] := 
FileNameJoin[
	{
		$ResourcesPath, 
		First[
			StringCases[
				First[StringSplit[request, "\r\n"]], 
				"GET /CGIServer" ~~ filename__ ~~ " HTTP/1.1" :> filename, 
				IgnoreCase -> True
			]
		]
	}
]; 

(* beans *)
BeanIndexPageCreate[_] := 
Module[{links, indexpage}, 
indexpage = 
"
<!DOCTYPE html>
<html>
	<head>
		<title>CGIServer - Index Page</title>
		<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\">
	</head>
	<body>
		<ul>
			`links`
		<ul>
	</body>
</html>
"; 

links = 
StringJoin[
	Table[
		Function[
			filename, 
			"<a href = \"" <> 
			StringReplace[
				FileNameJoin[
					{
						"/SGIServer/", 
						filename
					}
				], 
				"\\" -> "/"
			] <> 
			"\" >" <> 
			filename <> 
			"</a>\n"][
				StringReplace[
					StringReplace[
						file, 
						$ResourcesPath -> ""
					], 
					"\\" -> "/"
				]
			], 
		{file, FileNames["*.m", {$ResourcesPath}]}
	]
]; 

StringTemplate[indexpage][<|"links" -> links|>]

];

BeanScriptRun[script_String] := 
ToString[Get[script]]; 

BeanErrorPage[_] := 
"Error"; 

(* responses *)
ResponseFromCGIServer[body_String] := 
"HTTP 200 OK\r\n" <> 
StringTemplate["Date: `date`\r\n"][<|"date" -> DateString[]|>] <> 
StringTemplate["Content-Length: `length`\r\n"][<|"length" -> StringLength[body]|>] <> 
"Connection: close\r\n\r\n" <> body; 

ResponseError[_] := 
"HTTP 500 !OK\r\n" <> 
StringTemplate["Date: `date`\r\n"][<|"date" -> DateString[]|>] <> 
StringTemplate["Content-Length: `length`\r\n"][<|"length" -> StringLength["Internal Server Error"]|>] <> 
"Connection: close\r\n\r\n" <> "Internal Server Error"; 

CGIServer[port_Integer] := 
MathematicaSimpleServerCreate[
	port, 
	ConnectionHandlerCreate[
		RequestParser[
			{
				"index" -> RequestToCGIIndexQ -> RequestTakeAddress, 
				"script" -> RequestToCGIScriptQ -> RequestTakeAddress, 
				"error" -> RequestErrorQ -> RequestTakeAddress
			}
		], 
		ServerBean[
			{
				"index" -> BeanIndexPageCreate, 
				"script" -> BeanScriptRun, 
				"error" -> BeanErrorPage
			}
		], 
		ResponseGenerator[
			{
				"index" -> ResponseFromCGIServer, 
				"script" -> ResponseFromCGIServer, 
				"error" -> ResponseError
			}
		]
	]
];

End[]; (*`Private`*)