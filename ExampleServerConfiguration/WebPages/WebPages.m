(* ::Package:: *)

(* Wolfram Language Package *)

WebPages::usage = 
"WebPages[port]"; 

Begin["`Private`"]; 

$ResourcesPath = FileNameJoin[{DirectoryName[$InputFileName], "Resources"}]; 

(* request checkers *)
RequestToIndexWebPageQ[request_String] := 
StringMatchQ[First[StringSplit[request, "\r\n"]], "GET / HTTP/1.1" ~~ ___]; 

RequestToOtherContentQ[request_String] := 
FileExistsQ[FileNameJoin[
	{
		$ResourcesPath, 

		First[
			StringCases[
				First[
					StringSplit[request, "\r\n"]
				], "GET " ~~ address___ ~~ " HTTP/1.1" :> address
			]
		]
	}
]]; 

(* request parse >> address *)

RequestTakeAddress[request_String] := 
FileNameJoin[
	{
		$ResourcesPath, 
		
		If[# == "/", "/Index.html", #]& @ First[
			StringCases[
				First[StringSplit[request, "\r\n"]], 
				"GET " ~~ address__ ~~ " HTTP/1.1" :> address
			]
		]
	}
]; 

(* server bean *)

ServerBeanTakePage[address_String] := 
ReadString[address]; 

(* response generator *)

ResponseWebPage[body_String] := 
"HTTP 200 OK\r\n" <> 
StringTemplate["Date: `date`\r\n"][<|"date" -> DateString[]|>] <> 
"Server: MathematicaSimpleServer\r\n" <> 
StringTemplate["Content-Length: `length`\r\n"][<|"length" -> StringLength[body]|>] <> 
"Connection: close\r\n\r\n" <> body; 

(* main defintion *)
WebPages[port_Integer] := 
MathematicaSimpleServerCreate[
	port, 
	
	ConnectionHandlerCreate[
		RequestParser[
			{
				"index" -> RequestToIndexWebPageQ -> RequestTakeAddress, 
				"other" -> RequestToOtherContentQ -> RequestTakeAddress
			}
		], 
		ServerBean[
			{
				"index" -> ServerBeanTakePage, 
				"other" -> ServerBeanTakePage
			}
		], 
		ResponseGenerator[
			{
				"index" -> ResponseWebPage, 
				"other" -> ResponseWebPage
			}
		]
	]
]; 

End[]; (* `Private` *)