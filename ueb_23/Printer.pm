# --
# Kernel/System/PostMaster/Filter/Printer.pm - Link ticket to the printer item
# Copyright (C) 2014 perl-services.de, http://perl-services.de/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::PostMaster::Filter::Printer;

use strict;
use Kernel::System::Ticket;
use Kernel::System::LinkObject;
use Kernel::System::ITSMConfigItem;

sub new {
    my $Type  = shift;
    my %Param = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    $Self->{Debug} = $Param{Debug} || 0;

    # get needed objects
    for my $Object (
        qw(ConfigObject LogObject DBObject TimeObject MainObject EncodeObject)
        )
    {
        $Self->{$Object} = $Param{$Object} || die "Got no $Object!";
    }

    $Self->{TicketObject}     = Kernel::System::Ticket->new( %{$Self} );
    $Self->{ConfigItemObject} = Kernel::System::ITSMConfigItem->new( %{$Self} );
    $Self->{LinkObject}       = Kernel::System::LinkObject->new( %{$Self} );

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    for my $Needed (qw(JobConfig GetParam TicketID)) {
        if ( !$Param{$Needed} ) {
            $Self->{LogObject}->Log(
                Priority => 'error',
                Message  => "Need $Needed!",
            );
            return;
        }
    }

    my $Email = $Param{GetParam};

    return 1 if $Email->{Subject} !~ m{Drucker\ 681}xms;

    my $CIs = $Self->{ConfigItemObject}->ConfigItemSearchExtended(
        Name => 'Drucker 681',
    ) || [];

    return 1 if !@{ $CIs };

    $Self->{LinkObject}->LinkAdd(
        SourceObject => 'Ticket',
        SourceKey    => $Param{TicketID},
        TargetObject => 'ITSMConfigItem',
        TargetKey    => $CIs->[0],
        Type         => 'Normal',
        State        => 'Valid',
        UserID       => 1,
    );

    return 1;
}

1;

