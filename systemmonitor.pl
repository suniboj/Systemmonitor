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
use Tk::NoteBook;                               #Reiter
use Tk::Labelframe;                             #Frame mit Bezeichnung
use Tk::ProgressBar;                            #Anzeigebalken
#use Tk::Table;
use Tk::MListbox;

use Sys::Statistics::Linux;                     #Modul zum Auslesen der Systeminformationen

use Data::Dumper;

my $total;

#===================================================================#
#	Globale Variablen												#
#===================================================================#
my $mw;

my %WIDGETS;                                    #Hash der alle Widgets enthält

my $width = 370;                                #Breite des Fensters

my $CPUanz;                                     #Anzahl der CPU Kerne

my $lxs;                                        #Variable für die Statistiken

my @volumes;

my @networks;

my $canHeight = 60;
my $canWidth  = 330;

my $xold = 0;
my $yold = $canHeight;



#===================================================================#
#	Initialisieren													#
#===================================================================#

initialise();                                   #Initialisieren der Systeminformationen

createGUI();

$mw->repeat( 1000 => \&update );
MainLoop;

sub initialise {

	#initialisieren aller sachen... z.B. Anzahl der CPUs, Gesamt RAM...

	$lxs = Sys::Statistics::Linux->new(
		sysinfo   => 1,
		cpustats  => 1,
		memstats  => 1,
		diskstats => 1,
		netstats  => 1
	);

	#### Anzahl der CPUs ermitteln ####
	$CPUanz = $lxs->get()->sysinfo->{countcpus};

	#### Datenträger ermitteln ####
	@volumes =
		sort( map { m/^(sd[a-z]{1}$)/ ? $_ : () }
			keys $lxs->get()->{diskstats} );

	@networks = sort( map { $_ } keys $lxs->get()->{netstats} );

} ## ---------- end sub initialise

