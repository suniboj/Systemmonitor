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

my $width = 300;
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

$WIDGETS{'NotebookRessourcen'} = $WIDGETS{'Notebook'}->add("Ressourcen", -label => "Ressourcen");
$WIDGETS{'NotebookRessourcen'}->Label()->pack();

$WIDGETS{'NotebookProzesse'} = $WIDGETS{'Notebook'}->add("Prozesse", -label => "Prozesse");
$WIDGETS{'NotebookProzesse'}->Label()->pack();

$WIDGETS{'Notebook'}->pack(-fill => 'both', -expand => 1,);


#===================================================================#
#	Ressourcen														#
#===================================================================#

#===================================================================#
#	CPU																#
																

$WIDGETS{'FrameCPU'}=$WIDGETS{'NotebookRessourcen'}->Labelframe(-width => $width,
																-height => 200,
																-text => 'CPU',)->pack();
for(my $i = 1; $i<= $CPUanz; $i++){
	$WIDGETS{"LabelCPU" . $i} = $WIDGETS{'FrameCPU'}->Label(	-text  => "CPU" . $i,
																	-width => 6)->pack();
	$WIDGETS{"CPU.$i.Progress"} = $WIDGETS{'FrameCPU'}
	  ->ProgressBar( -colors => [ 0, 'green', 70, 'yellow', 90, 'red' ] )->pack();
	
	#===================================================================#
	#	Label und ProgressBar ausrichten								#
	
	$WIDGETS{"LabelCPU" . $i}->grid(
	-row    => $i,
	-column => 0);
	
	$WIDGETS{"CPU.$i.Progress"}->grid(
	-row    => $i,
	-column => 1);
}


															
																																				
$WIDGETS{'FrameRAM'}=$WIDGETS{'NotebookRessourcen'}->Labelframe(-width => $width,
    															-height => 50,
																-text => 'RAM',)->pack(-pady => 5);
																
$WIDGETS{'FrameDISK'}=$WIDGETS{'NotebookRessourcen'}->Labelframe(-width => $width,
    															-height => 50,
																-text => 'DISKS',)->pack(-pady => 5);	
															
$WIDGETS{'FrameNET'}=$WIDGETS{'NotebookRessourcen'}->Labelframe(-width => $width,
    															-height => 50,
																-text => 'NETWORK',)->pack(-pady => 5);																						

MainLoop();
