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

use Sys::Statistics::Linux;

my $total;

#===================================================================#
#	Globale Variablen												#
#===================================================================#

my %WIDGETS; 				#enthält alle Widgets

my $width = 370;
my $CPUanz;

my $lxs;

initialise();

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

$WIDGETS{'Notebook'} = $mw->NoteBook()->pack(-expand => 0, -fill => 'both');

$WIDGETS{'NotebookRessourcen'} = $WIDGETS{'Notebook'}->add("Ressourcen", 
	-label => "Ressourcen", -anchor => 'nw');
	
$WIDGETS{'NotebookProzesse'} = $WIDGETS{'Notebook'}->add("Prozesse", 
	-label => "Prozesse" );	

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
	-sticky => 'nswe');
	
$WIDGETS{'FrameRAM'}->grid(
	-row    => 1,
	-column => 0,
	-sticky => 'nswe');
	
$WIDGETS{'FrameDISK'}->grid(
	-row    => 2,
	-column => 0,
	-sticky => 'nswe');

$WIDGETS{'FrameNET'}->grid(
	-row    => 3,
	-column => 0,
	-sticky => 'nswe'
	);



#===================================================================#
#	CPU																#
my $cpu;															

for(my $i = 0; $i< $CPUanz; $i++){
	$WIDGETS{"LabelCPU" . $i} = $WIDGETS{'FrameCPU'}->Label(	
		-text  => "CPU" . $i . ": ",
		-anchor => 'e',
		);
	
	$WIDGETS{"CPU$i"."Progress"} = $WIDGETS{'FrameCPU'}->ProgressBar( 
		-colors => [ 0, 'green', 65, 'yellow', 85, 'red' ], 
		-width => 15, 
		-length => 250,
		-blocks => 100,
	);
	  
	$WIDGETS{"CPU$i"."Used"} = $WIDGETS{'FrameCPU'}->Label(	
		-width => 5,
		-anchor => 'e',
		-textvariable => \$cpu);
																	
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

$WIDGETS{"LabelCPUGesamt"} = $WIDGETS{'FrameCPU'}->Label(
	-text => "\nCPU Gesamt:");

my $canHeight	= 60;
my $canWidth	= 330;

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

$WIDGETS{'LabelCPUGesamt'}->grid(
	-row    => 6,
	-column => 1,
	-in 	=> $WIDGETS{"FrameCPU"});
	
	$WIDGETS{"CPUCanvas"}->grid(
	-row    => 7,
	-columnspan => 3,
	-in 	=> $WIDGETS{"FrameCPU"});
	
	
	

	


#===================================================================#
#	RAM																#														
#	
#$WIDGETS{"LabelRAMTotal"} = $WIDGETS{'FrameRAM'}->Label(	
#	-text  => "RAM Total/Used: ");	
#	
#$WIDGETS{"LabelRAMTotalUsed"} = $WIDGETS{'FrameRAM'}->Label(	
#	-text  => "16000/16000 KB/s");	

my $usedRAM;																		
															
$WIDGETS{"LabelRAM"} = $WIDGETS{'FrameRAM'}->Label(	
	-text  => "RAM: ",
	#-width => 10,
	-anchor => 'e',
	);
	
$WIDGETS{"RAMProgress"} = $WIDGETS{'FrameRAM'}->ProgressBar( 
	-colors => [ 0, 'green', 65, 'yellow', 85, 'red' ], 
	-width => 15,
	-length => 250,
	-blocks => 1
	); 
	
$WIDGETS{"RAMUsed"} = $WIDGETS{'FrameRAM'}->Label(	
	-width => 5,
	-anchor => 'e',
	-textvariable => \$usedRAM
	);	
	
#$WIDGETS{"LabelRAMTotal"}->grid(
#	-row    => 0,
#	-column => 0,
#	-in => $WIDGETS{"FrameRAM"});
#
#$WIDGETS{"LabelRAMTotalUsed"}->grid(
#	-row    => 0,
#	-column => 1,
#	-in => $WIDGETS{"FrameRAM"});		

$WIDGETS{"LabelRAM"}->grid(
	-row    => 1,
	-column => 0,
	-in 	=> $WIDGETS{"FrameRAM"});
	
$WIDGETS{"RAMProgress"}->grid(
	-row    => 1,
	-column => 1,
	-in 	=> $WIDGETS{"FrameRAM"});
	
$WIDGETS{"RAMUsed"}->grid(
	-row    => 1,
	-column => 2,
	-in 	=> $WIDGETS{"FrameRAM"});
	
	
#===================================================================#
#	DISK															#															
																

	
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


$mw->repeat( 1000 => \&update );
MainLoop;


sub initialise{
	#initialisieren aller sachen... z.B. Anzahl der CPUs, Gesamt RAM...	
	
	
	$lxs = Sys::Statistics::Linux->new(
        sysinfo  => 1,
        cpustats => 1,
        memstats => 1,
        diskusage => 1,
        netstats => 1);
        
    #### Anzahl der CPUs ermitteln ####    
	$CPUanz = $lxs->get()->sysinfo->{countcpus};
	
}

sub updateCPU{
	#auslesen der neuen werte und ausgeben in der GUI
	
	my $total;
	 my $stat = $lxs->get()->{cpustats};
	
	for(my $i = 0; $i < $CPUanz; $i++){
		$total = int( $stat->{"cpu" . "$i"}->{total});
			$WIDGETS{"CPU". $i . "Progress"}->value($total);
			$cpu = "$total" . " %";
		}	
}

sub updateRAM{
	my $total;
	my $stat = $lxs->get()->{memstats};
	
	$total = int(($stat->{memused}  / $stat->{memtotal}) * 100) ;
	
	
	$WIDGETS{"RAMProgress"}->value($total);
	$usedRAM = "$total" . " %";

}

sub updateDISK{
	
}

sub updateNET{
	
}


sub update{
	
	updateCPU();
	updateRAM();
	#updateDISK();
	#updateNET();
		
}																	


