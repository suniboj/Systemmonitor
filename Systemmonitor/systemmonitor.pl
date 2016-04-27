#!/usr/bin/env perl 
#===============================================================================
#
#         FILE: systemmonitor.pl
#
#        USAGE: ./systemmonitor.pl  
#
#  DESCRIPTION: Ein grafischer Systemmonitor zur Anzeige der Ressourcen aus-
#				nutzung und der laufenden Prozesse unter Linux.
#
#      OPTIONS: ---
# REQUIREMENTS: ---
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Mike Giemsa, Franco Grothe 
# ORGANIZATION: FH Südwestfalen, Iserlohn
#      VERSION: 1.0
#      CREATED: 22.04.2016 11:06:26
#     REVISION: ---
#===============================================================================

asdasDadf

use strict;
use warnings;
use utf8;

use Tk;
use Tk::NoteBook; 	#Reiter
use Tk::Labelframe; #Frame mit Label
use Tk::ProgressBar;

#===================================================================#
#	Globale Variablen												#
#===================================================================#

my %WIDGETS; 				#enthält alle Widgets

my $width = 400;
my $CPUanz = 4;

#===================================================================#
#	MainWindow														#
#===================================================================#

my $mw = MainWindow->new; 	# Main Window
$mw->title("Systemmonitor");
$mw->minsize( $width, 400 );
$mw->maxsize( $width, 999 );


#===================================================================#
#	Reiter erstellen												#
#===================================================================#

$WIDGETS{'Notebook'} = $mw->NoteBook();

$WIDGETS{'NotebookRessourcen'} = $WIDGETS{'Notebook'}->add("Ressourcen", 
	-label => "Ressourcen");
	
$WIDGETS{'NotebookRessourcen'}->Label();

$WIDGETS{'NotebookProzesse'} = $WIDGETS{'Notebook'}->add("Prozesse", 
	-label => "Prozesse");
	
$WIDGETS{'NotebookProzesse'}->Label();

$WIDGETS{'Notebook'}->pack(-fill => 'both', -expand => 1,);

$WIDGETS{'Notebook'}->grid(
	-row    => 0,
	-column => 0,
	-sticky => "nsew");


#===================================================================#
#	Ressourcen - LabelFrames erstellen								#
#===================================================================#
$WIDGETS{'FrameCPU'}=$WIDGETS{'NotebookRessourcen'}->Labelframe(
	-width => $width,
	-text => 'CPU');
	
$WIDGETS{'FrameRAM'}=$WIDGETS{'NotebookRessourcen'}->Labelframe(
	-width => $width,
	-height => 50,
	-text => 'RAM',);
	

	
$WIDGETS{'FrameDISK'}=$WIDGETS{'NotebookRessourcen'}->Labelframe(
	-width => $width,
	-height => 50,
	-text => 'DISKS',);
	
$WIDGETS{'FrameNET'}=$WIDGETS{'NotebookRessourcen'}->Labelframe(
	-width => $width,
	-height => 50,
	-text => 'NETWORK',);
	

#===================================================================#
#	Frames ausrichten												#
	
$WIDGETS{'FrameCPU'}->grid(
	-row    => 0,
	-column => 0,
	-sticky => "nsew");	#?????????
	
$WIDGETS{'FrameRAM'}->grid(
	-row    => 1,
	-column => 0,
	-sticky => "nsew");
	
$WIDGETS{'FrameDISK'}->grid(
	-row    => 2,
	-column => 0,
	-sticky => "nsew");

$WIDGETS{'FrameNET'}->grid(
	-row    => 3,
	-column => 0,
	-sticky => "nsew");
		

#===================================================================#
#	CPU																#
																
	
for(my $i = 1; $i<= $CPUanz; $i++){
	$WIDGETS{"LabelCPU" . $i} = $WIDGETS{'FrameCPU'}->Label(	
		-text  => "CPU" . $i,
		-width => 6);
	
	$WIDGETS{"CPU$i"."Progress"} = $WIDGETS{'FrameCPU'}->ProgressBar( 
		-colors => [ 0, 'green', 70, 'yellow', 90, 'red' ], 
		-width => 13, 
		-length => 150 );
	  
	$WIDGETS{"CPU$i"."Used"} = $WIDGETS{'FrameCPU'}->Label(	
		-text  => "99p",
		-width => 5);
																	
	#===================================================================#
	#	CPU-Label, ProgressBar und Percentage ausrichten				#
	
	$WIDGETS{"LabelCPU" . $i}->grid(
	-row    => $i,
	-column => 0,
	-in 	=> $WIDGETS{"FrameCPU"});
	
	$WIDGETS{"CPU$i"."Progress"}->grid(
	-row    => $i,
	-column => 1,
	-in 	=> $WIDGETS{"FrameCPU"});
	
	$WIDGETS{"CPU$i"."Used"}->grid(
	-row    => $i,
	-column => 2,
	-in 	=> $WIDGETS{"FrameCPU"});

}
$WIDGETS{"CPUCanvas"}=$WIDGETS{FrameCPU}->Canvas(
	-height => 40,
	-width => 280,
	-borderwidth => 0,
	-background => 'white');
	
	$WIDGETS{"CPUCanvas"}->grid(
	-row    => 5,
	-column => 0,
	-sticky => "nsew",
	-in 	=> $WIDGETS{"FrameCPU"});
	


#===================================================================#
#	RAM																#														
																																				
#															
#$WIDGETS{"LabelRAM"} = $WIDGETS{'FrameRAM'}->Label(	
#	-text  => "RAM",
#	-width => 6)->pack();
#	
#$WIDGETS{"RAMProgress"} = $WIDGETS{'FrameRAM'}->ProgressBar( 
#	  -colors => [ 0, 'green', 70, 'yellow', 90, 'red' ], 
#	  -width => 13, 
#	  -length => 150 )->pack();
#	  
#$WIDGETS{"RAMUsed"} = $WIDGETS{'FrameRAM'}->Label(	
#	-text  => "2048/4096",
#	-width => 10)->pack();		
#	
#	
#	
##===================================================================#
##	DISK															#															
#																
#
#	
##===================================================================#
##	Network															#	
#															
#
#
#$WIDGETS{"LabelNETDown"} = $WIDGETS{'FrameNET'}->Label(	
#	-text  => "Download: ",
#	-width => 8)->pack();	
#	
#$WIDGETS{"NETDown"} = $WIDGETS{'FrameNET'}->Label(	
#	-text  => "300Kb/s ",
#	-width => 9)->pack();	
#
#$WIDGETS{"LabelNETUp"} = $WIDGETS{'FrameNET'}->Label(	
#	-text  => "Upload: ",
#	-width => 8)->pack();	
#
#$WIDGETS{"NETUp"} = $WIDGETS{'FrameNET'}->Label(	
#	-text  => "100Kb/s ",
#	-width => 9)->pack();

#$WIDGETS{"LabelNETDown"}->grid(
#	-row    => 0,
#	-column => 0);
#
#$WIDGETS{"NETDown"}->grid(
#	-row    => 0,
#	-column => 1);	
#	
#$WIDGETS{"LabelNETUp"}->grid(
#	-row    => 0,
#	-column => 2);	
#	
#$WIDGETS{"NETUp"}->grid(
#	-row    => 0,
#	-column => 3);		

																			

MainLoop();