sub createGUI {

	#===================================================================#
	#	MainWindow														#
	#===================================================================#

	$mw = MainWindow->new;                      #Hauptfenster

	$mw->title("Systemmonitor");

	$mw->minsize( $width, 400 );

	$mw->maxsize( $width, 999 );

	#===================================================================#
	#	Reiter (Notebook) erstellen										#

	$WIDGETS{'Notebook'} =
		$mw->NoteBook()->pack( -expand => 0, -fill => 'both' );

	$WIDGETS{'NotebookRessourcen'} =
		$WIDGETS{'Notebook'}->add( "Ressourcen", -label => "Ressourcen" );

	$WIDGETS{'NotebookProzesse'} =
		$WIDGETS{'Notebook'}->add( "Prozesse", -label => "Prozesse" );

	#===================================================================#
	#	Ressourcen - LabelFrames erstellen								#

	$WIDGETS{'FrameCPU'} =
		$WIDGETS{'NotebookRessourcen'}->Labelframe( -text => 'CPU' );

	$WIDGETS{'FrameRAM'} =
		$WIDGETS{'NotebookRessourcen'}->Labelframe( -text => 'RAM' );

	$WIDGETS{'FrameDISK'} = $WIDGETS{'NotebookRessourcen'}->Labelframe(
		-height => 50,
		-text   => 'DISKS'
	);

	$WIDGETS{'FrameNET'} = $WIDGETS{'NotebookRessourcen'}->Labelframe(
		-height => 50,
		-text   => 'NETWORK'
	);

	#===================================================================#
	#	Frames ausrichten												#

	$WIDGETS{'FrameCPU'}->grid(
		-row    => 0,
		-column => 0,
		-sticky => 'nswe'
	);

	$WIDGETS{'FrameRAM'}->grid(
		-row    => 1,
		-column => 0,
		-sticky => 'nswe'
	);

	$WIDGETS{'FrameDISK'}->grid(
		-row    => 2,
		-column => 0,
		-sticky => 'nswe'
	);

	$WIDGETS{'FrameNET'}->grid(
		-row    => 3,
		-column => 0,
		-sticky => 'nswe'
	);

	#===================================================================#
	#	CPU																#
	#===================================================================#

	#===================================================================#
	#	CPU Widgets (Label, Progressbar, Percent) erstellen				#

	for ( my $i = 0; $i < $CPUanz; $i++ ) {

		$WIDGETS{ "LabelCPU" . $i } = $WIDGETS{'FrameCPU'}->Label(
			-text   => "CPU" . $i . ": ",
			-anchor => 'e',
		);

		$WIDGETS{ "CPU$i" . "Progress" } = $WIDGETS{'FrameCPU'}->ProgressBar(
			-colors => [ 0, 'green', 65, 'yellow', 85, 'red' ],
			-width  => 15,
			-length => 250,
			-blocks => 100,
		);

		$WIDGETS{ "CPU$i" . "Used" } = $WIDGETS{'FrameCPU'}->Label(
			-width        => 5,
			-anchor       => 'e',
			-textvariable => \$WIDGETS{ "cpu" . $i }
		);

		#===================================================================#
		#	CPU Widgets (Label, Progressbar, Percent) ausrichten			#

		$WIDGETS{ "LabelCPU" . $i }->grid(
			-row    => $i,
			-column => 0,
			-in     => $WIDGETS{"FrameCPU"}
		);

		$WIDGETS{ "CPU$i" . "Progress" }->grid(
			-row    => $i,
			-column => 1,
			-in     => $WIDGETS{"FrameCPU"}
		);

		$WIDGETS{ "CPU$i" . "Used" }->grid(
			-row    => $i,
			-column => 2,
			-in     => $WIDGETS{"FrameCPU"}
		);

	}

	#===================================================================#
	#	CPU Canvas erstellen											#

	$WIDGETS{"LabelCPUGesamt"} =
		$WIDGETS{'FrameCPU'}->Label( -text => "\nCPU Gesamt:" );

	$WIDGETS{"CPUCanvas"} = $WIDGETS{FrameCPU}->Canvas(
		-height      => $canHeight,
		-width       => $canWidth,
		-background  => 'white',
		-borderwidth => 1,
		-relief      => 'sunken'
	);

	$WIDGETS{"CPUCanvas"}
		->createGrid( 3, 3, ( $canWidth / 8 ) - 2, ( $canHeight / 2 ) + 2 );

	#$WIDGETS{"CPUCanvas"}->createRectangle( 1, 2, $canWidth+1, $canHeight+1 );
#### 100% ####
	$WIDGETS{"CPUCanvas"}->createText( 19, 8, -text => "100%" );

#### 0%	####
	$WIDGETS{"CPUCanvas"}->createText( 11, $canHeight - 4, -text => "0%" );

	#===================================================================#
	#	CPU Canvas ausrichten											#

	$WIDGETS{'LabelCPUGesamt'}->grid(
		-row    => 6,
		-column => 1,
		-in     => $WIDGETS{"FrameCPU"}
	);

	$WIDGETS{"CPUCanvas"}->grid(
		-row        => 7,
		-columnspan => 3,
		-in         => $WIDGETS{"FrameCPU"}
	);

	#===================================================================#
	#	RAM																#
	#===================================================================#

	my $usedRAMpercent;
	my $usedRAM;

	#===================================================================#
	#	RAM Widgets erstellen											#

	$WIDGETS{"LabelRAM"} = $WIDGETS{'FrameRAM'}->Label(
		-text   => "RAM: ",
		-anchor => 'e',
	);

	$WIDGETS{"RAMProgress"} = $WIDGETS{'FrameRAM'}->ProgressBar(
		-colors => [ 0, 'green', 65, 'yellow', 85, 'red' ],
		-width  => 15,
		-length => 250,
		-blocks => 1
	);

	$WIDGETS{"RAMUsedPercent"} = $WIDGETS{'FrameRAM'}->Label(
		-width        => 5,
		-anchor       => 'e',
		-textvariable => \$WIDGETS{"usedRAMpercent"}
	);

	$WIDGETS{"LabelRAMUsed"} = $WIDGETS{'FrameRAM'}->Label(
		-text   => "Used/Total: ",
		-anchor => 'e',
	);

	$WIDGETS{"RAMUsed"} = $WIDGETS{'FrameRAM'}->Label(
		-anchor       => 'w',
		-textvariable => \$WIDGETS{"usedRAM"}
	);

	#===================================================================#
	#	RAM Widgets ausrichten											#

	$WIDGETS{"LabelRAM"}->grid(
		-row    => 0,
		-column => 0,
		-in     => $WIDGETS{"FrameRAM"}
	);

	$WIDGETS{"RAMProgress"}->grid(
		-row    => 0,
		-column => 1,
		-in     => $WIDGETS{"FrameRAM"}
	);

	$WIDGETS{"RAMUsedPercent"}->grid(
		-row    => 0,
		-column => 2,
		-in     => $WIDGETS{"FrameRAM"}
	);

	$WIDGETS{"LabelRAMUsed"}->grid(
		-row        => 1,
		-columnspan => 2,
		-sticky     => 'w',
		-in         => $WIDGETS{"FrameRAM"}
	);

	$WIDGETS{"RAMUsed"}->grid(
		-row    => 1,
		-column => 1,
		-in     => $WIDGETS{"FrameRAM"}
	);

	#===================================================================#
	#	DISK															#
	#===================================================================#

	#===================================================================#
	#	DISK Widgets erstellen											#

	foreach (@volumes) {
		$WIDGETS{ "LabelDISK" . $_ } = $WIDGETS{'FrameDISK'}->Label(

			#-background => 'red',
			-text   => "$_:",
			-anchor => 'w',
			-width  => 6,
		);

		$WIDGETS{ "LabelDISKRead" . $_ } = $WIDGETS{'FrameDISK'}->Label(

			#-background => 'blue',
			-text   => "Read: ",
			-anchor => 'w'
		);

		$WIDGETS{ "DISKRead" . $_ } = $WIDGETS{'FrameDISK'}->Label(

			#-background => 'red',
			-anchor       => 'e',
			-width        => 13,
			-textvariable => \$WIDGETS{ "diskRead" . $_ }
		);

		$WIDGETS{ "LabelDISKWrite" . $_ } = $WIDGETS{'FrameDISK'}->Label(

			#-background => 'blue',
			-width  => 7,
			-text   => "Write: ",
			-anchor => 'e',
		);

		$WIDGETS{ "DISKWrite" . $_ } = $WIDGETS{'FrameDISK'}->Label(

			#-background => 'red',
			-width        => 13,
			-anchor       => 'e',
			-textvariable => \$WIDGETS{ "diskWrite" . $_ }
		);
	}

	#===================================================================#
	#	DISK Widgets ausrichten											#

	my $row = 0;

	foreach (@volumes) {

		$WIDGETS{ "LabelDISK" . $_ }->grid(
			-row    => $row,
			-column => 0,
			-sticky => 'nw',
			-in     => $WIDGETS{"FrameDISK"}
		);

		$WIDGETS{ "LabelDISKRead" . $_ }->grid(
			-row    => $row,
			-column => 1,
			-in     => $WIDGETS{"FrameDISK"},

			#-sticky => 'e',
		);

		$WIDGETS{ "DISKRead" . $_ }->grid(
			-row    => $row,
			-column => 2,
			-in     => $WIDGETS{"FrameDISK"},
			-sticky => 'w',
		);

		$WIDGETS{ "LabelDISKWrite" . $_ }->grid(
			-row    => $row,
			-column => 3,
			-in     => $WIDGETS{"FrameDISK"},
			-sticky => 'w',
		);

		$WIDGETS{ "DISKWrite" . $_ }->grid(
			-row    => $row,
			-column => 4,
			-in     => $WIDGETS{"FrameDISK"},
			-sticky => 'w',
		);

		$row++;
	}

	#===================================================================#
	#	Network															#
	#===================================================================#

	#===================================================================#
	#	Network Widgets erstellen										#

	foreach (@networks) {

		$WIDGETS{ "LabelNET" . $_ } = $WIDGETS{'FrameNET'}->Label(

			#-background => 'red',
			-text   => "$_:",
			-width  => 6,
			-anchor => 'w'
		);

		$WIDGETS{ "LabelNETDown" . $_ } = $WIDGETS{'FrameNET'}->Label(

			#-background => 'blue',
			-text   => "Down: ",
			-anchor => 'w'
		);

		$WIDGETS{ "NETDown" . $_ } = $WIDGETS{'FrameNET'}->Label(

			#-background => 'red',
			-anchor       => 'e',
			-width        => 13,
			-textvariable => \$WIDGETS{ "netdown" . $_ }

		);

		$WIDGETS{ "LabelNETUp" . $_ } = $WIDGETS{'FrameNET'}->Label(

			#-background => 'blue',
			-text   => "Up:",
			-anchor => 'e',
			-width  => 7,
		);

		$WIDGETS{ "NETUp" . $_ } = $WIDGETS{'FrameNET'}->Label(

			#-background => 'red',
			-anchor       => 'e',
			-width        => 13,
			-textvariable => \$WIDGETS{ "netup" . $_ },
		);
	}

	#===================================================================#
	#	Network Widgets ausrichten										#

	$row = 0;

	foreach (@networks) {
		$WIDGETS{ "LabelNET" . $_ }->grid(
			-row    => $row,
			-column => 0,
			-in     => $WIDGETS{"FrameNET"}
		);

		$WIDGETS{ "LabelNETDown" . $_ }->grid(
			-row    => $row,
			-column => 1,
			-in     => $WIDGETS{"FrameNET"}
		);

		$WIDGETS{ "NETDown" . $_ }->grid(
			-row    => $row,
			-column => 2,
			-in     => $WIDGETS{"FrameNET"}
		);

		$WIDGETS{ "LabelNETUp" . $_ }->grid(
			-row    => $row,
			-column => 3,
			-in     => $WIDGETS{"FrameNET"}
		);

		$WIDGETS{ "NETUp" . $_ }->grid(
			-row    => $row,
			-column => 4,
			-in     => $WIDGETS{"FrameNET"}
		);

		$row++;
	}
	
	my %red   = qw(-bg red -fg white);
my %green = qw(-bg green -fg white);
my %white = qw(-fg black);
	
	$WIDGETS{"ProzessTabelle"} = $WIDGETS{"NotebookProzesse"}->Scrolled(
  'MListbox',
  -scrollbars         => 'osoe',
  -background         => 'white',
  -textwidth          => 10,
  -highlightthickness => 2,
  -width              => 0,
  -selectmode         => 'browse',
  -bd                 => 2,
  -columns            => [
    [ -text => "Name", -width => 17  ],
    [ -text => "CPU %"],
    [ -text => "RAM %"],
    [ -text => "PID"]
  ]
)->pack( -expand => 1, -fill => 'both', -anchor => 'w' );

	$WIDGETS{"ProzessTabelle"}->insert('end', ["test1", "test1", "test1", "test1"]);
$WIDGETS{"ProzessTabelle"}->insert('end', ["test2", "test2", "test2", "test2"]);
$WIDGETS{"ProzessTabelle"}->insert('end', ["test3", "test3", "test3", "test3"]);
	


} ## ---------- end sub createGUI

