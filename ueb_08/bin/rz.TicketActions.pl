#!/usr/bin/perl

use strict;
use warnings;

use Kernel::Config;
use Kernel::System::Log;
use Kernel::System::Encode;
use Kernel::System::Main;
use Kernel::System::DB;

my $ConfigObject = Kernel::Config->new();
my $LogObject    = Kernel::System::Log->new(
    ConfigObject => $ConfigObject,
    Prefix       => 'ueb01',
);
my $EncodeObject = Kernel::System::Encode->new();
my $MainObject   = Kernel::System::Main->new(
    ConfigObject => $ConfigObject,
    LogObject    => $LogObject,
    EncodeObject => $EncodeObject,
);
my $DBObject = Kernel::System::DB->new(
    ConfigObject => $ConfigObject,
    LogObject    => $LogObject,
    EncodeObject => $EncodeObject,
    MainObject   => $MainObject,
);

my $QueueIDs = $ConfigObject->Get('Uebung::Queues') || [];
my $SQL = 'SELECT t.queue_id, t.id, COUNT(*) FROM ticket_history th '
    . ' INNER JOIN ticket t ON t.id = th.ticket_id '
    . ' WHERE t.queue_id IN ( ' . join( ', ', ('?') x @{ $QueueIDs } ) . ')'
    . ' GROUP BY t.id';
$DBObject->Prepare(
    SQL  => $SQL,
    Bind => [ map{ \$_ }@{ $QueueIDs } ],
);

my %Data;
while ( my @Row = $DBObject->FetchrowArray() ) {
    $Data{ $Row[0] }->{Count} += $Row[2];
    $Data{ $Row[0] }->{Tickets}++;
}

for my $Queue ( @QueueIDs ) {
    my $Ratio = sprintf "%.2f", $Data{$Queue}->{Count} / $Data{$Queue}->{Tickets};
    print sprintf "%s: %s\n", $Queue, $Ratio;
}
