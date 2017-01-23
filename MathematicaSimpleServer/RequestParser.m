(* Wolfram Language Package *)

BeginPackage["MathematicaSimpleServer`RequestParser`"];
(* Exported symbols added here with SymbolName::usage *)  

RequestParser::usage = 
"RequestParser[name] >> " <> 
"RequestParser[{name1 -> condition1 -> function1, name2 -> ...}]"; 

Begin["`Private`"]; (* Begin Private Context *) 

Component::usage = 
"RequestParser[[Component[name]]]"; 

RequestParser::nodef = 
"RequestParser[`1`] is not defined"; 

RequestParser[tag_] := 
(Message[RequestParser::nodef, tag]; Null); 

Part[
	RequestParser[
		{
			___Rule,
			name_String -> condition: 
				(
					_Symbol | 
					_Function	
				) -> 
			function: 
				(
					_Symbol | 
					_Function
				), 
			___Rule
		}
	], 
	Component[name_String]
] ^:= condition -> function; 

RequestParser /: 
Keys[RequestParser[{rules__Rule}]] := rules[[All, 1]]; 

requestParser_RequestParser[requestString_String] /; 
MatchQ[
	requestParser, 
	RequestParser[
		{
			Rule[_String, Rule[(_Symbol | _Function), (_Symbol | _Function)]]..
		}
	]
] := 
Last[Last[Reap[Do[
	If[
		First[requestParser[[Component[key]]]][requestString], 
		Sow[key -> Last[requestParser[[Component[key]]]][requestString]]; Break[]
	], 
	{key, Keys[requestParser]}
]]]]; 

End[]; (* End Private Context *)

EndPackage[];