sub updateCPU {

	#auslesen der neuen werte und ausgeben in der GUI

	my $total;
	my $stat = $lxs->get()->{cpustats};


	for ( my $i = 0; $i < $CPUanz; $i++ ) {
		$total = int( $stat->{ "cpu" . "$i" }->{total} );
		$WIDGETS{ "CPU" . $i . "Progress" }->value($total);
		$WIDGETS{ "cpu" . $i } = "$total" . " %";
	}

		$WIDGETS{"CPUCanvas"}->createLine($xold, $yold, $xold+20, $canHeight/100*(101-$total),
					-tags => 'graph',
					-fill => 'red'
				);

	
	$xold += 20;							# Schritte in X-Richtung pro Sekunde
	$yold = $canHeight/100*(101-$total);
	

	if ( $xold > $canWidth ) {
		$xold = 0;
		$WIDGETS{"CPUCanvas"}->delete("graph");
	}
	

} ## ---------- end sub updateCPU

sub updateRAM {
	my $total;
	my $stat = $lxs->get()->{memstats};

	$total = int( ( $stat->{memused} / $stat->{memtotal} ) * 100 );

	$WIDGETS{"RAMProgress"}->value($total);
	$WIDGETS{"usedRAMpercent"} = "$total" . " %";

	my $used     = int( $stat->{memused} / 1000 );
	my $totalmem = int( $stat->{memtotal} / 1000 );

	$WIDGETS{"usedRAM"} = "$used MB / $totalmem MB";

} ## ---------- end sub updateRAM

