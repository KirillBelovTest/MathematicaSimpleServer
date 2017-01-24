(* Wolfram Language Package *)

BeginPackage["MathematicaSimpleServer`ServerBean`"];
(* Exported symbols added here with SymbolName::usage *)  

ServerBean::usage = 
"ServerBean[]"; 

Begin["`Private`"]; (* Begin Private Context *) 

(* internal name *)
Component::usage = "Internal symbol. Using: ServerBean[[Component[key]]]"; 

(* 
	override Keys on the request parser type 
	Keys[ServerBean[{key1 -> component1, key2 -> ...}]] >> {key1, key2, ...}
*)
ServerBean /: 
Keys[serverBean_ServerBean] /; 
MatchQ[
	serverBean, 
	ServerBean[
		{
			Rule[
				_String, 
				(_Symbol | _Function) 
			] ..
		}
	]

] := serverBean[[1, All, 1]]; 

(*  *)
ServerBean /: 
Part[
	ServerBean[
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
serverBean_ServerBean[key_String -> parsedRequest_] /; 
MemberQ[Keys[serverBean], key] := 
Check[
	key -> serverBean[[Component[key]]][parsedRequest], 
	$Failed	
]; 

serverBean_ServerBean[$Failed] := $Failed; 

End[]; (* End Private Context *)

EndPackage[];