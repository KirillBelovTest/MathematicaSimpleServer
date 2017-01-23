(* ::Package:: *)

(* :Title: MathematicaSimpleServer *)
(* :Context: MathematicaSimpleServer` *)

(* :Author: Kirill Belov *)
(* :Email: KirillBelovTest@gmail.com *)

(* :Keywords: Web Server; HTTP; Sockets *)

BeginPackage["MathematicaSimpleServer`", {"SocketLink`", "MathematicaSimpleServer`ConnectionHandler`"}]; 

MathematicaSimpleServerCreate::usage = 
"MathematicaSimpleServerCreate[port, handler]"; 

MathematicaSimpleServerClose::usage = 
"MathematicaSimpleServerClose[server]"; 

Begin["`Private`"]; 

(* internal symbol *)
Component::usage = 
"MathematicaSimpleServer[..][[Component[\"Name\"]]]"; 

(* override Part or name[[..]] on the MathematicaSimpleServer *)
Part[
	MathematicaSimpleServer[
		{
			___, key_String -> component: 
				(
					_Symbol | 
					_Integer | 
					_Socket | 
					_ConnectionHandler | 
					_AsynchronousTaskObject
				),
	 		___
		}
	], Component[key_String]
] ^:= component; 

(* server constructors *)
MathematicaSimpleServerCreate[port_Integer, handler_ConnectionHandler] := 
	Module[{tag, socket, asynchronousserver}, 
		
		tag = Unique[]; 
		socket = CreateServerSocket[port]; 
		asynchronousserver = CreateAsynchronousServer[socket, handler]; 
		
		(* Return *)
		MathematicaSimpleServer[
			{
				"Tag" -> tag, 
				"Port" -> port, 
				"Socket" -> socket, 
				"ServerHandler" -> handler, 
				"AsynchronousServer" -> asynchronousserver 
			}
		] 
	];

(* server destructor *)
MathematicaSimpleServerClose[server_MathematicaSimpleServer] := 
	(
		SocketLink`Sockets`CloseSocket[server[[Component["Socket"]]]]; 
		StopAsynchronousTask[server[[Component["AsynchronousServer"]]]]; 
	);

(* define format *)
Format[server_MathematicaSimpleServer] := 
"Server"[Hyperlink["http://localhost:" <> ToString[server[[Component["Port"]]]] <> "/"]];

End[]; (*`Private`*)

EndPackage[]; (*MathematicaSimpleServer`*) 