#!/usr/bin/perl

# gpl
# 
#  Author: Renwix (renwix@gmail.com)
#  Maintainer: Renwix
#  Copyright (C) 2008 Renwix, all rights reserved.
#  Created: Tue Sep 23 23:52:17 MDT 2008
# 
# 
#=======================================================================
# 
# This file is part of theSiliProject, a humorous software organization,
# design and development toolkit.
# 
# theSiliProject is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# theSiliProject is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with theSiliProject. If not, see <http://www.gnu.org/licenses/>.
# 
#=======================================================================
# 
# /gpl

=pod

=head1 NAME

sili - The top level glue. Most commands in the sili world will start here.

=head1 SYNOPSIS

There are several different 'modes' that sili can be run in:

Execute a target for a list of modules. It is best to use --target for
the name of the target to match, but sili will attempt to derive it
from the commandline. Packages should always use the --packages flag
unless running against all defined packages - which is the default
case. There

    > sili -t deploy
    > sili -t deploy -p mod1
    > sili -t deploy -p mod1 -p  mod2 -p mod3
    > sili -p mod1 -p  mod2 -p mod3 deploy

It can also be used to run an arbitrary command against package(s).

    > sili -p mod1 -p mod2 ls -al
    > sili ls -al

It will also tell you the environment that it is querying to derive
its work to do. And if you tell it 2x, it will tell you derived
environment.

    > sili --env
    > sili --env --env
    > sili -ee

It can also be used to manage multiple roots. If you have several
codelines that you are working in parallel, then this can help point
sili at the correct environment.

    > sili --which

It will also tell you environmental information about where it as
installed and whatnot.

    > sili --libpath
    > sili --binpath
    > sili --tplpath

And it will tell you its version as well.

    > sili --version

=head1 DESCRIPTION

In order to use sili, you need to set the SILI env var, or use the
--sili flag on the command line. This variable should point at the
sili definition that will be processed. Additionally, if you are using
the --which flag, then the SILID variable should be set to a file that
contains a list of environment definitions. The only real requirement
of a SILID file is that is defines the \$silis variable without a
'my'. Here is an example:

    package Def;
    use Sili::Ness;
    defineClass
        isa => Sili::Ness,
        param( name => 'name',
               doc => 'The name of the definition'),
        param( name => 'description',
               doc => 'The description of the definition' ),
        param( name => 'ROOT',
               doc => 'The root location on disk where the definition occurs' ),
        param( name => 'SILI',
               doc => 'A Pointer to the env definition file' ),
        param( name => 'target',
               isa => 'Target',
               doc => 'A target that can be applied to the Def' ),
        ;

    package Target;
    use Sili::Ness;
    defineClass
        isa => Sili::Ness,
        param( name => 'name',
               doc => 'The name of the target'),
        param( name => 'command',
               doc => 'The command to run in the directory' ),
        ;

    package main;
    use Sili::Ness;

    # usually silis wouldn't = silid... but in this case they do.
    $silis = [
              new Def( name => 'sili',
                       description => 'The sili codeline',
                       ROOT => '/home/user/sili',
                       SILI => \$ENV{SILID},
                       target => new Target( name => 'build',
                                             command => 'ant' )),
              new Def( name => 'tests',
                       description => 'The tests in the sili codeline',
                       ROOT => '/home/user/sili/tests',
                       SILI => \$ENV{SILID} ),
              ];

This demonstrates nested Sili::Ness, using 'defineClass' to simplify
the perl declarations, nested Sili::Ness, and multiple namespaces in
the same file. The last one isn't a requirement - just a function of
this example. If you had a Tuple describing how you think about your
environment, then you could use that Tuple in a library and just 'use'
it into any of your SILID definition files.

If you set the SILID environment variable to a file containing the
blurb above, then run C<sili -w>, you will see:

     0) sili: The sili codeline
     1) tests: The tests in the sili codeline

That is a picklist which allows you to choose the Def that you want to
work with and set the rest of the data in the Def (in this case) as
shell export variables. Like so:

    export ROOT="/home/renwick/work/sili/tests"; export SILI="/home/renwick/work/sili/tests/silid_1.pl";

