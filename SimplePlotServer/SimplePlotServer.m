(* ::Package:: *)

(* :Title: SimplePlotServer *)
(* :Context: SimplePlotServer` *)

(* :Author: Kirill Belov *)
(* :Email: KirillBelovTest@gmail.com *)

BeginPackage["MathematicaSimpleServer`SimplePlotServer`", {"MathematicaSimpleServer`"}]; 

SimplePlotServerCreate::usage = 
"SimplePlotServerCreate[port]"; 

Begin["`Private`"]; 

SimplePlotServerCreate[port_Integer] := 
MathematicaSimpleServerCreate[port, SimplePlotServerConnectionHandler[]]; 

SimplePlotServerConnectionHandler[] := 
ConnectionHandlerCreate[]; 

End[] (*`Private`*)

EndPackage[]; (* MathematicaSimpleServer`SimplePlotServer` *)
