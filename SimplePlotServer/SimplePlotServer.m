(* ::Package:: *)

(* :Title: SimplePlotServer *)
(* :Context: SimplePlotServer` *)

(* :Author: Kirill Belov *)
(* :Email: KirillBelovTest@gmail.com *)

BeginPackage["SimplePlotServer`", {"MathematicaSimpleServer`"}]; 

SimplePlotServerStart::usage = 
"SimplePlotServerStart[port] >> SimpleMathematicaServer"; 

PlotRequest::usage = 
"PlotRequest[requestString] >> parserAssociation"; 

PlotRequest::errreq = 
"Error during parsing of the request"; 

PlotResponse::usage = 
"PlotRequest[parserAssociation] >> responseString"; 

Begin["`Private`"]; 

(*  *)
SimplePlotServerStart[port_Integer] := 
MathematicaSimpleServer`ServerCreate[
	port, 
	HandlerCreate[ServerHandler[
		PlotRequest, 
		PlotResponse
	]]]; 

(* public definitions *)

PlotRequest[requestString_String] :=  
	If[PlotRequestQ[requestString], 
		SplitAddress[TakeAddress[requestString]], 
		Message[PlotRequest::errreq]; $Failed
]; 

PlotResponse[parsedRequest_Association] := 
	Check[
		PlotResponseText[PlotResponseImage[parsedRequest]], 
		PlotResponseError["Error during the plotting"]
	]; 

(* private definitions *)

PlotRequestQ[requestString_String] := 
	StringContainsQ["get /simpleplotserver?"][
		First[StringSplit[ToLowerCase[requestString], "\r\n"]]
	]; 

TakeAddress[requestString_String] := 
	"Address" -> 
	First[StringCases[
		First[StringSplit[requestString, "\r\n"]], 
		"GET /" ~~ address___ ~~ " HTTP/1." :> "/" <> address
	]]; 

SplitAddress["Address" -> address_String] /; 
	PlotResponseQ["get " <> address] := 
	Association[MapThread[
   		Rule[#1, If[
   			#1 == "Range", 
   			ToExpression[StringSplit[#2, "%"]], ToExpression[#2, TraditionalForm]]
   		] &, 
   		{
   			{"Function", "Range"}, 
   			First[StringSplit[StringSplit[address, "/simpleplotserver?"], "@"]]
   		}
    ]]; 
    
SplitAddress["Address" -> address_String] /; 
	address == "/" || ToLowerCase[address] == "/index" || 
	ToLowerCase[address] == "/simpleplotserver" := 
	<|"Address" -> address|>; 

PlotResponseImage[$Failed] := 
	"Error address"; 

PlotResponseImage[parsedRequest_Association] /; 
	Keys[parsedRequest] == {"Function", "Range"} := 
	Module[
		{
			function = parsedRequest[["Function"]], 
			range = parsedRequest[["Range"]]
		}, 
		
		ExportString[Plot[function[x], {x, range[[1]], range[[2]]}], "SVG"]
	];
	
PlotResponseImage[parsedRequest_Association] /; 
Keys[parsedRequest] == {"Address"} := 
"<html> 
	<head> 
    	<meta http-equiv=\"Content-Type\" content=\"text/html; charset=UTF8\"/>
        <title> 
			Plot Server Index Page 
		</title>
	</head> 
	<body> 
		<H1> 
			Index Page of the Simple Plot Server 
		</H1>
		<P>
			<ul>
				<li><A href = \"/SimplePlotServer?Sin@-4%4\">Sin[x, {x, -4, 4}]</A></li>
			</ul> 
		</P> 
	</body> 
</html>"

(*image/svg+xml; *)
(*text/html; charset=utf-8*)
PlotResponseText[responseBody_String] := 
	"HTTP/1.1 200 OK\r\n" <> 
	"Content-Type: image/svg+xml;\r\n" <> 
	"Content-Length: " <> ToString[StringLength[responseBody]] <> 
	"\r\nConnection: close\r\n\r\n" <> responseBody; 

PlotResponseError[message_String] := 
	"HTTP/1.1 400 OK\r\n" <> 
	"Content-Type: text/html; charset=utf-8\r\n" <> 
	"Content-Length: " <> ToString[StringLength[message]] <> 
	"\r\nConnection: close\r\n\r\n" <> 
	"Error during plotting\n" <> 
	"\t" <> message; 
	
End[] (*`Private`*)

EndPackage[]; (* SimplePlotServer` *)
