(* ::Package:: *)

(* :Title: SimplePlotServer *)
(* :Context: SimplePlotServer` *)

(* :Author: Kirill Belov *)
(* :Email: KirillBelovTest@gmail.com *)

PlotServer::usage = 
"PlotServer[port] >> MathematicaSimpleServer[...]"; 

Begin["`Private`"]; 

$ResourcesPath = 
FileNameJoin[{DirectoryName[$InputFileName], "Resources"}]; 

(* function for the creation of the request parser *)
PlotRequestQ[request_String] := 
StringContainsQ[
	ToLowerCase[First[StringSplit[ToLowerCase[request], "\r\n"]]], 
	"get /plotserver?" ~~ ___ ~~ "http/1.1"
];

PlotRequestToImageQ[request_String] := 
StringContainsQ[
	ToLowerCase[First[StringSplit[ToLowerCase[request], "\r\n"]]], 
	"get /plotserver/image?" ~~ ___ ~~ "http/1.1"
];

PlotRequestToIndexQ[request_String] := 
ToLowerCase[First[StringSplit[ToLowerCase[request], "\r\n"]]] == "get / http/1.1" || 
ToLowerCase[First[StringSplit[ToLowerCase[request], "\r\n"]]] == "get /index http/1.1" || 
ToLowerCase[First[StringSplit[ToLowerCase[request], "\r\n"]]] == "get /plotserver http/1.1"; 

PlotRequestAddressTake[request_String] := 
First[StringCases[
	First[StringSplit[request, "\r\n"]], 
	"GET " ~~ address__ ~~ " HTTP/1.1" :> address
]]; 

(* function for the creation of the request parser *)
PlotIndexPageBean[_String] := 
StringTemplate[
	ReadString[
		FileNameJoin[
			{
				$ResourcesPath, 
				"Index.html"
			}
		]
	]
][<|"image" -> ""|>]; 

PlotGraphicPageBean[address_String] := 
StringTemplate[
	ReadString[
		FileNameJoin[
			{
				$ResourcesPath, 
				"Index.html"
			}
		]
	]
][
	<|
		"image" -> 
		"<img src = \"" <> 
		StringReplace[
			address, 
			"/plotserver?" -> "/plotserver/image?", 
			IgnoreCase -> True
		] <> 
		"\">"|>]; 

PlotImageBean[address_String] := 
Module[{func, range},
	func = 
	Symbol[First[StringCases[address, __ ~~ "?" ~~ funcname__ ~~ "@" ~~ __ :> funcname]]];

	range = ToExpression[
		StringSplit[
			StringReplace[First[
				StringCases[
					address, 
					"/plotserver/image?" ~~ __ ~~ "@" ~~ rangestring__ :> rangestring
				]
			], "/" -> ""], 
			"%" 
		]
	]; 
	
	(*Return*)
	ExportString[Plot[func[x], {x, range[[1]], range[[2]]}], "SVG"]
];

PlotPageResponse[body_String] := 
"HTTP 200 OK\r\n" <> 
StringTemplate["Date: `date`\r\n"][<|"date" -> DateString[]|>] <> 
"Server: MathematicaSimpleServer\r\n" <> 
"Content-Type: text/html; charset=utf-8\r\n" <> 
StringTemplate["Content-Length: `length`\r\n"][<|"length" -> StringLength[body]|>] <> 
"Connection: close\r\n\r\n" <> body; 

PlotImageResponse[body_String] := 
"HTTP 200 OK\r\n" <> 
StringTemplate["Date: `date`\r\n"][<|"date" -> DateString[]|>] <> 
"Server: MathematicaSimpleServer\r\n" <> 
"Content-Type: image/svg+xml\r\n" <> 
StringTemplate["Content-Length: `length`\r\n"][<|"length" -> StringLength[body]|>] <> 
"Connection: close\r\n\r\n" <> body; 

(* main definition *)
PlotServer[port_Integer] := 
MathematicaSimpleServerCreate[
	port, 	
	ConnectionHandlerCreate[
		RequestParser[
			{
				"index" -> PlotRequestToIndexQ -> PlotRequestAddressTake, 
				"graphic" -> PlotRequestQ -> PlotRequestAddressTake, 
				"image" -> PlotRequestToImageQ -> PlotRequestAddressTake
			}
		], 
		ServerBean[
			{
				"index" -> PlotIndexPageBean, 
				"graphic" -> PlotGraphicPageBean, 
				"image" -> PlotImageBean
			}
		], 
		ResponseGenerator[
			{
				"index" -> PlotPageResponse, 
				"graphic" -> PlotPageResponse,
				"image" -> PlotImageResponse
			}
		]
	]
]; 

End[]; (*`Private`*)