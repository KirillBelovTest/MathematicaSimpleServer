(* ::Package:: *)

(* :Title: Installer *)

(* :Author: Kirill Belov *)
(* :Email: KirillBelovTest@gmail.com *)

Begin["Installer`Private`"]; 

Block[
	{
		$ProjectDirectory, 
		$TargetKernelDirectory, 
		$ApplicationInitFilePath, 
		$ApplicationContext, 
		Extensions, 
		Name
	}, 
	
	$ProjectDirectory = DirectoryName[$InputFileName]; 
	
	SetDirectory[$ProjectDirectory]; 
	
	$TargetKernelDirectory = 
	FileNameJoin[
		{
			$UserBaseDirectory, "Applications", 
			(Association @@ Get["PacletInfo.m"])[[Key[Name]]], 
			"Kernel"
		}
	]; 
	
	$ApplicationInitFilePath = FileNameJoin[{$TargetKernelDirectory, "Init.m"}]; 

	$ApplicationContext = 
	Association[Rest[
		(Association @@ Get["PacletInfo.m"])[[Key[Extensions]]][[1]]
	]][[Key[Context]]]; 

	If[!FileExistsQ[$TargetKernelDirectory], CreateDirectory[$TargetKernelDirectory]]; 

	With[{ProjectDirectory = $ProjectDirectory, ApplicationContext = $ApplicationContext}, 
		With[{code = Unevaluated[$Path = DeleteDuplicates[Prepend[$Path, ProjectDirectory]]; Get[ApplicationContext, Path -> {ProjectDirectory}];]}, 
			Put[code, $ApplicationInitFilePath]; 
		]; 
	]; 
	
	ResetDirectory[]; 

	Remove["Installer`Private`*"]; 

]; 

End[]; (*Installer`Private`*)
