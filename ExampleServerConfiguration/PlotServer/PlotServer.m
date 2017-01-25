(* ::Package:: *)

(* :Title: SimplePlotServer *)
(* :Context: SimplePlotServer` *)

(* :Author: Kirill Belov *)
(* :Email: KirillBelovTest@gmail.com *)

PlotServer::usage = 
"PlotServer[port] >> MathematicaSimpleServer[...]"; 

(* function for the creation of the request parser *)
PlotRequestQ[request_String] := 
StringContainsQ[
	ToLowerCase[First[StringSplit[request, "\r\n"]]], 
	"get /plotserver?" ~~ ___ ~~ "http/1.1"
];

PlotRequestToIndexQ[request_String] := 
ToLowerCase[First[StringSplit[request, "\r\n"]]] == "get / http/1.1" || 
ToLowerCase[First[StringSplit[request, "\r\n"]]] == "get /index http/1.1" || 
ToLowerCase[First[StringSplit[request, "\r\n"]]] == "get /plotserver http/1.1"; 

PlotRequestAddressTake[request_String] := 
First[StringCases[
	First[StringSplit[request, "\r\n"]], 
	"GET " ~~ address__ ~~ " HTTP/1.1" :> address
]]; 

(* function for the creation of the request parser *)
PlotBean[address_String] := 

PlotIndexPageBean[_String] := 
ReadString[
	FileNameJoin[
		{
			DirectoryName[$InputFileName], 
			"Resources", 
			"Index.html"
		}
	]
];