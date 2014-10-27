use Kernel::Config;
use Kernel::System::Encode;
use Kernel::System::Log;
use Kernel::System::Main;
use Kernel::System::DB;

# Objekte
my $ConfigObject = Kernel::Config->new();
my $EncodeObject = Kernel::System::Encode->new(
    ConfigObject => $ConfigObject,
);
my $LogObject = Kernel::System::Log->new(
    ConfigObject => $ConfigObject,
    EncodeObject => $EncodeObject,
);
my $MainObject = Kernel::System::Main->new(
    ConfigObject => $ConfigObject,
    EncodeObject => $EncodeObject,
    LogObject    => $LogObject,
);

my $DBObject = Kernel::System::DB->new(
   ConfigObject => $ConfigObject,
   LogObject    => $LogObject,
   MainObject   => $MainObject,
   EncodeObject => $EncodeObject,
);

for my $QueueID ( 1, 2 ) {
    # SQL-Statement erstellen
    my $SQL = "SELECT COUNT(*) FROM ticket t INNER JOIN ticket_history th ON t.id = th.ticket_id WHERE t.queue_id = ? GROUP BY t.id";

    my @Bind = (\$QueueID);

    # Prepare
    $DBObject->Prepare(
        SQL  => $SQL,
        Bind => \@Bind,
    );

    my $NrTickets;
    my $SumActions = 0;
    while ( my @Row = $DBObject->FetchrowArray() ) {
        $NrTickets++;
        $SumActions += $Row[0];
    }

    if ( $NrTickets == 0 ) {
       print "Noch keine Daten für Queue $QueueID\n";
       next;
    }

    print "Queue $QueueID: ", ( $SumActions / $NrTickets ), "\n";
}
