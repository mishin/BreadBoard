#!/usr/bin/perl

use strict;
use warnings;

use Test::More;
use Test::Exception;
use Test::Moose;

BEGIN {
    use_ok('Bread::Board');
}

{
    package Desk;
    use Moose;

    package Chair;
    use Moose;

    package Cubicle;
    use Moose;

    has 'desk' => (
        is       => 'ro',
        isa      => 'Desk',
        required => 1,
    );

    has 'chair' => (
        is       => 'ro',
        isa      => 'Chair',
        required => 1,
    );

    package KeyCard;
    use Moose;
    use Moose::Util::TypeConstraints;

    subtype 'KeyCardUUID' => as 'Str';

    has 'uuid' => (
        is       => 'ro',
        isa      => 'KeyCardUUID',
        required => 1,
    );

    package Employee;
    use Moose;

    has [ 'first_name', 'last_name' ] => (
        is       => 'ro',
        isa      => 'Str',
    );

    has 'keycard' => (
        is       => 'ro',
        isa      => 'KeyCard',
        required => 1,
    );

    has 'cubicle' => (
        is       => 'ro',
        isa      => 'Cubicle',
        required => 1,
    );
}

my $UUID = 0;

my $c = container 'Initech' => as {

    service 'keycard_uuid_generator' => (
        block => sub { ++$UUID }
    );

    typemap 'KeyCardUUID' => 'keycard_uuid_generator';
    typemap 'Employee'    => infer;
};

my $micheal = $c->resolve( type => 'Employee' );
my $samir   = $c->resolve( type => 'Employee' );

isnt($micheal, $samir, '... two different employees');
isnt($micheal->cubicle, $samir->cubicle, '... two different cubicles');
isnt($micheal->cubicle->chair, $samir->cubicle->chair, '... two different cubicle chairs');
isnt($micheal->cubicle->desk, $samir->cubicle->desk, '... two different cubicle desks');
isnt($micheal->keycard, $samir->keycard, '... two different keycards');
isnt($micheal->keycard->uuid, $samir->keycard->uuid, '... two different keycard uuids');

done_testing;