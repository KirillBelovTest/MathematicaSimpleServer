(* ::Package:: *)

(* :Title: RequestParser *)
(* :Contetx: MathematicaSimpleServer`RequestParser` *)

(* :Keywords: request parser *)

(* :Author: Kirill Belov *)
(* :Email: KirillBelovTest@gmail.com *)

BeginPackage["MathematicaSimpleServer`RequestParser`"]; 
(* publick funcs and names *)

RequestParser::usag = "RequestParser[]"; 

Begin["`Private`"]; 
(* private definitions *)

(* internal name *)
Checker::usage = "Checker[]"; 

(* internal name *)
Component::usage = "Component[]";

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
			]..
		}
	]
] := requestParser[[1, All, 1]]; 

(* 
	override Part on the request parser type and checker of the parser type
	RequestParser[{key1 -> check1 -> component1, key2 -> ...}][[Component[key1]]] >> checker1
*)
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
] ^:= checker; 

(* 
	override Part on the request parser type and component of the parser type
	RequestParser[{key1 -> check1 -> component1, key2 -> ...}][[Component[key1]]] >> component1
*)
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
] ^:= component; 

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

	$Failed
]; 

End[]; (*`Private`*)

EndPackage[]; (*`RequestParser`*)