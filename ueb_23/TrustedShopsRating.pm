# --
# Kernel/System/PostMaster/Filter/TrustedShopsRating.pm - the global PostMaster module for OTRS
# Copyright (C) 2014 perl-services.de, http://perl-services.de/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::PostMaster::Filter::TrustedShopsRating;

use strict;
use Kernel::System::Ticket;

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

    $Self->{TicketObject} = Kernel::System::Ticket->new( %{$Self} );

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    for my $Needed (qw(JobConfig GetParam)) {
        if ( !$Param{$Needed} ) {
            $Self->{LogObject}->Log(
                Priority => 'error',
                Message  => "Need $Needed!",
            );
            return;
        }
    }

    my $Email = $Param{GetParam};

    $Self->{LogObject}->Log(
        Priority => 'error',
        Message  => $Self->{MainObject}->Dump( $Email ),
    );

    return 1;
}

1;

