package Kernel::Modules::FrontendBasis;

use strict;
use warnings;

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {%Param};
    bless( $Self, $Type );

    # check all needed objects
    for my $Needed ( qw(ParamObject DBObject QueueObject LayoutObject ConfigObject LogObject)) {
        if ( !$Self->{$Needed} ) {
            $Self->{LayoutObject}->FatalError( 
                Message => "Got no $Needed!",
            );
        }
    }

    # create needed objects - don't forget to "use" the module
    # $Self->{NeededObject} = Kernel::System::Needed->new( %Param );

    return $Self;
}

sub Run {
    my ($Self, %Param) = @_;

    if ( $Self->{Subaction} eq 'xxxxx' ) {
        # $Self->{LayoutObject}->Block(
        #     Name => 'BlockName',
        #     Data => {
        #     },
        # );
    }

    my $Output = $Self->{LayoutObject}->Header();
    $Output .= $Self->{LayoutObject}->NavigationBar();
    # $Output .= $Self->{LayoutObject}->Output(
    #     TemplateFile => 'FrontendBasis',
    #     Data         => {
    #     },
    # );
    $Output .= $Self->{LayoutObject}->Footer();

    return $Output;
}

1;