sub updateDISK {
	my $stat = $lxs->get()->{diskstats};

	foreach (@volumes) {

		$WIDGETS{ "diskRead" . $_ } =
			sprintf( "%.2f", $$stat{$_}{"rdbyt"} / 1024 / 1024 ) . " MB/s";
		$WIDGETS{ "diskWrite" . $_ } =
			sprintf( "%.2f", $$stat{$_}{"wrtbyt"} / 1024 / 1024 ) . " MB/s";
	}

} ## ---------- end sub updateDISK

sub updateNET {

	my $stat = $lxs->get()->{netstats};

	foreach (@networks) {

		$WIDGETS{ "netdown" . $_ } =
			sprintf( "%.3f", $$stat{$_}{"rxbyt"} / 1024 / 1024 ) . " MB/s";
		$WIDGETS{ "netup" . $_ } =
			sprintf( "%.3f", $$stat{$_}{"txbyt"} / 1024 / 1024 ) . " MB/s";
	}
} ## ---------- end sub updateNET

sub updateProcess{
	$WIDGETS{"ProzessTabelle"}->insert('end', ["test1", "test1", "test1", "test1"]);
$WIDGETS{"ProzessTabelle"}->insert('end', ["test2", "test2", "test2", "test2"]);
$WIDGETS{"ProzessTabelle"}->insert('end', ["test3", "test3", "test3", "test3"]);
	
}

sub update {

	updateCPU();
	updateRAM();
	updateDISK();
	updateNET();
	#updateProcess();
	

} ## ---------- end sub update

