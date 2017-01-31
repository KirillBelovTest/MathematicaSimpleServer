(* ::Package:: *)

(* :Title: RequestParser *)
(* :Contetx: MathematicaSimpleServer`RequestParser` *)

(* :Keywords: request parser *)

(* :Author: Kirill Belov *)
(* :Email: KirillBelovTest@gmail.com *)

BeginPackage["MathematicaSimpleServer`RequestParser`"]; 

(* preparation *)
Unprotect[RequestParser]; 

(* messages block ... *)
RequestParser::usage = 
"RequestParser[{key1 -> checker1 -> component1, key2 -> ...}] - creating parser \n" <>
"RequestParser[...][request] - request parsing "; 

RequestParser::reqex = 
"Exception during request "; 

(* private definitions *)
Begin["`Private`"]; 

(* internal names *)
Unprotect[Checker]; 
Unprotect[Component]; 

Checker::usage = 
"Checker - internal name \n" <> 
"RequestParser[{key -> checker -> component}][[Checker[key]]] >> checker "; 

Component::usage = 
"Component - internal name \n" <> 
"RequestParser[{key -> checker -> component}][[Component[key]]] >> component "; 

Protect[Checker]; 
Protect[Component]; 

(* 
	override Keys on the request parser type 
	Keys[RequestParser[{key1 -> check1 -> component1, key2 -> ...}]] >> {key1, key2, ...}
*)
RequestParser /: 
Keys[requestParser_RequestParser] /; 
MatchQ[
	requestParser, 
	RequestParser[
		{
			Rule[
				_String, 
				Rule[
					(_Symbol | _Function), 
					(_Symbol | _Function)
				]
			] ..
		}
	]
] := requestParser[[1, All, 1]]; 

(* 
	override Part on the request parser type and checker of the parser type
	RequestParser[{key1 -> check1 -> component1, key2 -> ...}][[Component[key1]]] >> checker1
*)
RequestParser /: 
Part[
	RequestParser[
		{
			___Rule, 
			key_String -> 
			checker: 
				(
					_Symbol | 
					_Function
				) -> 
			_: 
				(
					_Symbol | 
					_Function
				), 	
			___Rule
		}
	], 
	Checker[key_String]
] := checker; 

(* 
	override Part on the request parser type and component of the parser type
	RequestParser[{key1 -> check1 -> component1, key2 -> ...}][[Component[key1]]] >> component1
*)
RequestParser /: 
Part[
	RequestParser[
		{
			___Rule, 
			key_String -> 
			_: 
				(
					_Symbol | 
					_Function
				) -> 
			component: 
				(
					_Symbol | 
					_Function
				), 	
			___Rule
		}
	], 
	Component[key_String]
] := component; 

(* main definition *)
requestParser_RequestParser[request_String] := 
Check[

	(* Return[key -> result] *)
	First[First[Last[Reap[
		Do[
			If[
				(* check condition *)
				requestParser[[Checker[key]]][request], 
		
				(* action *)
				Sow[key -> requestParser[[Component[key]]][request]]; Break[]
			], 
			{key, Keys[requestParser]}
		]; 
	]]]], 

	(* Error return *)
	Message[RequestParser::reqex]; $Failed
]; 

End[]; (*`Private`*) 

Protect[RequestParser]; 

EndPackage[]; (*`RequestParser`*) 
