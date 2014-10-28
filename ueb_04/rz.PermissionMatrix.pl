#!/usr/bin/perl

use strict;
use warnings;

use Kernel::Config;
use Kernel::System::Log;
use Kernel::System::Encode;
use Kernel::System::Main;
use Kernel::System::DB;
use Kernel::System::Group;
use Kernel::System::User;

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

my $UserObject = Kernel::System::User->new(
    ConfigObject => $ConfigObject,
    LogObject    => $LogObject,
    EncodeObject => $EncodeObject,
    MainObject   => $MainObject,
    DBObject     => $DBObject,
);

my $GroupObject = Kernel::System::Group->new(
    ConfigObject => $ConfigObject,
    LogObject    => $LogObject,
    EncodeObject => $EncodeObject,
    MainObject   => $MainObject,
    DBObject     => $DBObject,
);

my %UserList = $UserObject->UserList(
    Type => 'Long',
);

my %GroupList = $GroupObject->GroupList();

my @Lines;
for my $UserID ( sort{ $UserList{$a} cmp $UserList{$b} }keys %UserList ) {
    my %UserGroups;

    TYPE:
    for my $PermissionType ( qw/ro move_into rw create owner priority/ ) {
        my %Groups = $GroupObject->GroupMemberList(
            UserID => $UserID,
            Type   => $PermissionType,
            Result => 'HASH',
        );

        for my $GroupName ( values %Groups ) {
            $UserGroups{$GroupName} = 1;
        }
    }

    my $Line = join ",", 
        $UserList{$UserID},
        map{ $UserGroups{$_} ? 1 : '' } sort values %GroupList;
    push @Lines, $Line;
}

my $FileContent = join "\n", @Lines;

$MainObject->FileWrite(
    Location => '/tmp/permissions.csv',
    Content  => \$FileContent,
);
