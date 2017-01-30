(* Wolfram Language package *)

MathServerPages::usage = 
"MathServerPages[]"; 

Begin["`MathServerPages`"]; 

RequstToIndexQ[request_String] := 
1

MathServerPages[port_Integer] := 
MathematicaSimpleServerCreate[
	port, 
	ConnectionHandlerCreate[
		{
			RequestParser[
				{
					"index" -> ""
				}
			], 
			ServerBean[
				{
					
				}
			], 
			ResponseGenerator[
				{
					
				}
			]
		}
	]
]; 

End[]; (*`MathServerPages`*)