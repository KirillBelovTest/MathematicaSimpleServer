(* Wolfram Language Package *)

BeginPackage["MathematicaSimpleServer`ResponseGenerator`"]; 
(* Exported symbols added here with SymbolName::usage *)  

ResponseGenerator::usage = 
"ResponseGenerator[]"; 

Begin["`Private`"]; (* Begin Private Context *) 

Part[
	ResponseGenerator[
		{
			___Rule, 
			name_String -> component: (_Symbol | _Function), 
			___Rule
		}
	], 
	Component[name_Sring]
] := component; 

responseGenerator_ResponseGenerator[parsedReaquest_] := 
Block[{name}, responseGenerator[[Component[parsedReaquest[[1]]]]][parsedReaquest[[2]]]]; 

End[]; (* End Private Context *)

EndPackage[];