#!/usr/bin/perl

use strict;
use warnings;

use Kernel::Config;
use Kernel::System::Log;
use Kernel::System::Encode;
use Kernel::System::Main;
use Kernel::System::DB;
use Kernel::System::Ticket;

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

my $TicketObject = Kernel::System::DB->new(
    ConfigObject => $ConfigObject,
    LogObject    => $LogObject,
    EncodeObject => $EncodeObject,
    MainObject   => $MainObject,
    DBObject     => $DBObject,
);

my $TicketID = $TicketObject->TicketCreate(
    Title          => 'Ein automatisch erstelltes Ticket',
    QueueID        => 1,
    Lock           => 'unlock',
    PriorityID     => 3,
    State          => 'new',
    CustomerID     => 12345,
    CustomerUserID => 'test@test.de',
    OwnerID        => 1,
    UserID         => 1,
);

$TicketObject->ArticleCreate(
    TicketID       => $TicketID,
    ArticleType    => 'note-internal', # email-external|email-internal|phone|fax|...
    SenderType     => 'agent', # agent|system|customer
    Subject        => 'some short description', # required
    Body           => 'the message text', # required
    Charset        => 'ISO-8859-15',
    MimeType       => 'text/plain',
    HistoryType    => 'AddNote', # EmailCustomer|Move|AddNote|PriorityUpdate|WebRequestCustomer|...
    HistoryComment => 'Some free text!',
    UserID         => 1,
);

