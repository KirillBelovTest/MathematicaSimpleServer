(* Wolfram Language Package *)

BeginPackage["MathematicaSimpleServer`ResponseGenerator`"]; 
(* Exported symbols added here with SymbolName::usage *)  

ResponseGenerator::usage = 
"ResponseGenerator[]"; 

Begin["`Private`"]; (* Begin Private Context *) 

(* internal symbol *)
Component::usage = 
"ResponseGenerator[{key1 -> component1, key2 -> ...}][[Component[key1]]] >> component1"; 

(* internal name *)
Component::usage = "Internal symbol. Using: ServerBean[[Component[key]]]"; 

ResponseGenerator::srverr = 
"Inernal server error"; 

(* 
	override Keys on the request parser type 
	Keys[ResponseGenerator[{key1 -> component1, key2 -> ...}]] >> {key1, key2, ...}
*)
ResponseGenerator /: 
Keys[responseGenerator_ResponseGenerator] /; 
MatchQ[
	responseGenerator, 
	ResponseGenerator[
		{
			Rule[
				_String, 
				(_Symbol | _Function) 
			] ..
		}
	]

] := responseGenerator[[1, All, 1]]; 

(* override [[..]] on the response generator *)
ResponseGenerator /: 
Part[
	ResponseGenerator[
		{
			___Rule, 
			key_String -> component: 
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
responseGenerator_ResponseGenerator[key_String -> content_] /; 
MemberQ[Keys[responseGenerator], key] := 
responseGenerator[[Component[key]]][content]; 

responseGenerator_ResponseGenerator[$Failed] := (Message[ResponseGenerator::srverr]; $Failed); 

End[]; (* End Private Context *)

EndPackage[]; 