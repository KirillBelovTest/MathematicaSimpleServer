(* ::Package:: *)

(* :Title: SimplePlotServer *)
(* :Context: SimplePlotServer` *)

(* :Author: Kirill Belov *)
(* :Email: KirillBelovTest@gmail.com *)

BeginPackage["SimplePlotServer`", {"MathematicaSimpleServer`"}]; 

SimplePlotServerStart::usage = 
"SimplePlotServerStart[] >> SimpleMathematicaServer"; 

PlotRequest::usage = 
"PlotRequest[requestString] >> parserAssociation"; 

PlotResponse::usage = 
"PlotRequest[parserAssociation] >> responseString"; 

Begin["`Private`"]; 

(**)
SimplePlotServerStart[] := 
MathematicaSimpleServer`ServerCreate[
	8888, 
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
		PlotResponseImage[parsedRequest], 
		PlotErrorResponse["Error during the plotting"]
	]; 

(* private definitions *)

PlotRequestQ[requestString_String] := 
	StringContainsQ["get /plotserver?"][
		First[StringSplit[ToLowerCase[requestString], "\r\n"]]
	]; 

TakeAddress[requestString_String] := 
	"Address" -> 
	First[StringCases[
		First[StringSplit[requestString, "\r\n"]], 
		"GET /" ~~ address___ ~~ " HTTP/1." :> "/" <> address
	]]; 

SplitAddress["Address" -> address_String] := 
	Association[MapThread[
   		Rule[#1, If[
   			#1 == "Range", 
   			ToExpression[StringSplit[#2, "%"]], ToExpression[#2, TraditionalForm]]
   		] &, 
   		{
   			{"Function", "Range"}, 
   			First[StringSplit[StringSplit[address, "/plotserver?"], "@"]]
   		}
    ]]; 

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

PlotImageResponse[responseBody_String] := 
	"HTTP/1.1 200 OK\r\n" <> 
	"Content-Type: image/svg+xml\r\n" <> 
	"Content-Length: " <> ToString[StringLength[responseBody]] <> 
	"Connection: close\r\n\r\n" <> responseBody; 

PlotErrorResponse[message_String] := 
	"HTTP/1.1 400 OK\r\n" <> 
	"Content-Type: image/svg+xml\r\n" <> 
	"Content-Length: " <> ToString[StringLength[responseBody]] <> 
	"Connection: close\r\n\r\n" <> 
	"Error during plotting\n" <> 
	"\t" <> message; 
	
End[] (*`Private`*)

EndPackage[]; (* SimplePlotServer` *)
