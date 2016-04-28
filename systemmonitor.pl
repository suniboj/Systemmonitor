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
	
$WIDGETS{'NotebookProzesse'} = $WIDGETS{'Notebook'}->add("Prozesse", 
	-label => "Prozesse");	

$WIDGETS{'Notebook'}->grid(
	-row    => 0,
	-column => 0);




#===================================================================#
#	Ressourcen - LabelFrames erstellen								#
#===================================================================#
$WIDGETS{'FrameCPU'}=$WIDGETS{'NotebookRessourcen'}->Labelframe(
	-text => 'CPU');
	
$WIDGETS{'FrameRAM'}=$WIDGETS{'NotebookRessourcen'}->Labelframe(
	-text => 'RAM');
	
$WIDGETS{'FrameDISK'}=$WIDGETS{'NotebookRessourcen'}->Labelframe(
	-height => 50,
	-text => 'DISKS');
	
$WIDGETS{'FrameNET'}=$WIDGETS{'NotebookRessourcen'}->Labelframe(
	-height => 50,
	-text => 'NETWORK');
	

#===================================================================#
#	Frames ausrichten												#
	
$WIDGETS{'FrameCPU'}->grid(
	-row    => 0,
	-column => 0,
	-sticky => 'nsew');	#?????????
	
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

my $cpu;	

#===================================================================#
#	CPU																#
																
	
for(my $i = 1; $i<= $CPUanz; $i++){
	$WIDGETS{"LabelCPU" . $i} = $WIDGETS{'FrameCPU'}->Label(	
		-text  => "CPU" . $i . ":  ",
		-anchor => 'e');
	
	$WIDGETS{"CPU$i"."Progress"} = $WIDGETS{'FrameCPU'}->ProgressBar( 
		-colors => [ 0, 'green', 70, 'yellow', 90, 'red' ], 
	#	-width => 15, 
		-length => 200 
	);
	  
	$WIDGETS{"CPU$i"."Used"} = $WIDGETS{'FrameCPU'}->Label(	
		-text  => "99p",
		-anchor => 'w',
		-width => 5,
		-textvariable => \$cpu);
																	
	#===================================================================#
	#	CPU-Label, ProgressBar und Percentage ausrichten				#
	
	$WIDGETS{"LabelCPU" . $i}->grid(
	-row    => $i,
	-column => 0,
	-sticky => 'w',
	-in 	=> $WIDGETS{"FrameCPU"});
	
	$WIDGETS{"CPU$i"."Progress"}->grid(
	-row    => $i,
	-column => 1,
	-sticky => 'ew',
	-in 	=> $WIDGETS{"FrameCPU"});
	
	$WIDGETS{"CPU$i"."Used"}->grid(
	-row    => $i,
	-column => 2,
	-sticky => 'ew',
	-in 	=> $WIDGETS{"FrameCPU"});

}

my $canHeight	= 60;
my $canWidth	= 350;

$WIDGETS{"CPUCanvas"} = $WIDGETS{FrameCPU}->Canvas(
	-height => $canHeight,
	-width => $canWidth,
	-background => 'white',
	-borderwidth => 1,
	-relief => 'sunken');
	
$WIDGETS{"CPUCanvas"}->createGrid(3,3, ($canWidth/8)-2, ($canHeight/2)+2);
	
#### 100% ####	
$WIDGETS{"CPUCanvas"}->createText(19, 8, -text => "100%");

#### 0%	####	
$WIDGETS{"CPUCanvas"}->createText(11, $canHeight-4,-text => "0%");

	
	$WIDGETS{"CPUCanvas"}->grid(
	-row    => 6,
	-columnspan => 3,
	-in 	=> $WIDGETS{"FrameCPU"});
	
	
	

	


