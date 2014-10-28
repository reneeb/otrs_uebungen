#!/usr/bin/perl

use strict;
use warnings;

use Kernel::Config;
use Kernel::System::Log;
use Kernel::System::Encode;
use Kernel::System::Main;
use Kernel::System::DB;
use Kernel::System::ITSMConfigItem;

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

my $CIObject = Kernel::System::ITSMConfigItem->new(
    ConfigObject => $ConfigObject,
    LogObject    => $LogObject,
    EncodeObject => $EncodeObject,
    MainObject   => $MainObject,
    DBObject     => $DBObject,
);

my $CI = $CIObject->ConfigItemGet(
    ConfigItemID => $ARGV[0],
);

$CIObject->VersionAdd( %{ $CI }, InciStateID => $ARGV[1] );