Wrapping that in an C<eval $(sili -w)> will give you a chooser for
setting your local environment to point at different roots (for
example) from the same command line interface. The benefit being that
all the sili commands will continue to work, but be relative to the
new "context" defined by your SILI pointer. No more having to remember
where something lives or some special edge case about it.


=cut

use Sili::NamedParams;
use Sili::Ness;
use Sili::Q;
use Getopt::Long;
use Data::Dumper;
use Carp;
$| = 0;


sub _get_objs [$tag:required, $list:required] {
  return unless $tag;
  my @targets = query_by_type( type => $tag,
                               list => $list );
  if ( @targets == 0 ) {
    @targets = query_by_key( key => 'name',
                             match => $tag,
                             list => $list );
  }
  return @targets;
}

sub choose_silis {

  require $ENV{SILID} || CONFESS "Sili requires the SILID variable to be set: $@";
  debugPrint 1, $ENV{SILID}, " ", Dumper($silis);
  $silis || USAGE "specify \$silid in $ENV{SILID}";

  my $i = 0;
  for (my $i=0; $i<@$silis; $i++) {
    print STDERR " $i) " . $silis->[$i]->{name} . ': ' .
        $silis->[$i]->{description} . "\n";
  }
  my $choice = <>; chomp $choice;
  CONFESS "pick a choice between 0 and " . scalar @$silis
      if $choice < 0 || $choice > @$silis;

  my $o = '';
  while (my ($k, $v) = each %{ $silis->[$choice] }) {
    next if $k eq 'name' || $k eq 'description';
    $o .= "export $k=\"$v\"; ";
  }
  print $o;
}

sub show_silis { print STDERR Dumper( @_ ) }
sub binpath { print "$ENV{SILIHOME}/share/thesiliproject/bin" }
sub libpath { print "$ENV{SILIHOME}/share/thesiliproject/lib" }
sub version { print "grrr" }

my @targets; my @packages;
my $sili = $ENV{SILI};

getopts
    'binpath' => \$binpath,
    'libpath' => \$libpath,
    'tplpath' => \$tplpath,
    'version' => \$version,
    'env+'    => \$show_silis,
    'which'   => \$choose_silis,
    'compile' => \$compile,
    'packages:s' => \@pkgNames,
    'target:s'  => \$targetName,
    'silis:s'   => \$sili,
    ;
$binpath && binpath() && exit 0;
$libpath && libpath() && exit 0;
$tplpath && templateRepo() && exit 0;
$rplpath && rplpath() && exit 0;
$version && version() && exit 0;
$choose_silis && choose_silis() && exit 0;

# load the definition
require $sili || CONFESS "Sili requires the SILI env var to be set: $@";
if ($show_silis == 1) {
  show_silis( $silis ) && exit 0;
}

# check for required compilation
if ($compile) {
  my $ast = []; my @failures = (); my $pushed_failues = 0;
  while (my $s = shift @$silis) {
    if ($s &&
        $s->isa('Sili::C') &&
        $s->can('run')) {
      push @$silis, grep { defined && $_->_failed_cnt == 1 } ( $s->run( ast => $ast ) );
    }
  }
  exit 0;
}

# process a command against that definition
my $cmd = join ' ', @ARGV;
my @targets = _get_objs( tag => $targetName || $cmd,
                         list => $silis );

# find the packages to process
if (@pkgNames) {
  my $re = '(' . join('|', @pkgNames) . ')';
  @packages = _get_objs( tag => $re,
                         list => $silis );
} else {
  @packages = _get_objs( tag => 'Def',
                         list => $silis );
}

if ($show_silis > 1) {
  print STDERR "Targets: ", Dumper(\@targets),
    "\nPackages: ", Dumper(\@packages), "\n";
  exit 0;
}

# and process away
for my $pkg (@packages) {
  if (@targets) {
    for my $trg (@targets) {
      debugPrint 1, "Processing target: ", $trg->name;
      docmd("cd " . $pkg->ROOT . " && " .
            $trg->command . ' ' . $trg->name);
    }
  } else {
    debugPrint 1, "Execing $cmd on " . $pkg->name;
    print docmd("cd " . $pkg->ROOT . " && " . $cmd);
  }
}

exit 0;
