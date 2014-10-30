package Kernel::Modules::AdminPermissionMatrix;

use strict;
use warnings;

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {%Param};
    bless( $Self, $Type );

    # check all needed objects
    for my $Needed ( qw(ParamObject DBObject QueueObject LayoutObject ConfigObject LogObject GroupObject UserObject)) {
        if ( !$Self->{$Needed} ) {
            $Self->{LayoutObject}->FatalError( 
                Message => "Got no $Needed!",
            );
        }
    }

    return $Self;
}

sub Run {
    my ($Self, %Param) = @_;

    my %UserList = $Self->{UserObject}->UserList(
        Type => 'Long',
    );
    
    my %RoleList = $Self->{GroupObject}->RoleList();
    my %ReverseRoleList = reverse %RoleList;

    for my $RoleName ( sort keys %ReverseRoleList ) {
        $Self->{LayoutObject}->Block(
            Name => 'Role',
            Data => {
                Name => $RoleName,
            },
        );
    }
    
    for my $UserID ( sort{ $UserList{$a} cmp $UserList{$b} }keys %UserList ) {

        $Self->{LayoutObject}->Block(
            Name => 'UserRoles',
            Data => {
                Username => $UserList{$UserID},
            },
        );
    
        my %UserRoles = $Self->{GroupObject}->GroupUserRoleMemberList(
            UserID => $UserID,
            Result => 'HASH',
        );
    
        for my $RoleName ( sort keys %ReverseRoleList ) {
            my $RoleID = $ReverseRoleList{$RoleName};
            my $Active = $UserRoles{$RoleID} ? 'X' : '';

            $Self->{LayoutObject}->Block(
                Name => 'UserRole',
                Data => {
                    Active => $Active,
                },
            );
        }
    }

    my $Output = $Self->{LayoutObject}->Header();
    $Output .= $Self->{LayoutObject}->NavigationBar();
    $Output .= $Self->{LayoutObject}->Output(
        TemplateFile => 'AdminPermissionMatrix',
        Data         => {
        },
    );
    $Output .= $Self->{LayoutObject}->Footer();

    return $Output;
}

1;