#===================================================================#
#	RAM																#														
					
					
#	
#for(my $i = 1; $i<= $CPUanz; $i++){
#	$WIDGETS{"LabelRAM" . $i} = $WIDGETS{'FrameRAM'}->Label(	
#		-text  => "  CPU" . $i,
#		-width => 10,
#		-anchor => 'w');
#	
#	$WIDGETS{"RAM$i"."Progress"} = $WIDGETS{'FrameRAM'}->ProgressBar( 
#		-colors => [ 0, 'green', 70, 'yellow', 90, 'red' ], 
#	#	-width => 15, 
#		-length => 200 
#	);
#	  
#	$WIDGETS{"RAM$i"."Used"} = $WIDGETS{'FrameRAM'}->Label(	
#		-text  => "99p",
#		-anchor => 'e',
#		-width => 10
#		);
#			
#		
#			
#	$WIDGETS{"LabelRAM" . $i}->grid(
#	-row    => $i,
#	-column => 0,
#	-sticky => 'ew',
#	-in 	=> $WIDGETS{"FrameRAM"});
#	
#	$WIDGETS{"RAM$i"."Progress"}->grid(
#	-row    => $i,
#	-column => 1,
#	-sticky => 'ew',
#	-in 	=> $WIDGETS{"FrameRAM"});
#	
#	$WIDGETS{"RAM$i"."Used"}->grid(
#	-row    => $i,
#	-column => 2,
#	-sticky => 'ew',
#	-in 	=> $WIDGETS{"FrameRAM"});
#}																														
															
$WIDGETS{"LabelRAM"} = $WIDGETS{'FrameRAM'}->Label(	
	-text  => "RAM",
	-anchor => 'w');
	
$WIDGETS{"RAMProgress"} = $WIDGETS{'FrameRAM'}->ProgressBar( 
	-colors => [ 0, 'green', 70, 'yellow', 90, 'red' ], 
	#-width => 15,
	-length => 200,
	-blocks => 1
	); 
	  
$WIDGETS{"RAMUsed"} = $WIDGETS{'FrameRAM'}->Label(	
	-text  => "4096",
	-anchor => 'e');	
	

		$WIDGETS{"LabelRAM"}->grid(
	-row    => 0,
	-column => 0,
	-sticky => 'ew',
	-in 	=> $WIDGETS{"FrameRAM"});
	
		$WIDGETS{"RAMProgress"}->grid(
	-row    => 0,
	-column => 1,
	-sticky => 'ew',
	-in 	=> $WIDGETS{"FrameRAM"});
	
		$WIDGETS{"RAMUsed"}->grid(
	-row    => 0,
	-column => 2,
	-sticky => 'ew',
	-in 	=> $WIDGETS{"FrameRAM"});
	
	
##===================================================================#
##	DISK															#															
#																
#
#	
#===================================================================#
#	Network															#	
															


$WIDGETS{"LabelNETDown"} = $WIDGETS{'FrameNET'}->Label(	
	-text  => "Download: ");	
	
$WIDGETS{"NETDown"} = $WIDGETS{'FrameNET'}->Label(	
	-text  => "300Kb/s ");	

$WIDGETS{"LabelNETUp"} = $WIDGETS{'FrameNET'}->Label(	
	-text  => "Upload: ");	

$WIDGETS{"NETUp"} = $WIDGETS{'FrameNET'}->Label(	
	-text  => "100Kb/s ");

$WIDGETS{"LabelNETDown"}->grid(
	-row    => 0,
	-column => 0,
	-in => $WIDGETS{"FrameNET"});

$WIDGETS{"NETDown"}->grid(
	-row    => 0,
	-column => 1,
	-in => $WIDGETS{"FrameNET"});	
	
$WIDGETS{"LabelNETUp"}->grid(
	-row    => 0,
	-column => 2,
	-in => $WIDGETS{"FrameNET"});	
	
$WIDGETS{"NETUp"}->grid(
	-row    => 0,
	-column => 3,
	-in => $WIDGETS{"FrameNET"});		

my $n = 10;


$mw->repeat( 20 => \&run );
MainLoop;

sub run{

		if($n == 101){
			$n = 0;
		}
		$WIDGETS{"RAMProgress"}->value($n);
		$WIDGETS{"CPU1Progress"}->value($n);
		
		$cpu = "  $n" . " %";
		$n += 1;
		
		
}																	


