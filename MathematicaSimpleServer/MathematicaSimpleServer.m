(* ::Package:: *)

(* :Title: MathematicaSimpleServer *)
(* :Context: MathematicaSimpleServer` *)

(* :Author: Kirill Belov *)
(* :Email: KirillBelovTest@gmail.com *)

(* :Keywords: Web Server; HTTP *)

BeginPackage["MathematicaSimpleServer`", {"SocketLink`"}]; 

MathematicaSimpleServer::usage = 
"MathematicaSimpleServer[Socket[..], AsynchronousServer[..]]"; 

ServerCreate::usage = 
"MathematicaSimpleServerCreate[port, handler] \n" <> 
"MathematicaSimpleServerCreate[socket, handler]"; 

ServerClose::usage = 
"MathematicaSimpleServerClose[MathematicaSimpleServer[..]]"; 

ServerHandler::usage = 
"ServerHandler[]"; 

HandlerCreate::usage = 
"HandlerCreate[]"

SetParser::usage = 
"SetParser[]"; 

SetGenerator::usage = 
"SetGenerator[]"; 

RequestParser::usage = 
"RequestParser[]"; 

ResponseGenerator::usage = 
"ResponseGenerator[]"; 

Begin["`Private`"]; 

(* server constructors/destructors *)
ServerCreate[socket_Socket, handler_ServerHandler] := 
MathematicaSimpleServer[socket, CreateAsynchronousServer[socket, handler]]; 

ServerCreate[port_Integer, handler_ServerHandler] := 
Module[{socket = CreateServerSocket[port]}, 
	MathematicaSimpleServer[
		socket, 
		CreateAsynchronousServer[socket, handler]
	]
]; 

MathematicaSimpleServer /: 
ServerClose[MathematicaSimpleServer[socket_Socket, asyncServer_AsynchronousTaskObject]] := 
(SocketLink`Sockets`CloseSocket[socket]; StopAsynchronousTask[asyncServer];); 

RequestParser[_] := Nothing; 
ResponseGenerator[_] := Nothing; 
	
ServerHandler /:
HandlerCreate[ServerHandler[]] := 
ServerHandler[Unique[]];
	
ServerHandler /: 
HandlerCreate[ServerHandler[
	Parser: (_Symbol|_Function), 
	Generator: (_Symbol|_Function)
]] := 
Module[{tag = Unique[]}, 
	RequestParser[tag] = Parser;
	ResponseGenerator[tag] = Generator;
	ServerHandler[tag]
]; 
	
ServerHandler /: 
RequestParser[ServerHandler[tag_]] := 
RequestParser[tag]; 

ServerHandler /: 
ResponseGenerator[ServerHandler[tag_]] := 
ResponseGenerator[tag]; 
	
ServerHandler /: 
SetParser[ServerHandler[tag_], Parser: (_Symbol|_Function)] := 
RequestParser[tag] = Parser; 
	
ServerHandler /: 
SetGenerator[ServerHandler[tag_], Generator: (_Symbol|_Function)] := 
ResponseGenerator[tag] = Generator; 
	
serverHandler_ServerHandler[{input_InputStream, output_OutputStream}] := 
Module[
	{
		request, requestString, 
		requestParser = RequestParser[serverHandler], 
		responseGenerator = ResponseGenerator[serverHandler], 
		responseString, response
	}, 
	
	(* reading the request *)
	request = 
		Flatten[Last[Reap[
			While[True, 
				TimeConstrained[
					Sow[BinaryRead[input]], 0.01, Break[]
				]
			]
		]]];
	
	Close[input]; 
	
	requestString = FromCharacterCode[request]; 
	
	Print[DateString[], "\r\n", "Request:\r\n", requestString]; 
	
	If[
		Not[StringMatchQ[requestString, __ ~~ " /" ~~ ___ ~~ "HTTP/1." ~~ __]], 
		Return[]
	]; 
	
	responseString = responseGenerator[requestParser[requestString]]; 
	
	Print[DateString[], "\r\n", "Response:\r\n", responseString]; 
	
	response = ToCharacterCode[responseString]; 
	BinaryWrite[output, response]; 
	Close[output];		
];

End[]; (*`Private`*)

EndPackage[]; (*MathematicaSimpleServer`*)