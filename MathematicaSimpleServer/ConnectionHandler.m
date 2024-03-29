(* ::Package:: *)

(* :Title: ConnectionHandler *)
(* :Condext: MathematicaSimpleServer`ConnectionHandler` *)
(* :Version: 0.0.3 *)
(* :Author: Kirill Belov *)

BeginPackage["MathematicaSimpleServer`ConnectionHandler`", 
	{
		"MathematicaSimpleServer`RequestParser`", 
		"MathematicaSimpleServer`ServerBean`", 
		"MathematicaSimpleServer`ResponseGenerator`"
	}
]; 

(* You can create a handler with a single parser and generaor *)
ConnectionHandlerCreate::usage = 
"ConnectionHandlerCreate[]; \n" <> 
"ConnectionHandlerCreate[RequestParser[..], ServerBean[], ResponseGenerator[..]]; "; 

(* at any time, you can replace the parser and generator *)
ConnectionHandlerReplace::usage = 
"ConnectionHandlerReplace[ConnectionHandler[..], \"RequestParser\" -> RequestParser[..]]; \n" <> 
"ConnectionHandlerReplace[ConnectionHandler[..], \"ServerBean\" -> ServerBean[..]]; \n"  <> 
"ConnectionHandlerReplace[ConnectionHandler[..], \"RequestParser\" -> ResponseGenerator[..]]; "; 

ConnectionHandler::usage = 
"ConnectionHandler[{}]"; 

Begin["`Private`"]; (* Begin Private Context *) 

Component::usage = 
"ConnectionHandler[..][[Component[\"Name\"]]]"; 

ConnectionHandlerCreate[parser_RequestParser, bean_ServerBean, generator_ResponseGenerator] := 
	Module[{tag = Unique[]}, 
		
		Unprotect[RequestParser, ServerBean, ResponseGenerator]; 
		
		RequestParser[tag] := parser; 
		ServerBean[tag] := bean; 
		ResponseGenerator[tag] := generator; 
		
		Protect[RequestParser, ServerBean, ResponseGenerator]; 
		
		(* Return *)
		ConnectionHandler[
			{
				"Tag" :> tag, 
				"RequestParser" :> RequestParser[tag], 
				"ServerBean" :> ServerBean[tag], 
				"ResponseGenerator" :> ResponseGenerator[tag]
			}
		]
	]; 

ConnectionHandlerReplace[
	handler_ConnectionHandler, 
	name_String -> component: 
	(
		_RequestParser |  
		_ServerBean | 
		_ResponseGenerator 
	)
] /; 
StringMatchQ[name, "RequestParser" | "ServerBean" | "ResponseGenerator", IgnoreCase -> True] := 
Module[
	{
		tag = handler[[Component["Tag"]]]
	}, 

	Unprotect[Evaluate[Head[component]]]; 

	Head[component][tag] := component; 
	
	Protect[Evaluate[Head[component]]]; 
	
	(* Return *)
	handler
]; 

ConnectionHandlerReplace[handler_ConnectionHandler, rules: 
	(
		__Rule | 
		_List?Function[ruleList, Apply[And, Map[(Head[#] == Rule)&, ruleList]]]
	)
] /; Length[{rules}] > 1 := 
(
	Do[ConnectionHandlerReplase[handler, rule], {rule, rules}]; 
	
	(* Return *)
	handler
); 

(* override [[]] on the ConnectionHandler *)
Part[
	ConnectionHandler[
		{
			(___Rule | ___RuleDelayed), 
			(Rule | RuleDelayed) [
				name_String, component: 
				(
					_Symbol | 
					_RequestParser | 
					_ServerBean | 
					_ResponseGenerator
				)
			], 
			(___Rule | ___RuleDelayed)
		}
	], Component[name_String]
] ^:= component; 

(* basic functionality of the handler *)
handler_ConnectionHandler[{input_InputStream, output_OutputStream}] := 
	Module[
		{
			request,
			requestString, 
			requestParser, 
			responseGenerator, 
			serverBean, 
			responseString, 
			response
		}, 
		
		Block[{$HistoryLength = 0},  
		
			(* reading the request from client *)
			Check[request = 
				Flatten[Last[Reap[
					While[True, 
						TimeConstrained[
							Sow[BinaryRead[input]], 
							0.01, Break[] 
						]
					]
				]]];, Close[input]; CLose[output]; Return[]]; 
			
			(* close input stream of the socket after reading *)
			Close[input]; 
			
			(* an initial check of the correctness of the request *)
			If[Length[request] == 0, Print["Error:\r\nEmpty request"]; Close[output]; Return[]]; 
			If[Length[request] < 16, Print["Error:\r\n", FromCharacterCode[request]]; Close[output]; Return[]]; 
		
			(* converting a binary data to string and logging*)
			requestString = FromCharacterCode[request]; 
			Print[requestString]; 
		
			(* request verification *)
			If[
				Not[StringMatchQ[
					First[StringSplit[requestString, "\r\n"]], 
					__ ~~ " /" ~~ ___ ~~ "HTTP/" ~~ _ ~~ _ ~~ _
				
				]], 
				Print["Error:\r\nIncorrect request:\r\n", requestString]; Close[output]; Return[]
			]; 
		
			(* getting handler components *)
			Check[
				requestParser = handler[[Component["RequestParser"]]]; 
				serverBean = handler[[Component["ServerBean"]]]; 
				responseGenerator = handler[[Component["ResponseGenerator"]]];, 
			
				(* error logging *)
				Print["Error during getting handler components"]; Close[output]; Return[]; 
			]; 
		
			(* response creation *)
			responseString = 
				Check[
					responseGenerator[serverBean[requestParser[requestString]]], 
				
					"HTTP 500 Internal Server Error\r\n" <> 
					StringTemplate["Date: `date`\r\n"][<|"date" -> DateString[]|>] <> 
					"Contetn-Length: 32\r\n" <> 
					"Connection: close\r\n\r\n" <> 
				
					"Internal Server Error"; 
				]; 
			
			(* loging *)
			Print[responseString]; 
			
			(* 
				converting response string to bynary data
				write response to the output stream of the socket 
				close ouptut stream
			*)
			response = ToCharacterCode[responseString]; 
			BinaryWrite[output, response]; 
			Close[output]; 
		]
	];

End[]; (* End Private Context *)

EndPackage[]; 